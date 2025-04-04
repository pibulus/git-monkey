#!/bin/bash

# ========= GIT MONKEY WORKTREE REMOVE COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Removes a worktree safely with checks for unsaved work


# Default worktree prefix (should match the one in worktree.sh)
WORKTREE_PREFIX="gm-"
WORKTREE_STATE_FILE="$HOME/.gitmonkey/worktrees.json"

# Function to handle errors with friendly messages
handle_error() {
  echo "❌ $1"
  exit 1
}

# Function to get worktree path for a branch
get_worktree_path() {
  local branch="$1"
  local path=$(jq -r --arg branch "$branch" '.worktrees[] | select(.branch == $branch) | .path' "$WORKTREE_STATE_FILE" 2>/dev/null)
  
  if [ -z "$path" ] || [ "$path" = "null" ]; then
    # Try finding it manually through git worktree list
    path=$(git worktree list --porcelain | grep -A1 "branch refs/heads/$branch" | head -1 | cut -d' ' -f2-)
  fi
  
  echo "$path"
}

# Function to check for uncommitted changes
has_uncommitted_changes() {
  local repo_path="$1"
  if [ ! -d "$repo_path" ]; then
    return 1
  fi
  
  # Check for unstaged or staged but uncommitted changes
  if [ -n "$(git -C "$repo_path" status --porcelain)" ]; then
    return 0  # Has changes
  else
    return 1  # No changes
  fi
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

# Function to get random removal messages
random_removal_message() {
  local messages=(
    "🐒 Worktree removed! One less branch to manage."
    "🌴 Tree chopped down! Keeping your workspace tidy."
    "🧹 Cleanup complete! Less clutter, more focus."
    "🍌 No more bananas on that branch! Workspace simplified."
    "🌱 Pruned a branch from your development forest!"
  )
  
  # Get a random message
  echo "${messages[$RANDOM % ${#messages[@]}]}"
}

# Main function
main() {
  local branch_name="$1"
  local force="$2"
  
  # Get the worktree path for the branch
  local worktree_path=$(get_worktree_path "$branch_name")
  
  if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
    handle_error "No worktree found for branch '$branch_name'."
  fi
  
  # Check if this is our current directory
  if [ "$(pwd)" = "$worktree_path" ]; then
    handle_error "Cannot remove the worktree you're currently in. Please switch to another directory first."
  fi
  
  # Check for uncommitted changes unless --force is specified
  if [ "$force" != "--force" ] && has_uncommitted_changes "$worktree_path"; then
    echo "⚠️ Worktree has uncommitted changes!"
    echo ""
    echo "Changes found in: $worktree_path"
    echo ""
    read -p "Do you still want to remove it? UNCOMMITTED WORK WILL BE LOST! (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
      echo "Worktree removal cancelled."
      exit 0
    fi
  fi
  
  # Remove the worktree
  echo "🗑️ Removing worktree for branch '$branch_name' at '$worktree_path'..."
  git worktree remove "$worktree_path" --force
  
  if [ $? -ne 0 ]; then
    handle_error "Failed to remove worktree. You might need to use --force if there are untracked files."
  fi
  
  # Remove the worktree from our state file
  remove_worktree_record "$branch_name"
  
  # Success message
  echo ""
  typewriter "$(random_removal_message)" 0.01
  echo ""
  
  # Ask if they want to delete the branch too
  read -p "Would you like to delete the branch '$branch_name' too? (y/n): " delete_branch
  
  if [[ $delete_branch =~ ^[Yy]$ ]]; then
    echo "🗑️ Deleting branch '$branch_name'..."
    git branch -D "$branch_name"
    
    if [ $? -eq 0 ]; then
      echo "✅ Branch deleted successfully!"
    else
      echo "❌ Failed to delete branch. It might be your current branch or have unmerged changes."
    fi
  fi
}

# Execute main function with args
main "$@"
