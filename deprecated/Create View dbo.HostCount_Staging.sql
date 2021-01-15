SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[HostCount_Staging]
WITH SCHEMABINDING
AS
    SELECT 
    SUBSTRING([SourceFile],0,CHARINDEX('-',[SourceFile],0)) as 'Host'
    , COUNT_BIG(*) as 'Total'
    from [dbo].[Staging]
    GROUP BY SUBSTRING([SourceFile],0,CHARINDEX('-',[SourceFile],0))
GO

-- CREATE INDEX
CREATE UNIQUE CLUSTERED INDEX IX_HostCount_HostName ON [dbo].[HostCount_Staging] ([Host] ASC)
GO