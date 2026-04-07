-- Histogram: Comparing average rating of all airlines

WITH airline_stats AS (
    SELECT
        a.AIRLINE_NAME,
        COUNT(f.REVIEW_KEY)             AS total_reviews,
        ROUND(AVG(f.AVERAGE_RATING), 2) AS avg_rating,
        CASE WHEN a.AIRLINE_NAME = 'Delta Air Lines'
             THEN 'Delta Air Lines' 
             ELSE 'Competitor' END       AS airline_type
    FROM SKYTRAX_REVIEWS_DB.MARTS.FCT_REVIEW f
    JOIN SKYTRAX_REVIEWS_DB.MARTS.DIM_AIRLINE a ON f.AIRLINE_ID = a.AIRLINE_ID
    WHERE f.IS_VERIFIED = TRUE
    GROUP BY a.AIRLINE_NAME
    HAVING COUNT(f.REVIEW_KEY) >= 200
)
SELECT
    AIRLINE_NAME,
    total_reviews,
    avg_rating,
    airline_type,
    -- percentile rank so you can show where Delta sits
    ROUND(
        PERCENT_RANK() OVER (ORDER BY avg_rating) * 100
    , 1)                                AS percentile_rank
FROM airline_stats
ORDER BY avg_rating DESC;