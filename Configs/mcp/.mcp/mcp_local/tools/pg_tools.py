from __future__ import annotations
import json

def _get_url(config: dict, conn: str) -> str:
    conns = config.get("postgres", {}).get("connections", {})
    if conn not in conns:
        raise KeyError(f"Unknown Postgres connection: {conn}")
    url = conns[conn].get("url")
    if not url:
        raise ValueError(f"Missing url for Postgres connection: {conn}")
    return url

def query(config: dict, conn: str, sql: str, limit: int = 2000) -> str:
    try:
        import psycopg
    except Exception as e:
        raise RuntimeError("psycopg not installed. Install requirements.txt to enable Postgres tools.") from e

    url = _get_url(config, conn)
    # Force a limit wrapper if user forgot; best-effort (only if it's a SELECT)
    trimmed = sql.strip()
    if trimmed[:6].lower() == "select" and "limit" not in trimmed.lower():
        sql = f"{trimmed}\nLIMIT {int(limit)}"

    with psycopg.connect(url) as cx:
        with cx.cursor() as cur:
            cur.execute(sql)
            rows = cur.fetchall() if cur.description else []
            cols = [d.name for d in (cur.description or [])]
    payload = {"columns": cols, "rows": rows[:limit], "rowCount": len(rows)}
    return json.dumps(payload, ensure_ascii=False, default=str, indent=2)

def exec_write(config: dict, conn: str, sql: str) -> str:
    try:
        import psycopg
    except Exception as e:
        raise RuntimeError("psycopg not installed. Install requirements.txt to enable Postgres tools.") from e

    url = _get_url(config, conn)
    with psycopg.connect(url) as cx:
        with cx.cursor() as cur:
            cur.execute(sql)
            rowcount = cur.rowcount
        cx.commit()
    return json.dumps({"status": "ok", "rowCount": rowcount}, ensure_ascii=False, indent=2)
