import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.width", None)

files = [
    "yellow_tripdata_2025-01.parquet",
    "yellow_tripdata_2025-02.parquet",
    "yellow_tripdata_2025-03.parquet",
    "yellow_tripdata_2026-01.parquet",
    "yellow_tripdata_2026-02.parquet",
    "yellow_tripdata_2026-03.parquet",
]

for file in files:
    df = pd.read_parquet(f"data/{file}")
    print(f"\n===== {file} =====")
    df.info()
    print(df[["fare_amount", "trip_distance"]].describe())
    print(df.isnull().sum())
    print(df["payment_type"].value_counts(normalize=True))