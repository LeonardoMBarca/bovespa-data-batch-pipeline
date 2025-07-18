import subprocess
import sys
import os

def instalar_requisitos():
    requirements_path = "/home/ec2-user/app/requirements.txt"
    
    if os.path.exists(requirements_path):
        print("Instalando dependências do requirements.txt via subprocess...")
        with open(requirements_path) as f:
            for line in f:
                pacote = line.strip()
                if pacote and not pacote.startswith('#'):
                    try:
                        print(f"Instalando: {pacote}")
                        subprocess.check_call([sys.executable, "-m", "pip", "install", "--user", pacote])
                    except subprocess.CalledProcessError as e:
                        print(f"Erro ao instalar {pacote}: {e}")
    else:
        print("Arquivo requirements.txt não encontrado.")

# Instalar dependências antes de qualquer outra importação
instalar_requisitos()
print("✅ Dependências instaladas")

import json
import requests
import boto3
import os
import time
import traceback
from datetime import datetime
from dotenv import load_dotenv

print("✅ Lendo variáveis de ambiente")

load_dotenv("/home/ec2-user/app/.env")

FIREHOSE_STREAM_NAME = os.getenv("FIREHOSE_STREAM_NAME", "")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

print(f"FIREHOSE_STREAM_NAME: {FIREHOSE_STREAM_NAME}")
print(f"AWS_REGION: {AWS_REGION}")

firehose = boto3.client('firehose', region_name=AWS_REGION)

def enviar_para_firehose(payload: dict):
    try:
        json_data = json.dumps(payload)
        result = firehose.put_record(
            DeliveryStreamName=FIREHOSE_STREAM_NAME,
            Record={"Data": json_data + "\n"}
        )
        print(f"[{datetime.now()}] Dados enviados ao Firehose. RecordId: {result.get('RecordId')}")
    except Exception as e:
        print(f"[{datetime.now()}] Falha ao enviar dados para o Firehose: {e}")

def coletar_e_enviar():
    url = "https://cointradermonitor.com/api/pbb/v1/ticker"
    try:
        if not FIREHOSE_STREAM_NAME:
            raise ValueError("FIREHOSE_STREAM_NAME não está definido")

        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        data["timestamp_utc"] = datetime.utcnow().isoformat()
        data["type"] = "ticker_data"

        print(f"[{datetime.now()}] Tentando enviar dados para o stream: {FIREHOSE_STREAM_NAME}")
        enviar_para_firehose(data)

    except Exception as e:
        error_payload = {
            "type": "error",
            "timestamp_utc": datetime.utcnow().isoformat(),
            "error_message": str(e),
            "stack_trace": traceback.format_exc()
        }
        print(f"[{datetime.now()}] Erro ao coletar/enviar dados: {e}")
        enviar_para_firehose(error_payload)

if __name__ == "__main__":
    print(f"[{datetime.now()}] Iniciando script com as seguintes configurações:")
    print(f"[{datetime.now()}] FIREHOSE_STREAM_NAME: {FIREHOSE_STREAM_NAME}")
    print(f"[{datetime.now()}] AWS_REGION: {AWS_REGION}")
    
    try:
        sts = boto3.client('sts', region_name=AWS_REGION)
        identity = sts.get_caller_identity()
        print(f"[{datetime.now()}] AWS Identity: {identity['Account']}")
    except Exception as e:
        print(f"[{datetime.now()}] ERRO: Credenciais AWS não configuradas corretamente: {e}")
    
    while True:
        try:
            coletar_e_enviar()
        except Exception as e:
            print(f"[{datetime.now()}] Erro não tratado: {e}")
            error_payload = {
                "type": "unhandled_error",
                "timestamp_utc": datetime.utcnow().isoformat(),
                "error_message": str(e),
                "stack_trace": traceback.format_exc()
            }
            enviar_para_firehose(error_payload)

        print(f"[{datetime.now()}] Aguardando 60 segundos para próxima coleta...")
        time.sleep(60)
