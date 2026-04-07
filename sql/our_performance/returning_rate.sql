-- Card 4 — Returning Rate with YoY Indicator

WITH yearly AS (
    SELECT
        d.CAL_YEAR,
        COUNT(*) AS total_reviewers,
        SUM(CASE 
                WHEN c.NUMBER_OF_FLIGHTS > 1 THEN 1 
                ELSE 0 
            END) AS returning_reviewers,
        ROUND(
            SUM(CASE 
                    WHEN c.NUMBER_OF_FLIGHTS > 1 THEN 1 
                    ELSE 0 
                END)
            / NULLIF(COUNT(*), 0),
        3) AS returning_rate_pct
    FROM SKYTRAX_REVIEWS_DB.MARTS.FCT_REVIEW f
    JOIN SKYTRAX_REVIEWS_DB.MARTS.DIM_AIRLINE  a ON f.AIRLINE_ID  = a.AIRLINE_ID
    JOIN SKYTRAX_REVIEWS_DB.MARTS.DIM_CUSTOMER c ON f.CUSTOMER_ID = c.CUSTOMER_ID
    JOIN SKYTRAX_REVIEWS_DB.MARTS.DIM_DATE     d ON f.DATE_FLOWN_ID = d.DATE_ID
    WHERE a.AIRLINE_NAME = 'Delta Air Lines'
        AND f.IS_VERIFIED = TRUE
    GROUP BY d.CAL_YEAR
),
with_lag AS (
    SELECT
        CAL_YEAR,
        total_reviewers,
        returning_reviewers,
        returning_rate_pct,
        LAG(returning_rate_pct) OVER (ORDER BY CAL_YEAR) AS prev_year_rate
    FROM yearly
)
SELECT
    total_reviewers,
    returning_reviewers,
    returning_rate_pct                        AS current_returning_rate_pct,
    prev_year_rate,
    ROUND(returning_rate_pct - prev_year_rate, 3) AS yoy_change,
    CAL_YEAR
FROM with_lag
WHERE prev_year_rate IS NOT NULL
ORDER BY CAL_YEAR DESC;