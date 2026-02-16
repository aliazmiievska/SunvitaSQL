SELECT TOP 20

DATEADD(YEAR, -2000, rnVypuskProd.Perio)	AS Date_BASE1,

CASE enumVidySmen._EnumOrder 
    WHEN 1 THEN 'Night'
    WHEN 0 THEN 'Day'
    ELSE 'Unknown'
END												AS TypZminy_BASE2,

sprVidyPodrazdel._Description					AS Linia_BASE3,
sprNomenklatura._Description					AS Naimenuvannia_BASE4,

rsVremiaIzhotovlenia._Fld24502					AS PlanPerMinute_BASE5,

CAST(wt.WorkMinutes / 60 AS VARCHAR(10)) + 'h ' 
+ RIGHT(CAST(wt.WorkMinutes % 60 AS VARCHAR(2)), 2) + 'min'
												AS WorhingTime_BASE9,

CAST(
    ROUND(
        rnVypuskProd.Qty * 1.0 
        / NULLIF(wt.WorkMinutes, 0),
    0)
AS INT)									        AS FactPerMinute_BASE6,

rsColichRezov.RezCount			            	AS CountRiziv_BASE7,

CAST(zat.defectProzent AS VARCHAR(20)) + N'%'	AS BrakSyrovynyVidsotok_BASE8,		

zat.allSum										AS AllSyrovyna_BASE,



CAST(ISNULL(rsRemonty.RepairMinutes, 0) / 60 AS VARCHAR(10)) + 'h ' 
+ RIGHT(
    '0' + CAST(ISNULL(rsRemonty.RepairMinutes, 0) % 60 AS VARCHAR(2)),
    2
) + 'min'									  AS RemontTime_BASE10,

CAST(ISNULL(rsProstoi.DowntimeMinutes, 0) / 60 AS VARCHAR(10)) + 'h ' 
+ RIGHT(
    '0' + CAST(ISNULL(rsProstoi.DowntimeMinutes, 0) % 60 AS VARCHAR(2)),
    2
) + 'min'                                      AS ProstoiTime_BASE11,

ISNULL(sotr_count.executantsCount, 0)			AS ExecutantsCount_BASE12

FROM _Document426 docOtchetyPoProd

CROSS APPLY (
    SELECT DATEDIFF(MINUTE, docOtchetyPoProd._Fld23192, docOtchetyPoProd._Fld23193) AS WorkMinutes
) wt

--

LEFT JOIN (
    SELECT 
        _RecorderRRef,
        _Fld20665RRef,
        _Fld20666RRef,
        _Fld20667RRef,
		MAX(_Period) AS Perio,
        SUM(_Fld20674) AS Qty
    FROM _AccumRg20664
    GROUP BY 
        _RecorderRRef,
        _Fld20665RRef,
        _Fld20666RRef,
        _Fld20667RRef
) rnVypuskProd
    ON rnVypuskProd._RecorderRRef = docOtchetyPoProd._IDRRef


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
        SUM(DATEDIFF(MINUTE, _Fld24655, _Fld24656)) AS RepairMinutes
    FROM _InfoRg24651
    GROUP BY _Fld24657RRef
) rsRemonty
    ON rnVypuskProd._RecorderRRef = rsRemonty._Fld24657RRef

LEFT JOIN (
    SELECT 
        _Fld25202RRef,
        SUM(DATEDIFF(MINUTE, _Fld25199, _Fld25200)) AS DowntimeMinutes
    FROM _InfoRg25196
    GROUP BY _Fld25202RRef
) rsProstoi
    ON rnVypuskProd._RecorderRRef = rsProstoi._Fld25202RRef

LEFT JOIN _Reference151 sprNomenklatura
    ON rnVypuskProd._Fld20666RRef = sprNomenklatura._IDRRef

LEFT JOIN _Reference170 sprVidyPodrazdel
    ON rnVypuskProd._Fld20665RRef = sprVidyPodrazdel._IDRRef

LEFT JOIN _Enum23693 enumVidySmen
    ON docOtchetyPoProd._Fld23714RRef = enumVidySmen._IDRRef

--

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

--

WHERE sprVidyPodrazdel._Description LIKE N'Цех%'
AND enumVidySmen._EnumOrder IS NOT NULL

ORDER BY DATEADD(YEAR, -2000, rnVypuskProd.Perio) DESC