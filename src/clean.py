import pandas as pd

files = [
    "yellow_tripdata_2025-01.parquet",
    "yellow_tripdata_2025-02.parquet",
    "yellow_tripdata_2025-03.parquet",
    "yellow_tripdata_2026-01.parquet",
    "yellow_tripdata_2026-02.parquet",
    "yellow_tripdata_2026-03.parquet",
]


def clean_df(df, year, month):
    label = f"{year}-{month:02d}"
    print(label, "raw:", len(df))
    df = df[df["payment_type"].isin([1, 2])]
    print(label, "after scope:", len(df))
    df = df[(df["tpep_pickup_datetime"] >= f"{year}-{month}-01") & (df["tpep_pickup_datetime"] < f"{year}-{month + 1}-01")]
    print(label, "after dates:", len(df))
    df["duration_min"] = (df["tpep_dropoff_datetime"] - df["tpep_pickup_datetime"]).dt.total_seconds() / 60
    df = df[df["duration_min"] >= 1]
    print(label, "after duration_min >= 1:", len(df))
    df = df[df["fare_amount"] >= 3]
    print(label, "after fare_amount >= 3:", len(df))
    df["speed_mph"] = df["trip_distance"] / (df["duration_min"] / 60)
    df = df[(df["speed_mph"] > 1) & (df["speed_mph"] <= 100)]
    print(label, "after speed:", len(df))
    return df
        

for file in files:
    year = int(file[16:20])
    month = int(file[21:23])
    df = pd.read_parquet(f"data/{file}")
    df = clean_df(df, year, month)
    print(f"{year}-{month}: {len(df)} eilučių")