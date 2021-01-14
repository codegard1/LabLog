SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[DailyCounts]
WITH SCHEMABINDING
AS 

SELECT
      CAST([Timestamp] AS DATE) AS DateStamp
    , COUNT_BIG(*) as Total
FROM [dbo].[ParsedFieldValues]
GROUP BY CAST([Timestamp] AS DATE)
GO

CREATE UNIQUE CLUSTERED INDEX IX_DailyCounts_DateStamp ON [dbo].[DailyCounts] ([DateStamp] ASC) /*Change sort order as needed*/
GO
