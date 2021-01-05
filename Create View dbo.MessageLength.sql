CREATE VIEW [dbo].[MessageLength] 
WITH SCHEMABINDING
AS
SELECT
    [Id],
    LEN([Message]) as 'MessageLength'
FROM dbo.Logs1
GO

-- CREATE INDEX
CREATE UNIQUE CLUSTERED INDEX IX_MessageLength_Id ON [dbo].[MessageLength] ([Id] ASC) /*Change sort order as needed*/
GO

CREATE INDEX IX_MessageLength_MessageLength ON [dbo].[MessageLength] ([MessageLength] DESC) /*Change sort order as needed*/
GO

