#!/usr/bin/env python3
import sys
import json
import traceback
from typing import Any, Dict, List, Optional
from mcp_local.config import load_config
from mcp_local.policy import (
    ensure_path_allowed,
    check_sql_write_policy,
    split_single_statement,
)
from mcp_local.tools import (
    fs_tools,
    git_tools,
    rg_tools,
    pg_tools,
    nerdctl_tools,
    mgrep_tools,
)

PROTOCOL_VERSION = "2024-11-05"  # informational; MCP is JSON-RPC 2.0


class InvalidParams(Exception):
    """Raised when request arguments are invalid or missing."""


def _send(obj: Dict[str, Any]) -> None:
    sys.stdout.write(json.dumps(obj, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def _result(id_: Any, result: Any) -> None:
    _send({"jsonrpc": "2.0", "id": id_, "result": result})


def _error(id_: Any, code: int, message: str, data: Optional[Any] = None) -> None:
    err = {"code": code, "message": message}
    if data is not None:
        err["data"] = data
    _send({"jsonrpc": "2.0", "id": id_, "error": err})


def _text_content(text: str) -> Dict[str, Any]:
    return {"content": [{"type": "text", "text": text}]}


def tools_list(config) -> List[Dict[str, Any]]:
    # Minimal tool schema with JSON schema inputSchema
    return [
        # Filesystem
        {
            "name": "fs_read",
            "description": "Read a text file (restricted to allowed_roots).",
            "inputSchema": {
                "type": "object",
                "properties": {"path": {"type": "string"}},
                "required": ["path"],
            },
        },
        {
            "name": "fs_write",
            "description": "Write a text file (restricted to allowed_roots).",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "path": {"type": "string"},
                    "content": {"type": "string"},
                },
                "required": ["path", "content"],
            },
        },
        {
            "name": "fs_list",
            "description": "List directory entries (restricted to allowed_roots).",
            "inputSchema": {
                "type": "object",
                "properties": {"path": {"type": "string"}},
                "required": ["path"],
            },
        },
        {
            "name": "fs_glob",
            "description": "Glob files under an allowed root (restricted).",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "root": {"type": "string"},
                    "pattern": {"type": "string"},
                },
                "required": ["root", "pattern"],
            },
        },
        # Git
        {
            "name": "git_status",
            "description": "git status --porcelain in a repo.",
            "inputSchema": {
                "type": "object",
                "properties": {"repo": {"type": "string"}},
                "required": ["repo"],
            },
        },
        {
            "name": "git_diff",
            "description": "git diff (optionally staged).",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "repo": {"type": "string"},
                    "staged": {"type": "boolean"},
                },
                "required": ["repo"],
            },
        },
        {
            "name": "git_log",
            "description": "git log --oneline (n entries).",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "repo": {"type": "string"},
                    "n": {"type": "integer", "minimum": 1, "maximum": 200},
                },
                "required": ["repo"],
            },
        },
        {
            "name": "git_checkout",
            "description": "git checkout <branch>.",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "repo": {"type": "string"},
                    "branch": {"type": "string"},
                },
                "required": ["repo", "branch"],
            },
        },
        {
            "name": "git_commit",
            "description": "git commit -am <message> (only tracked changes).",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "repo": {"type": "string"},
                    "message": {"type": "string"},
                },
                "required": ["repo", "message"],
            },
        },
        # Ripgrep
        {
            "name": "rg_search",
            "description": "Search text in repo using ripgrep (rg).",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "root": {"type": "string"},
                    "query": {"type": "string"},
                    "glob": {"type": "string"},
                    "max_results": {"type": "integer", "minimum": 1, "maximum": 5000},
                },
                "required": ["root", "query"],
            },
        },
        {
            "name": "mgrep_search",
            "description": "Approximate text search with match probability (mimics mgrep).",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "path": {"type": "string"},
                    "query": {"type": "string"},
                    "min_probability": {
                        "type": "number",
                        "minimum": 0.0,
                        "maximum": 1.0,
                    },
                    "max_results": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 500,
                    },
                },
                "required": ["path", "query"],
            },
        },
        # Postgres
        {
            "name": "pg_query",
            "description": "Run a read-only SQL query on a named Postgres connection.",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "conn": {"type": "string"},
                    "sql": {"type": "string"},
                    "limit": {"type": "integer", "minimum": 1, "maximum": 10000},
                },
                "required": ["conn", "sql"],
            },
        },
        {
            "name": "pg_exec",
            "description": "Run a write SQL statement (INSERT/UPDATE/DELETE) with policy guards on a named Postgres connection.",
            "inputSchema": {
                "type": "object",
                "properties": {"conn": {"type": "string"}, "sql": {"type": "string"}},
                "required": ["conn", "sql"],
            },
        },
        # nerdctl
        {
            "name": "nerdctl",
            "description": "Run nerdctl locally or on a remote SSH host when host is provided.",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "args": {"type": "array", "items": {"type": "string"}},
                    "host": {"type": "string"},
                },
                "required": ["args"],
            },
        },
        {
            "name": "nerdctl_local",
            "description": "Run nerdctl locally (e.g., ps/logs/exec).",
            "inputSchema": {
                "type": "object",
                "properties": {"args": {"type": "array", "items": {"type": "string"}}},
                "required": ["args"],
            },
        },
        {
            "name": "nerdctl_ssh",
            "description": "Run nerdctl on a remote host via SSH (key-based auth).",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "host": {"type": "string"},
                    "args": {"type": "array", "items": {"type": "string"}},
                },
                "required": ["host", "args"],
            },
        },
    ]


def handle_tools_call(name: str, args: Dict[str, Any], config) -> str:
    allowed_roots = config.get("allowed_roots", [])
    if not allowed_roots:
        raise InvalidParams("allowed_roots is not configured; set it in config.yaml")

    postgres_cfg = config.get("postgres", {})
    write_policy = postgres_cfg.get("write_policy", {})

    # Filesystem (scoped)
    if name == "fs_read":
        path = args["path"]
        ensure_path_allowed(path, allowed_roots)
        return fs_tools.read_text(path)
    if name == "fs_write":
        path = args["path"]
        ensure_path_allowed(path, allowed_roots)
        return fs_tools.write_text(path, args["content"])
    if name == "fs_list":
        path = args["path"]
        ensure_path_allowed(path, allowed_roots)
        return fs_tools.list_dir(path)
    if name == "fs_glob":
        root = args["root"]
        ensure_path_allowed(root, allowed_roots)
        return fs_tools.glob_files(root, args["pattern"])

    # Git (scoped to allowed roots via repo path check)
    if name.startswith("git_"):
        repo = args["repo"]
        ensure_path_allowed(repo, allowed_roots)
        if name == "git_status":
            return git_tools.status(repo)
        if name == "git_diff":
            return git_tools.diff(repo, staged=bool(args.get("staged", False)))
        if name == "git_log":
            return git_tools.log(repo, n=int(args.get("n", 20)))
        if name == "git_checkout":
            return git_tools.checkout(repo, args["branch"])
        if name == "git_commit":
            return git_tools.commit_am(repo, args["message"])

    # Ripgrep
    if name == "rg_search":
        root = args["root"]
        ensure_path_allowed(root, allowed_roots)
        return rg_tools.search(
            root,
            args["query"],
            glob=args.get("glob"),
            max_results=int(args.get("max_results", 200)),
        )
    if name == "mgrep_search":
        path = args["path"]
        ensure_path_allowed(path, allowed_roots)
        return mgrep_tools.search_file(
            path,
            args["query"],
            min_probability=float(args.get("min_probability", 0.5)),
            max_results=int(args.get("max_results", 20)),
        )

    # Postgres
    if name == "pg_query":
        conn = args["conn"]
        sql = args["sql"]
        limit = int(args.get("limit", 2000))
        return pg_tools.query(config, conn, sql, limit=limit)

    if name == "pg_exec":
        conn = args["conn"]
        sql = args["sql"]
        sql = split_single_statement(
            sql,
            allow_multi=bool(
                write_policy.get("allow_multi_statement", False)
            ),
        )
        check_sql_write_policy(sql, write_policy)
        return pg_tools.exec_write(config, conn, sql)

    # nerdctl
    if name == "nerdctl":
        host = args.get("host")
        if host:
            return nerdctl_tools.remote_ssh(config, host, args["args"])
        return nerdctl_tools.local(config, args["args"])
    if name == "nerdctl_local":
        return nerdctl_tools.local(config, args["args"])
    if name == "nerdctl_ssh":
        return nerdctl_tools.remote_ssh(config, args["host"], args["args"])

    raise ValueError(f"Unknown tool: {name}")


def main() -> None:
    config = load_config()

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
            id_ = msg.get("id")
            method = msg.get("method")
            params = msg.get("params") or {}

            # Notifications may omit id; ignore unknown notifications
            if method == "initialize":
                _result(
                    id_,
                    {
                        "protocolVersion": PROTOCOL_VERSION,
                        "capabilities": {"tools": {}},
                        "serverInfo": {"name": "local-mcp", "version": "1.0.0"},
                    },
                )
                continue

            if method == "tools/list":
                _result(id_, {"tools": tools_list(config)})
                continue

            if method == "tools/call":
                tool_name = params.get("name")
                tool_args = params.get("arguments") or {}
                if not tool_name:
                    _error(
                        id_,
                        -32602,
                        "tools/call missing tool name; pass params.name",
                    )
                    continue
                try:
                    out = handle_tools_call(tool_name, tool_args, config)
                    _result(id_, _text_content(out))
                except InvalidParams as e:
                    _error(id_, -32602, str(e))
                except Exception as e:
                    _error(
                        id_,
                        -32000,
                        f"Tool error: {e}",
                        data={"trace": traceback.format_exc()},
                    )
                continue

            # Minimal responses for optional methods
            if method in ("resources/list", "prompts/list"):
                _result(
                    id_,
                    {"resources": []}
                    if method == "resources/list"
                    else {"prompts": []},
                )
                continue

            if method in ("resources/read", "prompts/get"):
                _error(
                    id_,
                    -32602,
                    "No resources or prompts are exposed by this server.",
                )
                continue

            # Unknown method
            if id_ is not None:
                _error(id_, -32601, f"Method not found: {method}")
        except Exception as e:
            # If we can't parse / handle, respond if possible
            try:
                _error(msg.get("id"), -32700, f"Parse/dispatch error: {e}")
            except Exception:
                # Can't even respond; keep going
                pass


if __name__ == "__main__":
    main()
