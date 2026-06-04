# Install fzf and enable shell integration (Ctrl-R fuzzy history, Ctrl-T files).

# 1. Install the fzf binary if it isn't already available.
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install fzf
        else
            echo "Homebrew not found. Please install Homebrew first to install fzf."
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Clone the latest fzf (apt's package is too old for `fzf --zsh`/`--bash`).
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --bin --no-update-rc --no-key-bindings --no-completion
        export PATH="$PATH:$HOME/.fzf/bin"
        if [ -n "$SHELL_CONFIG" ] && ! grep -q 'export PATH="$PATH:$HOME/.fzf/bin"' "$SHELL_CONFIG"; then
            echo 'export PATH="$PATH:$HOME/.fzf/bin"' >> "$SHELL_CONFIG"
            echo "Added ~/.fzf/bin to PATH in $SHELL_CONFIG"
        fi
    fi
fi

# 2. Enable fzf shell integration (key bindings + completion). fzf >= 0.48
#    generates these via `fzf --<shell>`. Guarded so re-runs don't duplicate.
if command -v fzf &> /dev/null && [ -n "$SHELL_CONFIG" ]; then
    FZF_MARKER="# fzf shell integration (key bindings + completion)"
    if ! grep -qF "$FZF_MARKER" "$SHELL_CONFIG"; then
        echo "Enabling fzf shell integration in $SHELL_CONFIG..."
        if [[ "$SHELL_CONFIG" == *".zshrc" ]] || [[ "$SHELL" == *"zsh"* ]]; then
            FZF_SOURCE='command -v fzf >/dev/null && source <(fzf --zsh)'
        else
            FZF_SOURCE='command -v fzf >/dev/null && eval "$(fzf --bash)"'
        fi
        printf '\n%s\n%s\n' "$FZF_MARKER" "$FZF_SOURCE" >> "$SHELL_CONFIG"
    else
        echo "fzf shell integration already present in $SHELL_CONFIG"
    fi
fi
