CREATE VIEW [dbo].[Last30Days]
AS
    SELECT
        [Id]
      , [Timestamp]
    --   , [TimeZone]
      , [Level]
      , [HostIP]
      , [HostName]
    --   , [Protocol]
      , [Message]
      , [SourceFile]
    FROM [LabLog].[dbo].[Logs1]
    WHERE [Timestamp] >= DATEADD(DAY,-30,CURRENT_TIMESTAMP)
