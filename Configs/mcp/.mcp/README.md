# local-mcp (Local, Free MCP Server)
A single, local MCP server (stdio) bundling common dev tools for Swift/SwiftUI + Python (FastAPI/Flask/Django) + HTML/JS workflows.

## What you get (tools)
- Filesystem (scoped to allowed roots): read/write/list/glob
- Git: status/diff/log/checkout/commit
- Ripgrep: fast repo search
- PostgreSQL:
  - pg_query (read)
  - pg_exec (write, policy-guarded)
- nerdctl over SSH: run nerdctl on a remote host via `ssh` (key-based auth)
- nerdctl local: run nerdctl locally (optional)

## Requirements
- Python 3.10+
- `git` in PATH
- `rg` (ripgrep) in PATH (recommended)
- `ssh` in PATH (for remote nerdctl)
- PostgreSQL driver: `psycopg[binary]` (optional but recommended for pg_* tools)
- nerdctl installed on target (local/remote) if you use nerdctl tools

## Install
```bash
cd ~/.mcp/local-mcp
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Configure
Edit `config.yaml`:
- `allowed_roots`: directories the filesystem tools may touch
- `postgres.connections`: named DATABASE_URLs
- `ssh.hosts`: named SSH targets for remote nerdctl

## Run (manual)
```bash
source .venv/bin/activate
python server.py
```

## Codex TUI integration
Add to `~/.codex/config.toml`:
```toml
[mcp_servers.local_mcp]
command = "/Users/YOURUSER/.mcp/local-mcp/.venv/bin/python"
args = ["/Users/YOURUSER/.mcp/local-mcp/server.py"]
```
Restart Codex.

## Security model
- Filesystem is restricted to `allowed_roots`.
- `pg_exec` blocks dangerous SQL by default (DROP/ALTER/TRUNCATE/etc.) and enforces WHERE on UPDATE/DELETE unless overridden in config.
- nerdctl remote runs exactly `ssh <target> -- nerdctl <args...>`; no shell expansion is used.

## Notes
- If `psycopg` isn't installed, Postgres tools will return an explanatory error.
- If `rg` isn't installed, ripgrep tool will return an explanatory error.
