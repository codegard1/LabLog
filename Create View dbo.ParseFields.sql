USE LabLog;
GO

CREATE VIEW dbo.ParseFields
AS

-- 
-- 1 Nov 19 11:28:17 DC2.stern.com MSWinEventLog	
-- 2 5	
-- 3 Security	
-- 4 22418	
-- 5 Thu Nov 19 11:28:10 2020	
-- 6 4634	
-- 7 Microsoft-Windows-Security-Auditing		
-- 8 N/A	
-- 9 Audit Success	
-- 10 DC2.stern.com	
-- 11 12545	
-- 12 An account was logged off.Subject:	

Select
    A.Id
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