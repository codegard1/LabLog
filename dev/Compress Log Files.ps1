# get uncompressed files from source folder
$files = Get-ChildItem -Path "/mnt/Logs2" -Filter "*.txt" -File

# Compress files and store locally
$Files | ForEach-Object {
  Compress-Archive -Path $_.FullName -DestinationPath "/home/chris/LabLog/ETL/compressed/$($_.Name).zip" -CompressionLevel Optimal -PassThru 
}
