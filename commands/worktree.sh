#!/bin/bash

# ========= GIT MONKEY WORKTREE COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Create and manage Git worktrees with a monkey-friendly interface


# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"  # Can be "info", "success", "error", "warning"
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        *) echo "🐒" ;;
      esac
      ;;
  esac
}

# Get theme-specific emojis
info_emoji=$(get_theme_emoji "info")
success_emoji=$(get_theme_emoji "success")
error_emoji=$(get_theme_emoji "error")
warning_emoji=$(get_theme_emoji "warning")

# Default worktree prefix
WORKTREE_PREFIX="gm-"
WORKTREE_STATE_FILE="$HOME/.gitmonkey/worktrees.json"

# Make sure our gitmonkey config directory exists
mkdir -p "$HOME/.gitmonkey" 2>/dev/null

# Create the worktrees state file if it doesn't exist
if [ ! -f "$WORKTREE_STATE_FILE" ]; then
  echo '{"worktrees":[], "last_location":""}' > "$WORKTREE_STATE_FILE"
fi

# Function to show usage help
show_help() {
  # Check if we have the new help system available
  if [ -f "./commands/help.sh" ] && [ -d "./help_data/worktree" ]; then
    ./commands/help.sh worktree
  else
    # Fallback to legacy help with tone awareness
    echo ""
    box "$info_emoji Git Monkey Worktree Commands"
    echo ""
    
    # Adjust explanation based on tone stage
    if [ "$TONE_STAGE" -le 2 ]; then
      # Beginners get detailed, friendly explanation
      echo "🌴 Hey $IDENTITY! Worktrees are amazing - they let you work on multiple branches at the same time, in different folders."
      echo "   No more stashing or context switching! You can have separate workspaces for each task."
    elif [ "$TONE_STAGE" -le 3 ]; then
      # Intermediate users get standard explanation
      echo "🌴 Worktrees let you work on multiple branches at the same time, in different folders."
      echo "   No more stashing! Just jump between contexts without losing your flow."
    else
      # Expert users get minimal explanation
      echo "🌴 Worktrees: Multiple branch workspaces in separate directories."
    fi
    
    echo ""
    echo "Commands:"
    echo "  gitmonkey worktree:add <branch>      - Create a new worktree for a branch"
    echo "  gitmonkey worktree:list              - Show all your active worktrees"
    echo "  gitmonkey worktree:switch <branch>   - Jump to a worktree"
    echo "  gitmonkey worktree:remove <branch>   - Clean up a worktree you don't need"
    echo "  gitmonkey worktree                   - Shows this help message"
    echo ""
    
    # Only show learning resources for beginners and intermediate users
    if [ "$TONE_STAGE" -le 3 ]; then
      echo "Learn more: gitmonkey learn worktrees"
      echo ""
    fi
  fi
}

# Check if in a git repo
check_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    # Tone-appropriate error message
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$error_emoji Hold on, $IDENTITY! You need to be inside a Git repository for this to work."
      echo "   Try navigating to a Git repository first, or create one with 'git init'."
    elif [ "$TONE_STAGE" -le 3 ]; then
      echo "$error_emoji Not inside a Git repository."
      echo "   Please run this command inside a Git repository."
    else
      echo "$error_emoji Not in a Git repository."
    fi
    exit 1
  fi
}

# Function to validate branch name
validate_branch() {
  local branch="$1"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    return 0  # Branch exists
  else
    return 1  # Branch doesn't exist
  fi
}

# Function to record worktree information
record_worktree() {
  local branch="$1"
  local path="$2"
  local temp_file=$(mktemp)

  # Get current data
  cat "$WORKTREE_STATE_FILE" > "$temp_file"
  
  # Add new worktree, replacing existing entry for the same branch if it exists
  jq --arg branch "$branch" --arg path "$path" '
    .worktrees = (
      .worktrees | map(select(.branch != $branch)) + [{"branch": $branch, "path": $path}]
    )
  ' "$temp_file" > "$WORKTREE_STATE_FILE"
  
  rm "$temp_file"
}

# Function to remove worktree from records
remove_worktree_record() {
  local branch="$1"
  local temp_file=$(mktemp)

  # Get current data
  cat "$WORKTREE_STATE_FILE" > "$temp_file"
  
  # Remove worktree entry
  jq --arg branch "$branch" '
    .worktrees = (
      .worktrees | map(select(.branch != $branch))
    )
  ' "$temp_file" > "$WORKTREE_STATE_FILE"
  
  rm "$temp_file"
}

# Function to get worktree path for a branch
get_worktree_path() {
  local branch="$1"
  
  jq -r --arg branch "$branch" '
    .worktrees[] | select(.branch == $branch) | .path
  ' "$WORKTREE_STATE_FILE"
}

# Function to record current location
record_location() {
  local location="$(pwd)"
  local temp_file=$(mktemp)

  # Get current data
  cat "$WORKTREE_STATE_FILE" > "$temp_file"
  
  # Update last location
  jq --arg loc "$location" '.last_location = $loc' "$temp_file" > "$WORKTREE_STATE_FILE"
  
  rm "$temp_file"
}

# Function to get last location
get_last_location() {
  jq -r '.last_location' "$WORKTREE_STATE_FILE"
}

# Main function
main() {
  # Check if a command is provided
  if [ -z "$1" ]; then
    show_help
    exit 0
  fi

  # Handle commands
  case "$1" in
    "add"|":add"|"add:"|"worktree:add")
      if [ -z "$2" ]; then
        # Tone-appropriate error message
        if [ "$TONE_STAGE" -le 2 ]; then
          echo "$error_emoji Hey $IDENTITY, you need to specify which branch to add a worktree for."
          echo "For example: gitmonkey worktree:add feature-branch"
        elif [ "$TONE_STAGE" -le 3 ]; then
          echo "$error_emoji Please specify a branch name."
          echo "Usage: gitmonkey worktree:add <branch>"
        else
          echo "$error_emoji Missing branch name."
          echo "Usage: worktree:add <branch>"
        fi
        exit 1
      fi
      check_git_repo
      # Pass through tone stage and identity information
      TONE_STAGE=$TONE_STAGE THEME=$THEME IDENTITY=$IDENTITY ./commands/worktree/add.sh "$2"
      ;;
    "list"|":list"|"list:"|"worktree:list")
      check_git_repo
      TONE_STAGE=$TONE_STAGE THEME=$THEME IDENTITY=$IDENTITY ./commands/worktree/list.sh
      ;;
    "switch"|":switch"|"switch:"|"worktree:switch")
      if [ -z "$2" ]; then
        # Tone-appropriate error message
        if [ "$TONE_STAGE" -le 2 ]; then
          echo "$error_emoji $IDENTITY, you need to tell me which branch you want to switch to."
          echo "For example: gitmonkey worktree:switch feature-branch"
        elif [ "$TONE_STAGE" -le 3 ]; then
          echo "$error_emoji Please specify a branch name."
          echo "Usage: gitmonkey worktree:switch <branch>"
        else
          echo "$error_emoji Missing branch name."
          echo "Usage: worktree:switch <branch>"
        fi
        exit 1
      fi
      check_git_repo
      TONE_STAGE=$TONE_STAGE THEME=$THEME IDENTITY=$IDENTITY ./commands/worktree/switch.sh "$2"
      ;;
    "remove"|":remove"|"remove:"|"worktree:remove")
      if [ -z "$2" ]; then
        # Tone-appropriate error message
        if [ "$TONE_STAGE" -le 2 ]; then
          echo "$error_emoji $IDENTITY, I need to know which branch worktree you want to remove."
          echo "For example: gitmonkey worktree:remove feature-branch"
        elif [ "$TONE_STAGE" -le 3 ]; then
          echo "$error_emoji Please specify a branch name."
          echo "Usage: gitmonkey worktree:remove <branch>"
        else
          echo "$error_emoji Missing branch name."
          echo "Usage: worktree:remove <branch>"
        fi
        exit 1
      fi
      check_git_repo
      TONE_STAGE=$TONE_STAGE THEME=$THEME IDENTITY=$IDENTITY ./commands/worktree/remove.sh "$2" "$3"
      ;;
    "help"|"--help"|"-h")
      show_help
      ;;
    *)
      # Tone-appropriate error for unknown command
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "$error_emoji Hmm, I don't recognize the command '$1', $IDENTITY."
      else
        echo "$error_emoji Unknown command: $1"
      fi
      show_help
      exit 1
      ;;
  esac
}

# Execute main function with all args
main "$@"
