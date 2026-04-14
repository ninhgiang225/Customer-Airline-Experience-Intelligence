SELECT
    CONCAT(d.CAL_YEAR, ' Q', d.CAL_QUARTER)        AS time_period,
    d.CAL_YEAR,
    d.CAL_QUARTER,

    SUM(CASE WHEN UPPER(f.RECOMMENDED) = 'TRUE' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100                 AS rec_rate_pct,
    COUNT(f.REVIEW_KEY)                             AS review_count,
    SUM(CASE 
        WHEN LOWER(f.RATING_BAND) = 'good' THEN 1 
        ELSE 0 
    END)/ NULLIF(COUNT(*), 0) * 100                 AS good_reviews_pct
FROM MARTS.FCT_REVIEW f
JOIN MARTS.DIM_AIRLINE a ON f.AIRLINE_ID    = a.AIRLINE_ID
JOIN MARTS.DIM_DATE    d ON f.DATE_FLOWN_ID = d.DATE_ID
WHERE a.AIRLINE_NAME = 'Delta Air Lines'
    AND f.IS_VERIFIED = TRUE
GROUP BY d.CAL_YEAR, d.CAL_QUARTER
ORDER BY d.CAL_YEAR, d.CAL_QUARTER;