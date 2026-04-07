SELECT
    f.SEAT_TYPE,
    COUNT(*)                                        AS bad_review_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_bad_reviews,
    ROUND(AVG(f.AVERAGE_RATING), 2)                 AS avg_rating
FROM MARTS.FCT_REVIEW f
JOIN MARTS.DIM_AIRLINE a ON f.AIRLINE_ID = a.AIRLINE_ID
WHERE a.AIRLINE_NAME = 'Delta Air Lines'
    AND LOWER(f.RATING_BAND) IN ('bad', 'poor', 'terrible')
    AND f.IS_VERIFIED = TRUE
    AND f.SEAT_TYPE IS NOT NULL
GROUP BY f.SEAT_TYPE
ORDER BY bad_review_count DESC;