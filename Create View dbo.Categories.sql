CREATE view dbo.Categories
AS
    SELECT DISTINCT
        [Category]
    FROM
        dbo.ParseFields
GO