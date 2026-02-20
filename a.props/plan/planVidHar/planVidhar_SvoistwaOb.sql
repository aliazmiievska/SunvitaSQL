;WITH
    planVidHar_SvoistwaOb
    AS
    (

        SELECT

            planVidHar_SvoistwaOb._IDRRef AS ID,
            planVidHar_SvoistwaOb._Code AS Code,
            planVidHar_SvoistwaOb._Description AS NameN,
            planVidHar_SvoistwaOb._Marked AS ПоміткаВидалення,

            planVidHar_SvoistwaOb._Fld22859RRef AS Призначення

        FROM _Chrc1016 AS planVidHar_SvoistwaOb

    )

SELECT *
FROM planVidHar_SvoistwaOb