import os
import logging
import pandas as pd
import boto3
from datetime import datetime

BUCKET_NAME = os.environ.get("BUCKET_NAME", "")
S3_PREFIX = S3_PREFIX = "raw/"
DOWNLOAD_DIR = "b3/raw"

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def csv_to_parquet(csv_content):
    try:
        from io import StringIO
        
        lines = csv_content.strip().split('\n')
        primeira_linha = lines[0]
        data_pregao_br = primeira_linha.strip().split()[-1]
        try:
            pregao_date = datetime.strptime(data_pregao_br, "%d/%m/%y").date().isoformat()
        except Exception:
            pregao_date = datetime.today().strftime("%Y-%m-%d")

        df = pd.read_csv(
            StringIO(csv_content),
            sep=";",
            encoding="latin1",
            skiprows=1,
            skipfooter=2,
            engine="python",
            index_col=False
        )
        df.columns = ["codigo", "acao", "tipo", "qtd_teorica", "part", ""][:df.shape[1]]
        if "" in df.columns:
            df = df.drop(columns=[""])
        df["tipo"] = df["tipo"].str.strip()
        df["data_pregao"] = pregao_date

        # Conversão de campos numéricos:
        df["qtd_teorica"] = df["qtd_teorica"].str.replace(".", "", regex=False)
        df["qtd_teorica"] = df["qtd_teorica"].str.replace(",", ".", regex=False)
        df["qtd_teorica"] = pd.to_numeric(df["qtd_teorica"], errors="coerce")

        df["part"] = df["part"].str.replace(",", ".", regex=False)
        df["part"] = pd.to_numeric(df["part"], errors="coerce")

        df = df.dropna(how="all")
        
        # Armazenar DataFrame globalmente para upload
        global processed_df
        processed_df = df
        
        logging.info(f"Parquet processado para data: {pregao_date}")
        return pregao_date

    except Exception as e:
        logging.error(f"Falha na conversão para Parquet: {e}")
        raise



def upload_to_s3(pregao_date):
    """
    Faz upload do DataFrame processado para o S3 como parquet.
    """
    try:
        global processed_df
        s3_key = f"{S3_PREFIX}pregao={pregao_date}/IBOV.parquet"
        
        # Converter DataFrame para parquet em memória
        parquet_buffer = processed_df.to_parquet(index=False)
        
        s3 = boto3.client('s3')
        s3.put_object(Bucket=BUCKET_NAME, Key=s3_key, Body=parquet_buffer)
        
        logging.info(f"Arquivo Parquet enviado ao S3 em {s3_key}")
    except Exception as e:
        logging.error(f"Falha ao enviar arquivo ao S3: {e}")
        raise
