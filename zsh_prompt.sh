# Custom Zsh Prompt with Time, Path and Git Branch
# Colors that look good on black terminal backgrounds
CYAN="%F{cyan}"
GREEN="%F{green}"
YELLOW="%F{yellow}"
MAGENTA="%F{magenta}"
RESET="%f"

# Need to load the vcs_info system for git information
autoload -Uz vcs_info
precmd() { vcs_info }

# Configure the vcs_info format
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats " (%b)"
zstyle ':vcs_info:git:*' enable git

# Function to format the path (relative to HOME or absolute)
format_path() {
  local current_path="$PWD"
  if [[ "$current_path" == "$HOME"* ]]; then
    # Show path relative to $HOME with ~/
    echo "~${current_path#$HOME}"
  else
    # Show absolute path
    echo "$current_path"
  fi
}

# Set the prompt with all required elements
setopt PROMPT_SUBST
PROMPT='${MAGENTA}[%D{%I:%M:%S %p}]${RESET}${YELLOW}${vcs_info_msg_0_}${RESET} ${WHITE}$(format_path)${RESET}$ '

