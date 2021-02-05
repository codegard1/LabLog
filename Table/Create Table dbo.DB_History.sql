-- Create a new table called '[Lineage]' in schema '[dbo]'
-- Drop the table if it already exists
IF OBJECT_ID('[dbo].[DB_History]', 'U') IS NOT NULL
DROP TABLE [dbo].[DB_History]
GO
-- Create the table in the specified schema
CREATE TABLE [dbo].[DB_History]
(
      [Id] INT IDENTITY(1,1)
    , [Date] DATETIME NOT NULL
    , [Action] VARCHAR(20) NOT NULL
    , [RowsAffected] INT NOT NULL
    , [TableAffected] VARCHAR(50) NOT NULL
    , [SourceFile] VARCHAR(255) NULL
);
GO

-- Create Indexes
CREATE UNIQUE CLUSTERED INDEX IX_Id ON [dbo].[DB_History] ([Id] DESC)
GO
CREATE NONCLUSTERED INDEX IX_Date ON [dbo].[DB_History] ([Date] DESC)
GO
