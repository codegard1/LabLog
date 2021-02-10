# Add necessary assembly
Add-Type -Assembly System.IO.Compression.Filesystem

# Get a single log file archive
$logfilepath = "/home/chris/LabLog/ETL/compressed/DC1-2020-11-19.txt.zip"

# Open the archive, then open the entry for the log file
$zip = [io.compression.zipfile]::OpenRead($logfilepath)
$file = $zip.Entries | where-object { $_.Name -eq "DC1-2020-11-19.txt" }
$stream = $file.Open()

# Read content of the log file into a variable
$reader = New-Object IO.StreamReader($stream)
$text = $reader.ReadToEnd()

# Do something with the content of the log file
# $text

# Clean up 
$reader.Close()
$stream.Close()\
$zip.Dispose()
