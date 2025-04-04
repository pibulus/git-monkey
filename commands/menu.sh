#\!/bin/bash

# Load utils
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/profile.sh"
source "$PARENT_DIR/utils/titles.sh"
source "$PARENT_DIR/utils/identity.sh"
source "$PARENT_DIR/utils/ascii_art.sh"  # Added ASCII art utils

# Get current theme
THEME=$(get_selected_theme)

# 🔥 Menu Intro
clear

# Display themed menu header
display_menu_header

# Get identity for personalized welcome
full_identity=$(get_full_identity)

# Display themed greeting
display_greeting "$THEME"

# Display themed tip
display_tip "$THEME"

# 🧭 Menu
PS3=$'\nChoose an option: '
options=(
  "Install Git aliases" 
  "Clone a repo" 
  "Make a new branch" 
  "Stash manager" 
  "Smart push (with upstream)" 
  "Undo something" 
  "Git School (interactive tutorials)" 
  "Show Git tips" 
  "AI-assisted commit messages"
  "Get AI-powered Git help"
  "View Git context (whoami)"
  "Manage your title"
  "Setup your identity"
  "Change theme"
  "Enter Wizard Mode" 
  "Settings" 
  "Exit"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1) "$PARENT_DIR/commands/alias.sh"; break ;;
        2) "$PARENT_DIR/commands/clone.sh"; break ;;
        3) "$PARENT_DIR/commands/branch.sh"; break ;;
        4) "$PARENT_DIR/commands/stash.sh"; break ;;
        5) "$PARENT_DIR/commands/push.sh"; break ;;
        6) "$PARENT_DIR/commands/undo.sh"; break ;;
        7) "$PARENT_DIR/commands/tutorial.sh"; break ;;
        8) "$PARENT_DIR/commands/tips.sh"; break ;;
        9) "$PARENT_DIR/commands/commit.sh"; break ;;
        10) "$PARENT_DIR/commands/ask.sh"; break ;;
        11) "$PARENT_DIR/commands/whoami.sh"; break ;;
        12) "$PARENT_DIR/commands/title.sh"; break ;;
        13) "$PARENT_DIR/commands/identity.sh" setup; break ;;
        14) "$PARENT_DIR/utils/theme_manager.sh"; break ;;
        15) "$PARENT_DIR/commands/wizard.sh"; break ;;
        16) "$PARENT_DIR/commands/settings.sh"; break ;;
        17) echo "$(display_success $THEME) Come back anytime\!"; exit 0 ;;
        *) echo "$(display_error $THEME) Please choose a valid option." ;;
    esac
done

# Display the footer
display_menu_footer
