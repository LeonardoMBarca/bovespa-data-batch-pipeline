import json
import requests
import boto3
import os
import time
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

FIREHOSE_STREAM_NAME = os.getenv("FIREHOSE_STREAM_NAME")

firehose = boto3.client('firehose')

def coletar_e_enviar():
    url = "https://cointradermonitor.com/api/pbb/v1/ticker"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()

        data["timestamp_utc"] = datetime.utcnow().isoformat()

        json_data = json.dumps(data)

        firehose.put_record(
            DeliveryStreamName=FIREHOSE_STREAM_NAME,
            Record={"Data": json_data + "\n"}
        )

        print(f"[{datetime.now()}] Dados enviados para o Firehose com sucesso.")
    
    except Exception as e:
        print(f"[{datetime.now()}] Erro: {e}")

if __name__ == "__main__":
    while True:
        coletar_e_enviar()
        time.sleep(60)
