# 🐳 Docker Daemon Connection Issue — Troubleshooting Guide (Windows + Docker Desktop + WSL)

---

## 📌 Problem Summary

Docker CLI commands (e.g., `docker ps`, `docker info`) fail with:

```
ERROR: Get "http://172.21.x.x:2375/...": dial tcp ... i/o timeout
```

Despite:

* Docker being installed correctly
* Docker Desktop running

---

## 🧠 Root Cause

### FACT

Docker CLI is attempting to connect to a **remote daemon** via:

```
tcp://172.21.63.142:2375
```

### FACT

This overrides normal Docker behavior via:

```
DOCKER_HOST environment variable
```

### RESULT

* Docker ignores selected context (`desktop-linux`)
* CLI attempts to connect to a dead/unreachable daemon
* All commands fail

---

## ⚠️ Key Indicator

Run:

```
docker context ls
```

If you see:

```
Warning: DOCKER_HOST environment variable overrides the active context
```

→ This confirms the issue.

---

## 🔍 Diagnosis Checklist

| Check            | Command                 | Expected               |
| ---------------- | ----------------------- | ---------------------- |
| Docker installed | `docker -v`             | Version output         |
| Context list     | `docker context ls`     | No warnings            |
| Env variable     | `echo $Env:DOCKER_HOST` | Empty                  |
| Docker daemon    | `docker info`           | Server section present |

---

## 🔧 Resolution Steps

---

### ✅ Step 1: Remove DOCKER_HOST (Current Session)

```powershell
$Env:DOCKER_HOST = $null
```

Verify:

```powershell
echo $Env:DOCKER_HOST
```

✔ Should return nothing

---

### ✅ Step 2: Remove DOCKER_HOST (Persistent)

```powershell
[Environment]::SetEnvironmentVariable("DOCKER_HOST", $null, "User")
[Environment]::SetEnvironmentVariable("DOCKER_HOST", $null, "Machine")
```

---

### ✅ Step 3: Restart Environment

* Close ALL PowerShell / terminal sessions
* Restart Docker Desktop

---

### ✅ Step 4: Select Correct Context

```powershell
docker context use desktop-linux
```

---

### ✅ Step 5: Validate

```powershell
docker info
```

✔ Expected:

* No timeout errors
* Server info displayed
* No warnings about DOCKER_HOST

---

## 🧨 Advanced Troubleshooting

---

### 🔍 Check if Variable Still Exists

```powershell
Get-ChildItem Env: | findstr DOCKER
```

---

### 🔍 Check PowerShell Profile

```powershell
notepad $PROFILE
```

Look for:

```powershell
$Env:DOCKER_HOST = "tcp://..."
```

Remove it if present.

---

### 🔍 Force Docker Context Usage

If needed:

```powershell
docker --context desktop-linux info
```

---

### 🔍 Verify Docker Desktop Engine

Ensure:

* Docker Desktop is running
* WSL integration enabled
* No backend errors

---

## ⚠️ Common Failure Modes

| Symptom                  | Cause                  | Fix              |
| ------------------------ | ---------------------- | ---------------- |
| Timeout to 172.x.x.x     | DOCKER_HOST override   | Remove env var   |
| Cannot connect to daemon | Docker Desktop stopped | Start service    |
| Context ignored          | Env override active    | Clear variable   |
| Works after restart only | Session variable issue | Restart terminal |

---

## 🧠 Lessons Learned

* `DOCKER_HOST` overrides ALL contexts
* Environment variables exist at:

  * Process level (current shell)
  * User level
  * Machine level
* Removing persistent variables does NOT affect active sessions
* Docker CLI silently follows env variables even if incorrect

---

## 🧾 Final Expected State

```
docker context ls
```

Output:

* No warnings
* `desktop-linux` usable
* No reference to remote TCP endpoint

---

## ✅ Conclusion

This issue is not a Docker failure.

It is a **misconfigured environment variable overriding the Docker daemon connection**, causing the CLI to attempt communication with an invalid endpoint.

Fixing the environment restores normal Docker functionality.

---
