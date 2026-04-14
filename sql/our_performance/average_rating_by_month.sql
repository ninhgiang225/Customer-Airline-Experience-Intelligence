SELECT
    d.CAL_MON_NAME                                  AS month_name,
    d.CAL_MONTH                                     AS month_num,
    ROUND(AVG(f.AVERAGE_RATING), 2)                 AS avg_rating,
    COUNT(f.REVIEW_KEY)                             AS review_count
FROM MARTS.FCT_REVIEW f
JOIN MARTS.DIM_AIRLINE a ON f.AIRLINE_ID    = a.AIRLINE_ID
JOIN MARTS.DIM_DATE    d ON f.DATE_FLOWN_ID = d.DATE_ID
WHERE a.AIRLINE_NAME = 'Delta Air Lines'
    AND f.IS_VERIFIED = TRUE
GROUP BY d.CAL_MONTH, d.CAL_MON_NAME
ORDER BY d.CAL_MONTH;