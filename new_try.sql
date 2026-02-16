SELECT TOP 20
    -- BAZA (nonduplicatable)
    docOtchetyPoProd._IDRRef BAZA,
    docOtchetyPoProd._Number DocNUMBER,

    -- BASE1_DATE
    DATEADD(YEAR, -2000, docOtchetyPoProd._Date_Time) AS BASE1_DATE,

    -- BASE2_TIP_ZMINY
    docOtchetyPoProd._Fld23714RRef VydyZmin,
    CASE enumVidySmen._EnumOrder 
    WHEN 1 THEN 'Night'
    WHEN 0 THEN 'Day'
    ELSE 'Unknown' END AS BASE2_TIP_ZMINY,

    -- BASE3_LINIA
    docOtchetyPoProd._Fld9847RRef Podrazdelenie,
    sprVidyPodrazdel._Description AS BASE3_LINIA,

    -- BASE4_NAIMENUVANNIA
    rnVypuskProd._Fld20666RRef Nomenklatura,
    sprNomenklatura._Description AS BASE4_NAIMENUVANNIA,

    -- BASE5_PLAN_PER_MINUTE
    rsVremiaIzhotovlenia._Fld24502 AS BASE5_PLAN_PER_MINUTE,

    -- BASE6_FACT_PER_MINUTE
    CAST( ROUND(
        rnVypuskProd._Fld20674 * 1.0 
        / NULLIF(wm.WorkMinutes, 0),     0)     AS INT)	 AS BASE6_FACT_PER_MINUTE,

    -- BASE7_COUNT_RIZIV
    rnVypuskProd._RecorderRRef RizyCount,
    rsColichRezov.RezCount AS BASE7_COUNT_RIZIV,

    -- BASE8_BRAK_SYROVINY_VIDSOTOK

    -- BASE9_WORKING_TIME
    docOtchetyPoProd._Fld23192 AS NachaloSmeny,
    docOtchetyPoProd._Fld23193 AS KonecSmeny,
    wm.WorkMinutes,
    CAST(wm.WorkMinutes / 60 AS VARCHAR(10)) + 'h ' 
    + RIGHT(CAST(wm.WorkMinutes % 60 AS VARCHAR(2)), 2) + 'min' AS BASE9_WORKING_TIME,

    -- BASE10_REMONT_TIME (other reg)
    CAST(ISNULL(rsRemonty.RepairMinutes, 0) / 60 AS VARCHAR(10)) + 'h ' 
    + RIGHT(
    '0' + CAST(ISNULL(rsRemonty.RepairMinutes, 0) % 60 AS VARCHAR(2)),
    2) + 'min'   AS BASE10_REMONT_TIME,

    -- BASE11_PROSTOI_TIME (other reg)
    CAST(ISNULL(rsProstoi.DowntimeMinutes, 0) / 60 AS VARCHAR(10)) + 'h ' 
    + RIGHT(
    '0' + CAST(ISNULL(rsProstoi.DowntimeMinutes, 0) % 60 AS VARCHAR(2)),
    2
    ) + 'min'   AS BASE11_PROSTOI_TIME,

    -- BASE12_EXECUTANTS_COUNT (other reg)
    ISNULL(sotr_count.executantsCount, 0)


FROM _Document426 docOtchetyPoProd

CROSS APPLY (
    SELECT DATEDIFF(MINUTE, docOtchetyPoProd._Fld23192, docOtchetyPoProd._Fld23193) WorkMinutes
) wm

LEFT JOIN _AccumRg20664 rnVypuskProd
    ON docOtchetyPoProd._IDRRef = rnVypuskProd._RecorderRRef

LEFT JOIN _Enum23693 enumVidySmen
    ON docOtchetyPoProd._Fld23714RRef = enumVidySmen._IDRRef

LEFT JOIN _Reference170 sprVidyPodrazdel
    ON rnVypuskProd._Fld20665RRef = sprVidyPodrazdel._IDRRef

LEFT JOIN _Reference151 sprNomenklatura
    ON rnVypuskProd._Fld20666RRef = sprNomenklatura._IDRRef

LEFT JOIN (
    SELECT 
        _RecorderRRef,
        SUM(_Fld25445) AS RezCount
    FROM _InfoRg25440
    GROUP BY _RecorderRRef
) rsColichRezov
    ON rnVypuskProd._RecorderRRef = rsColichRezov._RecorderRRef

LEFT JOIN (
    SELECT 
        _Fld24657RRef,
        SUM(DATEDIFF(MINUTE, _Fld24655, _Fld24656)) RepairMinutes
    FROM _InfoRg24651
    GROUP BY _Fld24657RRef
) rsRemonty
    ON docOtchetyPoProd._IDRRef = rsRemonty._Fld24657RRef

LEFT JOIN (
    SELECT 
        _Fld25202RRef,
        SUM(DATEDIFF(MINUTE, _Fld25199, _Fld25200)) AS DowntimeMinutes
    FROM _InfoRg25196
    GROUP BY _Fld25202RRef
) rsProstoi
    ON docOtchetyPoProd._IDRRef = rsProstoi._Fld25202RRef

    LEFT JOIN (
    SELECT 
        s._Document426_IDRRef,
        COUNT(*) executantsCount
    FROM _Document426_VT9992 s
    GROUP BY s._Document426_IDRRef
) sotr_count
    ON docOtchetyPoProd._IDRRef = sotr_count._Document426_IDRRef

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


ORDER BY docOtchetyPoProd._Date_Time DESC