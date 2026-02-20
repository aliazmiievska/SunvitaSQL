---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

;WITH
    regSv_ZnachSvoistvOb
    AS
    (

        SELECT

            regSv_ZnachSvoistvOb._SimpleKey         AS ID,
            regSv_ZnachSvoistvOb._Fld17698_RRRef    AS Обьект,
            regSv_ZnachSvoistvOb._Fld17699RRef      AS Свойство,
            regSv_ZnachSvoistvOb._Fld17700_RRRef    AS Значення

        -- тут будуть FK поля

        FROM _InfoRg17697                           AS regSv_ZnachSvoistvOb
    ),


    spr_ZnachSvoistvOb
    AS
    (

        SELECT

            spr_ZnachSvoistvOb._IDRRef              AS ID,
            spr_ZnachSvoistvOb._Code                AS Code,
            spr_ZnachSvoistvOb._Description         AS Назва,
            spr_ZnachSvoistvOb._Marked              AS ПоміткаВидалення,
            spr_ZnachSvoistvOb._Folder              AS Група

        -- тут будуть FK поля

        FROM _Reference93                           AS spr_ZnachSvoistvOb
    ),


    spr_Nomenklatura
    AS
    (

        SELECT

            spr_Nomenklatura._IDRRef                AS ID,
            spr_Nomenklatura._Code                  AS Code,
            spr_Nomenklatura._Description           AS Назва,
            spr_Nomenklatura._Marked                AS ПоміткаВидалення,
            spr_Nomenklatura._Folder                AS Група

        -- тут будуть FK поля

        FROM _Reference149                          AS spr_Nomenklatura
    ),


    spr_PlanVidovHarakteristik
    AS
    (

        SELECT

            spr_PlanVidovHarakteristik._IDRRef      AS ID,
            spr_PlanVidovHarakteristik._Description AS Назва

        FROM _Chrc1016                              AS spr_PlanVidovHarakteristik
    ),


    Props
    AS
    (

        SELECT

            regSv_ZnachSvoistvOb.Обьект,
            spr_PlanVidovHarakteristik.Назва        AS НазваВластивості,
            spr_ZnachSvoistvOb.Назва                AS Значення

        FROM regSv_ZnachSvoistvOb

            LEFT JOIN spr_PlanVidovHarakteristik
            ON spr_PlanVidovHarakteristik.ID = regSv_ZnachSvoistvOb.Свойство

            LEFT JOIN spr_ZnachSvoistvOb
            ON spr_ZnachSvoistvOb.ID = regSv_ZnachSvoistvOb.Значення

        WHERE spr_PlanVidovHarakteristik.Назва IN (
        N'Категорія',
        N'Бренд',
        N'SKU',
        N'Група Пріоритета',
        N'Кількість в упаковці',
        N'Постачальник'
    )
    ),


    PropsSvoistva
    AS
    (

        SELECT

            Props.Обьект,

            MAX(CASE WHEN Props.НазваВластивості = N'Категорія'
                THEN Props.Значення END)        AS [Категорія],

            MAX(CASE WHEN Props.НазваВластивості = N'Бренд'
                THEN Props.Значення END)        AS [Бренд],

            MAX(CASE WHEN Props.НазваВластивості = N'SKU'
                THEN Props.Значення END)        AS [SKU],

            MAX(CASE WHEN Props.НазваВластивості = N'Група Пріоритета'
                THEN Props.Значення END)        AS [Група Пріоритета],

            MAX(CASE WHEN Props.НазваВластивості = N'Кількість в упаковці'
                THEN Props.Значення END)        AS [Кількість в упаковці],

            MAX(CASE WHEN Props.НазваВластивості = N'Постачальник'
                THEN Props.Значення END)        AS [Постачальник]

        FROM Props

        GROUP BY Props.Обьект
    )

---------------------------------------------------------------------------------------

SELECT

    spr_Nomenklatura.Code                       AS КодНоменклатури,
    spr_Nomenklatura.Назва                      AS Номенклатура,

    PropsSvoistva.[Категорія],
    PropsSvoistva.[Бренд],
    PropsSvoistva.[SKU],
    PropsSvoistva.[Група Пріоритета],
    PropsSvoistva.[Кількість в упаковці],
    PropsSvoistva.[Постачальник],
    TRY_CONVERT(decimal(18,3),
        PropsSvoistva.[Кількість в упаковці])      AS КількістьВУпаковці_число,

    CASE
        WHEN ISNULL(PropsSvoistva.[Бренд], N'Інше') IN (
            N'NATURELLE',
            N'Purfix',
            N'Biolly',
            N'Summer Fresh',
            N'Super Baby',
            N'Baby Zaya'
        )
        THEN N'Власний Бренд'
        ELSE N'Інше'
    END                                         AS ТипБренду

FROM spr_Nomenklatura

    ---------------------------------------------------------------------------------------

    LEFT JOIN PropsSvoistva
    ON PropsSvoistva.Обьект = spr_Nomenklatura.ID

---------------------------------------------------------------------------------------

WHERE spr_Nomenklatura.ПоміткаВидалення = 0

ORDER BY spr_Nomenklatura.Code;

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------