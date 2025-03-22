#!/bin/bash
# Custom Prompt Configuration Installer
# Detects shell type and installs the appropriate prompt configuration

set -e  # Exit on error

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Prompt files
BASH_PROMPT_FILE="$SCRIPT_DIR/bash_prompt.sh"
ZSH_PROMPT_FILE="$SCRIPT_DIR/zsh_prompt.sh"

# Check that prompt files exist
if [ ! -f "$BASH_PROMPT_FILE" ]; then
  echo "Error: Bash prompt file not found at $BASH_PROMPT_FILE"
  exit 1
fi

if [ ! -f "$ZSH_PROMPT_FILE" ]; then
  echo "Error: Zsh prompt file not found at $ZSH_PROMPT_FILE"
  exit 1
fi

# Determine the user's default shell
if [ -n "$ZSH_VERSION" ]; then
  SHELL_TYPE="zsh"
  CONFIG_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_TYPE="bash"
  CONFIG_FILE="$HOME/.bashrc"
else
  # Try to determine shell from process
  CURRENT_SHELL=$(basename "$(ps -p $$ -o comm=)")
  if [ "$CURRENT_SHELL" = "zsh" ]; then
    SHELL_TYPE="zsh"
    CONFIG_FILE="$HOME/.zshrc"
  elif [ "$CURRENT_SHELL" = "bash" ]; then
    SHELL_TYPE="bash"
    CONFIG_FILE="$HOME/.bashrc"
  else
    echo "Could not determine shell type. Please specify with --shell=bash or --shell=zsh"
    exit 1
  fi
fi

# Check for manual override
for arg in "$@"; do
  if [[ "$arg" == "--shell=bash" ]]; then
    SHELL_TYPE="bash"
    CONFIG_FILE="$HOME/.bashrc"
  elif [[ "$arg" == "--shell=zsh" ]]; then
    SHELL_TYPE="zsh"
    CONFIG_FILE="$HOME/.zshrc"
  elif [[ "$arg" == "--file="* ]]; then
    CONFIG_FILE="${arg#--file=}"
  fi
done

echo "Detected shell: $SHELL_TYPE"
echo "Config file: $CONFIG_FILE"

# Backup existing config file
if [ -f "$CONFIG_FILE" ]; then
  BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
  echo "Creating backup of $CONFIG_FILE to $BACKUP_FILE"
  cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

# Create a section marker for easy removal later
START_MARKER="# === CUSTOM PROMPT CONFIGURATION START ==="
END_MARKER="# === CUSTOM PROMPT CONFIGURATION END ==="

# Remove any existing prompt configuration
if grep -q "$START_MARKER" "$CONFIG_FILE" 2>/dev/null; then
  echo "Removing existing custom prompt configuration..."
  # Create a temporary file
  TEMP_FILE=$(mktemp)
  # Extract the file content without the section between markers
  sed "/$START_MARKER/,/$END_MARKER/d" "$CONFIG_FILE" > "$TEMP_FILE"
  # Replace the original file with the modified content
  mv "$TEMP_FILE" "$CONFIG_FILE"
fi

# Append the appropriate prompt configuration to the shell config file
echo "Installing custom prompt for $SHELL_TYPE..."
echo "$START_MARKER" >> "$CONFIG_FILE"

if [ "$SHELL_TYPE" = "bash" ]; then
  cat "$BASH_PROMPT_FILE" >> "$CONFIG_FILE"
elif [ "$SHELL_TYPE" = "zsh" ]; then
  cat "$ZSH_PROMPT_FILE" >> "$CONFIG_FILE"
fi

echo "$END_MARKER" >> "$CONFIG_FILE"

echo "Installation complete!"
echo "To apply changes, run: source $CONFIG_FILE"
