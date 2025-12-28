# Docker Daemon Setup for WSL2 + Windows CLI (No Docker Desktop)

This guide explains how to configure Docker running **natively inside WSL2 Ubuntu** so that it can be accessed directly from **Windows PowerShell/CMD** without needing `wsl docker ...`.  
We use **Option B**: configure `hosts` only via `daemon.json` and keep the systemd override minimal.

---

## 1. Configure Docker in WSL2 Ubuntu

### Step 1: Edit `daemon.json`
Open the file with nano:

```bash
sudo nano /etc/docker/daemon.json
```

Paste the following JSON:

```json
{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://127.0.0.1:2375"
  ]
}
```

Save and exit nano:
- Press **Ctrl+O**, then **Enter**
- Press **Ctrl+X**

---

### Step 2: Clean systemd override
Ensure the override file only clears the default `ExecStart` and lets Docker read from `daemon.json`.

```bash
sudo systemctl edit docker.service
```

Paste:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock
```

Save and exit.

---

### Step 3: Reload systemd and restart Docker
```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart docker
```

Check status:
```bash
sudo systemctl status docker
```

You should see Docker listening on:
- `/var/run/docker.sock`
- `127.0.0.1:2375`

---

### Step 4: Verify inside WSL
```bash
docker ps
```

---

## 2. Configure Windows CLI

### Step 1: Install Docker CLI
Download the standalone Docker CLI binary for Windows from [Docker windows official binaries](https://download.docker.com/win/static/stable/x86_64/).  
Place `docker.exe` in a folder like `C:\Program Files\Docker\cli` and add it to your **PATH**.

Verify:
```powershell
docker --version
```

---

### Step 2: Create a Docker context
Point the Windows CLI to the WSL daemon:

```powershell
docker context create wsl --docker "host=tcp://127.0.0.1:2375"
docker context use wsl
```

---

### Step 3: Test from Windows
```powershell
docker ps
```

You should see the same containers as inside WSL.

---

## 3. Security Notes
- Binding to `127.0.0.1:2375` is safe (only local access).  
- Do **not** use `0.0.0.0:2375` unless you secure with TLS, otherwise Docker is exposed to your LAN.  
- For production, configure TLS certificates and use `--tlsverify`.

---

## 4. Summary
- WSL Ubuntu runs Docker daemon with both Unix and TCP sockets configured via `daemon.json`.  
- Windows CLI connects to the daemon using a Docker context.  
- Both environments share the same containers seamlessly.  
- No need for Docker Desktop or `wsl docker ...`.

---
