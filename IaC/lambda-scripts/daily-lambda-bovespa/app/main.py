from scraper.downloader import download_base
from scraper.upload import csv_to_parquet, upload_to_s3
from datetime import datetime
import os
import json

DOWNLOAD_DIR = "b3/raw"

def handler(event, context):
    try:
        csv_content = download_base()
        pregao_date = csv_to_parquet(csv_content)
        upload_to_s3(pregao_date)
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Success', 'date': pregao_date})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }