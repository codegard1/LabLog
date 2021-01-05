SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[Files]
WITH SCHEMABINDING
AS
    SELECT 
    DISTINCT [SourceFile]
    FROM dbo.FileCount
GO
