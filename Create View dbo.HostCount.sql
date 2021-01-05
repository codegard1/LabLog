SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[HostCount]
WITH SCHEMABINDING
AS
    SELECT 
    SUBSTRING([SourceFile],0,CHARINDEX('-',[SourceFile],0)) as 'Host'
    , COUNT_BIG(*) as 'Total'
    from [dbo].[Logs1]
    GROUP BY SUBSTRING([SourceFile],0,CHARINDEX('-',[SourceFile],0))
GO

-- CREATE INDEX
CREATE UNIQUE CLUSTERED INDEX IX_HostCount_HostName ON [dbo].[HostCount] ([Host] ASC) /*Change sort order as needed*/
GO