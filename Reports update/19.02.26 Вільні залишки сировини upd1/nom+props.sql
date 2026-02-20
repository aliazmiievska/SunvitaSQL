;WITH
    Props
    AS
    (

        SELECT

            regsvoy._Fld17698_RRRef AS NomenklaturaRRef, -- посилання на номенклатуру
            plansvoy._Description   AS НазваВластивості,
            refsvoy._Description    AS Значення

        FROM _InfoRg17697 AS regsvoy

            LEFT JOIN _Chrc1016   AS plansvoy
            ON regsvoy._Fld17699RRef = plansvoy._IDRRef

            LEFT JOIN _Reference93 AS refsvoy
            ON regsvoy._Fld17700_RRRef = refsvoy._IDRRef

        WHERE plansvoy._Description IN (N'Категорія', N'Бренд', N'Кількість в упаковці', N'SKU')

    ),

    PropsPivot
    AS
    (

        SELECT

            p.NomenklaturaRRef,
            [Категорія]              = MAX(CASE WHEN p.НазваВластивості = N'Категорія'             THEN p.Значення END),
            [Бренд]                  = MAX(CASE WHEN p.НазваВластивості = N'Бренд'                 THEN p.Значення END),
            [Кількість в упаковці]   = MAX(CASE WHEN p.НазваВластивості = N'Кількість в упаковці'  THEN p.Значення END),
            [SKU]                    = MAX(CASE WHEN p.НазваВластивості = N'SKU'                   THEN p.Значення END)

        FROM Props p

        GROUP BY p.NomenklaturaRRef

    )

SELECT

    nom._Code                                  AS КодНоменклатури,
    nom._Description                           AS Номенклатура,
    nom._Fld2296,
    nom._Fld23716,
    nom._Fld2306RRef                           AS ВидНоменклатуриRRef,
    r51._Description                           AS ВидНоменклатури,
    nom._Fld25116RRef                          AS ПроектRRef,
    r181._Description                          AS Проект,

    pp.[Категорія],
    pp.[Бренд],
    pp.[Кількість в упаковці],
    pp.[SKU],

    -- опціонально: числове подання "Кількість в упаковці", якщо там текст
    TRY_CONVERT(decimal(18,3), pp.[Кількість в упаковці]) AS КількістьВУпаковці_число

FROM _Reference149 AS nom

    LEFT JOIN _Reference51  AS r51
    ON r51._IDRRef       = nom._Fld2306RRef

    LEFT JOIN _Reference181 AS r181
    ON r181._IDRRef      = nom._Fld25116RRef

    LEFT JOIN PropsPivot    AS pp
    ON pp.NomenklaturaRRef = nom._IDRRef

-- WHERE nom._Marked = 0  -- розкоментуй, якщо треба виключити помічені на видалення
ORDER BY nom._Code;
