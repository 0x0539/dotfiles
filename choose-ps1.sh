#!/bin/bash

# PS1 Prompt Generator Script
# This script helps you create a custom PS1 prompt for your Ubuntu terminal

clear
echo "=== Custom PS1 Prompt Generator ==="
echo "This script will help you build a custom terminal prompt."
echo "Select options for each component and see a preview."
echo "At the end, you can copy the final PS1 string to your .bashrc file."
echo ""

# Initialize PS1 components
ps1_string=""
components=()
colors=()

# Color definitions
declare -A color_codes=(
  ["none"]=""
  ["black"]="\[\033[0;30m\]"
  ["red"]="\[\033[0;31m\]"
  ["green"]="\[\033[0;32m\]"
  ["yellow"]="\[\033[0;33m\]"
  ["blue"]="\[\033[0;34m\]"
  ["magenta"]="\[\033[0;35m\]"
  ["cyan"]="\[\033[0;36m\]"
  ["white"]="\[\033[0;37m\]"
  ["bright_black"]="\[\033[1;30m\]"
  ["bright_red"]="\[\033[1;31m\]"
  ["bright_green"]="\[\033[1;32m\]"
  ["bright_yellow"]="\[\033[1;33m\]"
  ["bright_blue"]="\[\033[1;34m\]"
  ["bright_magenta"]="\[\033[1;35m\]"
  ["bright_cyan"]="\[\033[1;36m\]"
  ["bright_white"]="\[\033[1;37m\]"
)

reset_color="\[\033[0m\]"

# Function to show color preview
show_colors() {
  echo "Available colors:"
  for color in "${!color_codes[@]}"; do
    if [ "$color" != "none" ]; then
      echo -e "${color_codes[$color]}$color${reset_color}"
    else
      echo "none (default terminal color)"
    fi
  done
}

# Function to prompt for color selection
select_color() {
  local component_name=$1
  local selected_color
  
  show_colors
  
  while true; do
    read -p "Select color for $component_name (or press enter for none): " selected_color
    
    if [ -z "$selected_color" ]; then
      selected_color="none"
      break
    elif [ -n "${color_codes[$selected_color]}" ]; then
      break
    else
      echo "Invalid color. Please select from the available colors."
    fi
  done
  
  echo "$selected_color"
}

# Function to add a component with its color
add_component() {
  local component=$1
  local component_name=$2
  local color=$3
  
  components+=("$component")
  colors+=("$color")
  
  build_ps1_string
  preview_ps1
}

# Function to build the PS1 string
build_ps1_string() {
  ps1_string=""
  for i in "${!components[@]}"; do
    local color="${colors[$i]}"
    local component="${components[$i]}"
    
    if [ "$color" != "none" ]; then
      ps1_string+="${color_codes[$color]}$component$reset_color"
    else
      ps1_string+="$component"
    fi
  done
  
  # Add final reset and prompt character
  ps1_string+=" \$ "
}

# Function to preview current PS1
preview_ps1() {
  echo -e "\nCurrent PS1 preview:"
  echo -e "$ps1_string"
  echo -e "\nPS1 string (for .bashrc):"
  echo "PS1=\"$ps1_string\""
  echo ""
}

# Main menu function
show_menu() {
  echo "=== PS1 Components Menu ==="
  echo "1) Add username"
  echo "2) Add hostname"
  echo "3) Add current directory"
  echo "4) Add full path"
  echo "5) Add time (12-hour format)"
  echo "6) Add time (24-hour format)"
  echo "7) Add date"
  echo "8) Add Git branch (requires git-prompt.sh)"
  echo "9) Add custom text"
  echo "10) Add special character"
  echo "11) Preview current PS1"
  echo "12) Reset PS1"
  echo "13) Save and exit"
  echo ""
}

# Main loop
while true; do
  show_menu
  read -p "Select an option (1-13): " choice
  echo ""
  
  case $choice in
    1)
      color=$(select_color "username")
      add_component "\u" "username" "$color"
      ;;
    2)
      color=$(select_color "hostname")
      add_component "\h" "hostname" "$color"
      ;;
    3)
      color=$(select_color "current directory")
      add_component "\W" "current directory" "$color"
      ;;
    4)
      color=$(select_color "full path")
      add_component "\w" "full path" "$color"
      ;;
    5)
      color=$(select_color "time (12-hour)")
      add_component "\A" "time (12-hour)" "$color"
      ;;
    6)
      color=$(select_color "time (24-hour)")
      add_component "\t" "time (24-hour)" "$color"
      ;;
    7)
      color=$(select_color "date")
      add_component "\d" "date" "$color"
      ;;
    8)
      color=$(select_color "Git branch")
      add_component "\$(__git_ps1 \" (%s)\")" "Git branch" "$color"
      echo "Note: For Git branch to work, you need to source git-prompt.sh in your .bashrc"
      echo "You may need to add these lines to your .bashrc:"
      echo "if [ -f /etc/bash_completion.d/git-prompt ]; then"
      echo "    source /etc/bash_completion.d/git-prompt"
      echo "elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then"
      echo "    source /usr/share/git-core/contrib/completion/git-prompt.sh"
      echo "fi"
      echo "GIT_PS1_SHOWDIRTYSTATE=true"
      echo "GIT_PS1_SHOWSTASHSTATE=true"
      echo "GIT_PS1_SHOWUNTRACKEDFILES=true"
      ;;
    9)
      read -p "Enter custom text: " custom_text
      color=$(select_color "custom text")
      add_component "$custom_text" "custom text" "$color"
      ;;
    10)
      echo "Special characters:"
      echo "1) [ (open bracket)"
      echo "2) ] (close bracket)"
      echo "3) @ (at symbol)"
      echo "4) : (colon)"
      echo "5) | (pipe)"
      echo "6) > (greater than)"
      echo "7) Custom character"
      read -p "Select special character (1-7): " char_choice
      
      case $char_choice in
        1) special_char="[" ;;
        2) special_char="]" ;;
        3) special_char="@" ;;
        4) special_char=":" ;;
        5) special_char="|" ;;
        6) special_char=">" ;;
        7)
          read -p "Enter custom character: " special_char
          ;;
        *) echo "Invalid choice, using default >"; special_char=">" ;;
      esac
      
      color=$(select_color "special character")
      add_component "$special_char" "special character" "$color"
      ;;
    11)
      preview_ps1
      ;;
    12)
      echo "Resetting PS1..."
      ps1_string=""
      components=()
      colors=()
      echo "PS1 has been reset."
      ;;
    13)
      clear
      echo "=== Final PS1 Configuration ==="
      echo "Copy the following line to your .bashrc file:"
      echo ""
      echo "PS1=\"$ps1_string\""
      echo ""
      echo "To apply immediately in current session, use this command:"
      echo "export PS1=\"$ps1_string\""
      echo ""
      echo "To make it permanent, add the PS1 line to your ~/.bashrc file with:"
      echo "echo 'PS1=\"$ps1_string\"' >> ~/.bashrc"
      echo ""
      exit 0
      ;;
    *)
      echo "Invalid option. Please try again."
      ;;
  esac
  
  echo ""
done
