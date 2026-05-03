SELECT
    -- identifiers
    f.REVIEW_KEY,
    f.REVIEW_ID,

    -- the main text
    f.REVIEW_TEXT,

    -- review context (useful for filtering/segmenting NLP results)
    f.AVERAGE_RATING,
    f.RATING_BAND,
    f.RECOMMENDED,
    f.SEAT_TYPE,
    f.TYPE_OF_TRAVELLER,
    f.HAS_LAYOVER,
    f.IS_VERIFIED,

    -- dimension scores (correlate with text sentiment)
    f.SEAT_COMFORT,
    f.CABIN_STAFF_SERVICE,
    f.FOOD_AND_BEVERAGES,
    f.INFLIGHT_ENTERTAINMENT,
    f.GROUND_SERVICE,
    f.WIFI_AND_CONNECTIVITY,
    f.VALUE_FOR_MONEY,

    -- who wrote it
    c.NATIONALITY,
    c.NUMBER_OF_FLIGHTS,

    -- when they flew
    d.CAL_YEAR,
    d.CAL_QUARTER,
    d.CAL_MONTH,

    -- airline (useful if you expand beyond Delta later)
    a.AIRLINE_NAME_CLEANED

FROM MARTS.FCT_REVIEW f
JOIN MARTS.DIM_AIRLINE  a ON f.AIRLINE_ID    = a.AIRLINE_ID
JOIN MARTS.DIM_CUSTOMER c ON f.CUSTOMER_ID   = c.CUSTOMER_ID
JOIN MARTS.DIM_DATE     d ON f.DATE_FLOWN_ID = d.DATE_ID
WHERE a.AIRLINE_NAME  = 'Delta Air Lines'
    AND f.IS_VERIFIED = TRUE
    AND f.REVIEW_TEXT IS NOT NULL
    AND LENGTH(TRIM(f.REVIEW_TEXT)) > 20   -- filter out near-empty strings
ORDER BY d.CAL_YEAR DESC, f.REVIEW_KEY;