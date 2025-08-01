import boto3
import os
import json
import concurrent.futures
from datetime import datetime

s3 = boto3.client('s3')
sqs = boto3.client('sqs')
lambda_client = boto3.client('lambda')

SOURCE_BUCKET = os.environ.get("SOURCE_BUCKET_NAME")
BACKUP_BUCKET = os.environ.get("BACKUP_BUCKET_NAME")
QUEUE_URL = os.environ.get("SQS_QUEUE_URL")

def process_batch(messages):
    backup_count = 0
    for message in messages:
        try:
            body = json.loads(message['Body'])
            for s3_record in body['Records']:
                object_key = s3_record['s3']['object']['key']
                
                if object_key.startswith('bitcoin-data/'):
                    backup_key = object_key.replace('bitcoin-data/', 'backup-data/')
                    
                    s3.copy_object(
                        CopySource={'Bucket': SOURCE_BUCKET, 'Key': object_key},
                        Bucket=BACKUP_BUCKET,
                        Key=backup_key
                    )
                    
                    backup_count += 1
                    print(f"Arquivo {object_key} copiado")
            
            sqs.delete_message(
                QueueUrl=QUEUE_URL,
                ReceiptHandle=message['ReceiptHandle']
            )
        except Exception as e:
            print(f"Erro processando mensagem: {e}")
    
    return backup_count

def handler(event, context):
    try:
        print(f"Iniciando backup - {datetime.now()}")
        print(f"Event: {json.dumps(event, default=str)}")
        
        # Coleta todas as mensagens
        all_messages = []
        while len(all_messages) < 1000:  # Limite para evitar timeout
            response = sqs.receive_message(
                QueueUrl=QUEUE_URL,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=1
            )
            
            if 'Messages' not in response:
                break
            all_messages.extend(response['Messages'])
        
        if not all_messages:
            print("Nenhuma mensagem para processar")
            return {"statusCode": 200, "body": "Nenhuma mensagem encontrada"}
        
        # Divide em lotes para processamento paralelo
        batch_size = 50
        batches = [all_messages[i:i+batch_size] for i in range(0, len(all_messages), batch_size)]
        
        total_count = 0
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(process_batch, batch) for batch in batches]
            for future in concurrent.futures.as_completed(futures):
                total_count += future.result()
        
        result = f"Backup concluído: {total_count} arquivos processados"
        print(result)
        return {"statusCode": 200, "body": result}
        
    except Exception as e:
        error_msg = f"Erro no backup: {e}"
        print(error_msg)
        return {"statusCode": 500, "body": error_msg}