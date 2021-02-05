SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[HostCount]
AS
    SELECT 
    SUBSTRING([SourceFile],0,CHARINDEX('-',[SourceFile],0)) as 'Host'
    , COUNT(Id) as 'Total'
    from [dbo].[ParsedFieldValues]
    GROUP BY SUBSTRING([SourceFile],0,CHARINDEX('-',[SourceFile],0))
GO
