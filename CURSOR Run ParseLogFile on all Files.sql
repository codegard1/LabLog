USE LabLog;
GO

-- VARIABLES
DECLARE @limit INT;
DECLARE @counter INT;
DECLARE @SourceFile varchar(50);
DECLARE @Total INT;

SET @limit = 10;
SET @counter = 0;

-- DECLARE the cursor as a SELECT statement
DECLARE cursor_LogFiles CURSOR
FOR SELECT TOP (@limit)
		[SourceFile]
		, COUNT([Id]) as [Total]
	FROM [dbo].[Staging]
	GROUP BY [SourceFile]
	ORDER BY SUBSTRING([SourceFile], 5, 10), SUBSTRING([SourceFile], 0, 4) DESC

-- OPEN the cursor for reading
OPEN cursor_LogFiles

-- (Try to) get the first result from the cursor
FETCH NEXT FROM cursor_LogFiles INTO @SourceFile, @Total;

-- Loop through the cursor results
-- @@FETCH_STATUS is 0 when the previous FETCH returned something
WHILE @@FETCH_STATUS = 0
    BEGIN
    FETCH NEXT FROM cursor_LogFiles INTO @SourceFile, @Total;

    PRINT CAST(@counter AS VARCHAR) + CHAR(9) + @SourceFile + CHAR(9) + CAST(@Total AS VARCHAR);

    -- Delete existing data
    DELETE FROM dbo.[ParsedFieldValues] WHERE [SourceFile] = @SourceFile

	
    -- Insert new data
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO dbo.[ParsedFieldValues]
			SELECT
			A.[Id]
			, A.[SourceFile]
			, A.[Level]
			, C.Pos3 AS [Category]
			, C.Pos5 AS [TimeStamp]
			-- , null as [DateStamp]
			, C.Pos6 AS [EventID]
			, C.Pos7 AS [Windows Log]
			, C.Pos10 AS [Short Message]
			, C.Pos11 AS [Host Name]
			, C.Pos13 AS [Message Subject]
			FROM dbo.[Staging] A
			Cross Apply [dbo].[udf-Str-Parse](A.[Message], char(13)) B
			Cross Apply [dbo].[udf-Str-Parse-Row](B.[RetVal], char(9)) C
			WHERE B.[RetVal] is not null 
				AND B.[RetSeq] = 1
				AND A.[SourceFile] = @SourceFile
			ORDER BY A.[Id]
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		INSERT INTO dbo.[DB_Errors]
		VALUES
		(
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);
		
		-- Transaction uncommittable
		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION
			PRINT 'Rollback'
 
		-- Transaction committable
		IF (XACT_STATE()) = 1
			COMMIT TRANSACTION
			PRINT 'Commit'
	END CATCH

    -- Increment the counter
    SET @counter = @counter + 1;
END;

-- CLOSE and DEALLOCATE the cursor to clean up
CLOSE cursor_LogFiles;
DEALLOCATE cursor_LogFiles;
GO

