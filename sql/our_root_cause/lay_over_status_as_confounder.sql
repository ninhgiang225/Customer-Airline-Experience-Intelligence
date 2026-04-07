SELECT
    CASE WHEN f.HAS_LAYOVER = TRUE THEN 'Has Layover' 
         ELSE 'No Layover' END                      AS layover_status,
    COUNT(*)                                        AS bad_review_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_bad_reviews
FROM MARTS.FCT_REVIEW f
JOIN MARTS.DIM_AIRLINE a ON f.AIRLINE_ID = a.AIRLINE_ID
WHERE a.AIRLINE_NAME = 'Delta Air Lines'
    AND LOWER(f.RATING_BAND) IN ('bad')
    AND f.IS_VERIFIED = TRUE
GROUP BY layover_status;