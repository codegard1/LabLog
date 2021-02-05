SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FileCount]
AS
SELECT
    [SourceFile]
    , COUNT(Id) as 'Total'
    FROM [dbo].[ParsedFieldValues]
    GROUP BY [SourceFile]
GO
