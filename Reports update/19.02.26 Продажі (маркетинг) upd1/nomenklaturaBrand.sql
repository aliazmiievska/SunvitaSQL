----------------------------------------------------------------

SELECT
    ------
    nom._Code 
    , [Категорія]
    , [Бренд]
    , [SKU]
    , [Група Пріоритета]

    , CASE 
        WHEN ISNULL([Бренд], 'Інше') IN (
            'NATURELLE',
            'Purfix',
            'Biolly',
            'Summer Fresh',
            'Super Baby',
            'Baby Zaya'
        )
        THEN 'Власний Бренд'
        ELSE 'Інше'
    END AS ТипБренду
------
FROM (

    SELECT
        regsvoy._Fld17698_RRRef as nomenklatura
        , plansvoy._Description as НазваВластивості
        , refsvoy._Description as Значення
    FROM _InfORg17697 as regsvoy

        LEFT JOIN _Chrc1016 as plansvoy
        ON regsvoy._Fld17699RRef = plansvoy._IDRRef

        LEFT JOIN _Reference93 as refsvoy
        ON refsvoy._IDRRef = regsvoy._Fld17700_RRRef

    WHERE ( 
        plansvoy._Description = 'Категорія'
        OR plansvoy._Description = 'Бренд'
        OR plansvoy._Description = 'Група Пріоритета'
        OR plansvoy._Description = 'SKU'
    )
    
) general

----------------------------------------------------------------

pivot (
        MIN(general.Значення)
        FOR general.НазваВластивості in (
            [Категорія], [Бренд], [SKU], [Група Пріоритета]
        )
) pvt

    ----------------------------------------------------------------

    JOIN _Reference149 nom
    ON nomenklatura = nom._IDRRef