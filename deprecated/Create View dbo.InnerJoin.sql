ALTER VIEW dbo.InnerJoin
WITH SCHEMABINDING
AS
SELECT 
-- TOP 1000
      a.[Id]
    , a.[Level]
    , b.[SourceFile]
    , b.[Category]
    , b.[TimeStamp]
    , b.[EventID]
    , b.[Windows Log]
    , b.[Short Message]
    , b.[Host Name]
    , b.[Message Subject]
  FROM [dbo].[Staging] a
  INNER JOIN [dbo].[ParsedFieldValues] b
  ON a.Id = b.Id
GO

CREATE UNIQUE CLUSTERED INDEX IX_ID ON [dbo].[InnerJoin] ([Id] ASC, [TimeStamp])
GO

CREATE NONCLUSTERED INDEX IX_SourceFile ON [dbo].[InnerJoin] ([SourceFile])
GO

CREATE NONCLUSTERED INDEX IX_Category ON [dbo].[InnerJoin] ([Category] ASC)
GO

CREATE NONCLUSTERED INDEX IX_EventID ON [dbo].[InnerJoin] ([EventID] ASC)
GO

CREATE NONCLUSTERED INDEX IX_WindowsLog ON [dbo].[InnerJoin] ([Windows Log] ASC)
GO

