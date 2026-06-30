SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY trip_distance)::numeric, 2) AS median_distance,
    ROUND(AVG(duration_min)::numeric, 2) AS avg_duration,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration_min)::numeric, 2) AS median_duration,
    ROUND(AVG(speed_mph)::numeric, 2) AS avg_speed,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY speed_mph)::numeric, 2) AS median_speed
FROM taxi_trips
GROUP BY year
ORDER BY year;