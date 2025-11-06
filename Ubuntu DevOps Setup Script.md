# 🚀 Ubuntu DevOps Setup Script

Here's a complete bash script that automates the entire setup process for a fresh Ubuntu installation:

## 📜 Complete Setup Script

Create a file called `devops-setup.sh`:

```bash
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please don't run this script as root. Run as regular user with sudo access."
    exit 1
fi

print_status "Starting Ubuntu DevOps Environment Setup..."
print_warning "This script will take several minutes to complete."

# Function to check if a command was successful
check_success() {
    if [ $? -eq 0 ]; then
        print_success "$1"
    else
        print_error "$2"
        exit 1
    fi
}

# Update and upgrade system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y
check_success "System updated successfully" "Failed to update system"

# Install essential packages
print_status "Installing essential packages and dependencies..."
sudo apt install -y \
    net-tools \
    git \
    wget \
    curl \
    ca-certificates \
    software-properties-common \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    jq \
    unzip \
    htop \
    tree
check_success "Essential packages installed" "Failed to install packages"

# Install Docker
print_status "Setting up Docker repository..."

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list with Docker repository
print_status "Updating package list with Docker repository..."
sudo apt update

# Install Docker
print_status "Installing Docker..."
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
check_success "Docker installed successfully" "Failed to install Docker"

# Start and enable Docker service
print_status "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker
check_success "Docker service started and enabled" "Failed to start Docker service"

# Add current user to docker group
print_status "Adding current user to docker group..."
sudo usermod -aG docker $USER
check_success "User added to docker group" "Failed to add user to docker group"

# Test Docker installation
print_status "Testing Docker installation..."
sudo docker run hello-world
check_success "Docker test completed" "Docker test failed"

# Create directory for Azure DevOps agent
print_status "Creating Azure DevOps agent directory..."
mkdir -p ~/myagent
check_success "Agent directory created" "Failed to create agent directory"

# Download Azure DevOps agent
print_status "Downloading Azure DevOps agent..."
cd ~/myagent
wget -q https://vstsagentpackage.azureedge.net/agent/4.261.0/vsts-agent-linux-x64-4.261.0.tar.gz
check_success "Agent downloaded" "Failed to download agent"

# Extract agent
print_status "Extracting Azure DevOps agent..."
tar zxvf vsts-agent-linux-x64-4.261.0.tar.gz
check_success "Agent extracted" "Failed to extract agent"

# Clean up tar file
rm vsts-agent-linux-x64-4.261.0.tar.gz

# Make config script executable
chmod +x config.sh

# Install additional useful tools
print_status "Installing additional development tools..."

# Install Azure CLI (optional)
print_status "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
check_success "Azure CLI installed" "Failed to install Azure CLI"

# Install Docker Compose standalone (as backup)
print_status "Installing Docker Compose standalone..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
check_success "Docker Compose installed" "Failed to install Docker Compose"

# Set up bashrc aliases
print_status "Setting up useful aliases..."
cat >> ~/.bashrc << 'EOF'

# DevOps Aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dlogs='docker logs'
alias dstop='docker stop'
alias drm='docker rm'
alias dirm='docker image rm'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias agent-status='cd ~/myagent && ./svc.sh status'
alias agent-start='cd ~/myagent && ./svc.sh start'
alias agent-stop='cd ~/myagent && ./svc.sh stop'
alias agent-restart='cd ~/myagent && ./svc.sh restart'
EOF

# Reload bashrc
source ~/.bashrc

# Create setup completion file
cat > ~/devops-setup-complete.txt << 'EOF'
Ubuntu DevOps Environment Setup Complete!

What was installed:
✅ System updates and upgrades
✅ Essential development tools (git, curl, wget, etc.)
✅ Docker Engine with Docker Compose
✅ Azure CLI
✅ Azure DevOps agent (downloaded and extracted)

Next steps:
1. Log out and log back in for docker group permissions to take effect
2. Configure Azure DevOps agent:
   cd ~/myagent
   ./config.sh

3. Follow the prompts with:
   - Your Azure DevOps organization URL
   - PAT token (create at: User Settings -> Personal Access Tokens)
   - Agent pool name
   - Agent name

4. Start the agent as service:
   sudo ./svc.sh install
   sudo ./svc.sh start

Useful commands:
- docker ps                          # List running containers
- docker-compose up                  # Start docker-compose
- agent-status                       # Check agent status
- dps, dpsa, di                      # Docker aliases

Your agent directory: ~/myagent
EOF

print_success "=========================================="
print_success "🚀 SETUP COMPLETED SUCCESSFULLY!"
print_success "=========================================="
echo ""
print_warning "IMPORTANT: Please log out and log back in for docker group permissions to take effect."
echo ""
print_status "Setup summary saved to: ~/devops-setup-complete.txt"
print_status "Azure DevOps agent is ready for configuration in: ~/myagent"
echo ""
print_status "Next step: Run './config.sh' in ~/myagent directory to configure your Azure DevOps agent"
print_status "Don't forget to create a PAT token in Azure DevOps first!"
```

## 🎯 Quick Installation

Make the script executable and run it:

```bash
# Download the script (if copying from above, save it as devops-setup.sh)
chmod +x devops-setup.sh

# Run the script
./devops-setup.sh
```

## 📥 Alternative: One-Line Download & Run

```bash
# Download and run directly
wget -O - https://raw.githubusercontent.com/yourusername/yourrepo/devops-setup.sh | bash
```

Or if you want to download first, then run:

```bash
wget https://raw.githubusercontent.com/yourusername/yourrepo/main/devops-setup.sh
chmod +x devops-setup.sh
./devops-setup.sh
```

## 🔧 Post-Setup Configuration

After the script completes:

1. **Log out and log back in** (for docker group permissions)
2. **Configure Azure DevOps Agent**:
   ```bash
   cd ~/myagent
   ./config.sh
   ```
3. **Start the agent service**:
   ```bash
   sudo ./svc.sh install
   sudo ./svc.sh start
   sudo ./svc.sh status
   ```

## ✨ Features of This Script

- ✅ **Color-coded output** for easy reading
- ✅ **Error handling** with clear messages
- ✅ **Complete dependency installation**
- ✅ **Docker setup with official repository**
- ✅ **Azure DevOps agent download and extraction**
- ✅ **Useful aliases** for common commands
- ✅ **Azure CLI installation**
- ✅ **Post-setup instructions**
- ✅ **User-friendly prompts and status updates**

## 🛡️ Safety Features

- Checks if running as root (prevents accidental system damage)
- Validates each step before proceeding
- Provides clear error messages
- Creates a summary file with next steps

This script will transform a fresh Ubuntu installation into a fully-equipped DevOps environment ready for Azure Pipelines! 🚀
