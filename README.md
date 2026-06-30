# Standard NYC Yellow Taxi — YoY Analysis (Q1 2025 vs Q1 2026)

Year-over-year analysis of standard NYC Yellow Taxi trips, comparing the first
quarter (January–March) of 2025 against the same period in 2026.

## Research Questions

1. Did the number of trips grow or decline?
2. Did the payment split (card vs cash) change?
3. How did fare per trip change — average and median?
4. How did total revenue change, and was it driven by volume or price?
5. How did fare per mile change?
6. How did distance, duration and speed change — and what does that say about traffic?
7. How did the tip-to-fare ratio change? (card trips only)
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

## Cleaning

After scoping to standard trips, the following quality filters were applied. Each
filter targets a specific problem found during EDA. One filter considered during
EDA was deliberately **not** applied (see below).

Filters are applied in this order: scope (payment_type) → date bounds → duration →
fare → speed. Definition filters (which trips belong in the study) come first;
quality filters (removing broken records) come after. `duration_min` and
`speed_mph` are derived columns, computed before the filters that depend on them.

### Filters applied

| Filter | Rule | Rationale |
|---|---|---|
| Scope | `payment_type IN (1, 2)` | Standard metered trips only; Flex Fare uses separate pricing (see Scope) |
| Date bounds | pickup within the file's month | EDA found pickups dated 2007–2008 and outside the file's month |
| Minimum duration | `duration_min >= 1` | Trips under one minute are not real rides; also removes negative durations (bad timestamps) |
| Minimum fare | `fare_amount >= 3` | NYC base fare is $3.00 (includes negative fares from EDA) |
| Speed bounds | `1 < speed_mph <= 100` | Removes physically impossible speeds. The lower bound also removes zero-distance trips (speed = 0) and stalled-meter trips where the cab barely moves over many hours |

### Rows removed per filter

Rows remaining after each filter, per file:

| File | Raw | After scope | After dates | After duration | After fare | After speed (final) | Kept |
|---|---|---|---|---|---|---|---|
| 2025-01 | 3,475,226 | 2,834,822 | 2,834,800 | 2,809,883 | 2,796,723 | 2,782,410 | 80.1% |
| 2025-02 | 3,577,543 | 2,675,656 | 2,675,625 | 2,649,958 | 2,637,456 | 2,622,664 | 73.3% |
| 2025-03 | 4,145,257 | 3,110,013 | 3,109,980 | 3,062,238 | 3,046,245 | 3,031,010 | 73.1% |
| 2026-01 | 3,724,889 | 2,563,790 | 2,563,785 | 2,493,048 | 2,484,334 | 2,474,157 | 66.4% |
| 2026-02 | 3,399,866 | 2,325,277 | 2,325,261 | 2,262,134 | 2,255,818 | 2,246,117 | 66.1% |
| 2026-03 | 3,952,451 | 2,962,371 | 2,962,352 | 2,883,854 | 2,878,623 | 2,867,760 | 72.6% |

Lower retention in 2026 is driven almost entirely by the scope filter (the growing
Flex Fare share removed before any cleaning), not by quality issues — the quality
filters remove a similar small share in both years.

### Deliberately not applied

- **`RatecodeID = 99` (unknown rate code):** ~41k rows, but `describe()` showed
  these are real trips (median ~6.7 miles, ~$31 fare). The speed filter already
  catches the genuinely broken ones, so dropping all of them would discard valid data.

## Validation

After loading, the data was validated with SQL checks (sql/validation.sql): no NULLs in any kept column, all cleaning filters held (no rows violating fare, duration, speed, or payment_type rules), dropoff always after pickup, pickup dates within the study period, and total row count matching the load output (16,024,118). All checks passed.

## Analysis

Each question is answered by a SQL query in `sql/` (one file per question).
All comparisons are Q1 2025 vs Q1 2026, standard trips only.

### Q1 — Trip volume

| Year | Trips |
|---|---|
| 2025 | 8,436,084 |
| 2026 | 7,588,034 |

Standard trips fell ~10% year over year. Since Flex Fare's share grew over the
same period (see Scope), part of this decline may reflect a shift toward Flex
Fare rather than an overall drop in demand.

### Q2 — Payment split

| Year | Card | Cash | Card % |
|---|---|---|---|
| 2025 | 7,383,431 | 1,052,653 | 87.5% |
| 2026 | 6,717,918 | 870,116 | 88.5% |

The card share rose slightly, from 87.5% to 88.5%. Both card and cash trip counts
fell year over year (overall volume declined, see Q1), but cash fell proportionally
more (−17% vs −9% for card), shifting the mix further toward card payment.

### Q3 — Fare per trip (average and median)

| Year | Avg fare | Median fare |
|---|---|---|
| 2025 | $18.09 | $12.80 |
| 2026 | $19.47 | $13.50 |

Both the average (+7.6%) and median (+5.5%) fare rose, so the increase reflects a
genuine price rise for the typical trip — not just a few expensive outliers pulling
the average up. The average rising slightly faster than the median suggests the
high-fare tail grew a bit more, but the core of the distribution shifted up too.

### Q4 — Revenue and what drove it

Revenue excludes tips (which go to the driver, not the operator).

| Year | Trips | Revenue | Revenue per trip |
|---|---|---|---|
| 2025 | 8,436,084 | $203.3M | $24.10 |
| 2026 | 7,588,034 | $192.6M | $25.39 |

Trips fell 10.0%, but revenue fell only 5.2% — because revenue per trip rose 5.4%.
The price increase offset roughly half the volume decline: operators ran 10% fewer
trips but lost only ~5% of revenue. The change is driven by both forces pulling in
opposite directions, with price partially cushioning the drop in volume.

### Q5 — Fare per mile

| Year | Fare per mile |
|---|---|
| 2025 | $5.65 |
| 2026 | $5.67 |

Computed as SUM(fare) / SUM(distance) — a distance-weighted rate that avoids the
distortion of very short trips (where fare/distance explodes). Fare per mile was
essentially flat (+0.4%). Combined with Q3 (fare per trip up ~5–7%), this suggests
the higher per-trip fares come from longer trips rather than a more expensive
service per mile — the rate held, but the typical trip covered more ground. Q6
tests this directly via distance.

### Q6 — Distance, duration, speed (average and median)

| Year | Avg dist | Med dist | Avg dur | Med dur | Avg speed | Med speed |
|---|---|---|---|---|---|---|
| 2025 | 3.20 | 1.66 | 15.12 | 11.68 | 11.11 | 9.45 |
| 2026 | 3.44 | 1.70 | 17.34 | 12.75 | 10.61 | 8.95 |

Distance rose only slightly (median +2.4%), but duration rose much more (median
+9.2%), so speed fell (median −5.3%). The typical trip covers about the same ground
but takes noticeably longer — consistent with worsening traffic. Average and median
move the same direction, so the slowdown is real, not a tail artifact. This also
completes Q5: since fare per mile was flat and distance barely grew, the higher
per-trip fares are driven largely by longer trip times (the fare's time component),
not by longer distances or a higher per-mile rate.

