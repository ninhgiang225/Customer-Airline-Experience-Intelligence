-- Card 2 — Recommending Rating with YoY Indicator

WITH yearly AS (
    SELECT
        d.CAL_YEAR,
        ROUND(
            AVG(CASE 
                    WHEN UPPER(f.RECOMMENDED) = 'TRUE' THEN 1 
                    ELSE 0 
                END), 
            2
        ) AS avg_rating
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
        avg_rating,
        LAG(avg_rating) OVER (ORDER BY CAL_YEAR) AS prev_year_rating
    FROM yearly
)
SELECT
    avg_rating                              AS current_avg_rating,
    prev_year_rating,
    ROUND(avg_rating - prev_year_rating, 2) AS yoy_change,
    CAL_YEAR
FROM with_lag
WHERE prev_year_rating IS NOT NULL
ORDER BY CAL_YEAR DESC;