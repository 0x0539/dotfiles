#!/bin/bash
# Neovim Configuration Setup Script
# Works on both macOS and Linux
set -e  # Exit on error
echo "Setting up Neovim configuration..."
# Create necessary directories
mkdir -p ~/.config/nvim

# Determine shell config file
SHELL_CONFIG=""
if [[ "${OSTYPE}" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    if [ -f "$HOME/.zshrc" ] && [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    fi
fi

# Install neovim if not already installed
if ! command -v nvim &> /dev/null; then
    echo "Neovim is not installed. Installing..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install neovim
        else
            echo "Homebrew not found. Please install Homebrew first."
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - Install the latest version from GitHub
        echo "Installing latest Neovim from GitHub releases..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
        rm nvim-linux-x86_64.tar.gz
        
        # Add to PATH in the current shell session
        export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
        
        if [ -n "$SHELL_CONFIG" ]; then
            if ! grep -q "export PATH=\"\$PATH:/opt/nvim-linux-x86_64/bin\"" "$SHELL_CONFIG"; then
                echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> "$SHELL_CONFIG"
                echo "Added Neovim to PATH in $SHELL_CONFIG"
            fi
        else
            echo "WARNING: Could not determine shell config file. Please manually add the following line to your shell config:"
            echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"'
        fi
    else
        echo "Unsupported operating system."
        exit 1
    fi
fi

# Install fzf if not already installed
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# Install ripgrep for Rg command
if ! command -v rg &> /dev/null; then
    echo "Installing ripgrep..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install ripgrep
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ripgrep
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ripgrep
        fi
    fi
fi

# Copy the init.vim file
echo "Copying Neovim configuration..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "$SCRIPT_DIR/init.vim" ]; then
  cp "$SCRIPT_DIR/init.vim" ~/.config/nvim/init.vim
  echo "Copied init.vim from local directory."
else
  echo "Error: init.vim file not found in the same directory as this script."
  echo "Please make sure init.vim is in: $SCRIPT_DIR"
  exit 1
fi

# Add custom shell configuration lines
add_shell_config() {
    if [ -n "$SHELL_CONFIG" ]; then
        echo "Adding custom configurations to $SHELL_CONFIG..."
        
        # Array of configuration lines to add
        CONFIG_LINES=(
            "alias vim=nvim"
            # Add more configuration lines here as needed
            # "export EDITOR=nvim"
            # "alias ll='ls -la'"
        )
        
        # Check if the Neovim configuration header exists, add if it doesn't
        if ! grep -q "# Neovim aliases and configurations" "$SHELL_CONFIG"; then
            echo -e "\n# Neovim aliases and configurations" >> "$SHELL_CONFIG"
        fi
        
        # Process each configuration line
        for config_line in "${CONFIG_LINES[@]}"; do
            if ! grep -q "^${config_line}$" "$SHELL_CONFIG"; then
                echo "${config_line}" >> "$SHELL_CONFIG"
                echo "Added '${config_line}' to $SHELL_CONFIG"
            else
                echo "'${config_line}' already exists in $SHELL_CONFIG"
            fi
        done
        
        echo "Shell configuration updated. Changes will take effect in new terminal sessions."
        echo "To apply changes to the current session, run: source $SHELL_CONFIG"
    else
        echo "WARNING: Could not determine shell config file. Please manually add these lines to your shell config:"
        for config_line in "${CONFIG_LINES[@]}"; do
            echo "${config_line}"
        done
    fi
}

echo "Configuration complete!"
echo "Starting Neovim to install plugins..."
nvim +PlugInstall +qall

# Install tmux if not already installed
if ! command -v tmux &> /dev/null; then
    echo "Tmux is not installed. Installing..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install tmux
        else
            echo "Homebrew not found. Please install Homebrew first to install tmux."
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - Install tmux from AppImage
        echo "Installing tmux from AppImage..."
        
        # Check if FUSE is installed
        sudo apt-get install libfuse2
        
        # Create directory for AppImages
        mkdir -p "$HOME/.local/bin"
        
        # Download tmux AppImage
        curl -L https://github.com/nelsonenzo/tmux-appimage/releases/download/3.3a/tmux.appimage -o "$HOME/.local/bin/tmux"
        chmod +x "$HOME/.local/bin/tmux"
        
        # Add to PATH in the current shell session
        export PATH="$PATH:$HOME/.local/bin"
        
        if [ -n "$SHELL_CONFIG" ]; then
            if ! grep -q "export PATH=\"\$PATH:\$HOME/.local/bin\"" "$SHELL_CONFIG"; then
                echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$SHELL_CONFIG"
                echo "Added ~/.local/bin to PATH in $SHELL_CONFIG"
            fi
        else
            echo "WARNING: Could not determine shell config file. Please manually add the following line to your shell config:"
            echo 'export PATH="$PATH:$HOME/.local/bin"'
        fi
    fi
fi

# Add custom shell configurations
add_shell_config

echo "Setup complete! You can now use nvim and tmux."
