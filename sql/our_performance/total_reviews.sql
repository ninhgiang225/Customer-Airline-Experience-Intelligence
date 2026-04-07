-- Card 3 — Total Reviews with YoY Indicator

WITH yearly AS (
    SELECT
        d.CAL_YEAR,
        COUNT(f.REVIEW_KEY) AS total_reviews
    FROM SKYTRAX_REVIEWS_DB.MARTS.FCT_REVIEW f
    JOIN SKYTRAX_REVIEWS_DB.MARTS.DIM_AIRLINE a ON f.AIRLINE_ID = a.AIRLINE_ID
    JOIN SKYTRAX_REVIEWS_DB.MARTS.DIM_DATE    d ON f.DATE_FLOWN_ID = d.DATE_ID
    WHERE a.AIRLINE_NAME = 'Delta Air Lines'
        AND f.IS_VERIFIED = TRUE
    GROUP BY d.CAL_YEAR
),
with_lag AS (
    SELECT
        CAL_YEAR,
        total_reviews,
        LAG(total_reviews) OVER (ORDER BY CAL_YEAR) AS prev_year_reviews
    FROM yearly
)
SELECT
    total_reviews                                   AS current_total_reviews
FROM with_lag
WHERE prev_year_reviews IS NOT NULL
ORDER BY CAL_YEAR DESC
LIMIT 1;