import os, requests
from dotenv import load_dotenv
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
KEY = os.getenv("SUPABASE_SERVICE_KEY")
PROXY = os.getenv("PROXY_URL")

s = requests.Session()
s.proxies.update({"http": PROXY, "https": PROXY})

# Tenta ler a dim_cid no schema gold
r = s.get(
    f"{SUPABASE_URL}/rest/v1/dim_cid?select=*&limit=1",
    headers={
        "apikey": KEY,
        "Authorization": f"Bearer {KEY}",
        "Accept-Profile": "gold",
    },
    timeout=20,
)
print("Status:", r.status_code)
print("Resposta:", r.text[:300])