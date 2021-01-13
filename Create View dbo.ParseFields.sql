USE LabLog;
GO

CREATE VIEW dbo.ParseFields
AS

Select
    A.Id
    , A.SourceFile
    -- ,B.RetSeq
    -- ,B.RetVal
    -- , B.*
    -- , C.Pos6 AS 'Level'
    , C.Pos3 AS 'Category'
    , C.Pos5 AS 'TimeStamp'
    , C.Pos6 AS 'EventID'
    , C.Pos7 AS 'Windows Log'
    , C.Pos10 AS 'Short Message'
    , C.Pos11 AS 'Host Name'
    , C.Pos13 AS 'Message Subject'
From dbo.Logs1 A
 Cross Apply [dbo].[udf-Str-Parse](A.Message,char(13)) B
 Cross Apply [dbo].[udf-Str-Parse-Row](B.RetVal,char(9)) C
Where B.RetVal is not null and B.RetSeq = 1

GO