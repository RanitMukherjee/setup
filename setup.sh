#!/usr/bin/env bash

# ===============================
# Dev Environment Bootstrap Script
# ===============================
# Installs: Go, NVM & Node LTS, VS Code, Docker, GitHub CLI, Git config
# Clones your forks and sets up upstreams
# Author: RanitMukherjee (adapt as needed)
# ===============================

set -e

# --- 1. Update and Install Essentials ---
echo "Updating system and installing essential packages..."
sudo apt update
sudo apt install -y wget curl git build-essential apt-transport-https ca-certificates gnupg lsb-release software-properties-common

# --- 2. Install Latest Go (official tarball) ---
GO_VERSION="1.24.3"
GO_ARCH="amd64"
echo "Installing Go $GO_VERSION..."
sudo rm -rf /usr/local/go
wget -q https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz -O /tmp/go${GO_VERSION}.tar.gz
sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.tar.gz
if ! grep -q '/usr/local/go/bin' ~/.profile; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi
source ~/.profile
go version

# --- 3. Install NVM and Node.js LTS ---
echo "Installing NVM (Node Version Manager)..."
export NVM_VERSION="v0.39.7"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash

# Load NVM into current shell session
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Installing Node.js LTS via NVM..."
nvm install --lts
nvm use --lts
node -v
npm -v

# --- 4. Install VS Code (official .deb with repo for updates) ---
echo "Installing VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt update
sudo apt install -y code

# --- 5. Install Docker Engine (official) ---
echo "Installing Docker..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo groupadd docker || true
sudo usermod -aG docker $USER
echo "You may need to log out and log back in for Docker group permissions to take effect."

# --- 6. Install GitHub CLI (official) ---
echo "Installing GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh


echo "Setup complete!"
echo "Remember to log out and back in (or run 'newgrp docker') to use Docker without sudo."
echo "You can now develop, sync forks with 'gh repo sync', and use Go, Node.js, VS Code, Docker, and GitHub CLI."
