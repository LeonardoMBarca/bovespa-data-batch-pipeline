import boto3
import os
import json
import urllib.parse

s3 = boto3.client('s3')

DEST_BUCKET = os.environ.get("BACKUP_BUCKET_NAME")

def handler(event):
    for record in event['Records']:
        try:
            body = json.loads(record['body'])
            source_bucket = body['source_bucket']
            key = urllib.parse.unquote_plus(body['object_key'])

            print(f"Copiando {key} de {source_bucket} para {DEST_BUCKET}")

            # Caminho temporário para download
            download_path = f"/tmp/{os.path.basename(key)}"

            s3.download_file(source_bucket, key, download_path)

            s3.upload_file(download_path, DEST_BUCKET, key)

            print(f"Arquivo {key} copiado com sucesso para {DEST_BUCKET}")

        except Exception as e:
            print(f"Erro ao processar mensagem: {e}")
