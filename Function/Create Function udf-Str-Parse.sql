CREATE FUNCTION [dbo].[udf-Str-Parse] (@String varchar(max), @Delimiter varchar(10))
Returns Table 
WITH SCHEMABINDING
As
Return (  
    Select RetSeq = Row_Number() over (Order By (Select null))
          , RetVal = LTrim(RTrim(B.i.value('(./text())[1]', 'varchar(max)')))
From (Select x = Cast('<x>' + replace((Select replace(@String,@Delimiter,'§§Split§§') as [*]
        For XML Path('')),'§§Split§§','</x><x>')+'</x>' as xml).query('.')) as A 
    Cross Apply x.nodes('x') AS B(i)
);

--Thanks Shnugo for making this XML safe
--Select * from [dbo].[udf-Str-Parse]('Dog,Cat,House,Car',',')
--Select * from [dbo].[udf-Str-Parse]('John Cappelletti was here',' ')
--Select * from [dbo].[udf-Str-Parse]('this,is,<test>,for,< & >',',')

-- Source: https://stackoverflow.com/questions/42259236/sql-split-tab-delimited-column
