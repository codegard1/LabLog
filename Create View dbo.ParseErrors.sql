Use LabLog;
GO

DROP VIEW IF EXISTS dbo.[ParseErrors]
GO

CREATE VIEW dbo.[ParseErrors]
AS
  SELECT 
	  [Id]
    , [SourceFile]
    , [Level]
    , [Datestamp]
    , [Category]
    , [TimeStamp]
    , [EventID]
    , [Windows Log]
    , [Host Name]
    , [Short Message]
    , [Message Body]
  FROM dbo.[ParseFields]
  WHERE [Level] = 'Error'
GO