#!/bin/bash

# ========= GIT MONKEY PIVOT COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Quickly switch context by stashing current work and creating/opening a worktree


# State file locations
WORKTREE_STATE_FILE="$HOME/.gitmonkey/worktrees.json"
PIVOT_STATE_FILE="$HOME/.gitmonkey/pivot.json"

# Make sure our gitmonkey config directory exists
mkdir -p "$HOME/.gitmonkey" 2>/dev/null

# Create the pivot state file if it doesn't exist
if [ ! -f "$PIVOT_STATE_FILE" ]; then
  echo '{"pivots":[]}' > "$PIVOT_STATE_FILE"
fi

# Function to handle errors with friendly messages
handle_error() {
  echo "❌ $1"
  exit 1
}

# Function to check if in a git repo
check_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    handle_error "Not inside a Git repository. Please run this command inside a Git repository."
  fi
}

# Function to get current branch
get_current_branch() {
  git branch --show-current
}

# Function to check for uncommitted changes
has_uncommitted_changes() {
  # Check for unstaged or staged but uncommitted changes
  if [ -n "$(git status --porcelain)" ]; then
    return 0  # Has changes
  else
    return 1  # No changes
  fi
}

# Function to save pivot state
save_pivot_state() {
  local current_branch="$1"
  local stash_name="$2"
  local temp_file=$(mktemp)

  # Get current data
  cat "$PIVOT_STATE_FILE" > "$temp_file"
  
  # Add or update pivot record
  jq --arg branch "$current_branch" --arg stash "$stash_name" '
    .pivots = (
      .pivots | map(select(.branch != $branch)) + [{"branch": $branch, "stash": $stash}]
    )
  ' "$temp_file" > "$PIVOT_STATE_FILE"
  
  rm "$temp_file"
}

# Function to get current directory
get_current_dir() {
  pwd
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

# Function to show usage help
show_help() {
  echo ""
  box "Git Monkey Pivot"
  echo ""
  echo "🧠 Pivot lets you quickly switch contexts with automatic stashing."
  echo ""
  echo "Usage:"
  echo "  gitmonkey pivot <branch>     - Stash current work and switch to branch"
  echo "  gitmonkey return             - Return to previous context and unstash"
  echo ""
  echo "Examples:"
  echo "  gitmonkey pivot feature-x    - Switch to feature-x (creating if needed)"
  echo "  gitmonkey pivot main         - Quick jump to main branch"
  echo "  gitmonkey return             - Go back to where you were before"
  echo ""
}

# Function for random pivot messages
random_pivot_message() {
  local messages=(
    "🧠 Context switch initiated! Your work is safely tucked away."
    "🌀 Pivoting to new dimension! Previous work preserved in amber."
    "🦸 Super context switch! No mental overhead required."
    "🌴 Swinging to a different tree while keeping your coconuts safe!"
    "🚀 Blast off to new code space! Previous changes secured."
  )
  
  # Get a random message
  echo "${messages[$RANDOM % ${#messages[@]}]}"
}

# Main function
main() {
  if [ -z "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
  fi
  
  local target_branch="$1"
  
  # Basic checks
  check_git_repo
  
  # Get current branch
  local current_branch=$(get_current_branch)
  if [ -z "$current_branch" ]; then
    handle_error "Could not determine current branch."
  fi
  
  # Store current location 
  record_location
  
  # If we have changes, stash them with a meaningful name
  if has_uncommitted_changes; then
    echo "🔍 Uncommitted changes detected."
    
    # Create a unique stash name with timestamp
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local stash_name="gitmonkey_pivot_${current_branch}_${timestamp}"
    
    echo "📦 Stashing your changes as '$stash_name'..."
    git stash push -m "$stash_name"
    
    if [ $? -ne 0 ]; then
      handle_error "Failed to stash changes."
    fi
    
    # Save pivot state for later retrieval
    save_pivot_state "$current_branch" "$stash_name"
    echo "✅ Changes safely stashed!"
  else
    echo "✅ No uncommitted changes to stash."
    # Save empty stash name to indicate no stash needed
    save_pivot_state "$current_branch" ""
  fi
  
  # Create success message
  echo ""
  typewriter "$(random_pivot_message)" 0.01
  echo ""
  
  # Now try to switch to the target branch via worktree
  echo "🚀 Switching to branch '$target_branch'..."
  
  # Delegate to worktree:switch, which will create if needed
  # Use command substitution to get cd commands to execute
  local commands=$(./commands/worktree/switch.sh "$target_branch")
  
  # Output the commands to be evaluated by the caller
  echo "$commands"
}

# Execute main function with args
main "$@"
