# LabLog
Experiments with SQL and log file ingestion using SQL and PowerShell

## Log Schema
The syslog files being ingested here have the following schema: 

### Fields
- Date-Time
- Time Zone
- Level
- Host address
- Host name
- Input source
- Message text

### Date Format
`ddddd` (e.g. 2/5/2021)

## Time Format
`ttttt` (e.g. 12:25:25 AM)

## Date-Time Format
`ddddd ttttt`

## Field Delimiter
`|` (Pipe)

## Qualifier
Double quotes


# PowerShell Classes
These classes are currently unused in this project but may be helpful later.

```powershell
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
```