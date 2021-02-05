SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LevelCount]
AS
    SELECT 
    [Level]
    , COUNT(Id) as 'Total'
    FROM [dbo].[ParsedFieldValues]
    GROUP BY [Level]
GO

