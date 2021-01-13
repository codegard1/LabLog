



CREATE TRIGGER dbo.[OnInsertStaging]
ON dbo.[Logs1_Staging]
AFTER INSERT AS 

IF @@ROWCOUNT

-- Update rows in table '[TableName]' in schema '[dbo]'
UPDATE [dbo].[TableName]
SET
    [ColumnName1] = ColumnValue1,
    [ColumnName2] = ColumnValue2
    -- Add more columns and values here
WHERE /* add search conditions here */
GO


GO