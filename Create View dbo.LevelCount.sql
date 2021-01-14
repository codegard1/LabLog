SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LevelCount]
WITH SCHEMABINDING
AS
    SELECT 
    [Level]
    , COUNT_BIG(*) as 'Total'
    FROM [dbo].[ParsedFieldValues]
    GROUP BY [Level]
GO

-- CREATE INDEX
CREATE UNIQUE CLUSTERED INDEX IX_LevelCount_Level ON [dbo].[LevelCount] ([Level] ASC) /*Change sort order as needed*/
GO
