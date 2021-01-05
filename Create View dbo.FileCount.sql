SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FileCount]
WITH SCHEMABINDING
AS
SELECT
    [SourceFile]
    , COUNT_BIG(*) as 'Total'
    FROM [dbo].[Logs1]
    GROUP BY [SourceFile]
GO

-- create index
CREATE UNIQUE CLUSTERED INDEX IX_FileCount_SourceFile ON [dbo].[FileCount] ([SourceFile] ASC)
GO
