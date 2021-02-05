SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[DailyCounts]
AS 

SELECT
      CAST([Timestamp] AS DATE) AS DateStamp
    , COUNT(Id) as Total
FROM [dbo].[ParsedFieldValues]
GROUP BY CAST([Timestamp] AS DATE)
GO

