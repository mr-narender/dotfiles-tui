import subprocess, shutil, json

def local(config: dict, args: list[str]) -> str:
    nerdctl = config.get("nerdctl", {}).get("local_path", "nerdctl")
    if shutil.which(nerdctl) is None:
        raise RuntimeError(f"nerdctl not found in PATH (configured as {nerdctl}). Install nerdctl or update config.")
    proc = subprocess.run([nerdctl] + list(args), text=True, capture_output=True)
    out = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
    if proc.returncode != 0:
        raise RuntimeError(out.strip() or f"nerdctl failed ({proc.returncode})")
    return out.strip() if out.strip() else "(ok)"

def remote_ssh(config: dict, host: str, args: list[str]) -> str:
    hosts = config.get("ssh", {}).get("hosts", {})
    if host not in hosts:
        raise KeyError(f"Unknown ssh host: {host}")
    target = hosts[host].get("target")
    nerdctl_path = hosts[host].get("nerdctl_path", "nerdctl")
    if not target:
        raise ValueError(f"Missing ssh.hosts.{host}.target in config.yaml")

    # No shell interpolation: ssh target -- nerdctl args...
    cmd = ["ssh", target, "--", nerdctl_path] + list(args)
    proc = subprocess.run(cmd, text=True, capture_output=True)
    out = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
    if proc.returncode != 0:
        raise RuntimeError(out.strip() or f"ssh nerdctl failed ({proc.returncode})")
    return out.strip() if out.strip() else "(ok)"
