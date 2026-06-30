SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    ROUND((SUM(fare_amount) / SUM(trip_distance))::numeric, 2) AS fare_per_mile
FROM taxi_trips
GROUP BY year
ORDER BY year;