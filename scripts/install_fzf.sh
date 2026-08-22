# Install fzf and enable shell integration (Ctrl-R fuzzy history, Ctrl-T files).

# 1. Install the fzf binary if it isn't already available.
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install fzf
        else
            echo "ERROR: Homebrew not found; cannot install fzf."
            echo "       Install Homebrew (https://brew.sh), or install fzf manually:"
            echo "         https://github.com/junegunn/fzf#installation"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Clone the latest fzf (apt's package is too old for `fzf --zsh`/`--bash`).
        # Guarded: a bare `git clone` into an existing ~/.fzf exits non-zero and,
        # under `set -e`, would abort the whole install.
        if [ -d "$HOME/.fzf/.git" ]; then
            echo "~/.fzf already present; reusing it."
        elif [ -e "$HOME/.fzf" ]; then
            echo "ERROR: $HOME/.fzf exists but is not a git checkout."
            echo "       Move it aside and re-run to install fzf."
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        fi
        if [ -x "$HOME/.fzf/install" ]; then
            ~/.fzf/install --bin --no-update-rc --no-key-bindings --no-completion
            export PATH="$PATH:$HOME/.fzf/bin"
            if [ -n "$SHELL_CONFIG" ] && ! grep -q 'export PATH="$PATH:$HOME/.fzf/bin"' "$SHELL_CONFIG"; then
                echo 'export PATH="$PATH:$HOME/.fzf/bin"' >> "$SHELL_CONFIG"
                echo "Added ~/.fzf/bin to PATH in $SHELL_CONFIG"
            fi
        fi
    else
        echo "ERROR: Unsupported OS '$OSTYPE'; cannot install fzf."
    fi

    # Report the outcome rather than exiting 0 regardless of what happened above.
    if command -v fzf &> /dev/null; then
        echo "fzf installed: $(fzf --version)"
    else
        echo "WARNING: fzf is still not on PATH. <C-f>/<C-g> in nvim will not work."
    fi
else
    echo "fzf already installed: $(fzf --version)"
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
