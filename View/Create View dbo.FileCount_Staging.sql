SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FileCount_Staging]
WITH SCHEMABINDING
AS
SELECT
    [SourceFile]
    , COUNT_BIG(*) as 'Total'
    FROM [dbo].[Staging]
    GROUP BY [SourceFile]
GO

