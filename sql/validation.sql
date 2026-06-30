-- Validation tests for taxi_trips
-- Every COUNT below must return 0; the row-count check must match the load output.

-- 1. No NULLs in any kept column
SELECT
    COUNT(*) - COUNT(tpep_pickup_datetime)  AS pickup_nulls,
    COUNT(*) - COUNT(tpep_dropoff_datetime) AS dropoff_nulls,
    COUNT(*) - COUNT(payment_type)          AS payment_nulls,
    COUNT(*) - COUNT(fare_amount)           AS fare_nulls,
    COUNT(*) - COUNT(total_amount)          AS total_nulls,
    COUNT(*) - COUNT(trip_distance)         AS distance_nulls,
    COUNT(*) - COUNT(tip_amount)            AS tip_nulls,
    COUNT(*) - COUNT(tolls_amount)          AS tolls_nulls,
    COUNT(*) - COUNT(duration_min)          AS duration_nulls,
    COUNT(*) - COUNT(speed_mph)             AS speed_nulls,
    COUNT(*) - COUNT(pulocationid)          AS pu_nulls,
    COUNT(*) - COUNT(dolocationid)          AS do_nulls
FROM taxi_trips;

-- 2. Cleaning filters held (all must be 0)
SELECT
    COUNT(*) FILTER (WHERE fare_amount < 3)                   AS bad_fare,
    COUNT(*) FILTER (WHERE duration_min < 1)                  AS bad_duration,
    COUNT(*) FILTER (WHERE speed_mph <= 1 OR speed_mph > 100) AS bad_speed,
    COUNT(*) FILTER (WHERE payment_type NOT IN (1, 2))        AS bad_payment
FROM taxi_trips;

-- 3. Dropoff is always after pickup (must be 0)
SELECT COUNT(*) AS bad_timestamps
FROM taxi_trips
WHERE tpep_dropoff_datetime <= tpep_pickup_datetime;

-- 4. Pickup dates stay within the study period (expect 2025-01-01 .. 2026-03-31)
SELECT MIN(tpep_pickup_datetime) AS earliest, MAX(tpep_pickup_datetime) AS latest
FROM taxi_trips;

-- 5. Total row count (must equal load output: 16,024,118)
SELECT COUNT(*) AS total_rows FROM taxi_trips;