#!/bin/bash
# System Setup Script
# Works on both macOS and Linux
set -e  # Exit on error

# Determine shell config file
export SHELL_CONFIG=""
if [[ "${OSTYPE}" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    if [ -f "$HOME/.zshrc" ] && [[ "$SHELL" == *"zsh"* ]]; then
        export SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        export SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        export SHELL_CONFIG="$HOME/.bash_profile"
    fi
fi

# Function to install a file as a symbolic link
install-linked() {
    if [ $# -ne 2 ]; then
        echo "Usage: install-linked <path-to-source-file> <path-to-link>"
        return 1
    fi

    source_file="$1"
    link_path="$2"

    # Check if source file exists
    if [ ! -e "$source_file" ]; then
        echo "Error: Source file '$source_file' does not exist"
        return 1
    fi

    # Create necessary parent directories for the link
    link_dir=$(dirname "$link_path")
    if [ ! -d "$link_dir" ]; then
        mkdir -p "$link_dir"
        echo "Created directory: $link_dir"
    fi

    # Remove existing link or file
    if [ -e "$link_path" ] || [ -L "$link_path" ]; then
        rm -f "$link_path"
        echo "Removed existing file or link: $link_path"
    fi

    # Create the symbolic link
    ln -s "$(realpath "$source_file")" "$link_path"
    echo "Created symbolic link: $link_path -> $source_file"
}

. install_nvim.sh
. install_fzf.sh
. install_rg.sh
. install_shell_config.sh
. install_tmux.sh

echo "Setup complete! You can now use nvim and tmux."
