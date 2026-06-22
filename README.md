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

## Exploratory Data Analysis (EDA)

EDA was performed on all six monthly files before any cleaning. The goal at this
stage was only to understand the data and document problems — no rows were
removed and no cleaning decisions were made here.

### What was done
- Loaded each of the six Parquet files (2025-01 to 2025-03, 2026-01 to 2026-03).
- Compared the schema across all files using `df.info()`.
- Reviewed value ranges with `df.describe()` (focus on `fare_amount` and
  `trip_distance`).
- Counted missing values per column with `df.isnull().sum()`.
- Examined the `payment_type` distribution with `value_counts(normalize=True)`.

### What was observed

**Schema is consistent across all six files.** All files have the same 20
columns with identical data types, so combining them later will be safe (no
type-mismatch issues between months).

**Missing values cluster together.** The same five columns are always null
together — `passenger_count`, `RatecodeID`, `store_and_fwd_flag`,
`congestion_surcharge`, and `Airport_fee` — and always with an identical count
per file. This suggests the gaps come from a specific record type rather than
random missing data. The scale is significant: roughly 15–30% of rows per file.

**Invalid timestamps exist.** Some files contain pickup dates far outside their
month — for example, trips dated 2007 and 2008 appear in the March files. Some
dropoff times also fall slightly outside the file's month. Dates will need to be
constrained to the actual study period.

**Negative and extreme monetary values.** `fare_amount` and `total_amount` both
have negative minimums (down to about -2,555) and absurd maximums (e.g.
`fare_amount` up to ~863,000 in 2025-01). However, the 25th–75th percentiles are
normal (~8.6–27 USD), so the typical trip looks reasonable while both tails are
problematic.

**Impossible trip distances.** `trip_distance` has a median of ~1.7–1.8 miles
across all files, but maximums reach into the hundreds of thousands of miles,
which is physically impossible. Minimum distance is 0 (zero-distance trips also
exist).

**payment_type distribution and Flex Fare growth.** Flex Fare trips
(`payment_type 0`) make up a large and growing share: roughly 15–22% in 2025 and
24–30% in 2026. This is direct evidence supporting the scope decision to exclude
them — their share shifted noticeably year over year, so mixing them in could
create an apparent YoY change unrelated to standard metered trips. Payment types
3, 4, and 5 (no charge, dispute, unknown) are small (~2–3% combined) and likely
account for some of the negative monetary values; they fall outside the scope
(payment_type 1, 2) as well.

**Note on fare medians.** The raw median `fare_amount` appears higher in 2026
than in 2025. This is only a preliminary observation on raw, unfiltered data and
is not a conclusion — it will be properly tested in the analysis stage on cleaned,
scoped data.

### Scope impact

Applying the scope filter (`payment_type IN (1, 2)`) removes Flex Fare and other
non-standard payment types before any cleaning:

| File | Raw rows | After scope | Removed | % removed |
|---|---|---|---|---|
| 2025-01 | 3,475,226 | 2,834,822 | 640,404 | 18.4% |
| 2025-02 | 3,577,543 | 2,675,656 | 901,887 | 25.2% |
| 2025-03 | 4,145,257 | 3,110,013 | 1,035,244 | 25.0% |
| 2026-01 | 3,724,889 | 2,563,790 | 1,161,099 | 31.2% |
| 2026-02 | 3,399,866 | 2,325,277 | 1,074,589 | 31.6% |
| 2026-03 | 3,952,451 | 2,962,371 | 990,080 | 25.1% |