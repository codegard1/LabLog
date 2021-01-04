SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf-Str-Parse-Row] (@String varchar(max),@Delimiter varchar(10))
Returns Table 
WITH SCHEMABINDING
As
Return (
    Select 
          Pos1 = ltrim(rtrim(xDim.value('/x[1]','varchar(255)')))
        , Pos2 = ltrim(rtrim(xDim.value('/x[2]','varchar(255)')))
        , Pos3 = ltrim(rtrim(xDim.value('/x[3]','varchar(255)')))
        , Pos4 = ltrim(rtrim(xDim.value('/x[4]','varchar(255)')))
        , Pos5 = ltrim(rtrim(xDim.value('/x[5]','varchar(255)')))
        , Pos6 = ltrim(rtrim(xDim.value('/x[6]','varchar(255)')))
        , Pos7 = ltrim(rtrim(xDim.value('/x[7]','varchar(255)')))
        , Pos8 = ltrim(rtrim(xDim.value('/x[8]','varchar(255)')))
        , Pos9 = ltrim(rtrim(xDim.value('/x[9]','varchar(255)')))
        , Pos10 = ltrim(rtrim(xDim.value('/x[10]','varchar(255)')))
        , Pos11 = ltrim(rtrim(xDim.value('/x[11]','varchar(255)')))
        , Pos12 = ltrim(rtrim(xDim.value('/x[12]','varchar(255)')))
        , Pos13 = ltrim(rtrim(xDim.value('/x[13]','varchar(255)')))
    From  (Select Cast('<x>' + replace((Select replace(@String,@Delimiter,'§§Split§§') as [*] For XML Path('')),'§§Split§§','</x><x>')+'</x>' as xml) as xDim) as A 
)
--Thanks Shnugo for making this XML safe
--Select * from [dbo].[udf-Str-Parse-Row]('Dog,Cat,House,Car',',')
--Select * from [dbo].[udf-Str-Parse-Row]('John <test> Cappelletti',' ')
--Select * from [dbo].[udf-Str-Parse-Row]('A&B;C;D;E, F;<x>',';')

-- Source: https://stackoverflow.com/questions/42259236/sql-split-tab-delimited-column
GO
