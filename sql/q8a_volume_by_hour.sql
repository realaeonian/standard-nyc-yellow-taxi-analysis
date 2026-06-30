SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS hour,
    COUNT(*) AS trips,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY EXTRACT(YEAR FROM tpep_pickup_datetime)), 2) AS pct_of_year
FROM taxi_trips
GROUP BY year, hour
ORDER BY year, hour;