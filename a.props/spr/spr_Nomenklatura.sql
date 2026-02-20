;WITH
    spr_Nomenklatura
    AS
    (

        SELECT

            spr_Nomenklatura._IDRRef AS ID,
            spr_Nomenklatura._Code AS Code,
            spr_Nomenklatura._Description AS Назва,
            spr_Nomenklatura._Marked AS ПоміткаВидалення,
            spr_Nomenklatura._Folder AS Група

        -- тут будуть FK поля

        FROM _Reference149 AS spr_Nomenklatura

    )

SELECT *
FROM spr_Nomenklatura