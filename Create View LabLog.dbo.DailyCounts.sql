SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DailyCounts]
AS 

WITH
    prod
    AS
    (
        SELECT
            CAST([Timestamp] AS DATE) AS 'DateStamp'
            , COUNT([Id]) as 'Total'
        FROM [LabLog].[dbo].[Logs1]
        GROUP BY CAST([Timestamp] AS DATE)
    ),
    staging
    AS
    (
        SELECT
            CAST([Timestamp] AS DATE) AS 'DateStamp'
            , COUNT([Id]) as 'Total'
        FROM [LabLog].[dbo].[Logs1_Staging]
        GROUP BY CAST([Timestamp] AS DATE)
    )

SELECT
    prod.DateStamp
    , SUM(prod.Total) as 'Logs1'
    , SUM(staging.Total) as 'Logs1_Staging'
FROM prod
    LEFT JOIN staging
    on prod.DateStamp = staging.DateStamp
GROUP BY prod.DateStamp
GO

