SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TotalCount]
AS

    SELECT
    'Logs1' as 'Table'
    , COUNT_BIG(*) as Total
    FROM [LabLog].[dbo].[Logs1]

    UNION ALL

    SELECT
    'Logs1_Staging' as 'Table'
    , COUNT_BIG(*) as Total
    FROM [LabLog].[dbo].[Logs1_Staging]
GO
