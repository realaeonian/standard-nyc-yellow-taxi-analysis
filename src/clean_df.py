import pandas as pd

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
    print(file, "raw:", len(df))
    df = df[df["payment_type"].isin([1, 2])]
    print(file, "after scope:", len(df))

