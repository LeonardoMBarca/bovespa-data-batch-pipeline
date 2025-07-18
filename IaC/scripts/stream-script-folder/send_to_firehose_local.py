import json
import boto3
import argparse
import os
from datetime import datetime
from dotenv import load_dotenv

# Carrega variáveis de ambiente do arquivo .env.stream
load_dotenv(".env.stream")

def send_to_firehose(stream_name, region, data_file=None):
    """
    Envia dados para um Firehose Delivery Stream
    
    Args:
        stream_name (str): Nome do Firehose Delivery Stream
        region (str): Região AWS
        data_file (str, optional): Caminho para arquivo JSON com dados a serem enviados
    """
    try:
        # Inicializa o cliente Firehose
        firehose = boto3.client('firehose', region_name=region)
        
        # Prepara os dados
        if data_file:
            with open(data_file, 'r') as f:
                data = json.load(f)
        else:
            # Dados de exemplo
            data = {
                "timestamp": datetime.utcnow().isoformat(),
                "message": "Teste manual de envio para Firehose",
                "source": "script_manual"
            }
        
        # Adiciona timestamp se não existir
        if "timestamp" not in data:
            data["timestamp"] = datetime.utcnow().isoformat()
            
        # Converte para JSON
        json_data = json.dumps(data)
        
        print(f"Enviando dados para o stream '{stream_name}' na região '{region}':")
        print(json_data)
        
        # Envia para o Firehose
        response = firehose.put_record(
            DeliveryStreamName=stream_name,
            Record={"Data": json_data + "\n"}
        )
        
        print(f"\nDados enviados com sucesso!")
        print(f"RecordId: {response['RecordId']}")
        
    except Exception as e:
        print(f"Erro ao enviar dados para Firehose: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Envia dados para um Firehose Delivery Stream')
    parser.add_argument('--stream', '-s', 
                        default=os.getenv("FIREHOSE_STREAM_NAME", "bitcoin-firehose"),
                        help='Nome do Firehose Delivery Stream')
    parser.add_argument('--region', '-r', 
                        default=os.getenv("AWS_REGION", "us-east-1"),
                        help='Região AWS')
    parser.add_argument('--file', '-f', 
                        help='Caminho para arquivo JSON com dados a serem enviados')
    
    args = parser.parse_args()
    
    send_to_firehose(args.stream, args.region, args.file)