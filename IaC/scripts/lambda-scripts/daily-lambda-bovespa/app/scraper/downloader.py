import os
import requests
import base64
from datetime import datetime
import shutil
import logging 
from requests.exceptions import Timeout, RequestException

logger = logging.getLogger()
logger.setLevel(logging.INFO)

IBOV_URL = os.environ.get("IBOV_URL", "")

def clear_data(path: str):
    if os.path.exists(path):
        shutil.rmtree(path)
    os.makedirs(path, exist_ok=True)

def safe_decode(content):
    try:
        decoded = base64.b64decode(content, validate=True)
        return decoded 
    except Exception:
        return content

def download_base():
    url = IBOV_URL
    
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        content = safe_decode(response.content)
        if isinstance(content, bytes):
            content = content.decode('latin1')
            
        logging.info("CSV content retrieved successfully")
        return content
        
    except Timeout:
        logging.error("Timeout while downloading")
        raise
    except RequestException as e:
        logging.error(f"Request error: {e}")
        raise
    except Exception as e:
        logging.exception(f"Unexpected error: {e}")
        raise