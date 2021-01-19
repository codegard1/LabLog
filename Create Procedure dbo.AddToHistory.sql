IF EXISTS (
    SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
    WHERE SPECIFIC_SCHEMA = N'dbo'
        AND SPECIFIC_NAME = N'AddToHistory'
        AND ROUTINE_TYPE = N'PROCEDURE'
    )
    DROP PROCEDURE dbo.AddToHistory;
GO

CREATE PROCEDURE dbo.AddToHistory
    @Date DATETIME,
    @Action VARCHAR(20), 
    @RowsAffected INT, 
    @TableAffected VARCHAR(50), 
    @SourceFile VARCHAR(255)
AS
    INSERT INTO [dbo].[DB_History]
    ( [Date], [Action], [RowsAffected], [TableAffected], [SourceFile] )
    VALUES
    ( @Date, @Action, @RowsAffected, @TableAffected, @SourceFile )
    ;
GO

-- example to execute the stored procedure we just created
DECLARE @datestamp datetime;
SET @datestamp = CURRENT_TIMESTAMP;
EXECUTE [dbo].[AddToHistory] @datestamp, 'Test', 0, 'Test', 'Test';
GO

SELECT * FROM dbo.DB_History
GO