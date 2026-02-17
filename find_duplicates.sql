SELECT 
    _Number,
    _Date_Time,
    COUNT(*) AS duplicate_count,
    STRING_AGG(CAST(_IDRRef AS VARCHAR(MAX)), ', ') AS IDRRef_list

FROM _Document426

GROUP BY 
    _Number,
    _Date_Time

HAVING COUNT(*) > 1

ORDER BY duplicate_count DESC
