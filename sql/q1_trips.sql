SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    COUNT(*) AS trips
FROM taxi_trips
GROUP BY year
ORDER BY year;