# LabLog
Experiments with SQL and log file ingestion using SQL and PowerShell


# Log Schema
The syslog files being ingested here have the following schema: 

## Fields
- Date-Time
- Time Zone
- Level
- Host address
- Host name
- Input source
- Message text

## Date Format
`ddddd` (e.g. 2/5/2021)

## Time Format
`ttttt` (e.g. 12:25:25 AM)

## Date-Time Format
`ddddd ttttt`

## Field Delimiter
`|` (Pipe)

## Qualifier
Double quotes



