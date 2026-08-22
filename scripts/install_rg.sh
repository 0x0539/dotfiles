# Install ripgrep. Needed by fzf-lua's grep_project (<C-g>) and AstroNvim's
# <Leader>fw, so a silent failure here surfaces much later as an empty picker.
if ! command -v rg &> /dev/null; then
    echo "Installing ripgrep..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install ripgrep
        else
            echo "ERROR: Homebrew not found; cannot install ripgrep."
            echo "       Install Homebrew (https://brew.sh), or install ripgrep manually:"
            echo "         https://github.com/BurntSushi/ripgrep#installation"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ripgrep
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y ripgrep
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ripgrep
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y ripgrep
        else
            echo "ERROR: No supported package manager found (tried apt-get, dnf, pacman, zypper)."
            echo "       Install ripgrep manually:"
            echo "         https://github.com/BurntSushi/ripgrep#installation"
        fi
    else
        echo "ERROR: Unsupported OS '$OSTYPE'; cannot install ripgrep."
    fi

    # Report the outcome rather than exiting 0 regardless of what happened above.
    if command -v rg &> /dev/null; then
        echo "ripgrep installed: $(rg --version | head -1)"
    else
        echo "WARNING: ripgrep is still not on PATH. Fuzzy search in nvim will not work."
    fi
else
    echo "ripgrep already installed: $(rg --version | head -1)"
fi
