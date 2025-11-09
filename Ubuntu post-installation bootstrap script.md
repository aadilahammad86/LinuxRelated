# 🚀 Ubuntu Post-Install Setup

This repository automates the setup of a new Ubuntu installation with all essential tools, gestures, and fonts — in one command.
Every step is logged to:

/var/log/post-install.log
---

## 🧩 What It Installs

| Script | Purpose |
|---------|----------|
| `devops-setup.sh` | Installs Docker, VS Code, Git, and other DevOps tools |
| `enable-gestures.sh` | Enables 3/4-finger trackpad gestures (via libinput-gestures) |
| `install-ubuntu-nf-font.sh` | Installs Ubuntu Mono Nerd Font system-wide for terminal/editor use |

Perfect — logging is the smart move. You’ll want full visibility in case something fails silently during setup (especially when you run it on a new system).

Here’s the **final, production-ready version** of your unified post-install script — complete with a persistent log file at `/var/log/post-install.log`, timestamped output, and error trapping.

---

## ⚡ **post-install.sh**

```bash
#!/bin/bash
# Ubuntu Post-Installation Bootstrap Script (with Logging)
# Author: Aadil Ahmad
# Purpose: Automate setup of DevOps tools, gestures, and Nerd Fonts on a fresh Ubuntu install

set -e
LOGFILE="/var/log/post-install.log"
REPO_URL="https://github.com/aadilahammad86/LinuxRelated.git"
REPO_DIR="$HOME/LinuxRelated"
SCRIPTS=("devops-setup.sh" "enable-gestures.sh" "install-ubuntu-nf-font.sh")

# ---------- LOGGING SETUP ----------
sudo mkdir -p "$(dirname "$LOGFILE")"
sudo touch "$LOGFILE"
sudo chmod 644 "$LOGFILE"

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}
# -----------------------------------

log "================ Ubuntu Post Install Started ================"

if [ "$EUID" -ne 0 ]; then
    log "⚠️  Please run this script with sudo."
    echo "Usage: sudo bash post-install.sh"
    exit 1
fi

log "📦 Updating system packages..."
apt update -y >>"$LOGFILE" 2>&1
apt upgrade -y >>"$LOGFILE" 2>&1

log "🧰 Installing base utilities (git, curl, unzip, make)..."
apt install -y git curl wget unzip make python3-pip >>"$LOGFILE" 2>&1

if [ ! -d "$REPO_DIR" ]; then
    log "📥 Cloning repository: $REPO_URL"
    git clone "$REPO_URL" "$REPO_DIR" >>"$LOGFILE" 2>&1
else
    log "🔁 Repo already exists — updating..."
    cd "$REPO_DIR"
    git pull >>"$LOGFILE" 2>&1
fi

cd "$REPO_DIR"
chmod +x "${SCRIPTS[@]}"

for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
        log "🚀 Running $SCRIPT..."
        bash "$SCRIPT" >>"$LOGFILE" 2>&1 || {
            log "❌ Error running $SCRIPT. Check the log for details."
            exit 1
        }
        log "✅ Finished $SCRIPT."
    else
        log "⚠️  Script not found: $SCRIPT — skipping."
    fi
done

log "✅ All setup scripts executed successfully."
log "💾 Log file saved at: $LOGFILE"

read -p "Would you like to reboot now? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    log "🔁 System reboot initiated by user."
    reboot
else
    log "🕶️ Setup complete. User opted not to reboot immediately."
    echo "Setup complete. Review $LOGFILE if needed."
fi

log "================ Ubuntu Post Install Completed ================"
```

--- 

Every step is logged to:
```

/var/log/post-install.log

````

---

## ⚙️ How to Run After Fresh Install

```bash
sudo apt install git -y
git clone https://github.com/aadilahammad86/LinuxRelated.git
cd LinuxRelated
chmod +x post-install.sh
sudo bash post-install.sh
````

---

## 🧠 Log Details

All output, including errors, is recorded here:

```
/var/log/post-install.log
```

You can monitor it live during installation:

```bash
sudo tail -f /var/log/post-install.log
```

---

## 🧑‍💻 Author

**Aadil Ahammad**
Full post-install automation for Ubuntu — with persistent logging.

```

---

✅ **This version will:**
- Log every install/update step.  
- Record command output and timestamps.  
- Halt on failure and write a precise error line in the log.  
- Leave a readable system log for later audits.  

Would you like me to extend it to **create a restore point or backup list** (like exporting installed packages before running the scripts)? That’s often useful before major automation.
```
