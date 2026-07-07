-- Q9: Top 10 pickup zones by trips + share of year total

-- 2025
SELECT
    z.zone,
    COUNT(*) AS trips,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM taxi_trips WHERE EXTRACT(YEAR FROM tpep_pickup_datetime) = 2025), 2) AS pct
FROM taxi_trips t
JOIN taxi_zones z ON t.pulocationid = z.locationid
WHERE EXTRACT(YEAR FROM t.tpep_pickup_datetime) = 2025
GROUP BY z.zone
ORDER BY trips DESC
LIMIT 10;

-- 2026
SELECT
    z.zone,
    COUNT(*) AS trips,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM taxi_trips WHERE EXTRACT(YEAR FROM tpep_pickup_datetime) = 2026), 2) AS pct
FROM taxi_trips t
JOIN taxi_zones z ON t.pulocationid = z.locationid
WHERE EXTRACT(YEAR FROM t.tpep_pickup_datetime) = 2026
GROUP BY z.zone
ORDER BY trips DESC
LIMIT 10;