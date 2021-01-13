-- VARIABLES
DECLARE @limit INT;
DECLARE @counter INT;
DECLARE @SourceFile varchar(50);
DECLARE @Total INT;

SET @limit = 5;
SET @counter = 0

-- DECLARE the cursor as a SELECT statement
DECLARE cursor_LogFiles CURSOR
FOR 
SELECT
    [SourceFile]
    , COUNT([Id]) as 'Total'
    FROM [dbo].[Logs1_Staging]
    GROUP BY [SourceFile]
-- Order by date, then hostname
ORDER BY SUBSTRING([SourceFile], 5, 10), SUBSTRING([SourceFile], 0, 4) DESC

-- OPEN the cursor for reading
OPEN cursor_LogFiles

-- (Try to) get the first result from the cursor
FETCH NEXT FROM cursor_LogFiles INTO @SourceFile, @Total;

-- Loop through the cursor results
-- @@FETCH_STATUS is 0 when the previous FETCH returned something
WHILE @@FETCH_STATUS = 0 AND @counter < @limit
    BEGIN
    FETCH NEXT FROM cursor_LogFiles INTO @SourceFile, @Total;

    PRINT CAST(@counter AS VARCHAR) + CHAR(9) + @SourceFile + CHAR(9) + CAST(@Total AS VARCHAR);

    EXECUTE dbo.ParseLogFile @SourceFile

    -- Increment the counter
    SET @counter = @counter + 1;
END;

-- CLOSE and DEALLOCATE the cursor to clean up
CLOSE cursor_LogFiles;
DEALLOCATE cursor_LogFiles;
