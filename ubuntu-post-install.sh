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
