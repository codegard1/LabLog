USE LabLog;
GO

SET NOCOUNT ON;
GO


-- VARIABLES
DECLARE @Limit INT;
DECLARE @Counter INT;
DECLARE @SourceFile varchar(50);
DECLARE @TotalStaging INT;
DECLARE @TotalProd INT;
DECLARE @HistoryTimeStamp DATETIME;
DECLARE @RunningTotal INT;

SET @Limit = 20;
SET @Counter = 0;
SET @RunningTotal = 0;

-- DECLARE the cursor as a SELECT statement
DECLARE cursor_LogFiles CURSOR
FOR SELECT TOP (@Limit)
		[SourceFile], [Total]
	FROM [dbo].[FileCount_Staging]
	ORDER BY SUBSTRING([SourceFile], 5, 10), SUBSTRING([SourceFile], 0, 4) DESC;

-- OPEN the cursor for reading
OPEN cursor_LogFiles;

-- (Try to) get the first result from the cursor
FETCH NEXT FROM cursor_LogFiles INTO @SourceFile, @TotalStaging;

-- Loop through the cursor results
-- @@FETCH_STATUS is 0 when the previous FETCH returned something
WHILE @@FETCH_STATUS = 0
    BEGIN
		FETCH NEXT FROM cursor_LogFiles INTO @SourceFile, @TotalStaging;

		PRINT (CAST(@Counter AS VARCHAR) + CHAR(9) + @SourceFile + CHAR(9) + CAST(@TotalStaging AS VARCHAR));

		-- Check if existing number of rows is the same in PROD/STAGING for the @Sourcefile
		SELECT @TotalProd = (SELECT [Total] FROM dbo.[FileCount] WHERE [SourceFile] = @SourceFile);
		-- SELECT @TotalStaging = (SELECT [Total] FROM dbo.[FileCount_Staging] WHERE [SourceFile] = @SourceFile);
		-- PRINT @TotalProd; PRINT @TotalStaging;

		IF (@TotalProd = @TotalStaging)
			PRINT (CHAR(9) + 'ALREADY IMPORTED. SKIPPING.');
		
		ELSE 
			-- Insert new data
			BEGIN TRY
				BEGIN TRANSACTION
					DELETE FROM dbo.[ParsedFieldValues] WHERE [SourceFile] = @SourceFile;
					-- Log to History 
					-- SET @HistoryTimeStamp = CURRENT_TIMESTAMP;
					-- EXECUTE [dbo].[AddToHistory] @HistoryTimeStamp, 'Delete', @TotalProd, 'ParsedFieldValues', @SourceFile;

					INSERT INTO dbo.[ParsedFieldValues]
					SELECT
					[Id]
					, [SourceFile]
					, [Level]
					, [Category]
					, [TimeStamp]
					-- [DateStamp]
					, [EventID]
					, [Windows Log]
					, [Short Message]
					, [Host Name]
					, [Message Subject]
					FROM [dbo].[ParseFields]
					WHERE [SourceFile] = @SourceFile
					ORDER BY [Id];
				COMMIT TRANSACTION
				SET @RunningTotal = @RunningTotal + @TotalStaging;
				PRINT (CHAR(9) + 'INSERTED ' + CONVERT(VARCHAR, @TotalStaging) + ' ROWS');

				-- Log to History 
				-- SET @HistoryTimeStamp = CURRENT_TIMESTAMP;
				-- EXECUTE [dbo].[AddToHistory] @HistoryTimeStamp, 'Insert', @TotalStaging, 'ParsedFieldValues', @SourceFile;
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
					PRINT ('ERROR! ROLLBACK OVERWRITE FOR ' + @SourceFile);
		
				-- Transaction committable
				IF (XACT_STATE()) = 1
					COMMIT TRANSACTION
					PRINT ('SUCCESS. COMMIT OVERWRITE FOR ' + @SourceFile);
			END CATCH
		;

		-- Increment the counter
		SET @Counter = @Counter + 1;
END;

PRINT ('INSERTED ' + CONVERT(VARCHAR, @RunningTotal) + ' TOTAL ROWS');

-- CLOSE and DEALLOCATE the cursor to clean up
CLOSE cursor_LogFiles;
DEALLOCATE cursor_LogFiles;
GO

