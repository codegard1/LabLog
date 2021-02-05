-- Backup LabLog 

BACKUP LOG [LabLog] TO 
DISK = N'/mnt/backup/LabLog-202117-10-57-48.bak' 
WITH 
    NOFORMAT, 
    NOINIT,  
    NAME = N'LabLog--2021-01-07T15:57:48', 
    NOSKIP, 
    REWIND, 
    NOUNLOAD,  
    STATS = 10

