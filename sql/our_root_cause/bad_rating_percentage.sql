WITH yearly AS (
    SELECT
        d.CAL_YEAR,
        COUNT(*) AS total_reviews,
        SUM(CASE 
                WHEN LOWER(f.RATING_BAND) = 'bad' THEN 1 
                ELSE 0 
            END) AS bad_reviews,
        ROUND(
            SUM(CASE 
                    WHEN LOWER(f.RATING_BAND) = 'bad' THEN 1 
                    ELSE 0 
                END
            ) / NULLIF(COUNT(*), 0),
        3) AS pct_bad_rating
    FROM MARTS.FCT_REVIEW f
    JOIN MARTS.DIM_AIRLINE a 
        ON f.AIRLINE_ID = a.AIRLINE_ID
    JOIN MARTS.DIM_DATE d 
        ON f.DATE_FLOWN_ID = d.DATE_ID
    WHERE a.AIRLINE_NAME = 'Delta Air Lines'
        AND f.IS_VERIFIED = TRUE
    GROUP BY d.CAL_YEAR
),

with_lag AS (
    SELECT
        CAL_YEAR,
        pct_bad_rating,
        LAG(pct_bad_rating) OVER (ORDER BY CAL_YEAR) AS prev_year_pct
    FROM yearly
)

SELECT
    CAL_YEAR,
    pct_bad_rating                         AS current_pct_bad_rating,
    prev_year_pct,
    ROUND(pct_bad_rating - prev_year_pct, 3) AS yoy_change
FROM with_lag
WHERE prev_year_pct IS NOT NULL
ORDER BY CAL_YEAR DESC;