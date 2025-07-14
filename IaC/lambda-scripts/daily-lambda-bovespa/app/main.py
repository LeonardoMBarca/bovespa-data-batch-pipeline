from scraper.downloader import download_base
from scraper.upload import csv_to_parquet, upload_to_s3
from datetime import datetime
import os
import requests
import pyarrow
import pandas

DOWNLOAD_DIR = "b3/raw"

def handler(event, context):
    download_base()
    today = datetime.today().strftime("%Y-%m-%d")
    csv_dir = os.path.join(DOWNLOAD_DIR, f"date={today}")
    csv_path = os.path.join(csv_dir, "IBOV.csv")
    parquet_path, pregao_date = csv_to_parquet(csv_path)
    if parquet_path:
        upload_to_s3(parquet_path, pregao_date)