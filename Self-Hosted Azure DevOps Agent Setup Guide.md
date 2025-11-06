# 🚀 Self-Hosted Azure DevOps Agent Setup Guide

A comprehensive beginner-friendly tutorial for setting up a self-hosted Azure DevOps agent on Ubuntu with Docker support.

## 📋 Prerequisites

- Ubuntu machine (physical or virtual)
- sudo privileges
- Internet connectivity
- Azure DevOps organization account

---

## 🛠️ Step 1: System Preparation

### Update System & Install Dependencies
```bash
# Update package lists and upgrade existing packages
sudo apt update && sudo apt upgrade -y

# Install essential networking tools and utilities
sudo apt install net-tools -y

# Install common development dependencies
sudo apt install -y git wget curl ca-certificates software-properties-common
```

---

## 🐳 Step 2: Docker Installation

### Add Docker's Official Repository
```bash
# Update package lists
sudo apt-get update

# Install certificate utilities
sudo apt-get install ca-certificates curl

# Create directory for Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyrings

# Download and install Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Install Docker Engine
```bash
# Update package lists with new Docker repository
sudo apt-get update

# Install Docker components
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
sudo docker run hello-world
```

---

## 🤖 Step 3: Azure DevOps Agent Setup

### Access Azure DevOps Organization
1. Navigate to your Azure DevOps organization:
   ```
   https://eduegate.visualstudio.com/eduegateerpv1/_settings/agentqueues
   ```

### Create Agent Pool
1. Click on **"Self-hosted"** option
2. Create a new agent pool with descriptive name
3. **Important**: Check **"Grant access permission to all pipelines"**
4. Click **"Create"**

### Generate Personal Access Token (PAT)
1. Click your profile picture in top-right corner → **User settings**
2. Select **Personal Access Tokens**
3. Click **New Token**
4. Configure with:
   - **Name**: "Self-Hosted-Agent"
   - **Organization**: Select your organization
   - **Expiration**: Set appropriate duration
   - **Scopes**: Select **"All scopes"** or minimum:
     - Agent Pools (Read & manage)
     - Deployment group (Read & manage)
     - Service Connections (View)
5. Click **Create** and **copy the token** (you won't see it again!)

### Download and Configure Agent
```bash
# Create agent directory
mkdir myagent && cd myagent

# Download Azure DevOps agent (check for latest version)
wget https://vstsagentpackage.azureedge.net/agent/4.261.0/vsts-agent-linux-x64-4.261.0.tar.gz

# Extract agent files
tar zxvf vsts-agent-linux-x64-4.261.0.tar.gz

# Configure the agent
./config.sh
```

### Agent Configuration Prompts
During `./config.sh`, you'll need:

1. **Server URL**: `https://dev.azure.com/your-organization`
2. **Authentication type**: PAT
3. **Personal Access Token**: Paste your copied token
4. **Agent Pool**: Select the pool you created
5. **Agent Name**: Choose descriptive name (e.g., "ubuntu-build-agent")
6. **Work folder**: Accept default or specify custom path
7. **Run as service?**: Yes (recommended)

### Start Agent Service
```bash
# If not running as service, start interactively
./run.sh

# If installed as service, it should start automatically
sudo ./svc.sh install
sudo ./svc.sh start

# Check service status
sudo ./svc.sh status
```

---

## ✅ Step 4: Verification

### Verify Docker Installation
```bash
# Check Docker version
docker --version

# Check Docker service status
sudo systemctl status docker

# Test Docker functionality
sudo docker run hello-world
```

### Verify Agent Registration
1. Go back to Azure DevOps → Project Settings → Agent Pools
2. Select your agent pool
3. Check **Agents** tab
4. Your agent should appear with **"Online"** status

---

## 🎯 Quality of Life Improvements

### Add User to Docker Group (Avoid sudo)
```bash
# Add current user to docker group
sudo usermod -aG docker $USER

# Apply group changes (or logout/login)
newgrp docker

# Verify can run docker without sudo
docker ps
```

### Configure Agent Auto-Restart
```bash
# Enable agent service to start on boot
sudo ./svc.sh install
sudo ./svc.sh enable

# Common service commands
sudo ./svc.sh start    # Start service
sudo ./svc.sh stop     # Stop service
sudo ./svc.sh restart  # Restart service
sudo ./svc.sh status   # Check status
```

### Install Additional Useful Tools
```bash
# Common development tools
sudo apt install -y \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    jq \
    unzip

# Azure CLI (optional)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

## 🔧 Troubleshooting Common Issues

### Agent Offline?
```bash
# Check agent logs
cd myagent/_diag
tail -f *.log

# Restart agent service
cd ..
sudo ./svc.sh restart
```

### Docker Permission Denied?
```bash
# Ensure user is in docker group
groups $USER

# If not, add and reload
sudo usermod -aG docker $USER
newgrp docker
```

### Network Connectivity Issues?
```bash
# Check if agent can reach Azure DevOps
curl -I https://dev.azure.com

# Verify firewall settings
sudo ufw status
```

---

## 🗂️ File Structure
```
~/myagent/
├── bin/
├── externals/
├── _diag/          # Log files
├── _work/          # Pipeline workspaces
├── config.sh       # Configuration script
├── run.sh          # Manual run script
└── svc.sh          # Service management
```

---

## 📝 Important Notes

- **Security**: Keep your PAT token secure and regenerate if compromised
- **Updates**: Regularly update both system packages and the agent software
- **Monitoring**: Set up monitoring for agent health and performance
- **Backup**: Backup agent configuration if you have custom settings

---

## 🎉 Success Checklist

- [ ] System updated and essential tools installed
- [ ] Docker successfully installed and tested
- [ ] Azure DevOps agent pool created
- [ ] PAT token generated with correct permissions
- [ ] Agent downloaded and configured
- [ ] Agent showing as "Online" in Azure DevOps
- [ ] Docker commands work without sudo
- [ ] Agent service starts automatically

---

## 🔗 Useful Links

- [Azure DevOps Agent Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops)
- [Docker Installation Guide](https://docs.docker.com/engine/install/ubuntu/)
- [Personal Access Token Documentation](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens?view=azure-devops)

---

**Happy Building!** 🚀 Your self-hosted agent is now ready to process Azure DevOps pipelines with Docker support.
