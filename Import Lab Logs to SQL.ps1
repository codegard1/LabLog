# Start the timer
$ScriptStartTime = Get-Date

try {
  Install-Module Invoke-SqlCmd2
  Import-Module Invoke-SqlCmd2
  # Import-Module "~/Invoke-Parallel/Invoke-Parallel/Invoke-Parallel.ps1"
}
catch {
  Write-Error "Could not import Invoke-SqlCmd2.`n$($_.Exception.Message)" 
}

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
$TempFolder = ".\temp"

# Connection variables
$ServerInstance = "192.168.1.207" # SQL2
$DatabaseName = "LabLog"
$TableNameStaging = "Logs1_Staging"
$TableNameProd = "Logs1"

# Get credentials from the operator
If ( $null -eq $Credential ) { $Credential = Get-Credential }  

# Location of Log Files
# $LogSource = "\\192.168.1.245\Public\HyperVLab_Logs"
# $LogSource = "\\192.168.1.250\Logs2"
$LogSource = "/mnt/Logs2"

# Get subset of Log files
$LogFiles = Get-ChildItem $LogSource -Filter "*2020-11*" | Sort-Object LastWriteTime | Select-Object -First 50

# Set up counters
$Total = $LogFiles.Count
$Counter = 0 
$InsertCount = 0
# Count total Size of all files
$LogFileTotalLength = 0; $LogFiles | % { $LogFileTotalLength += $_.Length }
$LogFileTotalSizeMB = ($LogFileTotalLength / 1024 / 1024).ToString('0.00')
$LengthCounter = 0

Write-host "Located $Total log files ($LogFileTotalSizeMB MB)" -ForegroundColor Yellow

# Loop through log files 
ForEach ($Log in $LogFiles) {
  
  $LogName = $Log.Name
  $LogPath = "$TempFolder\$LogName"

  Write-Host $LogName -ForegroundColor Yellow

  # Display Progess Bar
  Write-Progress `
    -Activity "Importing Logs to $DatabaseName" `
    -Status "Log $Counter of $Total" `
    -PercentComplete (($LengthCounter / $LogFileTotalLength) * 100) `
    -Id 1

  # Increment Counters
  $Counter++
  $LengthCounter += $Log.Length
  
  # Check to see if the Log File has already been imported
  $CheckQuery = "SELECT TOP 1 * FROM [dbo].[Files] WHERE [SourceFile] = '$LogName'"
  $CheckResult = Invoke-Sqlcmd2 `
    -ServerInstance $ServerInstance `
    -Database $DatabaseName `
    -Query $CheckQuery `
    -Credential $Credential

  # If the query returns any rows then the log file has already been imported
  If ($CheckResult.SourceFile.Count -gt 0) { 
    Write-Host "`tAlready imported. Skipping." -ForegroundColor DarkYellow
    Continue; 
  }

  # Copy log file to temp storage if not there already
  If (!(Test-Path $LogPath)) {
    Copy-Item -Path $Log.FullName -Destination $TempFolder
    Write-Host "`tCopied $LogName to temp folder"-ForegroundColor Cyan
  }

  # Define log file headers
  $ColumnHeaders = @("Timestamp"; "TimeZone"; "Level"; "HostIP"; "HostName"; "Protocol"; "Message")
  
  # Import log as CSV
  $CSV = Import-Csv -Path $LogPath -Encoding UTF8 -Delimiter "|" -Header $ColumnHeaders -ErrorAction Stop
 
  # Counters for the log file
  $RowCount = $CSV.count
  $RowCounter = 0

  Write-Host "`tImporting $LogName ($RowCount Rows)" -ForegroundColor Cyan

  # Insert each row to SQL
  Foreach ($Row in $CSV) {

    # Process column names from row fields
    $ColumnNames = $ColumnHeaders | Sort-Object
    $ColumnNames += "SourceFile"
    
    # Create and populate custom object with data from Row
    [PSCustomObject]$SQLParams = @{}
    ForEach ($key in @($ColumnNames)) {
      $KeyNameModified = $Key -replace " #", "" -replace " ", "_"
      If ($Key -eq "SourceFile") {
        $SQLParams.Add($Key, $LogName)
      }
      Else {
        $SQLParams.Add($KeyNameModified, $Row.$key)
      }
    }  

    # Preparing the SQL Insert query
    [String]$InsertColumns = ($ColumnNames | % { $_ -replace " #", "" -replace " ", "_" } | % { "[$_]" }) -join ","
    [String]$InsertValues = ($ColumnNames | % { $_ -replace " #", "" -replace " ", "_" } | % { "@$_" }) -join ","
    [String]$InsertQuery = "INSERT INTO [dbo].[$TableNameStaging] ($InsertColumns) VALUES ($InsertValues)"
    
    try {
      Invoke-Sqlcmd2 `
        -ServerInstance $ServerInstance `
        -Database $DatabaseName `
        -Query $InsertQuery `
        -SqlParameters $SQLParams `
        -Credential $Credential

      $InsertCount++
      $RowCounter++
    } 
    catch {
      Write-Error $_.Exception.Message
    }
    
    # Display Progess Bar
    Write-Progress `
      -Activity "Inserting Rows to $TableNameStaging" `
      -Status "Row $RowCounter of $RowCount" `
      -PercentComplete (($RowCounter / $RowCount) * 100) `
      -Id 2
  }

  # Delete log from temp storage
  If ((Test-Path $LogPath)) { Remove-Item -Path $LogPath }

  # Insert Staging into PROD
  If ($InsertCount -gt 0) {
    $MergeQuery = "INSERT INTO dbo.$TableNameProd
    SELECT 
      [Timestamp]
        , [TimeZone]
        , [Level]
        , [HostIP]
        , [HostName]
        , [Protocol]
        , [Message]
        , [SourceFile]
    FROM dbo.$TableNameStaging
    WHERE [SourceFile] = '$LogName' 
    ORDER BY [Id]"
    
    try {  
      Invoke-Sqlcmd2 `
        -ServerInstance $ServerInstance `
        -Database $DatabaseName `
        -Query $MergeQuery `
        -Credential $Credential
      Write-Host "`tCopied $RowCount new rows from Staging to PROD"
    } 
    catch {
      Write-Error $_.Exception.Message
    }
  }
}

# Truncate Staging table
try {  
  Invoke-Sqlcmd2 `
    -ServerInstance $ServerInstance `
    -Database $DatabaseName `
    -Query "TRUNCATE TABLE dbo.Logs1_Staging" `
    -Credential $Credential
  Write-Host "Truncated dbo.Logs1_Staging" -ForegroundColor Yellow
} 
catch {
  Write-Error $_.Exception.Message
}

$ScriptEndTime = Get-Date
$ScriptRunDuration = ($ScriptEndTime - $ScriptStartTime)

Write-Host "Finished. Duration: $ScriptRunDuration. Inserts: $InsertCount"