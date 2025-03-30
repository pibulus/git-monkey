#!/bin/bash

# Load utils
source ./utils/style.sh
source ./utils/config.sh

# 🔥 Cracktro Intro
clear

# Check if ASCII art is enabled
if [ "$ENABLE_ASCII_ART" = "true" ]; then
  ascii_banner "GIT MONKEY"
  echo
else
  echo "=== GIT MONKEY ==="
  echo
fi

# Check if animations are enabled
if [ "$ENABLE_ANIMATIONS" = "true" ]; then
  typewriter "🔥 Welcome to Git Monkey CLI – terminal-side clarity, chaos, and command 🔥" 0.015
else
  echo "🔥 Welcome to Git Monkey CLI – terminal-side clarity, chaos, and command 🔥"
fi

# Check if colors are enabled
if [ "$ENABLE_COLORS" = "true" ]; then
  echo "    powered by bananas, branches, and bravery" | lolcat
  sleep 0.3
else
  echo "    powered by bananas, branches, and bravery"
fi

box "What do you want to do?"

# Show version
if [ "$VERBOSITY_LEVEL" = "verbose" ]; then
  echo "Git Monkey $MONKEY_VERSION | User: $MONKEY_USER | Theme: $MONKEY_THEME"
  echo
fi

# 🧭 Menu
PS3=$'\nChoose an option: '
options=(
  "Install Git aliases" 
  "Clone a repo" 
  "Make a new branch" 
  "Stash manager" 
  "Undo something" 
  "Git School (interactive tutorials)" 
  "Show Git tips" 
  "Enter Wizard Mode" 
  "Settings" 
  "Exit"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1) ./commands/alias.sh; break ;;
        2) ./commands/clone.sh; break ;;
        3) ./commands/branch.sh; break ;;
        4) ./commands/stash.sh; break ;;
        5) ./commands/undo.sh; break ;;
        6) ./commands/tutorial.sh; break ;;
        7) ./commands/tips.sh; break ;;
        8) ./commands/wizard.sh; break ;;
        9) ./commands/settings.sh; break ;;
        10) echo "👋 Bye! Come back anytime."; exit 0 ;;
        *) echo "😵‍💫 Pick a number, not a banana." ;;
    esac
done

