# Standard NYC Yellow Taxi — YoY Analysis (Q1 2025 vs Q1 2026)

Year-over-year analysis of standard NYC Yellow Taxi trips, comparing the first
quarter (January–March) of 2025 against the same period in 2026.

## Research Questions

1. Did the number of trips grow or decline?
2. Did the payment split (card vs cash) change?
3. How did fare per trip change — average and median?
4. How did total revenue change, and was it driven by volume or price?
5. How did fare per mile change?
6. How did distance, duration and average speed change?
7. Did the tip percentage relative to fare change? (card trips only)
8. How did trip volume change by time of day and weekday vs weekend?
9. Which pickup/dropoff zones were most popular, and did the ranking shift?

## Data Source

Data comes from the NYC Taxi & Limousine Commission (TLC) Trip Record Data,
published monthly in Parquet format:
https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

This analysis uses six monthly Yellow Taxi files (2025-01 to 2025-03 and
2026-01 to 2026-03) plus the official taxi zone lookup table.

### Scope

This analysis examines **standard trips only**: `payment_type IN (1, 2)`
(credit card and cash). Flex Fare trips (`payment_type 0`) are excluded as a
deliberate methodological decision — they use a separate pricing system and are
not comparable to standard metered trips.