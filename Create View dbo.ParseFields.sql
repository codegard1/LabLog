SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ParseFields]
AS

Select 
	--TOP 100
    A.Id
    , A.SourceFile
    , A.Level
    , CAST(A.[Timestamp] AS DATE) AS Datestamp
	, A.TimeStamp

    -- ,B.RetSeq
    -- ,B.RetVal
    -- , B.*
    --, C.Pos6 AS 'Level'

    , C.Pos3 AS 'Category'
    --, C.Pos5 AS 'TimeStamp'
    , C.Pos6 AS 'EventID'
    , C.Pos7 AS 'Windows Log'
	, C.Pos11 AS 'Host Name'
    , C.Pos10 AS 'Short Message'
    --, C.Pos13 AS 'Message Subject'
	, [Message Body] = LTRIM(RTRIM(
				SUBSTRING( A.[Message], 
				PATINDEX('%' + C.Pos13 + '%', A.[Message]), 
				LEN(A.Message)-PATINDEX('%' + C.Pos13 + '%', A.[Message])+1)
			))
From dbo.Staging A
 Cross Apply [dbo].[udf-Str-Parse](A.Message,char(13)) B
 Cross Apply [dbo].[udf-Str-Parse-Row](B.RetVal,char(9)) C
Where B.RetVal is not null and B.RetSeq = 1

GO
