#!/bin/bash

set -e

echo "🚀 Setting up your fullstack development environment..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed based on package manager
is_package_installed() {
    local package=$1
    if command_exists apt; then
        dpkg -l "$package" > /dev/null 2>&1
    elif command_exists dnf; then
        dnf list installed "$package" > /dev/null 2>&1
    elif command_exists pacman; then
        pacman -Q "$package" > /dev/null 2>&1
    else
        return 1
    fi
}

# Function to install a single package with check
install_package() {
    local package=$1
    if is_package_installed "$package"; then
        echo "✓ $package is already installed"
    else
        echo "📦 Installing $package..."
        if command_exists apt; then
            sudo apt install -y "$package"
        elif command_exists dnf; then
            sudo dnf install -y "$package"
        elif command_exists pacman; then
            sudo pacman -S --noconfirm "$package"
        else
            echo "❌ Unsupported package manager"
            exit 1
        fi
    fi
}

# Function to install from GitHub release with version check
install_from_github() {
    local repo=$1
    local binary=$2
    
    if command_exists $binary; then
        echo "✓ $binary is already installed"
        return 0
    fi

    echo "📦 Installing $binary..."
    local latest_release_url="https://api.github.com/repos/$repo/releases/latest"
    
    # Get the latest release tag
    local latest_version=$(curl -s $latest_release_url | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd $temp_dir
    
    # Download and install based on architecture
    local arch=$(uname -m)
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    if [ "$arch" = "x86_64" ]; then
        arch="x86_64"
    elif [ "$arch" = "aarch64" ]; then
        arch="arm64"
    fi
    
    # Download the latest release
    local download_url="https://github.com/$repo/releases/download/$latest_version/${binary}_${latest_version#v}_${os}_${arch}.tar.gz"
    wget $download_url -O $binary.tar.gz
    
    # Extract and install
    tar xf $binary.tar.gz
    sudo mv $binary /usr/local/bin/
    
    # Cleanup
    cd -
    rm -rf $temp_dir
}

# Install essential development tools and libraries
echo "📦 Checking and installing essential development tools and libraries..."
ESSENTIAL_PACKAGES="git curl wget build-essential pkg-config autoconf bison rustc cargo clang \
    libssl-dev libreadline-dev zlib1g-dev libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev libjemalloc2 \
    libvips imagemagick libmagickwand-dev mupdf mupdf-tools \
    redis-tools sqlite3 libsqlite3-0 libmysqlclient-dev unzip"

if command_exists apt; then
    echo "📦 Updating package lists..."
    sudo apt update
    
    # Install packages one by one to check status
    for package in $ESSENTIAL_PACKAGES; do
        install_package "$package"
    done
elif command_exists dnf; then
    # Convert Ubuntu/Debian package names to Fedora equivalents
    FEDORA_PACKAGES="git curl wget @development-tools pkg-config autoconf bison rust cargo clang \
        openssl-devel readline-devel zlib-devel libyaml-devel readline-devel ncurses-devel libffi-devel gdbm-devel jemalloc \
        vips imagemagick ImageMagick-devel mupdf \
        redis sqlite sqlite-devel mysql-devel unzip"
    
    for package in $FEDORA_PACKAGES; do
        install_package "$package"
    done
elif command_exists pacman; then
    # Convert Ubuntu/Debian package names to Arch equivalents
    ARCH_PACKAGES="git curl wget base-devel pkg-config autoconf bison rust cargo clang \
        openssl readline zlib libyaml readline ncurses libffi gdbm jemalloc \
        libvips imagemagick mupdf \
        redis sqlite mysql-clients unzip"
    
    # Update package database
    sudo pacman -Sy
    
    for package in $ARCH_PACKAGES; do
        install_package "$package"
    done
else
    echo "❌ Unsupported package manager"
    exit 1
fi

# Install lazygit
echo "📦 Checking lazygit installation..."
if command_exists lazygit; then
    echo "✓ lazygit is already installed"
else
    echo "📦 Installing lazygit..."
    if command_exists apt; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
    elif command_exists pacman; then
        sudo pacman -S --noconfirm lazygit
    else
        install_from_github "jesseduffield/lazygit" "lazygit"
    fi
fi

# Install lazydocker
echo "📦 Checking lazydocker installation..."
if command_exists lazydocker; then
    echo "✓ lazydocker is already installed"
else
    install_from_github "jesseduffield/lazydocker" "lazydocker"
fi

# Install mise if not already installed
if command_exists mise; then
    echo "✓ mise is already installed"
else
    echo "🔧 Installing mise..."
    curl https://mise.run | sh
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
    source ~/.bashrc
fi

# Setup Node.js using mise
echo "📦 Setting up Node.js..."
if mise which node > /dev/null 2>&1; then
    echo "✓ Node.js is already set up with mise"
else
    mise use node@lts
    mise install node@lts
fi

# Setup Python using mise
echo "🐍 Setting up Python..."
if mise which python > /dev/null 2>&1; then
    echo "✓ Python is already set up with mise"
else
    mise use python@latest
    mise install python@latest
fi

# Install Rust using mise
echo "🦀 Setting up Rust..."
if mise which rust > /dev/null 2>&1; then
    echo "✓ Rust is already set up with mise"
else
    mise use rust@stable
    mise install rust@stable
fi

# Install Go using mise
echo "🐹 Setting up Go..."
if mise which go > /dev/null 2>&1; then
    echo "✓ Go is already set up with mise"
else
    mise use go@latest
    mise install go@latest
fi

# Function to check if global npm package is installed
is_npm_package_installed() {
    npm list -g "$1" > /dev/null 2>&1
}

# Install common global npm packages
echo "📦 Checking and installing common npm packages..."
npm_packages=("typescript" "ts-node" "nodemon" "create-react-app" "create-next-app" "shadcn-ui")

for package in "${npm_packages[@]}"; do
    if is_npm_package_installed "$package"; then
        echo "✓ $package is already installed globally"
    else
        echo "📦 Installing $package globally..."
        npm install -g "$package"
    fi
done

# Function to check if Python package is installed
is_pip_package_installed() {
    pip show "$1" > /dev/null 2>&1
}

# Install essential Python packages
echo "🐍 Checking and installing essential Python packages..."
pip_packages=("poetry" "virtualenv" "pipenv" "flask" "django" "fastapi")

for package in "${pip_packages[@]}"; do
    if is_pip_package_installed "$package"; then
        echo "✓ $package is already installed"
    else
        echo "📦 Installing $package..."
        pip install "$package"
    fi
done

# Database installation prompt
echo "🗄️ Would you like to install any databases? (y/n)"
read -r install_db

if [ "$install_db" = "y" ] || [ "$install_db" = "Y" ]; then
    echo "Select databases to install (enter numbers separated by space):"
    echo "1) PostgreSQL"
    echo "2) MongoDB"
    echo "3) Redis"
    echo "4) MySQL"
    read -r db_choices

    for choice in $db_choices; do
        case $choice in
            1)
                if command_exists psql; then
                    echo "✓ PostgreSQL is already installed"
                else
                    echo "📦 Installing PostgreSQL..."
                    install_package "postgresql postgresql-contrib"
                    sudo systemctl enable postgresql
                    sudo systemctl start postgresql
                fi
                ;;
            2)
                if command_exists mongod; then
                    echo "✓ MongoDB is already installed"
                else
                    echo "📦 Installing MongoDB..."
                    if command_exists apt; then
                        wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
                        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
                        sudo apt update
                        sudo apt install -y mongodb-org
                        sudo systemctl enable mongod
                        sudo systemctl start mongod
                    else
                        echo "MongoDB installation is currently only supported for Ubuntu-based systems"
                    fi
                fi
                ;;
            3)
                if command_exists redis-server; then
                    echo "✓ Redis is already installed"
                else
                    echo "📦 Installing Redis..."
                    install_package "redis"
                    sudo systemctl enable redis
                    sudo systemctl start redis
                fi
                ;;
            4)
                if command_exists mysql; then
                    echo "✓ MySQL is already installed"
                else
                    echo "📦 Installing MySQL..."
                    install_package "mysql-server"
                    sudo systemctl enable mysql
                    sudo systemctl start mysql
                fi
                ;;
        esac
    done
fi

# Docker installation check
echo "🐳 Would you like to install Docker? (y/n)"
read -r install_docker

if [ "$install_docker" = "y" ] || [ "$install_docker" = "Y" ]; then
    if command_exists docker; then
        echo "✓ Docker is already installed"
    else
        echo "📦 Installing Docker..."
        if command_exists apt; then
            # Add Docker's official GPG key
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            
            # Add Docker repository
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Update package list
            sudo apt update
            
            # Install Docker engine and plugins
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
            
            # Configure Docker logging
            sudo mkdir -p /etc/docker
            echo '{"log-driver":"local","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json > /dev/null
            
            # Add user to docker group and start service
            sudo usermod -aG docker "$USER"
            sudo systemctl enable docker
            sudo systemctl start docker
        else
            echo "Docker installation is currently only supported for Ubuntu-based systems"
        fi
    fi
fi

# Set up configuration directories if they don't exist
for dir in ~/.config/lazygit ~/.config/lazydocker; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created configuration directory: $dir"
    fi
done

# Final setup and verification
echo "🔍 Verifying installations..."
echo "Node.js version: $(node --version)"
echo "Python version: $(python --version)"
echo "Rust version: $(rustc --version)"
echo "Go version: $(go version)"
echo "Lazygit version: $(lazygit --version)"
echo "Lazydocker version: $(lazydocker --version)"

echo "✅ Setup complete! Please restart your terminal for all changes to take effect."
echo "🎉 Happy coding!"

echo "
📝 Next steps for a new Next.js project with shadcn/ui:
1. Create a new Next.js project:
   npx create-next-app@latest my-app
2. CD into your project:
   cd my-app
3. Initialize shadcn-ui:
   npx shadcn-ui@latest init
4. Start adding components:
   npx shadcn-ui@latest add button
   (and any other components you need)
"