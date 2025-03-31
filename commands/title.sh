#!/bin/bash

# ========= GIT MONKEY TITLE COMMAND =========
# View and manage your Git Monkey titles

source ./utils/style.sh
source ./utils/config.sh
source ./utils/profile.sh
source ./utils/titles.sh
source ./utils/identity.sh

# Function to show usage
show_usage() {
  echo ""
  echo "🐒 Git Monkey Title Manager"
  echo ""
  echo "Usage:"
  echo "  gitmonkey title                 - Show your current title"
  echo "  gitmonkey title list            - List available titles for your stage"
  echo "  gitmonkey title set <title>     - Set a custom title"
  echo "  gitmonkey title random          - Get a new random title"
  echo "  gitmonkey title theme <theme>   - Change title theme (jungle/hacker/wizard/cosmic)"
  echo ""
}

# Function to show current title
show_current_title() {
  local title=$(get_persistent_title)
  local stage=$(get_tone_stage)
  local theme=$(get_selected_theme)
  local full_identity=$(get_full_identity)
  local identity_mode=$(get_identity_mode)
  local title_locked="No"
  
  if is_title_locked; then
    title_locked="Yes"
  fi
  
  echo ""
  box "🐒 Your Git Monkey Title"
  echo ""
  
  echo "🏆 Current Title: $title"
  echo "🌟 Tone Stage: $stage/5"
  echo "🎨 Theme: $theme"
  echo "🔒 Title Locked: $title_locked"
  echo ""
  
  echo "🎭 Your identity appears as: $full_identity"
  echo "   (Identity Mode: $identity_mode)"
  
  echo ""
  echo "Stats:"
  local commands_run=$(get_profile_field "commands.total_run")
  local unique_commands=$(get_profile_field "commands.unique_used | length")
  echo "• Commands run: $commands_run"
  echo "• Unique commands used: $unique_commands"
  
  echo ""
  # Show explanation of tone stages based on current stage
  case $stage in
    0)
      echo "🌱 You're just starting out! Use more Git Monkey commands to level up."
      echo "   Try running 'gitmonkey tutorial' to boost your progress."
      ;;
    1)
      echo "🌿 You're getting familiar with Git Monkey basics."
      echo "   Try branch, stash, or undo commands to progress further."
      ;;
    2)
      echo "🌴 You're becoming comfortable with Git."
      echo "   Try advanced features like worktrees or pivot to reach the next level."
      ;;
    3)
      echo "🌲 You're quite proficient with Git now!"
      echo "   Explore generate or settings commands for even more mastery."
      ;;
    4)
      echo "🌳 You're a Git Monkey power user! Almost at the highest level."
      echo "   Complete the tutorial to reach the final stage."
      ;;
    5)
      echo "🌟 You've reached the highest tone stage - Git Monkey Mastery!"
      echo "   You have access to all titles. Well done!"
      ;;
  esac
  echo ""
}

# Function to list available titles
list_available_titles() {
  local stage=$(get_tone_stage)
  local theme=$(get_selected_theme)
  
  echo ""
  echo "🐒 Available Titles for Your Stage ($stage) and Theme ($theme):"
  echo ""
  
  # Get titles for the current stage and theme
  case "$theme" in
    "jungle")
      eval "titles=(\"\${JUNGLE_TITLES_${stage}[@]}\")"
      ;;
    "hacker")
      eval "titles=(\"\${HACKER_TITLES_${stage}[@]}\")"
      ;;
    "wizard")
      eval "titles=(\"\${WIZARD_TITLES_${stage}[@]}\")"
      ;;
    "cosmic")
      eval "titles=(\"\${COSMIC_TITLES_${stage}[@]}\")"
      ;;
    *)
      eval "titles=(\"\${JUNGLE_TITLES_${stage}[@]}\")"
      ;;
  esac
  
  # Display the titles
  for title in "${titles[@]}"; do
    echo "• $title"
  done
  
  echo ""
  echo "Use 'gitmonkey title set \"Title Name\"' to set a specific title."
  echo "Or 'gitmonkey title random' to get a random one."
  echo ""
}

# Function to set a custom title
set_title() {
  local new_title="$1"
  
  if [ -z "$new_title" ]; then
    echo "❌ Error: No title specified."
    echo "Usage: gitmonkey title set \"Your Chosen Title\""
    return 1
  fi
  
  set_custom_title "$new_title"
  echo ""
  echo "✅ Your title has been set to: $new_title"
  echo ""
}

# Function to set a random title
set_random_title() {
  local stage=$(get_tone_stage)
  local theme=$(get_selected_theme)
  
  # Don't update if title is locked
  if is_title_locked; then
    echo "📝 Your title is currently locked. Unlock it first with: gitmonkey identity lock off"
    return 1
  fi
  
  local new_title=$(get_monkey_title "$stage" "$theme")
  
  set_custom_title "$new_title"
  echo ""
  echo "✅ Your new random title is: $new_title"
  
  # Show how this affects identity
  local full_identity=$(get_full_identity)
  echo "🎭 Your identity now appears as: $full_identity"
  echo ""
}

# Function to change the theme
change_theme() {
  local new_theme="$1"
  
  if [ -z "$new_theme" ]; then
    echo "❌ Error: No theme specified."
    echo "Available themes: jungle, hacker, wizard, cosmic"
    echo "Usage: gitmonkey title theme hacker"
    return 1
  fi
  
  # Validate theme
  case "$new_theme" in
    jungle|hacker|wizard|cosmic)
      set_selected_theme "$new_theme"
      # Also update title to match new theme
      set_random_title
      echo "✅ Theme changed to: $new_theme"
      ;;
    *)
      echo "❌ Invalid theme: $new_theme"
      echo "Available themes: jungle, hacker, wizard, cosmic"
      return 1
      ;;
  esac
}

# Main function
main() {
  local action="$1"
  shift
  
  case "$action" in
    "list")
      list_available_titles
      ;;
    "set")
      set_title "$*"
      ;;
    "random")
      set_random_title
      ;;
    "theme")
      change_theme "$1"
      ;;
    "help"|"--help")
      show_usage
      ;;
    "")
      show_current_title
      ;;
    *)
      echo "❌ Unknown action: $action"
      show_usage
      return 1
      ;;
  esac
}

# Execute the main function
main "$@"