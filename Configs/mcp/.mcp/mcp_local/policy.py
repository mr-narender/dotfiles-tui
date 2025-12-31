import os, pathlib, re

SQL_DDL_RE = re.compile(r"\b(CREATE|ALTER|DROP)\b", re.IGNORECASE)
SQL_TRUNC_RE = re.compile(r"\bTRUNCATE\b", re.IGNORECASE)
SQL_MULTI_STMT_RE = re.compile(r";\s*\S", re.DOTALL)  # semicolon followed by non-whitespace later

SQL_UPDATE_RE = re.compile(r"^\s*UPDATE\b", re.IGNORECASE)
SQL_DELETE_RE = re.compile(r"^\s*DELETE\b", re.IGNORECASE)
SQL_WHERE_RE = re.compile(r"\bWHERE\b", re.IGNORECASE)

def _real(p: str) -> str:
    return str(pathlib.Path(p).expanduser().resolve())

def ensure_path_allowed(path: str, allowed_roots: list[str]) -> None:
    rp = _real(path)
    roots = [_real(r) for r in allowed_roots]
    if not any(rp == r or rp.startswith(r + os.sep) for r in roots):
        raise PermissionError(f"Path not allowed: {rp}")

def split_single_statement(sql: str, allow_multi: bool) -> str:
    # Simple guard: disallow multi-statement unless explicitly allowed.
    if not allow_multi:
        if ";" in sql.strip().rstrip(";"):
            # If there's a semicolon not only at the end, block
            if SQL_MULTI_STMT_RE.search(sql):
                raise PermissionError("Multi-statement SQL is disabled by policy.")
            # allow trailing semicolon only
            sql = sql.strip().rstrip(";")
    return sql

def check_sql_write_policy(sql: str, policy: dict) -> None:
    allow_ddl = bool(policy.get("allow_ddl", False))
    allow_truncate = bool(policy.get("allow_truncate", False))
    require_where = bool(policy.get("require_where", True))

    if not allow_ddl and SQL_DDL_RE.search(sql):
        raise PermissionError("DDL (CREATE/ALTER/DROP) blocked by policy.")
    if not allow_truncate and SQL_TRUNC_RE.search(sql):
        raise PermissionError("TRUNCATE blocked by policy.")

    if require_where:
        if SQL_UPDATE_RE.search(sql) and not SQL_WHERE_RE.search(sql):
            raise PermissionError("UPDATE without WHERE blocked by policy.")
        if SQL_DELETE_RE.search(sql) and not SQL_WHERE_RE.search(sql):
            raise PermissionError("DELETE without WHERE blocked by policy.")
