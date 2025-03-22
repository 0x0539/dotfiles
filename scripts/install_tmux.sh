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

echo "Copying tmux configuration..."
install-linked tmux.conf ~/.tmux.conf
