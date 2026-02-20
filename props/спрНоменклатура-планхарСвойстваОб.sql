;WITH Props AS (

    SELECT

        regsvoy._Fld17698_RRRef AS NomenklaturaRRef,
        plansvoy._Description   AS НазваВластивості,
        refsvoy._Description    AS Значення

    FROM _InfoRg17697 AS regsvoy

    LEFT JOIN _Chrc1016   AS plansvoy 
        ON regsvoy._Fld17699RRef = plansvoy._IDRRef

    LEFT JOIN _Reference93 AS refsvoy 
        ON regsvoy._Fld17700_RRRef = refsvoy._IDRRef

    WHERE plansvoy._Description IN (N'Категорія', N'Бренд', N'Кількість в упаковці', N'SKU')

), 

PropsPivot AS (

    SELECT

        p.NomenklaturaRRef,
        [Категорія]              = MAX(CASE WHEN p.НазваВластивості = N'Категорія'             THEN p.Значення END),
        [Бренд]                  = MAX(CASE WHEN p.НазваВластивості = N'Бренд'                 THEN p.Значення END),
        [Кількість в упаковці]   = MAX(CASE WHEN p.НазваВластивості = N'Кількість в упаковці'  THEN p.Значення END),
        [SKU]                    = MAX(CASE WHEN p.НазваВластивості = N'SKU'                   THEN p.Значення END)

    FROM Props p

    GROUP BY p.NomenklaturaRRef
    
)

SELECT * FROM PropsPivot