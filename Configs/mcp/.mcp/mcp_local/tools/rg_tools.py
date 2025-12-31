import subprocess, shutil, pathlib

def search(root: str, query: str, glob: str | None = None, max_results: int = 200) -> str:
    if shutil.which("rg") is None:
        raise RuntimeError("ripgrep (rg) not found in PATH. Install ripgrep.")
    r = pathlib.Path(root).expanduser()
    cmd = ["rg", "--no-heading", "--line-number", "--color", "never", query, str(r)]
    if glob:
        cmd.extend(["-g", glob])
    proc = subprocess.run(cmd, text=True, capture_output=True)
    # rg returns 1 when no matches; that's not an error.
    if proc.returncode not in (0, 1):
        raise RuntimeError((proc.stderr or proc.stdout or "").strip() or f"rg failed ({proc.returncode})")
    lines = (proc.stdout or "").splitlines()
    if not lines:
        return "(no matches)"
    if len(lines) > max_results:
        lines = lines[:max_results] + [f"... truncated to {max_results} results"]
    return "\n".join(lines)
