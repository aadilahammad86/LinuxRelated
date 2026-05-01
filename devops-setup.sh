#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Colors & helpers
# ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status()  { echo -e "${BLUE}[INFO]${NC}    $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC}   $1"; }

# ─────────────────────────────────────────────────────────────
# PHASE 0 – Pre-flight
# ─────────────────────────────────────────────────────────────
if [ "$EUID" -eq 0 ]; then
    print_error "Do not run as root. Use a regular user with sudo access."
    exit 1
fi

print_status "Starting Ubuntu DevOps Environment Setup..."
print_warning "This will take several minutes. Do not interrupt."

# ─────────────────────────────────────────────────────────────
# PHASE 0.5 – Stale file cleanup (safe to re-run)
# Removes list/key files from any previous partial run so they
# don't pollute the apt update in Phase 1.
# ─────────────────────────────────────────────────────────────
print_status "Phase 0.5 – Removing stale repo/key files from previous runs"
FOUND=$(sudo grep -rl "packages.microsoft.com" /etc/apt/sources.list.d/ 2>/dev/null || true)
if [ -n "$FOUND" ]; then
    while IFS= read -r leftover; do
        sudo rm -f "$leftover"
        print_status "  Removed residual Microsoft source: $leftover"
    done <<< "$FOUND"
else
    print_status "  No residual Microsoft source files found"
fi
STALE_LISTS=(
    /etc/apt/sources.list.d/docker.list
    /etc/apt/sources.list.d/vscode.list
    /etc/apt/sources.list.d/helium.list
    /etc/apt/sources.list.d/mozilla.list
    /etc/apt/sources.list.d/virtualbox.list
    /etc/apt/sources.list.d/antigravity.list
    # Catch pre-existing VS Code / Azure CLI source files under alternate names
    /etc/apt/sources.list.d/microsoft-prod.list
    /etc/apt/sources.list.d/azure-cli.list
)
STALE_KEYS=(
    /etc/apt/keyrings/docker.asc
    /etc/apt/keyrings/packages.microsoft.gpg
    /usr/share/keyrings/helium.gpg
    /etc/apt/keyrings/packages.mozilla.org.asc
    /usr/share/keyrings/oracle-virtualbox.gpg
    /etc/apt/keyrings/antigravity-repo-key.gpg
    # Alternate Microsoft key locations left by prior VS Code / Azure CLI installs
    /usr/share/keyrings/microsoft.gpg
    /etc/apt/trusted.gpg.d/microsoft.gpg
    /usr/share/keyrings/packages.microsoft.gpg
)

for f in "${STALE_LISTS[@]}" "${STALE_KEYS[@]}"; do
    [ -f "$f" ] && sudo rm -f "$f" && print_status "  Removed: $f"
done
print_success "Stale files cleared"

# ─────────────────────────────────────────────────────────────
# PHASE 1 – System upgrade + base packages
# Everything needed before adding third-party repos.
# ─────────────────────────────────────────────────────────────
print_status "Phase 1 – System upgrade & base dependencies"

sudo apt update && sudo apt upgrade -y
print_success "System upgraded"

sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gpg \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    net-tools \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    jq \
    unzip \
    htop \
    tree \
    flatpak \
    zsh \
    fonts-powerline
print_success "Base packages installed"

# ─────────────────────────────────────────────────────────────
# PHASE 2 – Create keyrings directory (once, shared by all)
# ─────────────────────────────────────────────────────────────
print_status "Phase 2 – Creating shared keyrings directory"
sudo install -d -m 0755 /etc/apt/keyrings

# ─────────────────────────────────────────────────────────────
# PHASE 3 – Register ALL third-party GPG keys + repos
# No apt update between these — batch everything first.
# ─────────────────────────────────────────────────────────────
print_status "Phase 3 – Registering all third-party repositories"

# ── Docker ──────────────────────────────────────────────────
print_status "  -> Docker"
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ── VS Code (Microsoft) ─────────────────────────────────────
print_status "  -> VS Code"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo install -D -o root -g root -m 644 /dev/stdin \
        /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# ── Helium ──────────────────────────────────────────────────
print_status "  -> Helium"
curl -fsSL https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc \
    | sudo gpg --yes --dearmor -o /usr/share/keyrings/helium.gpg
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/helium.gpg] \
https://pkg.helium.computer/deb stable main" \
    | sudo tee /etc/apt/sources.list.d/helium.list > /dev/null

# ── Firefox (Mozilla) ───────────────────────────────────────
print_status "  -> Firefox (Mozilla repo)"
wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg \
    | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] \
https://packages.mozilla.org/apt mozilla main" \
    | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

# ── VirtualBox ──────────────────────────────────────────────
print_status "  -> VirtualBox"
wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc \
    | sudo gpg --yes --dearmor -o /usr/share/keyrings/oracle-virtualbox.gpg
# Use UBUNTU_CODENAME so this works on Mint/derivatives (lsb_release -cs
# returns the Mint codename e.g. "zena" which VirtualBox repo doesn't carry).
UBUNTU_CODENAME_VBOX=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$(lsb_release -cs)}")
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] \
https://download.virtualbox.org/virtualbox/debian \
${UBUNTU_CODENAME_VBOX} contrib" \
    | sudo tee /etc/apt/sources.list.d/virtualbox.list > /dev/null

# ── Antigravity ─────────────────────────────────────────────
print_status "  -> Antigravity"
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg \
    | sudo gpg --dearmor --yes \
        -o /etc/apt/keyrings/antigravity-repo-key.gpg
# arch=amd64 explicitly set — repo has no i386 packages, suppresses the warning
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] \
https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ \
antigravity-debian main" \
    | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

# ─────────────────────────────────────────────────────────────
# PHASE 4 – Single apt update (loads all repos at once)
# ─────────────────────────────────────────────────────────────
print_status "Phase 4 – Refreshing package index (all repos)"
sudo apt update
print_success "Package index refreshed"

# ─────────────────────────────────────────────────────────────
# PHASE 5 – Install all third-party packages
# ─────────────────────────────────────────────────────────────
print_status "Phase 5 – Installing all third-party packages"

print_status "  -> Docker Engine"
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
print_success "Docker installed"

print_status "  -> VS Code"
sudo apt install -y code
print_success "VS Code installed"

print_status "  -> Helium"
sudo apt install -y helium-bin
print_success "Helium installed"

print_status "  -> Firefox"
sudo apt install -y --allow-downgrades firefox
print_success "Firefox installed"

print_status "  -> VirtualBox"
sudo apt install -y virtualbox
print_success "VirtualBox installed"

print_status "  -> Antigravity"
sudo apt install -y antigravity
print_success "Antigravity installed"

# ─────────────────────────────────────────────────────────────
# PHASE 6 – Docker post-install
# ─────────────────────────────────────────────────────────────
print_status "Phase 6 – Docker post-install configuration"

sudo systemctl enable --now docker
print_success "Docker service enabled and started"

sudo usermod -aG docker "$USER"
print_success "User '$USER' added to docker group"

# NOTE: newgrp docker in a script spawns a subshell and halts
# execution of everything after it — do NOT use it here.
# Group membership fully activates after reboot; use sudo for now.
print_status "Running Docker smoke test (with sudo — group activates after reboot)..."
sudo docker run --rm hello-world
print_success "Docker smoke test passed"

print_status "Installing Docker Compose standalone binary..."
sudo curl -fsSL \
    "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
print_success "Docker Compose standalone installed"

# ─────────────────────────────────────────────────────────────
# PHASE 7 – Flatpak + Flathub
# ─────────────────────────────────────────────────────────────
print_status "Phase 7 – Flatpak + Flathub"
flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
print_success "Flathub remote added"

# ─────────────────────────────────────────────────────────────
# PHASE 8 – ZSH + Oh My Zsh + plugins
# ─────────────────────────────────────────────────────────────
print_status "Phase 8 – ZSH + Oh My Zsh setup"

# Set ZSH as default shell (sudo avoids interactive password prompt)
sudo chsh -s "$(which zsh)" "$USER"
print_success "Default shell changed to ZSH (active after reboot)"

# Install Oh My Zsh non-interactively:
#   RUNZSH=no  — don't launch zsh at the end (would stall the script)
#   CHSH=no    — we already ran chsh above
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    print_success "Oh My Zsh installed"
else
    print_warning "Oh My Zsh already present — skipping install"
fi

# Clone plugins (idempotent — skip if already cloned)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

print_status "Cloning zsh-autosuggestions..."
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions cloned"
else
    print_warning "zsh-autosuggestions already present — skipping"
fi

print_status "Cloning zsh-syntax-highlighting..."
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting cloned"
else
    print_warning "zsh-syntax-highlighting already present — skipping"
fi

# Update the plugins=(...) line in .zshrc
# Before: plugins=(git)
# After:  plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
if grep -q 'zsh-autosuggestions' "$HOME/.zshrc"; then
    print_warning "plugins already configured in .zshrc — skipping sed"
else
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' \
        "$HOME/.zshrc"
    print_success "Plugins added to .zshrc"
fi

# ─────────────────────────────────────────────────────────────
# PHASE 9 – Shell aliases (written to both .bashrc and .zshrc)
# Guard prevents duplicates on re-runs.
# ─────────────────────────────────────────────────────────────
print_status "Phase 9 – Writing shell aliases"

ALIAS_BLOCK='
# === DevOps Aliases ===
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias dlogs="docker logs"
alias dstop="docker stop"
alias drm="docker rm -f"
alias dirm="docker image rm"
alias dcu="docker compose up"
alias dcd="docker compose down"
alias dcb="docker compose build"'

for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if ! grep -q '# === DevOps Aliases ===' "$RC" 2>/dev/null; then
        echo "$ALIAS_BLOCK" >> "$RC"
        print_success "Aliases written to $RC"
    else
        print_warning "Aliases already in $RC — skipping"
    fi
done

# ─────────────────────────────────────────────────────────────
# PHASE 10 – Post-reboot automation
#
# Strategy: a self-disabling script triggered on first login
# after reboot via a flag file check in .zshrc / .bashrc.
# Avoids systemd complexity and works regardless of shell.
# ─────────────────────────────────────────────────────────────
print_status "Phase 10 – Setting up post-reboot automation"

# Write the post-reboot script
cat > "$HOME/post-reboot-setup.sh" << 'POSTREBOOT'
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
print_status()  { echo -e "${BLUE}[POST-REBOOT]${NC} $1"; }
print_success() { echo -e "${GREEN}[POST-REBOOT]${NC} $1"; }
print_error()   { echo -e "${RED}[POST-REBOOT]${NC} $1"; }

print_status "Running one-time post-reboot checks..."

# ── Docker group verification ────────────────────────────────
print_status "Verifying Docker runs without sudo..."
if docker run --rm hello-world > /dev/null 2>&1; then
    print_success "Docker group membership confirmed — no sudo needed."
else
    print_error "Docker still needs sudo. Try logging out and back in."
fi

# ── Flatpak ─────────────────────────────────────────────────
print_status "Verifying Flatpak + Flathub..."
if flatpak remotes | grep -q flathub; then
    print_success "Flathub is active. Install apps with: flatpak install flathub <app.id>"
else
    print_error "Flathub remote not found. Run: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
fi

# ── ZSH confirmation ────────────────────────────────────────
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
    print_success "ZSH is your active shell."
else
    print_error "Shell is still $CURRENT_SHELL. Log out and back in to activate ZSH."
fi

print_success "Post-reboot checks complete. This script will not run again."
echo ""

# Self-disable: remove the hook from both rc files and the flag
sed -i '/# === DevOps post-reboot hook ===/,/fi/d' "$HOME/.zshrc"  2>/dev/null || true
sed -i '/# === DevOps post-reboot hook ===/,/fi/d' "$HOME/.bashrc" 2>/dev/null || true
rm -f "$HOME/.devops-post-reboot-pending"
POSTREBOOT

chmod +x "$HOME/post-reboot-setup.sh"

# Drop the flag file that triggers the hook
touch "$HOME/.devops-post-reboot-pending"

# Append the hook to both rc files (guarded)
POST_REBOOT_HOOK='
# === DevOps post-reboot hook ===
if [ -f "$HOME/.devops-post-reboot-pending" ]; then
    bash "$HOME/post-reboot-setup.sh"
fi'

for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if ! grep -q '# === DevOps post-reboot hook ===' "$RC" 2>/dev/null; then
        echo "$POST_REBOOT_HOOK" >> "$RC"
        print_success "Post-reboot hook added to $RC"
    fi
done

print_success "Post-reboot automation configured"

# ─────────────────────────────────────────────────────────────
# PHASE 11 – Summary file
# ─────────────────────────────────────────────────────────────
cat > "$HOME/devops-setup-complete.txt" << 'EOF'
Ubuntu DevOps Environment Setup Complete!

Installed:
  ✅ Base system tools (git, curl, wget, gpg, python3, node, etc.)
  ✅ Docker Engine + Compose (plugin & standalone binary)
  ✅ VS Code
  ✅ Helium
  ✅ Firefox (Mozilla repo, pinned above snap)
  ✅ VirtualBox
  ✅ Antigravity
  ✅ Flatpak + Flathub
  ✅ ZSH + Oh My Zsh + autosuggestions + syntax-highlighting

Post-reboot (automatic on first login):
  • Docker group check    — docker run hello-world without sudo
  • Flatpak remote check  — Flathub availability
  • ZSH shell check       — confirms active shell

Useful aliases (active in both bash & zsh):
  dps / dpsa / di     - docker ps / ps -a / images
  dcu / dcd / dcb     - docker compose up / down / build
  drm                 - docker rm -f

ZSH customisation:
  ~/.zshrc            - main config (theme, plugins)
  ~/.oh-my-zsh/       - Oh My Zsh framework
  Change theme:  edit ZSH_THEME="..." in ~/.zshrc
EOF

# ─────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────
echo ""
print_success "=========================================="
print_success "  SETUP COMPLETED SUCCESSFULLY!"
print_success "=========================================="
echo ""
print_warning "A REBOOT is required to activate:"
print_warning "  - ZSH as your default shell"
print_warning "  - Docker group membership (no sudo)"
print_warning "  - Flatpak desktop integration"
echo ""
print_status "On your FIRST LOGIN after reboot, post-reboot checks"
print_status "will run automatically and then permanently remove themselves."
echo ""
print_status "Summary saved to: ~/devops-setup-complete.txt"
echo ""
read -rp "$(echo -e "${YELLOW}Reboot now? [y/N]: ${NC}")" REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    print_status "Rebooting..."
    sudo reboot
else
    print_warning "Remember to reboot before using ZSH, Docker without sudo, or Flatpak apps."
fi
