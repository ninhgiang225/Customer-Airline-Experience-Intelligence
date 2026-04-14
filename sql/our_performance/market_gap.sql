WITH all_airlines AS (
    SELECT
        a.AIRLINE_NAME,
        AVG(f.SEAT_COMFORT)           AS seat_comfort,
        AVG(f.CABIN_STAFF_SERVICE)    AS cabin_staff,
        AVG(f.FOOD_AND_BEVERAGES)     AS food,
        AVG(f.INFLIGHT_ENTERTAINMENT) AS entertainment,
        AVG(f.GROUND_SERVICE)         AS ground_service,
        AVG(f.WIFI_AND_CONNECTIVITY)  AS wifi,
        AVG(f.VALUE_FOR_MONEY)        AS value_for_money
    FROM MARTS.FCT_REVIEW f
    JOIN MARTS.DIM_AIRLINE a ON f.AIRLINE_ID = a.AIRLINE_ID
    WHERE f.IS_VERIFIED = TRUE
    GROUP BY a.AIRLINE_NAME
    HAVING COUNT(f.REVIEW_KEY) >= 200
),
market_avg AS (
    SELECT
        AVG(seat_comfort)    AS mkt_seat,
        AVG(cabin_staff)     AS mkt_staff,
        AVG(food)            AS mkt_food,
        AVG(entertainment)   AS mkt_entertainment,
        AVG(ground_service)  AS mkt_ground,
        AVG(wifi)            AS mkt_wifi,
        AVG(value_for_money) AS mkt_value
    FROM all_airlines
),
delta_scores AS (
    SELECT * FROM all_airlines
    WHERE AIRLINE_NAME = 'Delta Air Lines'
)

SELECT
    'Seat Comfort'    AS dimension, ROUND(d.seat_comfort    - m.mkt_seat, 2)          AS gap FROM delta_scores d CROSS JOIN market_avg m
UNION ALL SELECT 'Cabin Staff',    ROUND(d.cabin_staff     - m.mkt_staff, 2)          FROM delta_scores d CROSS JOIN market_avg m
UNION ALL SELECT 'Food',           ROUND(d.food            - m.mkt_food, 2)           FROM delta_scores d CROSS JOIN market_avg m
UNION ALL SELECT 'Entertainment',  ROUND(d.entertainment   - m.mkt_entertainment, 2)  FROM delta_scores d CROSS JOIN market_avg m
UNION ALL SELECT 'Ground Service', ROUND(d.ground_service  - m.mkt_ground, 2)         FROM delta_scores d CROSS JOIN market_avg m
UNION ALL SELECT 'WiFi',           ROUND(d.wifi            - m.mkt_wifi, 2)           FROM delta_scores d CROSS JOIN market_avg m
UNION ALL SELECT 'Value for Money',ROUND(d.value_for_money - m.mkt_value, 2)          FROM delta_scores d CROSS JOIN market_avg m;