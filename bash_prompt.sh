# Custom PS1 Prompt with Time, Path and Git Branch
# Colors that look good on black terminal backgrounds
CYAN="\[\033[36m\]"
GREEN="\[\033[32m\]"
YELLOW="\[\033[33m\]"
MAGENTA="\[\033[35m\]"
RESET="\[\033[0m\]"

# Function to get current git branch if in a git repository
git_branch() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    echo " ($branch)"
  fi
}

# Main PS1 function
prompt_command() {
  # Get current time in 12-hour format with AM/PM
  local time=$(date "+%I:%M:%S %p")
  
  # Check if current path is under $HOME
  local current_path=$(pwd)
  if [[ "$current_path" == "$HOME"* ]]; then
    # Show path relative to $HOME with ~/
    current_path="~${current_path#$HOME}"
  fi
  
  # Get git branch information
  local git_info=$(git_branch)
  
  # Set the PS1
  PS1="${MAGENTA}[${time}]${RESET}${YELLOW}${git_info}${RESET} ${WHITE}${current_path}${RESET}$ "
}

# Set the PROMPT_COMMAND to update PS1 before each prompt
PROMPT_COMMAND=prompt_command

