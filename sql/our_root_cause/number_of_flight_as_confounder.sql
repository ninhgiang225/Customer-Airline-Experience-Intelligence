SELECT
    CASE
        WHEN c.NUMBER_OF_FLIGHTS >= 11 THEN '>10 flights'
        WHEN c.NUMBER_OF_FLIGHTS >= 5  THEN '5-10 flights'
        WHEN c.NUMBER_OF_FLIGHTS >= 4  THEN '4 flights'
        WHEN c.NUMBER_OF_FLIGHTS >= 3  THEN '3 flights'
        WHEN c.NUMBER_OF_FLIGHTS >= 2  THEN '2 flights'
        ELSE '1 flights'
    END AS flyer_segment,

    COUNT(*) AS total_reviews,

    SUM(CASE 
            WHEN LOWER(f.RATING_BAND) = 'bad' THEN 1 
            ELSE 0 
        END) AS bad_review_count,

    ROUND(
        SUM(CASE 
                WHEN LOWER(f.RATING_BAND) = 'bad' THEN 1 
                ELSE 0 
            END
        ) / NULLIF(COUNT(*), 0),
    3) AS pct_bad_reviews

FROM MARTS.FCT_REVIEW f
JOIN MARTS.DIM_AIRLINE  a ON f.AIRLINE_ID  = a.AIRLINE_ID
JOIN MARTS.DIM_CUSTOMER c ON f.CUSTOMER_ID = c.CUSTOMER_ID

WHERE a.AIRLINE_NAME = 'Delta Air Lines'
    AND f.IS_VERIFIED = TRUE   -- ❗ removed bad filter here

GROUP BY flyer_segment
ORDER BY pct_bad_reviews DESC;