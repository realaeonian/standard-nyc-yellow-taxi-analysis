SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    ROUND((SUM(tip_amount) / SUM(fare_amount) * 100)::numeric, 2) AS tip_pct
FROM taxi_trips
WHERE payment_type = 1
GROUP BY year
ORDER BY year;