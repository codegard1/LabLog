SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Hosts]
AS
    SELECT [Host]
    from dbo.HostCount
GO