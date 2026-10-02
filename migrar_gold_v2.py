import os
import sys
import psycopg2
import psycopg2.extras
import requests
import ssl
from requests.adapters import HTTPAdapter
from urllib3.util.ssl_ import create_urllib3_context
from datetime import date, datetime
from decimal import Decimal
from uuid import UUID
from dotenv import load_dotenv

# Carrega o .env que está na mesma pasta
load_dotenv()

# ============================================================
# CONFIGURAÇÕES (lidas do .env — nunca hardcoded)
# ============================================================
PG_HOST = "localhost"
PG_PORT = 5432
PG_USER = "postgres"
PG_PASSWORD = os.getenv("PG_PASSWORD")
PG_DATABASE = "hriv_bi"

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY")
PROXY_URL = os.getenv("PROXY_URL")   # ex: http://user:senha@proxy.saude.parana:3128

SCHEMA = "gold"
TAMANHO_LOTE = 500

# ============================================================
# VALIDAÇÃO RÁPIDA DAS CREDENCIAIS
# ============================================================
faltando = [k for k, v in {
    "PG_PASSWORD": PG_PASSWORD,
    "SUPABASE_URL": SUPABASE_URL,
    "SUPABASE_SERVICE_KEY": SUPABASE_SERVICE_KEY,
    "PROXY_URL": PROXY_URL,
}.items() if not v]

if faltando:
    print(f"[ERRO] Variáveis ausentes no .env: {faltando}")
    sys.exit(1)

# ============================================================
# SESSÃO HTTPS COM PROXY + TLS 1.2 CLÁSSICO
# ============================================================
class ClassicTLSAdapter(HTTPAdapter):
    def init_poolmanager(self, *args, **kwargs):
        ctx = create_urllib3_context()
        ctx.set_ciphers('ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20')
        ctx.minimum_version = ssl.TLSVersion.TLSv1_2
        ctx.maximum_version = ssl.TLSVersion.TLSv1_2
        kwargs['ssl_context'] = ctx
        return super().init_poolmanager(*args, **kwargs)

session = requests.Session()
session.mount('https://', ClassicTLSAdapter())
session.mount('http://', HTTPAdapter())

# Aplica o proxy em todas as requisições
session.proxies.update({
    "http": PROXY_URL,
    "https": PROXY_URL,
})

# ============================================================

def serializar_valor(valor):
    if isinstance(valor, (datetime, date)):
        return valor.isoformat()
    if isinstance(valor, Decimal):
        return float(valor)
    if isinstance(valor, UUID):
        return str(valor)
    if isinstance(valor, bytes):
        import base64
        return base64.b64encode(valor).decode("utf-8")
    return valor

def listar_tabelas(cursor):
    cursor.execute("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = %s AND table_type = 'BASE TABLE'
        ORDER BY table_name;
    """, (SCHEMA,))
    return [row[0] for row in cursor.fetchall()]

def enviar_lote(tabela, linhas):
    url = f"{SUPABASE_URL}/rest/v1/{tabela}"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates,return=minimal",
        "Content-Profile": SCHEMA,
        "Accept-Profile": SCHEMA,
    }
    try:
        resp = session.post(url, headers=headers, json=linhas, timeout=120)
        resp.raise_for_status()
        return True
    except requests.exceptions.HTTPError as e:
        print(f"    [ERRO HTTP] {e}")
        print(f"    Resposta: {resp.text[:500]}")
        return False
    except requests.exceptions.RequestException as e:
        print(f"    [ERRO REDE] {e!r}")
        return False

def migrar_tabela(pg_cursor, tabela):
    print(f"\n→ Migrando tabela: {SCHEMA}.{tabela}")
    pg_cursor.execute(f'SET search_path TO "{SCHEMA}";')
    pg_cursor.execute(f'SELECT * FROM "{tabela}";')
    colunas = [desc[0] for desc in pg_cursor.description]
    total_enviado = 0
    lote = []
    for row in pg_cursor:
        linha_dict = {col: serializar_valor(val) for col, val in zip(colunas, row)}
        lote.append(linha_dict)
        if len(lote) >= TAMANHO_LOTE:
            if enviar_lote(tabela, lote):
                total_enviado += len(lote)
                print(f"    Enviadas {total_enviado} linhas...")
            else:
                print(f"    Falha no lote. Abortando tabela {tabela}.")
                return False
            lote = []
    if lote:
        if enviar_lote(tabela, lote):
            total_enviado += len(lote)
    print(f"  ✓ Tabela '{tabela}' concluída: {total_enviado} linhas.")
    return True

def main():
    print("=" * 60)
    print("Migração PostgreSQL (local) → Supabase (REST API) — v3")
    print("=" * 60)

    try:
        conn = psycopg2.connect(
            host=PG_HOST, port=PG_PORT, user=PG_USER,
            password=PG_PASSWORD, dbname=PG_DATABASE,
            client_encoding='UTF8',
            options='-c lc_messages=C',
        )
        conn.set_session(readonly=True)
        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        print("✓ Conectado ao PostgreSQL local.")
    except Exception as e:
        print(f"[ERRO] Falha ao conectar no PostgreSQL: {e!r}")
        sys.exit(1)

    try:
        tabelas = listar_tabelas(cur)
        print(f"\nTabelas encontradas no schema '{SCHEMA}': {len(tabelas)}")
        for t in tabelas:
            print(f"  - {t}")
    except Exception as e:
        print(f"[ERRO] Falha ao listar tabelas: {e}")
        sys.exit(1)

    # ── TESTE DE CONEXÃO COM SUPABASE VIA PROXY ──
    print("\n" + "-" * 60)
    print("Testando conexão com o Supabase via proxy corporativo...")
    try:
        r = session.get(
            f"{SUPABASE_URL}/rest/v1/",
            timeout=20,
            headers={
                "apikey": SUPABASE_SERVICE_KEY,
                "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
                "Accept-Profile": SCHEMA,
            },
        )
        print(f"  Status HTTP: {r.status_code}")
        if r.status_code in (200, 401, 404):
            print("  ✓ Conexão SSL via proxy estabelecida com o Supabase!")
        else:
            print(f"  Resposta: {r.text[:200]}")
    except Exception as e:
        print(f"  [ERRO] Falha via proxy: {e!r}")
        print("  → Verifique a URL do proxy, usuário, senha (URL-encoded) e porta.")
        sys.exit(1)
    print("-" * 60)

    falhas = []
    for tabela in tabelas:
        try:
            if not migrar_tabela(cur, tabela):
                falhas.append(tabela)
        except Exception as e:
            print(f"  [ERRO] Falha em '{tabela}': {e!r}")
            falhas.append(tabela)
            conn.rollback()

    cur.close()
    conn.close()

    print("\n" + "=" * 60)
    if falhas:
        print(f"Migração concluída COM FALHAS em: {falhas}")
    else:
        print("Migração concluída com SUCESSO em todas as tabelas.")
    print("=" * 60)

if __name__ == "__main__":
    main()