SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    COUNT(*) AS trips,
    ROUND(SUM(total_amount - tip_amount)::numeric, 2) AS revenue,
    ROUND(AVG(total_amount - tip_amount)::numeric, 2) AS avg_per_trip
FROM taxi_trips
GROUP BY year
ORDER BY year;