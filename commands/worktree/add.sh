#!/bin/bash

# ========= GIT MONKEY WORKTREE ADD COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Creates a new worktree for a branch


# Check if tone variables are already set (passed from parent script)
if [ -z "$TONE_STAGE" ] || [ -z "$THEME" ] || [ -z "$IDENTITY" ]; then
  # If not set, load them directly
  
  # Get current tone stage and identity for context-aware help
  TONE_STAGE=$(get_tone_stage)
  THEME=$(get_selected_theme)
  IDENTITY=$(get_full_identity)
fi

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

# Default worktree prefix (should match the one in worktree.sh)
WORKTREE_PREFIX="gm-"
WORKTREE_STATE_FILE="$HOME/.gitmonkey/worktrees.json"

# Function to handle errors with friendly messages
handle_error() {
  # Tone-appropriate error message
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$error_emoji Oops, $IDENTITY! $1"
  else
    echo "$error_emoji $1"
  fi
  exit 1
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

# Function to get a random success message
display_success "$THEME"_message() {
  local messages=(
    "🐒 New dimension unlocked! Now you can work on multiple branches at once."
    "🌴 Your new branch tree is ready for climbing!"
    "🍌 Banana-split your work! This worktree lets you work on multiple things at once."
    "🧠 Git superpower activated: You can now context-switch without losing your place!"
    "🎉 Worktree created! It's like having a parallel universe for your code."
  )
  
  # Get a random message
  echo "${messages[$RANDOM % ${#messages[@]}]}"
}

# Main function
main() {
  local branch_name="$1"
  
  # Get root of current git repo
  local repo_root=$(git rev-parse --show-toplevel)
  if [ $? -ne 0 ]; then
    handle_error "Could not determine git repository root."
  fi
  
  # Check if branch exists
  if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
    echo "🤔 Branch '$branch_name' doesn't exist yet."
    read -p "Would you like to create it? (y/n): " create_branch
    
    if [[ $create_branch =~ ^[Yy]$ ]]; then
      echo "🌱 Creating new branch '$branch_name'..."
      git branch "$branch_name" || handle_error "Failed to create branch '$branch_name'."
      echo "✅ Branch created successfully!"
    else
      handle_error "Worktree creation cancelled. Branch must exist to create a worktree."
    fi
  fi
  
  # Define worktree path
  local worktree_path="$repo_root/../$WORKTREE_PREFIX$branch_name"
  worktree_path=$(realpath "$worktree_path")
  
  # Check if directory already exists
  if [ -d "$worktree_path" ]; then
    echo "🤔 Directory '$worktree_path' already exists."
    read -p "Would you like to use a different directory? (y/n): " use_different
    
    if [[ $use_different =~ ^[Yy]$ ]]; then
      read -p "Enter new directory name: $repo_root/../$WORKTREE_PREFIX" dir_suffix
      worktree_path="$repo_root/../$WORKTREE_PREFIX$dir_suffix"
      worktree_path=$(realpath "$worktree_path")
      
      if [ -d "$worktree_path" ]; then
        handle_error "Directory '$worktree_path' also exists. Please remove it first or choose another name."
      fi
    else
      handle_error "Worktree creation cancelled. Please remove the existing directory first."
    fi
  fi
  
  # Create the worktree
  echo "🚀 Creating worktree for branch '$branch_name' at '$worktree_path'..."
  git worktree add "$worktree_path" "$branch_name"
  
  if [ $? -ne 0 ]; then
    handle_error "Failed to create worktree. Make sure the branch exists and you have the right permissions."
  fi
  
  # Record the worktree in our state file
  record_worktree "$branch_name" "$worktree_path"
  
  # Success message with tone-appropriate styling
  if [ "$TONE_STAGE" -le 2 ]; then
    # Beginners get colorful, detailed success
    rainbow_box "$success_emoji Worktree Created!"
    echo ""
    typewriter "$(display_success "$THEME"_message)" 0.01
    echo ""
    echo "📁 Location: $worktree_path"
    echo "🌿 Branch: $branch_name"
    echo ""
    echo "Great job, $IDENTITY! To switch to this worktree, run:"
    echo "  gitmonkey worktree:switch $branch_name"
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get standard output
    rainbow_box "$success_emoji Worktree Created!"
    echo ""
    echo "$(display_success "$THEME"_message)"
    echo ""
    echo "📁 Location: $worktree_path"
    echo "🌿 Branch: $branch_name"
    echo ""
    echo "To switch to this worktree:"
    echo "  gitmonkey worktree:switch $branch_name"
    echo ""
  else
    # Expert users get minimal output
    echo "$success_emoji Worktree created for '$branch_name'"
    echo "📁 $worktree_path"
    echo "Switch: worktree:switch $branch_name"
    echo ""
  fi
}

# Execute main function with args
main "$@"
