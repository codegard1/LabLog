Install-Module Invoke-SqlCmd2 -ErrorAction Stop -Scope CurrentUser
Import-Module Invoke-SqlCmd2 -ErrorAction Stop

# Start the timer (whole script)
$ScriptDuration = [System.Diagnostics.Stopwatch]::StartNew()  

# BulkCopy Types
[void][Reflection.Assembly]::LoadWithPartialName("System.Data") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Data.SqlClient") 

# Read from Zip files
Add-Type -Assembly System.IO.Compression.Filesystem

# Temp storage location for log files
$TempFolder = "temp"

# Create Temp Folder if it does not exist
If ( !(Test-Path $TempFolder) ) { mkdir $TempFolder }

# Get credentials from the operator
$pw = (Get-Content "gxddb0v.txt" | ConvertTo-SecureString)
If ( $null -eq $pw ) { Write-Host "Credential check failed."; Break; }
$Credential = New-Object System.Management.Automation.PSCredential("chris", $pw)

# SqlCredentials use read-only SecureStrings
$pw.MakeReadOnly()

# Connection variables
$DestinationServer = "192.168.1.207" # SQL2
$DestinationDatabase = "LabLog"
$TableNameStaging = "Staging"
$BatchSize = 10000

# Location of Log Files
# $LogSource = "/mnt/Logs2"
$LogSource = "ETL/compressed"

# Get subset of Log files
$LogFiles = Get-ChildItem $LogSource | Sort-Object LastWriteTime

# Set up counters
$Total = $LogFiles.Count
$Counter = 0 

# Count total Size of all files
$LogFileTotalLength = 0; $LogFiles | ForEach-Object { $LogFileTotalLength += $_.Length }
$LogFileTotalSizeMB = ($LogFileTotalLength / 1024 / 1024).ToString('0.00')
$LengthCounter = 0

Write-host "Located $Total log files ($LogFileTotalSizeMB MB)" -ForegroundColor Yellow


# Loop through log files 
ForEach ($Log in $LogFiles) {

  # Start the timer (per log)
  $LogDuration = [System.Diagnostics.Stopwatch]::StartNew()  

  $LogName = $Log.Name 
  # $LogName = $Log.Name -replace ".zip",""
  $LogPath = "$TempFolder/$LogName"
  
  Write-Host $LogName -ForegroundColor Yellow
  
  # Display Progess Bar
  Write-Progress `
    -Activity "Importing Logs to $DestinationDatabase" `
    -Status "Log $Counter of $Total" `
    -PercentComplete (($LengthCounter / $LogFileTotalLength) * 100) `
    -Id 1
  
  # Increment Counters
  $Counter++
  $LengthCounter += $Log.Length
    
  # Check to see if the Log File has already been imported
  $CheckQuery = "SELECT TOP 1 [SourceFile] FROM [dbo].[FileCount_Staging] WHERE [SourceFile] = '$LogName'"
  $CheckResult = Invoke-Sqlcmd2 `
    -ServerInstance $DestinationServer `
    -Database $DestinationDatabase `
    -Query $CheckQuery `
    -Credential $Credential
  
  # If the query returns any rows then the log file has already been imported
  If ($null -ne $CheckResult) { 
    Write-Host "`tAlready imported. Skipping." -ForegroundColor DarkYellow
    Continue; 
  }
  
  # Copy log file to temp storage if not there already
  If (!(Test-Path $LogPath)) {
    try {
      Copy-Item -Path $Log.FullName -Destination $TempFolder
      Write-Host "`tCopied $LogName to temp folder"-ForegroundColor Cyan
    }
    catch {
      Write-Error $_.Exception.Message
      Break;
    }
  }
  
  # Define log file headers
  $ColumnHeaders = @("Timestamp"; "TimeZone"; "Level"; "HostIP"; "HostName"; "Protocol"; "Message")
    
  # Open the archive, then open the entry for the log file
  $zip = [io.compression.zipfile]::OpenRead($LogPath)
  $file = $zip.Entries | where-object { $_.Name -eq ($Logname -replace ".zip","") }
  $stream = $file.Open()

  # Read content of the log file into a variable
  $reader = New-Object IO.StreamReader($stream)
  $CSVString = $reader.ReadToEnd()

  # Import log as CSV
  $CSVArray = $CSVString | ConvertFrom-Csv -Delimiter "|" -Header $ColumnHeaders
  
  # $CSV = $text | Import-Csv -Encoding UTF8 -Delimiter "|" -Header $ColumnHeaders -ErrorAction Stop # | Select "Timestamp", "Level", "Message" 

  $reader.Close()
  $stream.Close()
  $zip.Dispose()
  
  
  # Counters for the log file
  $RowCount = $CSVArray.count
  $RowCounter = 0


  # Build the sqlbulkcopy connection
  $connectionstring = "Server=$DestinationServer;Database=$DestinationDatabase;" 
  $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($connectionstring)
  $sqlCred = New-Object System.Data.SqlClient.SqlCredential("chris", $pw)
  $sqlConnection.Credential = $sqlCred
  $sqlConnection.Open()

  # Create a transaction object for the bulk copy operation
  $sqlTransaction = $sqlConnection.BeginTransaction()

  # create the bulkcopy object
  try {
    $bulkcopy = New-Object System.Data.SqlClient.SqlBulkCopy($sqlConnection, [System.Data.SqlClient.SqlBulkCopyOptions]::TableLock, $sqlTransaction ) 
    $bulkcopy.DestinationTableName = $TableNameStaging 
    $bulkcopy.bulkcopyTimeout = 0 
    $bulkcopy.batchsize = $batchsize 
  } 
  catch {
    Write-Host $_.Exception.Message
    Break;
  }

  # Create the datatable, and manually add columns
  $datatable = New-Object System.Data.DataTable 
  $null = $datatable.Columns.Add("Timestamp", [DateTime])
  $null = $datatable.Columns.Add("Level", [String])
  $null = $datatable.Columns.Add("Message", [String])
  $null = $datatable.Columns.Add("SourceFile", [String])
  # $null = $datatable.Columns.Add("HostIP", [String])
  # $null = $datatable.Columns.Add("HostName", [String])
  # $null = $datatable.Columns.Add("Protocol", [String])
  # $null = $datatable.Columns.Add("TimeZone", [String])
  # Add column mappings
  $null = $bulkcopy.ColumnMappings.Add("Timestamp", "Timestamp")
  $null = $bulkcopy.ColumnMappings.Add("Level", "Level")
  $null = $bulkcopy.ColumnMappings.Add("Message", "Message")
  $null = $bulkcopy.ColumnMappings.Add("SourceFile", "SourceFile")
  # $null = $bulkcopy.ColumnMappings.Add("HostIP", "HostIP")
  # $null = $bulkcopy.ColumnMappings.Add("HostName", "HostName")
  # $null = $bulkcopy.ColumnMappings.Add("Protocol", "Protocol")
  # $null = $bulkcopy.ColumnMappings.Add("TimeZone", "TimeZone")

  Write-Host "`tImporting $LogName ($RowCount Rows)" -ForegroundColor Cyan

  # Clear the datatable
  $datatable.Clear()

  # Enumerate the SourceData
  $Enum = $CSVArray.GetEnumerator()
  While ($Enum.MoveNext()) {
    $CurrentRow = $Enum.Current

    # Create a new row and set column values 
    try {
      $newrow = $datatable.Rows.Add()
      foreach ( $col in $datatable.Columns.ColumnName ) {
        $newrow[$col] = If ($null -ne $CurrentRow.$col) { $CurrentRow.$col } else { [System.DBNull]::Value }
      }

      # Manually set the SourceFile column
      $newrow["SourceFile"] = $LogName
    }
    catch {
      Write-Error $_.Exception.Message
      Break;
    }
 
    # check if we have a large enough batch to do an insert
    $RowCounter++; if (($RowCounter % $batchsize) -eq 0) {  
      try {
        $bulkcopy.WriteToServer($datatable)  
        Write-Host "$RowCounter rows have been inserted in $($LogDuration.Elapsed.ToString())." 
      }
      catch {
        # Foreach($col in $datatable.Columns){
        #   Write-Host "$($Col.ColumnName) ($($col.DataType)): /$($CurrentRow[$col.ColumnName])/"
        # }
        Write-Error $_.Exception.Message
        $sqlTransaction.Rollback()
        Break;
      }
      $datatable.Clear()  
    }  
  }

  # Add in all the remaining rows since the last clear 
  if ($datatable.Rows.Count -gt 0) { 
    try {
      $bulkcopy.WriteToServer($datatable)
      $sqlTransaction.Commit()
      Write-Host "$RowCounter rows have been inserted in $($LogDuration.Elapsed.ToString()).`n" 
    }
    catch {
      Write-Error $_.Exception.Message
      $sqlTransaction.Rollback()
      Break;
    }
    $datatable.Clear() 
  }

  # Clean Up
  $datatable.Dispose()

  If ((Test-Path $LogPath)) { Remove-Item -Path $LogPath }
}
  

# Clean Up 
try {
  $bulkcopy.Close()
  $bulkcopy.Dispose()
  $sqlConnection.Dispose()
}
catch {
  # Oh well
}

[System.GC]::Collect()



Write-Host "Total Duration: $($ScriptDuration.Elapsed.ToString())" -ForegroundColor Yellow
