#!/bin/bash

###################
# Initial Setup
###################

# Print welcome message
echo "Starting ZSH installation and configuration..."
echo "This script will set up ZSH with Oh My Posh, useful plugins, and various configurations."
echo

# Ensure we have sudo privileges
if [ "$EUID" -ne 0 ]; then 
    echo "Checking sudo privileges..."
    sudo -v
    # Keep-alive: update existing sudo time stamp if set, otherwise do nothing
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# Install git, unzip and curl first as a critical dependency
sudo apt update -y
echo "Installing git..."
sudo apt-get update > /dev/null
sudo apt-get install -y git unzip curl > /dev/null

# Exit on error to prevent partial installations
set -e

###################
# Helper Functions
###################

# Function to print colorized output for better visibility
# Arguments: $1 = color code, $2 = message
print_status() {
    local color=$1
    local message=$2
    echo -e "\e[${color}m${message}\e[0m"
}

# Function to check if a command exists in the system
# Arguments: $1 = command name
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup existing configurations
# Creates timestamped backups of existing config files
backup_configs() {
    if [ -f ~/.zshrc ]; then
        print_status "33" "Backing up existing .zshrc..."
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    fi
    if [ -f ~/.inputrc ]; then
        print_status "33" "Backing up existing .inputrc..."
        cp ~/.inputrc ~/.inputrc.backup.$(date +%Y%m%d_%H%M%S)
    fi
}

# Function to check and install prerequisites
check_prerequisites() {
    print_status "36" "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check for required commands
    for cmd in curl eza fzf bat fd-find; do
        if ! command_exists $cmd; then
            missing_deps+=($cmd)
        fi
    done
    
    # Install missing dependencies
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_status "31" "Missing required dependencies: ${missing_deps[*]}"
        print_status "33" "Installing missing dependencies..."
        sudo apt update
        sudo apt install -y "${missing_deps[@]}"
    fi
}

# Function to configure readline settings
configure_readline() {
    print_status "36" "Configuring readline settings..."
    cat > ~/.inputrc << 'EOF'
# Input settings
set meta-flag on
set input-meta on
set output-meta on
set convert-meta off

# Completion settings
set completion-ignore-case on
set completion-prefix-display-length 2
set show-all-if-ambiguous on
set show-all-if-unmodified on

# Arrow key history search
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char

# Directory and file completion settings
set mark-symlinked-directories on
set match-hidden-files off
set page-completions off
set completion-query-items 200
set visible-stats on

$if Bash
  set skip-completed-text on
  set colored-stats on
$endif
EOF
}

# Function to configure ZSH settings and aliases
configure_zsh() {
    print_status "36" "Configuring ZSH settings and aliases..."
    cat > ~/.zshrc << 'EOF'
# Oh My Posh configuration
eval "$(oh-my-posh init zsh --config ~/.poshthemes/night-owl.omp.json)"

# ZSH Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

###################
# Custom Settings
###################

# File system aliases using modern alternatives
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'batcat --style=numbers --color=always {}'"
alias fd="fdfind"

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

###################
# Git Aliases
###################

# Basic git commands
alias g='git'
alias gi='git init'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gal='git add .'
alias gall='git add .'
alias gca='git commit --amend'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gd='git diff'
alias gf='git fetch'
alias gfo='git fetch origin'
alias gl='git log'
alias gll='git log --graph --oneline --all --decorate'
alias gld="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

# Branch operations
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout master'
alias gcod='git checkout develop'
alias gcp='git cherry-pick'

# Remote operations
alias gps='git push'
alias gpl='git pull'
alias gplo='git pull origin'
alias gpls='git pull && git status'
alias gplom='git pull origin master'
alias gpsom='git push origin master'
alias gpsod='git push origin develop'
alias gplos='git pull origin staging'
alias gpsos='git push origin staging'

# Stash operations
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash save'

# Reset operations
alias gr='git reset'
alias grs='git reset --soft'
alias grh='git reset --hard'
alias grhh='git reset --hard HEAD'
alias grho='git reset --hard origin/$(git branch --show-current)'

# Rebase operations
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbm='git rebase master'
alias grbd='git rebase develop'

# Merge operations
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gmm='git merge master'
alias gmd='git merge develop'

# Remote management
alias gra='git remote add'
alias grr='git remote remove'
alias grv='git remote -v'

# Clean operations
alias gclean='git clean -df'
alias gpristine='git reset --hard && git clean -dfx'

# Useful git aliases for specific scenarios
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
alias gundo='git reset --soft HEAD~1'
alias gredo='git commit -c HEAD@{1}'
alias gcount='git shortlog -sn'
alias gla='git log --author="$1"'
alias glf='git log --follow -p --'

# Show modified files in last commit
alias gls='git show --name-status'

# Show what was added to the last commit
alias gdlc='git diff --cached HEAD^'

# Show the diff of everything you haven't pushed yet
alias gunpushed='git diff origin/$(git rev-parse --abbrev-ref HEAD)..'

# Compression utilities
compress() {
    tar -czf "${1%/}.tar.gz" "${1%/}"
}
alias decompress="tar -xzf"

# WSL-specific (if applicable)
alias explorer='explorer.exe .'

# Environment settings
export EDITOR='nano'
export PAGER='less'

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

EOF
}

# Function to install Oh My Posh
install_oh_my_posh() {
    print_status "36" "Installing Oh My Posh..."
    
    # Download and install Oh My Posh
    curl -s https://ohmyposh.dev/install.sh | bash -s

    # Create Oh My Posh themes directory
    mkdir -p ~/.poshthemes

    # Download night-owl theme
    wget https://github.com/JanDeDobbeleer/oh-my-posh/raw/main/themes/night-owl.omp.json -O ~/.poshthemes/night-owl.omp.json
}

# Function to install ZSH plugins
install_zsh_plugins() {
    print_status "36" "Installing ZSH plugins..."

    # Create directory for ZSH plugins
    mkdir -p ~/.zsh

    # Install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions

    # Install zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
}

###################
# Main Installation
###################

main() {
    print_status "32" "Starting ZSH installation and configuration..."
    
    # Check and install prerequisites
    check_prerequisites
    
    # Backup existing configurations
    backup_configs
    
    # Install zsh if not present
    if ! command_exists zsh; then
        print_status "36" "Installing ZSH..."
        sudo apt install zsh -y
    fi
    
    # Display installed version
    print_status "36" "Installed ZSH version:"
    zsh --version
    
    # Set ZSH as default shell
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        print_status "36" "Setting ZSH as default shell..."
        chsh -s $(which zsh)
    fi
    
    # Install Oh My Posh
    install_oh_my_posh
    
    # Install ZSH plugins
    install_zsh_plugins
    
    # Configure readline settings
    configure_readline
    
    # Configure ZSH settings and aliases
    configure_zsh

    # Upgrade everything that might ask for a reboot last
    sudo apt upgrade -y
    
    print_status "32" "Installation and configuration completed successfully!"
    print_status "33" "Please log out and log back in to start using ZSH with Oh My Posh and plugins."
}

# Execute main installation
main "$@"