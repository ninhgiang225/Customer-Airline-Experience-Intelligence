-- Find which dimension scores lowest among bad reviews
WITH bad_reviews AS (
    SELECT
        f.SEAT_COMFORT,
        f.CABIN_STAFF_SERVICE,
        f.FOOD_AND_BEVERAGES,
        f.INFLIGHT_ENTERTAINMENT,
        f.GROUND_SERVICE,
        f.WIFI_AND_CONNECTIVITY,
        f.VALUE_FOR_MONEY
    FROM MARTS.FCT_REVIEW f
    JOIN MARTS.DIM_AIRLINE a ON f.AIRLINE_ID = a.AIRLINE_ID
    WHERE a.AIRLINE_NAME = 'Delta Air Lines'
        AND LOWER(f.RATING_BAND) IN ('bad', 'poor', 'terrible')
        AND f.IS_VERIFIED = TRUE
),
dim_avgs AS (
    SELECT 'Seat Comfort'    AS dimension, AVG(SEAT_COMFORT)           AS avg_score FROM bad_reviews UNION ALL
    SELECT 'Cabin Staff',                  AVG(CABIN_STAFF_SERVICE)                 FROM bad_reviews UNION ALL
    SELECT 'Food & Beverage',              AVG(FOOD_AND_BEVERAGES)                  FROM bad_reviews UNION ALL
    SELECT 'Entertainment',                AVG(INFLIGHT_ENTERTAINMENT)              FROM bad_reviews UNION ALL
    SELECT 'Ground Service',               AVG(GROUND_SERVICE)                      FROM bad_reviews UNION ALL
    SELECT 'WiFi',                         AVG(WIFI_AND_CONNECTIVITY)               FROM bad_reviews UNION ALL
    SELECT 'Value for Money',              AVG(VALUE_FOR_MONEY)                     FROM bad_reviews
)
SELECT
    dimension                           AS top_reason,
    ROUND(avg_score, 2)                 AS avg_score
FROM dim_avgs
WHERE avg_score IS NOT NULL
ORDER BY avg_score ASC
LIMIT 1;