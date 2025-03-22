# Add custom shell configuration lines
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
