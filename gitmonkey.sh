#!/bin/bash

# ==================================
# Git Monkey CLI - Main Dispatcher
# ==================================

# Import utilities
source "$(dirname "$0")/utils/style.sh"
source "$(dirname "$0")/utils/config.sh"

# Get absolute path to the commands directory
COMMANDS_DIR="$(dirname "$0")/commands"

# Function to display help
show_help() {
  clear
  # Check if ASCII art is enabled
  if [ "$ENABLE_ASCII_ART" = "true" ]; then
    ascii_banner "GIT MONKEY"
    echo
  else
    echo "=== GIT MONKEY ==="
    echo
  fi
  
  # Display welcome message with typewriter effect if enabled
  if [ "$ENABLE_ANIMATIONS" = "true" ]; then
    typewriter "$(random_greeting)" 0.02
    echo
  else
    echo "$(random_greeting)"
    echo
  fi
  
  box "Available Git Monkey Commands"
  
  # Determine appropriate icon based on theme
  if [ "$MONKEY_THEME" = "hacker" ]; then
    ICON="🔥"
  elif [ "$MONKEY_THEME" = "cute" ]; then
    ICON="🍌"
  else
    ICON="🐒"
  fi
  
  # List available commands by scanning the commands directory
  echo "Command reference:"
  echo
  
  # Map of command descriptions
  declare -A descriptions
  descriptions["alias"]="Install helpful Git aliases"
  descriptions["branch"]="Create or manage branches"
  descriptions["clone"]="Clone a repository with guidance"
  descriptions["menu"]="Open interactive menu"
  descriptions["settings"]="Customize your Git Monkey experience"
  descriptions["stash"]="Manage your stashed changes"
  descriptions["tips"]="View Git tips and tricks"
  descriptions["tutorial"]="Interactive Git School lessons"
  descriptions["undo"]="Undo mistakes safely"
  descriptions["wizard"]="Access advanced Git features"
  
  # Find all .sh files in the commands directory and list them
  for cmd_file in "$COMMANDS_DIR"/*.sh; do
    if [ -f "$cmd_file" ]; then
      cmd_name=$(basename "$cmd_file" .sh)
      description="${descriptions[$cmd_name]:-Command for $cmd_name}"
      printf "  $ICON %-12s %s\n" "gitmonkey $cmd_name" "$description"
    fi
  done
  
  echo
  echo "Run any command with --help to see specific options."
  echo "Example: gitmonkey tutorial --help"
  echo
  
  if [ "$ENABLE_COLORS" = "true" ]; then
    echo "Git Monkey v$MONKEY_VERSION | Theme: $MONKEY_THEME" | lolcat
  else
    echo "Git Monkey v$MONKEY_VERSION | Theme: $MONKEY_THEME"
  fi
}

# Function to check if a command exists
command_exists() {
  [ -f "$COMMANDS_DIR/$1.sh" ]
}

# No arguments - show the menu
if [ $# -eq 0 ]; then
  # Option 1: Show help
  # show_help
  
  # Option 2: Launch the menu (preferred for user-friendliness)
  "$COMMANDS_DIR/menu.sh"
  exit 0
fi

# Get the subcommand
COMMAND=$1
shift

# Special case for help command
if [ "$COMMAND" = "help" ]; then
  show_help
  exit 0
fi

# Special case for version command
if [ "$COMMAND" = "version" ]; then
  echo "Git Monkey CLI v$MONKEY_VERSION"
  exit 0
fi

# Check if command exists
if command_exists "$COMMAND"; then
  # Execute the command script with all remaining arguments
  "$COMMANDS_DIR/$COMMAND.sh" "$@"
else
  echo "😵 Unknown command: $COMMAND"
  echo
  echo "Here are the available commands:"
  
  # Find all command files and list them
  for cmd_file in "$COMMANDS_DIR"/*.sh; do
    if [ -f "$cmd_file" ]; then
      echo "  👉 $(basename "$cmd_file" .sh)"
    fi
  done
  
  echo
  echo "Run 'gitmonkey help' for more information."
  exit 1
fi