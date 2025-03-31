#!/bin/bash

# ========= GIT MONKEY HELP COMMAND =========
# Provides tone-modulated help for various Git Monkey commands

source ./utils/style.sh
source ./utils/config.sh
source ./utils/profile.sh
source ./utils/identity.sh
source ./utils/help_engine.sh

# Function to show usage
show_usage() {
  echo "Usage: gitmonkey help [command] [options]"
  echo ""
  echo "Options:"
  echo "  --deep N      Override tone stage (0-5)"
  echo "  --theme THEME Force specific theme (jungle, hacker, wizard, cosmic)"
  echo "  --all         Show all tone stages for development preview"
  echo ""
  echo "Examples:"
  echo "  gitmonkey help                    # List all available help topics"
  echo "  gitmonkey help commit             # Show help for 'commit' at your tone stage"
  echo "  gitmonkey help branch --deep 3    # Show intermediate help for 'branch'"
  echo "  gitmonkey help push --theme wizard # Show help with wizard theme"
  echo "  gitmonkey help worktree --all     # Show all tone levels for 'worktree'"
  echo ""
}

# Main function to handle help requests
main() {
  local command=""
  local tone_override=""
  local theme_override=""
  local show_all="false"
  
  # Process command line arguments
  for arg in "$@"; do
    case "$arg" in
      --deep=*)
        tone_override="${arg#*=}"
        ;;
      --deep)
        tone_override="$2"
        shift
        ;;
      --theme=*)
        theme_override="${arg#*=}"
        ;;
      --theme)
        theme_override="$2"
        shift
        ;;
      --all)
        show_all="true"
        ;;
      --help|-h)
        show_usage
        return 0
        ;;
      -*)
        echo "Unknown option: $arg"
        show_usage
        return 1
        ;;
      *)
        if [ -z "$command" ]; then
          command="$arg"
        fi
        ;;
    esac
    shift
  done
  
  # Get current tone stage and theme
  local tone_stage=$(get_tone_stage)
  local theme=$(get_selected_theme)
  
  # Apply overrides if provided
  if [ -n "$tone_override" ]; then
    if [[ "$tone_override" =~ ^[0-5]$ ]]; then
      tone_stage="$tone_override"
    else
      echo "Invalid tone stage: $tone_override (must be 0-5)"
      return 1
    fi
  fi
  
  if [ -n "$theme_override" ]; then
    case "$theme_override" in
      jungle|hacker|wizard|cosmic)
        theme="$theme_override"
        ;;
      *)
        echo "Invalid theme: $theme_override (must be jungle, hacker, wizard, or cosmic)"
        return 1
        ;;
    esac
  fi
  
  # If no command specified, show list of available topics
  if [ -z "$command" ]; then
    echo ""
    box "🐒 Git Monkey Help"
    echo ""
    list_help_topics "$theme"
    return 0
  fi
  
  # Check if help topic exists
  if ! help_topic_exists "$command"; then
    echo "❌ No help available for '$command'."
    echo ""
    echo "Available help topics:"
    list_help_topics "$theme"
    return 1
  fi
  
  # Display help content
  echo ""
  box "🐒 Git Monkey Help: $command"
  echo ""
  get_help_content "$command" "$tone_stage" "$theme" "$show_all"
  echo ""
}

# Execute main function with arguments
main "$@"