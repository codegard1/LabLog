SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Hosts_Staging]
AS
    SELECT [Host]
    from dbo.HostCount_Staging
GO
