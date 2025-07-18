import json
import requests
import time
from datetime import datetime

def coletar_e_exibir():
    url = "https://cointradermonitor.com/api/pbb/v1/ticker"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()

        data["timestamp_utc"] = datetime.utcnow().isoformat()

        json_data = json.dumps(data, ensure_ascii=False, indent=2)

        print(f"[{datetime.now()}] Dados coletados com sucesso:")
        print(json_data)

    except Exception as e:
        print(f"[{datetime.now()}] Erro ao coletar dados: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    print(f"[{datetime.now()}] Iniciando coleta local de dados para teste...")

    while True:
        try:
            coletar_e_exibir()
        except Exception as e:
            print(f"[{datetime.now()}] Erro não tratado: {e}")

        print(f"[{datetime.now()}] Aguardando 60 segundos para a próxima coleta...\n")
        time.sleep(2)
