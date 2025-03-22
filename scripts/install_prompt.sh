#!/bin/bash
# Custom Prompt Configuration Installer
# Detects shell type and installs the appropriate prompt configuration

# Prompt files
BASH_PROMPT_FILE="bash_prompt.sh"
ZSH_PROMPT_FILE="zsh_prompt.sh"

# Check that prompt files exist
if [ ! -f "$BASH_PROMPT_FILE" ]; then
  echo "Error: Bash prompt file not found at $BASH_PROMPT_FILE"
  return 1
fi

if [ ! -f "$ZSH_PROMPT_FILE" ]; then
  echo "Error: Zsh prompt file not found at $ZSH_PROMPT_FILE"
  return 1
fi

# Determine shell type
if [ -z "$SHELL_CONFIG" ]; then
  echo "Error: SHELL_CONFIG environment variable is not set"
  return 1
fi

echo "Using shell config: $SHELL_CONFIG"

# Determine shell type based on config file or current shell
if [[ "$SHELL_CONFIG" == *".zshrc" ]] || [[ "$SHELL" == *"zsh"* ]]; then
  SHELL_TYPE="zsh"
  PROMPT_FILE="$ZSH_PROMPT_FILE"
else
  SHELL_TYPE="bash"
  PROMPT_FILE="$BASH_PROMPT_FILE"
fi

echo "Detected shell type: $SHELL_TYPE"

# Add source command to shell config
START_MARKER="# === CUSTOM PROMPT CONFIGURATION START ==="
END_MARKER="# === CUSTOM PROMPT CONFIGURATION END ==="

# Remove any existing prompt configuration
if grep -q "$START_MARKER" "$SHELL_CONFIG" 2>/dev/null; then
  echo "Removing existing custom prompt configuration..."
  # Create a temporary file
  TEMP_FILE=$(mktemp)
  # Extract the file content without the section between markers
  sed "/$START_MARKER/,/$END_MARKER/d" "$SHELL_CONFIG" > "$TEMP_FILE"
  # Replace the original file with the modified content
  mv "$TEMP_FILE" "$SHELL_CONFIG"
fi

# Install the prompt file in user's config directory
PROMPT_INSTALL_PATH="$HOME/.config/shell/custom_prompt.sh"

# Create the install directory if it doesn't exist
mkdir -p "$(dirname "$PROMPT_INSTALL_PATH")"

# Install the prompt file using install-linked function
install-linked "$PROMPT_FILE" "$PROMPT_INSTALL_PATH"

# Add sourcing command to shell config
echo "$START_MARKER" >> "$SHELL_CONFIG"
echo "source \"$PROMPT_INSTALL_PATH\"" >> "$SHELL_CONFIG"
echo "$END_MARKER" >> "$SHELL_CONFIG"

echo "Installation complete!"
echo "To apply changes, run: source \"$SHELL_CONFIG\""

# Clean up
rm -rf "$TEMP_DIR"


