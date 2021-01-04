SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FileCount]
AS
SELECT
    prod.[SourceFile]
    , COUNT(prod.[Id]) 'Logs1'
    , COUNT(staging.[Id]) 'Logs1_Staging'
    FROM [LabLog].[dbo].[Logs1] prod
    LEFT JOIN [LabLog].[dbo].[Logs1_Staging] staging ON
    staging.[SourceFile] = prod.[SourceFile]
    GROUP BY prod.[SourceFile]
GO
