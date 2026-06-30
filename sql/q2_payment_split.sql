SELECT
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    COUNT(*) FILTER (WHERE payment_type = 1) AS card,
    COUNT(*) FILTER (WHERE payment_type = 2) AS cash,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_type = 1) / COUNT(*), 1) AS card_pct
FROM taxi_trips
GROUP BY year
ORDER BY year;