import os
import logging
import pandas as pd
import boto3
from datetime import datetime
from config import DOWNLOAD_DIR, LOG_FILE, S3_BUCKET, S3_PREFIX

os.makedirs(DOWNLOAD_DIR, exist_ok=True)
os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)

logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def csv_to_parquet(csv_path):
    try:
        with open(csv_path, encoding="latin1") as f:
            primeira_linha = f.readline()
            data_pregao_br = primeira_linha.strip().split()[-1]
            try:
                pregao_date = datetime.strptime(data_pregao_br, "%d/%m/%y").date().isoformat()
            except Exception:
                pregao_date = datetime.today().strftime("%Y-%m-%d")

        df = pd.read_csv(
            csv_path,
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
        df["qtd_teorica"] = df["qtd_teorica"].str.replace(".", "", regex=False)  # remove pontos dos milhares
        df["qtd_teorica"] = df["qtd_teorica"].str.replace(",", ".", regex=False)
        df["qtd_teorica"] = pd.to_numeric(df["qtd_teorica"], errors="coerce")

        df["part"] = df["part"].str.replace(",", ".", regex=False)
        df["part"] = pd.to_numeric(df["part"], errors="coerce")

        df = df.dropna(how="all")

        parquet_dir = os.path.join("data/bronze-layer", f"pregao={pregao_date}")
        os.makedirs(parquet_dir, exist_ok=True)
        parquet_path = os.path.join(parquet_dir, "IBOV.parquet")
        if os.path.exists(parquet_path):
            os.remove(parquet_path)
        df.to_parquet(parquet_path, index=False)
        print(f"Parquet gerado em: {parquet_path}")
        return parquet_path, pregao_date

    except Exception as e:
        print(f"[ERRO] Falha na conversão para Parquet: {e}")
        return None, None



def upload_to_s3(parquet_path, pregao_date):
    """
    Faz upload do arquivo parquet para o S3, na partição do dia.
    """
    try:
        s3_key = f"{S3_PREFIX}/pregao={pregao_date}/IBOV.parquet"
        s3 = boto3.client('s3')
        s3.upload_file(parquet_path, S3_BUCKET, s3_key)
        logging.info(f"Arquivo Parquet enviado ao S3 em {s3_key}")
        print(f"Arquivo Parquet enviado ao S3 em {s3_key}")
    except Exception as e:
        logging.error(f"[ERRO] Falha ao enviar arquivo ao S3: {e}")
        print(f"[ERRO] Falha ao enviar arquivo ao S3: {e}")
