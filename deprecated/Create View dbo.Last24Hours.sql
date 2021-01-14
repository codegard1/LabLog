CREATE VIEW dbo.[Last24Hours]
AS
    SELECT
        [Id]
      , [Timestamp]
      , [TimeZone]
      , [Level]
      , [HostIP]
      , [HostName]
      , [Protocol]
      , [Message]
      , [SourceFile]
    FROM [LabLog].[dbo].[Logs1]
    WHERE [Timestamp] >= DATEADD(HOUR,-24,CURRENT_TIMESTAMP)