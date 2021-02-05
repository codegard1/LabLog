Install-Module Invoke-SqlCmd2 -ErrorAction Stop -Scope CurrentUser
Import-Module Invoke-SqlCmd2 -ErrorAction Stop

# Start the timer (whole script)
$ScriptDuration = [System.Diagnostics.Stopwatch]::StartNew()  

# BulkCopy Types
[void][Reflection.Assembly]::LoadWithPartialName("System.Data") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Data.SqlClient") 

# Class definitions (unused)
Class LogCollection {
  # Props
  [LogEntry[]]$Data

  # Constructor
  LogCollection([Array]$CSVData) {
    ForEach ( $Row in $CSVData) {
      try {
        $This.Data += [LogEntry]::new($Row)
      }
      catch {
        Write-Error $_.Exception.Message
        Continue;
      }
    }
  }
}

Class LogEntry {
  # Props
  [DateTime]$Timestamp;
  [String]$TimeZone;
  [String]$Level;
  [String]$HostIP;
  [String]$HostName;
  [String]$Protocol;
  [String]$Message;

  # Constructor
  LogEntry([Object]$Row) {
    $This.Timestamp = $Row.Timestamp;
    $This.TimeZone = $Row.TimeZone;
    $This.Level = $Row.Level;
    $This.HostIP = $Row.HostIP;
    $This.HostName = $Row.HostName;
    $This.Protocol = $Row.Protocol;
    $This.Message = $Row.Message;
  }
}

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
$LogSource = "/mnt/Logs2"

# Get subset of Log files
$LogFiles = Get-ChildItem $LogSource -Filter "*2021*" | Sort-Object LastWriteTime

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
  $LogPath = "$TempFolder\$LogName"
  
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
    
  # Import log as CSV
  $CSV = Import-Csv -Path $LogPath -Encoding UTF8 -Delimiter "|" -Header $ColumnHeaders -ErrorAction Stop | Select "Timestamp","Level","Message"
   
  # Counters for the log file
  $RowCount = $CSV.count
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
  $Enum = $CSV.GetEnumerator()
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
$bulkcopy.Close()
$bulkcopy.Dispose() 
$sqlConnection.Dispose()

[System.GC]::Collect()



Write-Host "Total Duration: $($ScriptDuration.Elapsed.ToString())" -ForegroundColor Yellow
