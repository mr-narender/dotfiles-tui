import subprocess, pathlib

def _run(repo: str, args: list[str]) -> str:
    r = pathlib.Path(repo).expanduser()
    if not (r / ".git").exists():
        # allow git worktrees/submodules? best-effort
        pass
    proc = subprocess.run(
        ["git"] + args,
        cwd=str(r),
        text=True,
        capture_output=True
    )
    out = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
    if proc.returncode != 0:
        raise RuntimeError(out.strip() or f"git failed ({proc.returncode})")
    return out.strip()

def status(repo: str) -> str:
    return _run(repo, ["status", "--porcelain=v1", "-b"])

def diff(repo: str, staged: bool = False) -> str:
    return _run(repo, ["diff", "--staged"] if staged else ["diff"])

def log(repo: str, n: int = 20) -> str:
    return _run(repo, ["log", f"-n{n}", "--oneline", "--decorate"])

def checkout(repo: str, branch: str) -> str:
    return _run(repo, ["checkout", branch])

def commit_am(repo: str, message: str) -> str:
    # -a commits only tracked changes; avoids accidentally adding new files.
    return _run(repo, ["commit", "-am", message])
