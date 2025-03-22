echo "Setting up Neovim configuration..."

# Create necessary directories
mkdir -p ~/.config/nvim

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

# Copy the init.vim file
echo "Copying Neovim configuration..."
install-linked init.vim ~/.config/nvim/init.vim

echo "Starting Neovim to install plugins..."
nvim +PlugInstall +qall

