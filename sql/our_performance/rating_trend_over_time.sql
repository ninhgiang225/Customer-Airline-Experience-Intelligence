-- Line graph: Rating Trend over time

SELECT
    d.CAL_YEAR,
    d.CAL_QUARTER,
    CONCAT(d.CAL_YEAR, ' Q', d.CAL_QUARTER)        AS time_period,
    ROUND(AVG(f.SEAT_COMFORT), 2)                   AS seat_comfort,
    ROUND(AVG(f.CABIN_STAFF_SERVICE), 2)            AS cabin_staff,
    ROUND(AVG(f.INFLIGHT_ENTERTAINMENT), 2)         AS entertainment,
    ROUND(AVG(f.GROUND_SERVICE), 2)                 AS ground_service,
    ROUND(AVG(f.WIFI_AND_CONNECTIVITY), 2)          AS wifi,
    COUNT(f.REVIEW_KEY)                             AS review_count
FROM SKYTRAX_REVIEWS_DB.MARTS.FCT_REVIEW f
JOIN SKYTRAX_REVIEWS_DB.MARTS.DIM_AIRLINE a ON f.AIRLINE_ID    = a.AIRLINE_ID
JOIN SKYTRAX_REVIEWS_DB.MARTS.DIM_DATE    d ON f.DATE_FLOWN_ID = d.DATE_ID
WHERE a.AIRLINE_NAME = 'Delta Air Lines'
    AND f.IS_VERIFIED = TRUE
GROUP BY d.CAL_YEAR, d.CAL_QUARTER
ORDER BY d.CAL_YEAR, d.CAL_QUARTER;