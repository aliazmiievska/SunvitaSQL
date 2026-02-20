
SELECT

    -- BAZA (nonduplicatable)
    docOtchetyPoProd._IDRRef BAZA,
    docOtchetyPoProd._Number DocNUMBER,
	docOtchetyPoProd._Posted Posted,

    -- BASE1_DATE
    DATEADD(YEAR, -2000, docOtchetyPoProd._Date_Time) AS BASE1_DATE,

    -- BASE2_TYP_ZMINY
    -- docOtchetyPoProd._Fld23714RRef VydyZmin,
    CASE enumVidySmen._EnumOrder 
    WHEN 1 THEN 'Night'
    WHEN 0 THEN 'Day'
    ELSE 'Unknown' END AS BASE2_TYP_ZMINY,

    -- BASE3_LINIA
    docOtchetyPoProd._Fld9847RRef Podrazdelenie,
    sprVidyPodrazdel._Description AS BASE3_LINIA,

    -- BASE4_NAIMENUVANNIA
    rnVypuskProd._Fld20666RRef Nomenklatura,
    sprNomenklatura._Description AS BASE4_NAIMENUVANNIA,

    -- BASE5_PLAN_PER_MINUTE
    rsVremiaIzhotovlenia._Fld24502 AS BASE5_PLAN_PER_MINUTE,

    -- BASE6_FACT_PER_MINUTE
	rnVypuskProd._Fld20674 factCount,
	wm.WorkMinutes,
	docOtchetyPoProd._Fld23192 workStart, 
	docOtchetyPoProd._Fld23193 workEnd,
    CAST( 
        ROUND(
            rnVypuskProd._Fld20674 * 1.0 
            / NULLIF(wm.WorkMinutes, 0),     
        0)     
    AS INT)	 AS BASE6_FACT_PER_MINUTE,

    CAST( -- факт - план / план
        ROUND(
            (CAST( 
                ROUND(
                    rnVypuskProd._Fld20674 * 1.0 
                    / NULLIF(wm.WorkMinutes, 0)
                , 0
                )     
            AS INT) 
            - NULLIF(rsVremiaIzhotovlenia._Fld24502, 0))
            / NULLIF(rsVremiaIzhotovlenia._Fld24502, 0)
            * 100
        , 2) 
    AS DECIMAL(10,2)) AS VIDHYLENNIA,

    -- BASE7_COUNT_RIZIV
    rsColichRezov.RezCount AS BASE7_COUNT_RIZIV,

    -- BASE8_BRAK_SYROVINY_VIDSOTOK
	zat.defectSum, 
	zat.allSum,
    zat.defectProzent AS BASE8_BRAK_SYROVINY_VIDSOTOK,

    -- BASE9_WORKING_TIME
    docOtchetyPoProd._Fld23192 AS NachaloSmeny,
    docOtchetyPoProd._Fld23193 AS KonecSmeny,
    wm.WorkMinutes AS WorkingMinutes,
    CAST( DATEADD(
        MINUTE,
        CASE 
            WHEN 
                ISNULL(wm.WorkMinutes, 0) > 100000 
                OR ISNULL(wm.WorkMinutes, 0) < 0
                THEN 0
            ELSE ISNULL(wm.WorkMinutes, 0)
        END,
        0 )
    AS time) AS WorkingTime,
    CAST(wm.WorkMinutes / 60 AS VARCHAR(10)) + 'h ' 
    + RIGHT(CAST(wm.WorkMinutes % 60 AS VARCHAR(2)), 2) + 'min' AS BASE9_WORKING_TIME,

    -- BASE10_REMONT_TIME (other reg)
    rsRemonty.RepairMinutes AS RemontMinutes,
    CAST(
    DATEADD(
        MINUTE,
        CASE 
            WHEN ISNULL(rsRemonty.RepairMinutes, 0) > 100000 
                    OR ISNULL(rsRemonty.RepairMinutes, 0) < 0
            THEN 0
            ELSE ISNULL(rsRemonty.RepairMinutes, 0)
        END,
        0
    )
    AS time) AS RemontTime,
    CAST(ISNULL(rsRemonty.RepairMinutes, 0) / 60 AS VARCHAR(10)) + 'h ' 
    + RIGHT(
    '0' + CAST(ISNULL(rsRemonty.RepairMinutes, 0) % 60 AS VARCHAR(2)),
    2) + 'min'   AS BASE10_REMONT_TIME,

    -- BASE11_PROSTOI_TIME (other reg)
    rsProstoi.DowntimeMinutes AS ProstoiMinutes, 
    CAST(
    DATEADD(
        MINUTE,
        CASE 
            WHEN ISNULL(rsProstoi.DowntimeMinutes, 0) > 100000 
                    OR ISNULL(rsProstoi.DowntimeMinutes, 0) < 0
            THEN 0
            ELSE ISNULL(rsProstoi.DowntimeMinutes, 0)
        END,
        0
    )
    AS time) AS ProstoiTime,
    CAST(ISNULL(rsProstoi.DowntimeMinutes, 0) / 60.0 AS VARCHAR(10)) + 'h ' 
    + RIGHT(
    '0' + CAST(ISNULL(rsProstoi.DowntimeMinutes, 0) % 60 AS VARCHAR(2)),
    2
    ) + 'min'   AS BASE11_PROSTOI_TIME,

    -- BASE12_EXECUTANTS_COUNT (other reg)
    sotr_count.executantsCount AS BASE12_EXECUTANTS_COUNT

FROM _Document426 docOtchetyPoProd

---------------------------------------------------------------------------------------

CROSS APPLY (
    SELECT DATEDIFF(MINUTE, docOtchetyPoProd._Fld23192, docOtchetyPoProd._Fld23193) WorkMinutes
) wm

LEFT JOIN _AccumRg20664 rnVypuskProd
    ON docOtchetyPoProd._IDRRef = rnVypuskProd._RecorderRRef

---------------------------------------------------------------------------------------

-- BASE2_TYP_ZMINY
LEFT JOIN _Enum23693 enumVidySmen
    ON docOtchetyPoProd._Fld23714RRef = enumVidySmen._IDRRef

-- BASE3_LINIA
LEFT JOIN _Reference170 sprVidyPodrazdel
    ON rnVypuskProd._Fld20665RRef = sprVidyPodrazdel._IDRRef

-- BASE4_NAIMENUVANNIA
LEFT JOIN _Reference151 sprNomenklatura
    ON rnVypuskProd._Fld20666RRef = sprNomenklatura._IDRRef

-- BASE5_PLAN_PER_MINUTE
LEFT JOIN (
    SELECT *
    FROM (
        SELECT 
            *,
            ROW_NUMBER() OVER (
                PARTITION BY _Fld24500RRef, _Fld25310RRef
                ORDER BY _Period DESC
            ) AS rn
        FROM _InfoRg24499
    ) t
    WHERE rn = 1
) rsVremiaIzhotovlenia
    ON rnVypuskProd._Fld20665RRef = rsVremiaIzhotovlenia._Fld24500RRef
    AND rnVypuskProd._Fld20667RRef = rsVremiaIzhotovlenia._Fld25310RRef

-- BASE7_COUNT_RIZIV
LEFT JOIN (
    SELECT 
        _RecorderRRef,
        SUM(_Fld25445) AS RezCount
    FROM _InfoRg25440
    GROUP BY _RecorderRRef
) rsColichRezov
    ON rnVypuskProd._RecorderRRef = rsColichRezov._RecorderRRef

-- BASE8_BRAK_SYROVINY_VIDSOTOK
LEFT JOIN (
    SELECT
        rnZatratyNaVyplatu._RecorderRRef,
        SUM(rnZatratyNaVyplatu._Fld21062) allSum,

        SUM(CASE 
                WHEN stattiZatrat._Description LIKE N'Технологічні%' 
                THEN rnZatratyNaVyplatu._Fld21062 
                ELSE 0 
            END) defectSum,

	CAST(
    ROUND(
        CASE 
            WHEN SUM(rnZatratyNaVyplatu._Fld21062) = 0 THEN 0
            ELSE 
                SUM(CASE 
                        WHEN stattiZatrat._Description LIKE N'Технологічні%' 
                        THEN rnZatratyNaVyplatu._Fld21062 
                        ELSE 0 
                    END) * 100.0
                / SUM(rnZatratyNaVyplatu._Fld21062)
        END
    , 2)
AS DECIMAL(10,2)) defectProzent

    FROM _AccumRg21045 rnZatratyNaVyplatu

    LEFT JOIN _Reference216 stattiZatrat
        ON rnZatratyNaVyplatu._Fld21054RRef = stattiZatrat._IDRRef

    GROUP BY rnZatratyNaVyplatu._RecorderRRef
) zat
    ON rnVypuskProd._RecorderRRef = zat._RecorderRRef

-- BASE10_REMONT_TIME (other reg)
LEFT JOIN (
    SELECT 
        _Fld24657RRef,
        SUM(
            CASE 
                WHEN _Fld24655 IS NULL 
                    OR _Fld24656 IS NULL 
                    OR _Fld24656 <= _Fld24655
                    OR DATEDIFF(MINUTE, _Fld24655, _Fld24656) > 1440
                THEN NULL
            ELSE DATEDIFF(MINUTE, _Fld24655, _Fld24656)
        END
) AS RepairMinutes
    FROM _InfoRg24651
    GROUP BY _Fld24657RRef
) rsRemonty
    ON docOtchetyPoProd._IDRRef = rsRemonty._Fld24657RRef

-- BASE11_PROSTOI_TIME (other reg)
LEFT JOIN (
    SELECT 
        _Fld25202RRef,
        SUM(
            CASE 
                WHEN _Fld25199 IS NULL 
                    OR _Fld25200 IS NULL 
                    OR _Fld25200 <= _Fld25199
                THEN NULL
            ELSE DATEDIFF(MINUTE, _Fld25199, _Fld25200)
        END
) AS DowntimeMinutes

    FROM _InfoRg25196
    GROUP BY _Fld25202RRef
) rsProstoi
    ON docOtchetyPoProd._IDRRef = rsProstoi._Fld25202RRef

-- BASE12_EXECUTANTS_COUNT (other reg)
LEFT JOIN (
    SELECT 
        s._Document426_IDRRef,
        COUNT(*) executantsCount
    FROM _Document426_VT9992 s
    GROUP BY s._Document426_IDRRef
) sotr_count
    ON docOtchetyPoProd._IDRRef = sotr_count._Document426_IDRRef

---------------------------------------------------------------------------------------

WHERE sprVidyPodrazdel._Description LIKE N'Цех%' -- бо Цех Лінія.. нема цеху - нема лінії
AND sprVidyPodrazdel._Description <> 'Цех №1' -- Андрій сказав
AND sprVidyPodrazdel._Description <> 'Цех №2' -- Андрій сказав
AND sprVidyPodrazdel._Description <> 'Цех №2 (Лінія1)' -- Андрій сказав
AND docOtchetyPoProd._Posted  = 1 -- проведений
AND docOtchetyPoProd._Marked = 0 -- не помічений на видалення

ORDER BY docOtchetyPoProd._Date_Time DESC