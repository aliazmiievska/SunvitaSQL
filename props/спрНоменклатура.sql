;WITH Props AS (

    SELECT

        regsvoy._Fld17698_RRRef AS NomenklaturaRRef,       -- посилання на номенклатуру
        plansvoy._Description   AS НазваВластивості,
        refsvoy._Description    AS Значення

    FROM _InfoRg17697 AS regsvoy

    LEFT JOIN _Chrc1016   AS plansvoy 
        ON regsvoy._Fld17699RRef = plansvoy._IDRRef

    LEFT JOIN _Reference93 AS refsvoy 
        ON regsvoy._Fld17700_RRRef = refsvoy._IDRRef

    WHERE plansvoy._Description IN (N'Категорія', N'Бренд', N'Кількість в упаковці', N'SKU')

)

SELECT * FROM Props