SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    CASE
        WHEN EXTRACT(DOW FROM tpep_pickup_datetime) IN (0, 6) THEN 'weekend'
        ELSE 'weekday'
    END AS day_type,
    COUNT(*) AS trips,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY EXTRACT(YEAR FROM tpep_pickup_datetime)), 2) AS pct_of_year
FROM taxi_trips
GROUP BY year, day_type
ORDER BY year, day_type;