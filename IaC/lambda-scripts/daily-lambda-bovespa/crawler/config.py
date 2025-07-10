# config.py

# URL da página do IBOVESPA na B3 (usada pelo scraper para automação)
IBOV_URL = "https://sistemaswebb3-listados.b3.com.br/indexProxy/indexCall/GetDownloadPortfolioDay/eyJpbmRleCI6IklCT1YiLCJsYW5ndWFnZSI6InB0LWJyIn0="

# Diretório onde o CSV baixado será salvo
DOWNLOAD_DIR = "b3/raw"

# Caminho para o arquivo de log do scraper
LOG_FILE = "crawler/logs/scraper.log"


S3_BUCKET = "b3-datalake-gabriel"    
S3_PREFIX = "bovespa/raw"