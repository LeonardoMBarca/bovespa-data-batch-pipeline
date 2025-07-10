import os
import requests
import base64
from datetime import datetime
from config import IBOV_URL, DOWNLOAD_DIR
import shutil

def clear_data(path: str):
    if os.path.exists(path):
        shutil.rmtree(path)
    os.makedirs(path, exist_ok=True)

def download_base():
    clear_data(DOWNLOAD_DIR)
    today = datetime.today().strftime("%Y-%m-%d")
    output_dir = os.path.join(DOWNLOAD_DIR, f"date={today}")
    os.makedirs(output_dir, exist_ok=True)

    url_dict = IBOV_URL if isinstance(IBOV_URL, dict) else {'IBOV': IBOV_URL}
    for name, url in url_dict.items():
        try:
            filepath = os.path.join(output_dir, f"{name}.csv")
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            # Decodifica base64 se necessário
            try:
                content = base64.b64decode(response.content)
            except Exception:
                content = response.content
            with open(filepath, "wb") as f:
                f.write(content)
            print(f"✅ Download: {filepath}")
        except Exception as e:
            print(f"❌ Erro ao baixar {name}: {e}")

if __name__ == "__main__":
    download_base()
