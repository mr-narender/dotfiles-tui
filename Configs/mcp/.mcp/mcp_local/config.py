import os, pathlib, yaml

DEFAULT_CONFIG_PATHS = [
    os.environ.get("LOCAL_MCP_CONFIG", ""),
    str(pathlib.Path(__file__).resolve().parent.parent / "config.yaml"),
]

def load_config() -> dict:
    path = None
    for p in DEFAULT_CONFIG_PATHS:
        if p and os.path.exists(p):
            path = p
            break
    if not path:
        raise RuntimeError("config.yaml not found. Set LOCAL_MCP_CONFIG or place config.yaml next to server.py")
    with open(path, "r", encoding="utf-8") as f:
        cfg = yaml.safe_load(f) or {}

    # Normalize
    cfg.setdefault("allowed_roots", [])
    cfg.setdefault("postgres", {}).setdefault("connections", {})
    cfg["postgres"].setdefault("write_policy", {})
    cfg.setdefault("ssh", {}).setdefault("hosts", {})
    cfg.setdefault("nerdctl", {}).setdefault("local_path", "nerdctl")
    cfg.setdefault("logging", {}).setdefault("level", "INFO")
    return cfg
