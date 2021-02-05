-- Create a new stored procedure called 'ParseLogFile' in schema 'dbo'
-- Drop the stored procedure if it already exists
IF EXISTS (
SELECT *
FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'ParseLogFile'
    AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE dbo.ParseLogFile
GO

CREATE PROCEDURE dbo.ParseLogFile
    @FileName varchar(50) = 'DC1-2020-11-19.txt'
AS

-- Delete existing data
DELETE FROM dbo.[ParsedFieldValues] WHERE [SourceFile] = @FileName

-- Insert new data
INSERT INTO dbo.[ParsedFieldValues]
SELECT
    [Id]
    , [SourceFile]
    , [Level]
    , [Datestamp]
    , [Category]
    , [TimeStamp]
    , [EventID]
    , [Windows Log]
    , [Short Message]
    , [Host Name]
    , [Message Subject]
FROM [LabLog].[dbo].[ParseFields]
Where [SourceFile] = @FileName
GO
