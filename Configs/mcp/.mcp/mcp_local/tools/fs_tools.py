import os, pathlib, glob

def read_text(path: str) -> str:
    p = pathlib.Path(path).expanduser()
    return p.read_text(encoding="utf-8", errors="replace")

def write_text(path: str, content: str) -> str:
    p = pathlib.Path(path).expanduser()
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content, encoding="utf-8")
    return f"Wrote {len(content)} bytes to {str(p)}"

def list_dir(path: str) -> str:
    p = pathlib.Path(path).expanduser()
    if not p.exists():
        return f"Not found: {p}"
    if not p.is_dir():
        return f"Not a directory: {p}"
    items = []
    for child in sorted(p.iterdir(), key=lambda x: x.name.lower()):
        kind = "dir" if child.is_dir() else "file"
        items.append(f"{kind}\t{child.name}")
    return "\n".join(items) if items else "(empty)"

def glob_files(root: str, pattern: str) -> str:
    base = pathlib.Path(root).expanduser()
    pat = str(base / pattern)
    matches = glob.glob(pat, recursive=True)
    matches = sorted(set(matches))
    return "\n".join(matches) if matches else "(no matches)"
