#\!/bin/bash

# Placeholder for a proper welcome script
# This would show the initial welcome screen and onboarding

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"

# Get or set a default theme for first run
THEME=$(get_selected_theme 2>/dev/null || echo "jungle")

clear

# Display an awesome splash screen
display_splash "$THEME"

# Display welcome message
if [ -f "$PARENT_DIR/assets/messages/welcome.txt" ]; then
  cat "$PARENT_DIR/assets/messages/welcome.txt"
else
  echo "Welcome to Git Monkey\! 🐒"
  echo ""
  echo "Your friendly Git assistant is here to make version control fun and easy."
  echo "Let's swing through your Git workflows together\!"
  echo ""
  echo "Type 'gitmonkey help' to see all available commands."
fi

echo ""
echo "Choose a theme for your Git Monkey experience:"
echo ""
echo "1) Jungle (default) - Playful explorer vibe with natural, organic elements"
echo "2) Hacker - Technical, precise language with l33t system references"
echo "3) Wizard - Mystical language with arcane and magical references"
echo "4) Cosmic - Space-themed language with cosmic and galactic elements"
echo ""
echo -n "Theme choice (1-4): "
read theme_choice

case "$theme_choice" in
  1)
    set_config "theme" "jungle"
    echo "Jungle theme selected."
    ;;
  2)
    set_config "theme" "hacker" 
    echo "Hacker theme selected."
    ;;
  3)
    set_config "theme" "wizard"
    echo "Wizard theme selected."
    ;;
  4)
    set_config "theme" "cosmic"
    echo "Cosmic theme selected."
    ;;
  *)
    set_config "theme" "jungle"
    echo "Jungle theme selected (default)."
    ;;
esac

THEME=$(get_selected_theme)
echo ""
echo "Preview of your selected theme:"
echo ""
display_splash "$THEME"
echo ""
display_greeting "$THEME"
echo ""
display_success "$THEME"
echo ""
display_tip "$THEME"
echo ""

# Create the welcomed flag to prevent showing the welcome again
mkdir -p "$HOME/.gitmonkey"
touch "$HOME/.gitmonkey/welcomed"

echo "Setup complete\! Use 'gitmonkey help' to see available commands."
echo "You can change your theme anytime with 'gitmonkey theme'."
