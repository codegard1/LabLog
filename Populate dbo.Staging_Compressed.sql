USE [LabLog];
GO

-- Truncate tables
TRUNCATE TABLE dbo.[Staging_Compressed]
GO
TRUNCATE TABLE dbo.[Staging_Uncompressed]
GO

-- Insert data to compressed table
INSERT INTO dbo.[Staging_Compressed]
SELECT
    [Id]
      , [SourceFile]
      , COMPRESS([Message])
FROM [LabLog].[dbo].[Staging]
WHERE [SourceFile] IN (
    SELECT TOP (15)
    [SourceFile]
FROM [dbo].[FileCount_Staging]
ORDER BY SUBSTRING([SourceFile], 5, 10), SUBSTRING([SourceFile], 0, 4) DESC
)
GO

-- Insert data to Uncompressed table
INSERT INTO dbo.[Staging_Uncompressed]
SELECT
    [Id]
      , [SourceFile]
      , [Message]
FROM [LabLog].[dbo].[Staging]
WHERE [SourceFile] IN (
    SELECT TOP (15)
    [SourceFile]
FROM [dbo].[FileCount_Staging]
ORDER BY SUBSTRING([SourceFile], 5, 10), SUBSTRING([SourceFile], 0, 4) DESC
)
GO



-- SELECT [Id],[SourceFile],[CompressedMessage] FROM dbo.[Staging_Compressed]
-- GO

-- Select decompressed text
SELECT
    TOP 10
    [Id]
    , [SourceFile]
    , [Message]= CAST(DECOMPRESS([CompressedMessage]) AS VARCHAR(MAX))
FROM dbo.[Staging_Compressed]
GO