SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    ROUND(AVG(fare_amount)::numeric, 2) AS avg_fare,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fare_amount)::numeric, 2) AS median_fare
FROM taxi_trips
GROUP BY year
ORDER BY year;