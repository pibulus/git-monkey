#!/bin/bash

# ========= GIT MONKEY IDENTITY COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"
# Get current theme
THEME=$(get_selected_theme)


# Manage your personalized Git Monkey identity


# Show usage information
show_usage() {
  echo ""
  echo "🐒 Git Monkey Identity Manager"
  echo ""
  echo "Usage:"
  echo "  gitmonkey identity               - Show your current identity"
  echo "  gitmonkey identity setup         - Set up your identity"
  echo "  gitmonkey identity name [NAME]   - Set your display name"
  echo "  gitmonkey identity mode [1-3]    - Set your identity mode"
  echo "  gitmonkey identity preview [1-3] - Preview how your identity will look"
  echo "  gitmonkey identity random        - Get a new random title"
  echo "  gitmonkey identity lock [on|off] - Lock/unlock your current title"
  echo ""
  echo "Identity Modes:"
  echo "  1 - Name only        (e.g., \"Pablo\")"
  echo "  2 - Title only       (e.g., \"Git Guardian\")"
  echo "  3 - Combo (default)  (e.g., \"Pablo the Git Guardian\")"
  echo ""
  echo "Flags:"
  echo "  --preview            - Show how identity will appear without saving"
  echo "  --force              - Skip confirmation prompts"
  echo ""
}

# Function to show current identity
show_identity() {
  local user_name=$(get_user_real_name)
  local display_name=$(get_user_display_name)
  local user_title=$(get_persistent_title)
  local identity_mode=$(get_identity_mode)
  local full_identity=$(get_full_identity)
  local stage=$(get_tone_stage)
  local theme=$(get_selected_theme)
  local title_locked="No"
  
  if is_title_locked; then
    title_locked="Yes"
  fi
  
  echo ""
  box "🐒 Your Git Monkey Identity"
  echo ""
  
  echo "Personal Info:"
  echo "👤 Name: ${user_name:-"(not set)"}"
  echo "🏆 Title: $user_title"
  echo "🎭 Identity Mode: $identity_mode"
  echo "🎨 Theme: $theme"
  echo "🔒 Title Locked: $title_locked"
  echo ""
  
  echo "Your greeting will appear as:"
  echo "  \"Welcome back, $full_identity!\""
  echo ""
  
  echo "Identity Stats:"
  echo "🌟 Tone Stage: $stage/5"
  local commands_run=$(get_profile_field "commands.total_run")
  local unique_commands=$(get_profile_field "commands.unique_used | length")
  echo "• Commands run: $commands_run"
  echo "• Unique commands used: $unique_commands"
  echo ""
}

# Function to set up identity
setup_identity() {
  local name force preview
  
  # Process arguments
  for arg in "$@"; do
    case "$arg" in
      --force) force="true" ;;
      --preview) preview="true" ;;
      *) name="$arg" ;;
    esac
  done
  
  echo ""
  rainbow_box "🐒 Git Monkey Identity Setup"
  echo ""
  
  # Ask for name if not provided
  if [ -z "$name" ] && [ "$force" != "true" ]; then
    read -p "What's your name? (Enter to skip): " name
  fi
  
  # Set the name (or use anonymous name)
  if [ -n "$name" ]; then
    set_user_name "$name" "true"
    echo "👤 Name set to: $name"
  else
    # Use anonymous name
    local anon_name=$(get_anonymous_name)
    set_user_name "$anon_name" "false"
    echo "👤 Using anonymous name: $anon_name"
  fi
  echo ""
  
  # Choose identity mode
  if [ "$force" != "true" ]; then
    echo "How would you like to be addressed?"
    echo "  1) Name only       (e.g., \"Pablo\")"
    echo "  2) Title only      (e.g., \"Git Guardian\")"
    echo "  3) Combo (default) (e.g., \"Pablo the Git Guardian\")"
    read -p "Select mode [1-3]: " mode_choice
    
    if [[ ! "$mode_choice" =~ ^[1-3]$ ]]; then
      mode_choice=3  # Default to combo
    fi
  else
    mode_choice=3  # Default to combo
  fi
  
  set_identity_mode "$mode_choice"
  echo "🎭 Identity mode set to: $mode_choice"
  echo ""
  
  # Preview result
  preview_identity "$mode_choice"
  echo ""
  
  if [ "$preview" != "true" ]; then
    echo "✅ Identity setup complete!"
    echo ""
  else
    echo "📝 This was just a preview. Run without --preview to save changes."
    echo ""
  fi
}

# Set display name
set_display_name() {
  local name="$1"
  
  if [ -z "$name" ]; then
    echo "❌ No name provided."
    echo "Usage: gitmonkey identity name \"Your Name\""
    return 1
  fi
  
  set_user_name "$name" "true"
  echo "👤 Name set to: $name"
  
  # Preview result
  local mode=$(get_identity_mode)
  preview_identity "$mode"
}

# Set identity mode
change_identity_mode() {
  local mode="$1"
  
  if [ -z "$mode" ] || [[ ! "$mode" =~ ^[1-3]$ ]]; then
    echo "❌ Invalid mode: $mode"
    echo "Usage: gitmonkey identity mode [1-3]"
    echo "  1 - Name only"
    echo "  2 - Title only"
    echo "  3 - Combo (Name + Title)"
    return 1
  fi
  
  set_identity_mode "$mode"
  
  # Preview result
  preview_identity "$mode"
}

# Preview identity mode
preview_mode() {
  local mode="$1"
  
  if [ -z "$mode" ] || [[ ! "$mode" =~ ^[1-3]$ ]]; then
    echo "❌ Invalid mode: $mode"
    echo "Usage: gitmonkey identity preview [1-3]"
    return 1
  fi
  
  preview_identity "$mode"
}

# Lock or unlock title
lock_title() {
  local state="$1"
  
  case "$state" in
    on|true|yes)
      set_title_lock "true"
      ;;
    off|false|no)
      set_title_lock "false"
      ;;
    *)
      echo "❌ Invalid option: $state"
      echo "Usage: gitmonkey identity lock [on|off]"
      return 1
      ;;
  esac
}

# Main function
main() {
  local action="$1"
  shift
  
  case "$action" in
    "setup")
      setup_identity "$@"
      ;;
    "name")
      set_display_name "$*"
      ;;
    "mode")
      change_identity_mode "$1"
      ;;
    "preview")
      preview_mode "$1"
      ;;
    "random")
      randomize_title
      ;;
    "lock")
      lock_title "$1"
      ;;
    "help"|"--help")
      show_usage
      ;;
    "")
      show_identity
      ;;
    *)
      echo "❌ Unknown action: $action"
      show_usage
      return 1
      ;;
  esac
}

# Execute main function with arguments
main "$@"
