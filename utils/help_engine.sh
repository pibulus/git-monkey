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
      content=$(echo "$content" | sed 's/USAGE:/🦍 USAGE:/g')
      content=$(echo "$content" | sed 's/EXAMPLES:/🌴 EXAMPLES:/g')
      content=$(echo "$content" | sed 's/RELATED:/🐵 RELATED:/g')
      content=$(echo "$content" | sed 's/WHAT YOU NEED TO KNOW:/🍃 WHAT YOU NEED TO KNOW:/g')
      content=$(echo "$content" | sed 's/BASIC USAGE:/🌿 BASIC USAGE:/g')
      # Style command syntax with bold green
      content=$(echo "$content" | sed 's/`\([^`]*\)`/\\033[1;32m\1\\033[0m/g')
      # Highlight git commands on new lines
      content=$(echo "$content" | sed 's/^  git /  \\033[1;32mgit \\033[0m/g')
      content=$(echo "$content" | sed 's/^  gitmonkey /  \\033[1;32mgitmonkey \\033[0m/g')
      ;;
    "hacker")
      # Hacker themed styling
      content=$(echo "$content" | sed 's/TIP:/> TIP:/g')
      content=$(echo "$content" | sed 's/NOTE:/> NOTE:/g')
      content=$(echo "$content" | sed 's/WARNING:/! WARNING:/g')
      content=$(echo "$content" | sed 's/USAGE:/_USAGE_:/g')
      content=$(echo "$content" | sed 's/EXAMPLES:/\/\/ EXAMPLES:/g')
      content=$(echo "$content" | sed 's/RELATED:/### RELATED:/g')
      content=$(echo "$content" | sed 's/WHAT YOU NEED TO KNOW:/\/\* WHAT YOU NEED TO KNOW: \*\//g')
      content=$(echo "$content" | sed 's/BASIC USAGE:/\/\/ BASIC USAGE:/g')
      # Style command syntax with cyan
      content=$(echo "$content" | sed 's/`\([^`]*\)`/\\033[1;36m\1\\033[0m/g')
      # Highlight git commands on new lines
      content=$(echo "$content" | sed 's/^  git /  \\033[1;36mgit \\033[0m/g')
      content=$(echo "$content" | sed 's/^  gitmonkey /  \\033[1;36mgitmonkey \\033[0m/g')
      ;;
    "wizard")
      # Magical themed styling
      content=$(echo "$content" | sed 's/TIP:/✨ TIP:/g')
      content=$(echo "$content" | sed 's/NOTE:/📜 NOTE:/g')
      content=$(echo "$content" | sed 's/WARNING:/⚠️ WARNING:/g')
      content=$(echo "$content" | sed 's/USAGE:/🧙 USAGE:/g')
      content=$(echo "$content" | sed 's/EXAMPLES:/🔮 EXAMPLES:/g')
      content=$(echo "$content" | sed 's/RELATED:/📚 RELATED:/g')
      content=$(echo "$content" | sed 's/WHAT YOU NEED TO KNOW:/🌟 WHAT YOU NEED TO KNOW:/g')
      content=$(echo "$content" | sed 's/BASIC USAGE:/🪄 BASIC USAGE:/g')
      # Style command syntax with purple
      content=$(echo "$content" | sed 's/`\([^`]*\)`/\\033[1;35m\1\\033[0m/g')
      # Highlight git commands on new lines
      content=$(echo "$content" | sed 's/^  git /  \\033[1;35mgit \\033[0m/g')
      content=$(echo "$content" | sed 's/^  gitmonkey /  \\033[1;35mgitmonkey \\033[0m/g')
      ;;
    "cosmic")
      # Space themed styling
      content=$(echo "$content" | sed 's/TIP:/🚀 TIP:/g')
      content=$(echo "$content" | sed 's/NOTE:/🌌 NOTE:/g')
      content=$(echo "$content" | sed 's/WARNING:/☄️ WARNING:/g')
      content=$(echo "$content" | sed 's/USAGE:/🛰️ USAGE:/g')
      content=$(echo "$content" | sed 's/EXAMPLES:/💫 EXAMPLES:/g')
      content=$(echo "$content" | sed 's/RELATED:/🪐 RELATED:/g')
      content=$(echo "$content" | sed 's/WHAT YOU NEED TO KNOW:/🌠 WHAT YOU NEED TO KNOW:/g')
      content=$(echo "$content" | sed 's/BASIC USAGE:/👨‍🚀 BASIC USAGE:/g')
      # Style command syntax with blue
      content=$(echo "$content" | sed 's/`\([^`]*\)`/\\033[1;34m\1\\033[0m/g')
      # Highlight git commands on new lines
      content=$(echo "$content" | sed 's/^  git /  \\033[1;34mgit \\033[0m/g')
      content=$(echo "$content" | sed 's/^  gitmonkey /  \\033[1;34mgitmonkey \\033[0m/g')
      ;;
    *)
      # Default, no special styling but still highlight code
      content=$(echo "$content" | sed 's/`\([^`]*\)`/\\033[1m\1\\033[0m/g')
      # Highlight git commands on new lines
      content=$(echo "$content" | sed 's/^  git /  \\033[1mgit \\033[0m/g')
      content=$(echo "$content" | sed 's/^  gitmonkey /  \\033[1mgitmonkey \\033[0m/g')
      ;;
  esac
  
  # Apply section highlighting regardless of theme
  content=$(echo "$content" | sed 's/^[A-Z][A-Z ]*:/\\033[1;4m&\\033[0m/g')
  
  # Highlight command flags with appropriate color based on theme
  case "$theme" in
    "jungle")
      content=$(echo "$content" | sed 's/ -[a-zA-Z]/ \\033[32m-&\\033[0m/g')
      content=$(echo "$content" | sed 's/ --[a-zA-Z-]*/ \\033[32m&\\033[0m/g')
      ;;
    "hacker")
      content=$(echo "$content" | sed 's/ -[a-zA-Z]/ \\033[36m-&\\033[0m/g')
      content=$(echo "$content" | sed 's/ --[a-zA-Z-]*/ \\033[36m&\\033[0m/g')
      ;;
    "wizard")
      content=$(echo "$content" | sed 's/ -[a-zA-Z]/ \\033[35m-&\\033[0m/g')
      content=$(echo "$content" | sed 's/ --[a-zA-Z-]*/ \\033[35m&\\033[0m/g')
      ;;
    "cosmic")
      content=$(echo "$content" | sed 's/ -[a-zA-Z]/ \\033[34m-&\\033[0m/g')
      content=$(echo "$content" | sed 's/ --[a-zA-Z-]*/ \\033[34m&\\033[0m/g')
      ;;
    *)
      content=$(echo "$content" | sed 's/ -[a-zA-Z]/ \\033[1m-&\\033[0m/g')
      content=$(echo "$content" | sed 's/ --[a-zA-Z-]*/ \\033[1m&\\033[0m/g')
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
        echo -e "\033[1;4m=== TONE STAGE $stage ===\033[0m"
        echo ""
        local content=$(cat "$help_file")
        content=$(apply_theme_styling "$content" "$theme")
        echo -e "$content"
        echo ""
        echo -e "\033[1m=======================\033[0m"
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
  
  # Get actual stage of the help file (might be lower than requested)
  local actual_stage=$(basename "$help_file" | sed -n 's/help_stage_\([0-9]\).txt/\1/p')
  if [ -z "$actual_stage" ]; then
    actual_stage="base"
  fi
  
  # Create theme-based styled header
  local header_style=""
  case "$theme" in
    "jungle")
      header_style="\033[1;32m${command^^} HELP\033[0m 🌴"
      ;;
    "hacker")
      header_style="\033[1;36m${command^^}_HELP\033[0m //"
      ;;
    "wizard")
      header_style="\033[1;35m${command^^} HELP\033[0m ✨"
      ;;
    "cosmic")
      header_style="\033[1;34m${command^^} HELP\033[0m 🚀"
      ;;
    *)
      header_style="\033[1m${command^^} HELP\033[0m"
      ;;
  esac
  
  # Add identity-aware greeting if tone stage is low (0-2)
  if [ "$tone_stage" -le 2 ] && [ "$actual_stage" -le 2 ]; then
    local identity=$(get_full_identity)
    local greeting=""
    
    case "$theme" in
      "jungle")
        greeting="🐒 Hey there, $identity! Ready to swing through the '$command' command?"
        ;;
      "hacker")
        greeting="> Greetings $identity. Decoding the '$command' command for you..."
        ;;
      "wizard")
        greeting="✨ Well met, $identity! Let's unveil the magic of the '$command' command!"
        ;;
      "cosmic")
        greeting="🚀 Greetings, $identity! Let's explore the '$command' command in our journey through the Git cosmos!"
        ;;
      *)
        greeting="Hello, $identity! Here's some help with the '$command' command:"
        ;;
    esac
    
    echo -e "$greeting"
    echo ""
  fi
  
  # Add header with stage and theme info
  if [ "$tone_stage" -le 3 ]; then
    echo -e "$header_style (Tone Stage $tone_stage - $theme theme)"
  else 
    # More advanced users don't need the hand-holding
    echo -e "$header_style"
  fi
  
  echo ""
  echo -e "$content"
  
  # Append additional information based on tone stage
  if [ "$tone_stage" -le 1 ]; then
    # For absolute beginners, add encouragement
    echo ""
    echo -e "\033[1mYou're doing great!\033[0m Don't worry if everything isn't clear yet - practice makes perfect."
  fi
  
  # Add suggestions for related commands with theme styling
  if [ "$tone_stage" -le 3 ]; then
    # Get theme-appropriate marker for related commands
    local related_marker=""
    case "$theme" in
      "jungle")
        related_marker="🐵 RELATED COMMANDS:"
        ;;
      "hacker")
        related_marker="### RELATED COMMANDS:"
        ;;
      "wizard")
        related_marker="📚 RELATED COMMANDS:"
        ;;
      "cosmic")
        related_marker="🪐 RELATED COMMANDS:"
        ;;
      *)
        related_marker="RELATED COMMANDS:"
        ;;
    esac
    
    echo ""
    echo -e "\033[1m$related_marker\033[0m"
    case "$command" in
      commit)
        echo -e "  \033[1mgitmonkey help push\033[0m - to push your commits to a remote"
        echo -e "  \033[1mgitmonkey help undo\033[0m - to fix mistakes in commits"
        echo -e "  \033[1mgitmonkey help status\033[0m - to check what files are ready to commit"
        ;;
      branch)
        echo -e "  \033[1mgitmonkey help worktree\033[0m - to work on multiple branches at once"
        echo -e "  \033[1mgitmonkey help push\033[0m - to push your branches to a remote"
        echo -e "  \033[1mgitmonkey help checkout\033[0m - to switch between branches"
        ;;
      push)
        echo -e "  \033[1mgitmonkey help branch\033[0m - to create and manage branches"
        echo -e "  \033[1mgitmonkey help pull\033[0m - to get changes from remotes"
        echo -e "  \033[1mgitmonkey help remote\033[0m - to manage remote repositories"
        ;;
      worktree)
        echo -e "  \033[1mgitmonkey help branch\033[0m - to create and manage branches"
        echo -e "  \033[1mgitmonkey help pivot\033[0m - for quick context switching"
        echo -e "  \033[1mgitmonkey help status\033[0m - to check worktree status"
        ;;
      pull)
        echo -e "  \033[1mgitmonkey help push\033[0m - to send your changes to a remote"
        echo -e "  \033[1mgitmonkey help merge\033[0m - to combine branches"
        echo -e "  \033[1mgitmonkey help fetch\033[0m - to update remote references without merging"
        ;;
      clone)
        echo -e "  \033[1mgitmonkey help remote\033[0m - to manage remote repositories"
        echo -e "  \033[1mgitmonkey help branch\033[0m - to work with branches"
        echo -e "  \033[1mgitmonkey help pull\033[0m - to get changes from remotes"
        ;;
      *)
        # For other commands, suggest some common ones
        echo -e "  \033[1mgitmonkey help commit\033[0m - to save your changes"
        echo -e "  \033[1mgitmonkey help branch\033[0m - to create and manage branches"
        echo -e "  \033[1mgitmonkey help status\033[0m - to check your working directory status"
        ;;
    esac
  fi
  
  # For lower stages, add quick tip about advancing tone stages
  if [ "$tone_stage" -le 2 ]; then
    echo ""
    echo -e "\033[3mAs you use Git Monkey more, your tone stage will advance and you'll see more advanced help.\033[0m"
  fi
}

# Function to list all available help topics
list_help_topics() {
  local theme="$1"
  local tone_stage="${2:-$(get_tone_stage)}"
  
  # Get theme-specific styling for header
  local header_icon=""
  local cmd_style=""
  case "$theme" in
    "jungle")
      header_icon="🐒"
      cmd_style="\033[1;32m"
      ;;
    "hacker")
      header_icon=">"
      cmd_style="\033[1;36m"
      ;;
    "wizard")
      header_icon="✨"
      cmd_style="\033[1;35m"
      ;;
    "cosmic")
      header_icon="🚀"
      cmd_style="\033[1;34m"
      ;;
    *)
      header_icon="-"
      cmd_style="\033[1m"
      ;;
  esac
  
  # Print help topics header with theme styling
  echo -e "\033[1;4mAvailable Help Topics\033[0m"
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
  
  # Group topics by category for better organization
  local core_cmds=("commit" "branch" "push" "pull" "status" "clone")
  local advanced_cmds=("worktree" "merge" "rebase" "stash" "bisect")
  local utility_cmds=("remote" "tag" "undo" "log" "pivot")
  
  # For tone stages 0-2, categorize commands for easier navigation
  if [ "$tone_stage" -le 2 ]; then
    # Helper function to print topics in a category
    print_category() {
      local category="$1"
      local category_topics=("${@:2}")
      local found=false
      
      # Check if any commands from this category exist in our topics
      for cmd in "${category_topics[@]}"; do
        if [[ " ${sorted_topics[@]} " =~ " ${cmd} " ]]; then
          found=true
          break
        fi
      done
      
      if [ "$found" = true ]; then
        echo -e "\033[1m$category:\033[0m"
        for topic in "${sorted_topics[@]}"; do
          if [[ " ${category_topics[@]} " =~ " ${topic} " ]]; then
            echo -e "  $header_icon ${cmd_style}gitmonkey help $topic\033[0m"
          fi
        done
        echo ""
      fi
    }
    
    print_category "Core Commands" "${core_cmds[@]}"
    print_category "Advanced Commands" "${advanced_cmds[@]}"
    print_category "Utility Commands" "${utility_cmds[@]}"
    
    # Print remaining topics
    local uncategorized=()
    for topic in "${sorted_topics[@]}"; do
      if [[ ! " ${core_cmds[@]} ${advanced_cmds[@]} ${utility_cmds[@]} " =~ " ${topic} " ]]; then
        uncategorized+=("$topic")
      fi
    done
    
    if [ ${#uncategorized[@]} -gt 0 ]; then
      echo -e "\033[1mOther Commands:\033[0m"
      for topic in "${uncategorized[@]}"; do
        echo -e "  $header_icon ${cmd_style}gitmonkey help $topic\033[0m"
      done
      echo ""
    fi
  else
    # Advanced users get a simple alphabetical list
    for topic in "${sorted_topics[@]}"; do
      echo -e "  $header_icon ${cmd_style}gitmonkey help $topic\033[0m"
    done
    echo ""
  fi
  
  # For beginners, add more explanation
  if [ "$tone_stage" -le 1 ]; then
    echo -e "\033[1mTIP:\033[0m Each command has help tailored to your experience level!"
    echo ""
  fi
  
  echo -e "For more detailed help on a specific command, use:"
  echo -e "  ${cmd_style}gitmonkey help <command>\033[0m"
  
  # Show advanced options only to users at tone stage 2+
  if [ "$tone_stage" -ge 2 ]; then
    echo -e "Advanced options:"
    echo -e "  ${cmd_style}gitmonkey help <command> --deep N\033[0m     Override tone stage (0-5)"
    echo -e "  ${cmd_style}gitmonkey help <command> --theme THEME\033[0m Use specific theme"
    if [ "$tone_stage" -ge 4 ]; then
      echo -e "  ${cmd_style}gitmonkey help <command> --all\033[0m         Show all tone stages (dev preview)"
    fi
  fi
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