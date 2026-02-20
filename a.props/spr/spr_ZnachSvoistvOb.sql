;

WITH
    spr_ZnachSvoistvOb
    AS
    (
        SELECT
            spr_ZnachSvoistvOb._IDRRef AS ID,
            spr_ZnachSvoistvOb._Code AS Code,
            spr_ZnachSvoistvOb._Description AS Назва,
            spr_ZnachSvoistvOb._Marked AS ПоміткаВидалення,
            spr_ZnachSvoistvOb._Folder AS Група
        -- тут будуть FK поля
        FROM
            _Reference93 AS spr_ZnachSvoistvOb
    )
SELECT
    *
FROM
    spr_ZnachSvoistvOb