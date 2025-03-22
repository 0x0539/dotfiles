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

