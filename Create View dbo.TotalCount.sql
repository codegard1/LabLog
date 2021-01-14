SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TotalCount]
AS

    SELECT
    'ParsedFieldValues' as 'Table'
    , COUNT_BIG(*) as Total
    FROM [LabLog].[dbo].[ParsedFieldValues]

    UNION ALL

    SELECT
    'Staging' as 'Table'
    , COUNT_BIG(*) as Total
    FROM [LabLog].[dbo].[Staging]
GO
