#!/bin/bash

# ========= GIT MONKEY HELP ENGINE =========
# Provides tone-modulated help content based on user's experience level

# Load utilities
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/profile.sh"
source "$(dirname "${BASH_SOURCE[0]}")/identity.sh"

# Help data directory
HELP_DATA_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd )/help_data"

# Function to apply theme styling to help content
apply_theme_styling() {
  local content="$1"
  local theme="$2"
  
  case "$theme" in
    "jungle")
      # Monkey/jungle themed styling
      content=$(echo "$content" | sed 's/TIP:/🍌 TIP:/g')
      content=$(echo "$content" | sed 's/NOTE:/🐒 NOTE:/g')
      content=$(echo "$content" | sed 's/WARNING:/🙈 WARNING:/g')
      ;;
    "hacker")
      # Hacker themed styling
      content=$(echo "$content" | sed 's/TIP:/> TIP:/g')
      content=$(echo "$content" | sed 's/NOTE:/> NOTE:/g')
      content=$(echo "$content" | sed 's/WARNING:/! WARNING:/g')
      ;;
    "wizard")
      # Magical themed styling
      content=$(echo "$content" | sed 's/TIP:/✨ TIP:/g')
      content=$(echo "$content" | sed 's/NOTE:/📜 NOTE:/g')
      content=$(echo "$content" | sed 's/WARNING:/⚠️ WARNING:/g')
      ;;
    "cosmic")
      # Space themed styling
      content=$(echo "$content" | sed 's/TIP:/🚀 TIP:/g')
      content=$(echo "$content" | sed 's/NOTE:/🌌 NOTE:/g')
      content=$(echo "$content" | sed 's/WARNING:/☄️ WARNING:/g')
      ;;
    *)
      # Default, no special styling
      ;;
  esac
  
  echo "$content"
}

# Get the appropriate help file based on tone stage
get_help_file_path() {
  local command="$1"
  local tone_stage="$2"
  local theme="$3"
  
  # Check if a specific tone stage help file exists for this command
  local help_file="$HELP_DATA_DIR/$command/help_stage_${tone_stage}.txt"
  
  # If not found, try to find the closest lower stage file
  if [ ! -f "$help_file" ]; then
    for (( i = tone_stage - 1; i >= 0; i-- )); do
      local lower_stage_file="$HELP_DATA_DIR/$command/help_stage_${i}.txt"
      if [ -f "$lower_stage_file" ]; then
        help_file="$lower_stage_file"
        break
      fi
    done
  fi
  
  # If still not found, check for a default help file
  if [ ! -f "$help_file" ]; then
    help_file="$HELP_DATA_DIR/$command/help.txt"
  fi
  
  # Return the path (if it exists)
  if [ -f "$help_file" ]; then
    echo "$help_file"
  else
    echo ""
  fi
}

# Get help content for a command based on tone stage and theme
get_help_content() {
  local command="$1"
  local tone_stage="${2:-$(get_tone_stage)}"
  local theme="${3:-$(get_selected_theme)}"
  local show_all="${4:-false}"
  
  if [ "$show_all" = "true" ]; then
    # Show all available help stages for this command
    echo "Showing all help content for '$command' by tone stage:"
    echo ""
    
    for stage in {0..5}; do
      local help_file=$(get_help_file_path "$command" "$stage" "$theme")
      
      if [ -n "$help_file" ] && [ -f "$help_file" ]; then
        echo "=== TONE STAGE $stage ==="
        echo ""
        local content=$(cat "$help_file")
        content=$(apply_theme_styling "$content" "$theme")
        echo "$content"
        echo ""
        echo "======================="
        echo ""
      fi
    done
    
    return
  fi
  
  # Get the appropriate help file
  local help_file=$(get_help_file_path "$command" "$tone_stage" "$theme")
  
  # If no help file found
  if [ -z "$help_file" ] || [ ! -f "$help_file" ]; then
    echo "No help content available for '$command'."
    return 1
  fi
  
  # Read and apply theme styling to the content
  local content=$(cat "$help_file")
  content=$(apply_theme_styling "$content" "$theme")
  
  # Add header for help
  echo "Help for '$command' (Tone Stage $tone_stage - $theme theme):"
  echo ""
  echo "$content"
}

# Function to list all available help topics
list_help_topics() {
  local theme="$1"
  
  echo "Available help topics:"
  echo ""
  
  # Find all directories in help_data
  local topics=()
  for dir in "$HELP_DATA_DIR"/*; do
    if [ -d "$dir" ]; then
      topics+=("$(basename "$dir")")
    fi
  done
  
  # Sort the topics
  IFS=$'\n' sorted_topics=($(sort <<<"${topics[*]}"))
  unset IFS
  
  # Display topics with theme-appropriate styling
  for topic in "${sorted_topics[@]}"; do
    case "$theme" in
      "jungle")
        echo "🐒 gitmonkey help $topic"
        ;;
      "hacker")
        echo "> gitmonkey help $topic"
        ;;
      "wizard")
        echo "✨ gitmonkey help $topic"
        ;;
      "cosmic")
        echo "🚀 gitmonkey help $topic"
        ;;
      *)
        echo "- gitmonkey help $topic"
        ;;
    esac
  done
  
  echo ""
  echo "For more detailed help on a specific command, use:"
  echo "gitmonkey help <command> [--deep N] [--theme THEME] [--all]"
}

# Function to check if a help topic exists
help_topic_exists() {
  local topic="$1"
  
  if [ -d "$HELP_DATA_DIR/$topic" ]; then
    return 0  # Topic exists
  else
    return 1  # Topic doesn't exist
  fi
}