# Popstart Setup Guide

This guide provides instructions on how to execute the shell scripts in this repository and the order of execution. Each script serves a specific purpose in setting up your development environment.

## Order of Execution

1. **WSL2 and Ubuntu 24.04 LTS Setup**
2. **ZSH and Oh My Posh Setup**
3. **Fullstack Development Tools Setup**

## 1. WSL2 and Ubuntu 24.04 LTS Setup

### Script: `wsl-setup/WSL2_ubuntu_setup.ps1`

#### Purpose:
This PowerShell script automates the setup of WSL2 features and installs Ubuntu 24.04 LTS on Windows. It ensures that all necessary Windows features are enabled and sets WSL2 as the default version.

#### Execution:
1. Open PowerShell as an administrator.
2. Navigate to the `wsl-setup` directory.
3. Run the script using the following command:
   ```powershell
   .\WSL2_ubuntu_setup.ps1
   ```
4. Follow the on-screen instructions to complete the setup.

## 2. ZSH and Oh My Posh Setup

### Script: `zsh-posh-setup/shell-setup.sh`

#### Purpose:
This Bash script sets up ZSH with Oh My Posh, useful plugins, and various configurations. It installs necessary dependencies, configures readline settings, installs Oh My Posh and ZSH plugins, and sets ZSH as the default shell.

#### Execution:
1. Open a terminal.
2. Navigate to the `zsh-posh-setup` directory.
3. Run the script using the following command:
   ```bash
   ./shell-setup.sh
   ```
4. Follow the on-screen instructions to complete the setup.

## 3. Fullstack Development Tools Setup

### Script: `dev-tools/tools.sh`

#### Purpose:
This Bash script sets up a fullstack development environment by installing essential tools, libraries, and programming languages. It also prompts the user to install databases and Docker.

#### Development Tools Installed:

- **Essential Packages:**
  - git
  - curl
  - wget
  - build-essential
  - pkg-config
  - autoconf
  - bison
  - rustc
  - cargo
  - clang
  - libssl-dev
  - libreadline-dev
  - zlib1g-dev
  - libyaml-dev
  - libreadline-dev
  - libncurses5-dev
  - libffi-dev
  - libgdbm-dev
  - libjemalloc2s
  - libvips
  - imagemagick
  - libmagickwand-dev
  - mupdf
  - mupdf-tools
  - redis-tools
  - sqlite3
  - libsqlite3-0
  - libmysqlclient-dev
  - unzip

- **LazyGit**
- **LazyDocker**
- **Mise (for managing Node.js, Python, Rust, and Go versions)**
- **Node.js (LTS version)**
- **Python (latest version)**
- **Rust (stable version)**
- **Go (latest version)**

#### Global npm Packages Installed:
- typescript
- ts-node
- nodemon
- create-react-app
- create-next-app
- shadcn-ui

#### Global Python Packages Installed:
- poetry
- virtualenv
- pipenv
- flask
- django
- fastapi

#### Optional Databases:
- PostgreSQL
- MongoDB
- Redis
- MySQL

#### Optional Docker Installation

#### Execution:
1. Open a terminal.
2. Navigate to the `dev-tools` directory.
3. Run the script using the following command:
   ```bash
   ./tools.sh
   ```
4. Follow the on-screen instructions to complete the setup.

## Additional Notes

- Ensure you have the necessary permissions to execute the scripts.
- Some scripts may require a system restart to complete the setup.
- After running the scripts, verify that the installations were successful by checking the versions of the installed tools and configurations.

By following this guide, you will have a fully configured development environment ready for use.
