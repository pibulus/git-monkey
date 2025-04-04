#\!/bin/bash

# Git Monkey Settings Menu
# Allows configuring various aspects of Git Monkey

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/ascii_art.sh"

# Get current theme
THEME=$(get_selected_theme)

# Display the header
clear
display_menu_header

echo "Git Monkey Settings"
echo ""

# Main settings menu
display_main_menu() {
  local PS3="Choose a setting to configure: "
  local options=(
    "Theme (currently: $(get_selected_theme))"
    "ASCII Art (currently: $(get_config "enable_ascii_art" "true"))"
    "Animations (currently: $(get_config "enable_animations" "true"))"
    "Colors (currently: $(get_config "enable_colors" "true"))"
    "Verbosity (currently: $(get_config "verbosity_level" "normal"))"
    "AI Settings"
    "Back to main menu"
  )

  select opt in "${options[@]}"; do
    case $REPLY in
      1)
        # Theme settings - use the theme manager
        "$PARENT_DIR/utils/theme_manager.sh"
        break
        ;;
      2)
        # ASCII Art settings
        toggle_setting "enable_ascii_art"
        display_success "$THEME"
        break
        ;;
      3)
        # Animation settings
        toggle_setting "enable_animations"
        display_success "$THEME"
        break
        ;;
      4)
        # Color settings
        toggle_setting "enable_colors"
        display_success "$THEME"
        break
        ;;
      5)
        # Verbosity settings
        configure_verbosity
        break
        ;;
      6)
        # AI settings
        if [ -f "$PARENT_DIR/commands/settings_ai.sh" ]; then
          "$PARENT_DIR/commands/settings_ai.sh"
        else
          echo "$(display_error "$THEME") AI settings module not available."
          sleep 2
        fi
        break
        ;;
      7)
        # Return to main menu
        echo "$(display_success "$THEME") Settings saved."
        exit 0
        ;;
      *)
        echo "$(display_error "$THEME") Invalid option"
        ;;
    esac
  done

  # Return to settings menu after action
  display_main_menu
}

# Toggle a boolean setting
toggle_setting() {
  local setting="$1"
  local current_value=$(get_config "$setting" "true")
  
  if [ "$current_value" = "true" ]; then
    set_config "$setting" "false"
    echo "$setting set to false"
  else
    set_config "$setting" "true"
    echo "$setting set to true"
  fi
}

# Configure verbosity level
configure_verbosity() {
  local PS3="Select verbosity level: "
  local options=(
    "Normal - Standard output"
    "Verbose - Additional details"
    "Debug - Maximum information"
    "Back"
  )

  select opt in "${options[@]}"; do
    case $REPLY in
      1)
        set_config "verbosity_level" "normal"
        echo "Verbosity set to normal"
        return
        ;;
      2)
        set_config "verbosity_level" "verbose"
        echo "Verbosity set to verbose"
        return
        ;;
      3)
        set_config "verbosity_level" "debug"
        echo "Verbosity set to debug"
        return
        ;;
      4)
        return
        ;;
      *)
        echo "$(display_error "$THEME") Invalid option"
        ;;
    esac
  done
}

# Start the menu
display_main_menu
