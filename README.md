# setup

A bash script to quickly set up a modern development environment on Ubuntu.

## What Will Be Installed

- Go (1.24.3)
- Node.js LTS (via NVM)
- VS Code (official .deb with auto-updates)
- Docker & Docker Compose
- Git
- GitHub CLI (`gh`)

## Quick Start

Run this command in your terminal (wget is available by default on Ubuntu):
    ```
    
    wget -O- https://github.com/RanitMukherjee/setup/raw/main/set-up.sh | bash
    ```

Or, to review before running:
    ```
    
    wget https://github.com/RanitMukherjee/setup/raw/main/set-up.sh
    chmod +x setup.sh
    ./setup.sh
    ```


## Practices Followed

- **No Snap packages used** (for better compatibility and integration)
- **Official sources only** (Go, Node, Docker, VS Code, GitHub CLI)
- **Adds user to docker group** (for Docker without sudo)
