import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

from clean import clean_df, files

load_dotenv()
engine = create_engine(os.getenv("DATABASE_URL"))

for i, file in enumerate(files):
    year = int(file[16:20])
    month = int(file[21:23])
    df = pd.read_parquet(f"data/{file}")
    df = clean_df(df, year, month)
    df.columns = df.columns.str.lower()
    mode = "replace" if i == 0 else "append"
    df.to_sql("taxi_trips", engine, if_exists=mode, index=False)
    print(file, "loaded:", len(df))

zones = pd.read_csv("data/taxi_zone_lookup.csv")
zones.columns = zones.columns.str.lower()
zones.to_sql("taxi_zones", engine, if_exists="replace", index=False)
print("zones loaded:", len(zones))