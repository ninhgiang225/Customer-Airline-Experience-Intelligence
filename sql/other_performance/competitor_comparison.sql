WITH airline_stats AS (
    SELECT
        a.AIRLINE_NAME,
        COUNT(f.REVIEW_KEY)             AS total_reviews,
        ROUND(AVG(f.AVERAGE_RATING), 2) AS avg_rating,
        ROUND(
            SUM(CASE WHEN UPPER(f.RECOMMENDED) = 'YES' THEN 1 ELSE 0 END)
            / NULLIF(COUNT(*), 0) * 100
        , 1)                            AS rec_rate,
        CASE WHEN a.AIRLINE_NAME = 'Delta Air Lines'
             THEN 'Delta Air Lines'
             ELSE 'Competitor' END       AS airline_type
    FROM MARTS.FCT_REVIEW f
    JOIN MARTS.DIM_AIRLINE a ON f.AIRLINE_ID = a.AIRLINE_ID
    WHERE f.IS_VERIFIED = TRUE
    GROUP BY a.AIRLINE_NAME
    HAVING COUNT(f.REVIEW_KEY) >= 200
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY
            -- Delta always appears even if not top 10
            CASE WHEN AIRLINE_NAME = 'Delta Air Lines' THEN 0 ELSE 1 END,
            total_reviews DESC
        ) AS rnk
    FROM airline_stats
)
SELECT
    AIRLINE_NAME,
    total_reviews,
    avg_rating,
    rec_rate,
    airline_type,
    rnk
FROM ranked
WHERE rnk <= 10
ORDER BY avg_rating DESC;