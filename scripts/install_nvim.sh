echo "Setting up Neovim configuration..."

NVIM_CONFIG_DIR="$HOME/.config/nvim"
ASTRONVIM_TEMPLATE="https://github.com/AstroNvim/template"

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

# Bootstrap AstroNvim if it isn't already installed. AstroNvim is a lazy.nvim
# distro; its presence is signalled by lua/lazy_setup.lua.
if [ -f "$NVIM_CONFIG_DIR/lua/lazy_setup.lua" ]; then
    echo "Found an existing AstroNvim setup -- leaving it untouched."
elif [ -d "$NVIM_CONFIG_DIR" ] && [ -n "$(ls -A "$NVIM_CONFIG_DIR" 2>/dev/null)" ]; then
    echo "ERROR: $NVIM_CONFIG_DIR exists but is not an AstroNvim install."
    echo "Refusing to overwrite it. Move it aside and re-run."
    exit 1
else
    echo "No Neovim config found -- bootstrapping AstroNvim..."
    git clone --depth 1 "$ASTRONVIM_TEMPLATE" "$NVIM_CONFIG_DIR"
    rm -rf "$NVIM_CONFIG_DIR/.git"
fi

# Drop our personal spec into AstroNvim's auto-loaded plugins/ folder. AstroNvim
# loads every file there via `{ import = "plugins" }` in lazy_setup.lua, so this
# is purely additive -- we never touch init.lua or any existing file.
mkdir -p "$NVIM_CONFIG_DIR/lua/plugins"
install-linked nvim/lua/plugins/dotfiles.lua "$NVIM_CONFIG_DIR/lua/plugins/dotfiles.lua"

echo "Syncing plugins with lazy.nvim..."
# Non-fatal: a sync hiccup shouldn't abort the rest of the install (set -e).
nvim --headless "+Lazy! sync" +qa \
    || echo "WARNING: lazy.nvim sync reported an error. Open nvim and run :Lazy sync to retry."
