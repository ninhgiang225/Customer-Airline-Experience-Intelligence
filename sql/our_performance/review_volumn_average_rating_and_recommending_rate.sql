SELECT
    a.AIRLINE_NAME,
    COUNT(f.REVIEW_KEY)                             AS total_reviews,
    ROUND(AVG(f.AVERAGE_RATING), 2)                 AS avg_rating,
    ROUND(
        SUM(CASE WHEN UPPER(f.RECOMMENDED) = 'TRUE' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100
    , 1)                                            AS rec_rate,
    CASE WHEN a.AIRLINE_NAME = 'Delta Air Lines'
         THEN 'Delta Air Lines' ELSE 'Competitor'
    END                                             AS airline_type
FROM MARTS.FCT_REVIEW f
JOIN MARTS.DIM_AIRLINE a ON f.AIRLINE_ID = a.AIRLINE_ID
WHERE f.IS_VERIFIED = TRUE
GROUP BY a.AIRLINE_NAME, airline_type
HAVING COUNT(f.REVIEW_KEY) >= 200
ORDER BY total_reviews DESC;