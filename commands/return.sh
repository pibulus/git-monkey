#!/bin/bash

# ========= GIT MONKEY RETURN COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"
# Get current theme
THEME=$(get_selected_theme)


# Returns to previous context, restoring stashed work from pivot


# State file locations
WORKTREE_STATE_FILE="$HOME/.gitmonkey/worktrees.json"
PIVOT_STATE_FILE="$HOME/.gitmonkey/pivot.json"

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

# Function to get last location
get_last_location() {
  local last_location=$(jq -r '.last_location' "$WORKTREE_STATE_FILE" 2>/dev/null)
  
  if [ -z "$last_location" ] || [ "$last_location" = "null" ]; then
    return 1
  fi
  
  echo "$last_location"
}

# Function to get stash name for branch
get_stash_for_branch() {
  local branch="$1"
  local stash_name=$(jq -r --arg branch "$branch" '.pivots[] | select(.branch == $branch) | .stash' "$PIVOT_STATE_FILE" 2>/dev/null)
  
  if [ -z "$stash_name" ] || [ "$stash_name" = "null" ]; then
    return 1
  fi
  
  echo "$stash_name"
}

# Function to remove pivot record
remove_pivot_record() {
  local branch="$1"
  local temp_file=$(mktemp)

  # Get current data
  cat "$PIVOT_STATE_FILE" > "$temp_file"
  
  # Remove pivot entry
  jq --arg branch "$branch" '
    .pivots = (
      .pivots | map(select(.branch != $branch))
    )
  ' "$temp_file" > "$PIVOT_STATE_FILE"
  
  rm "$temp_file"
}

# Function to find stash entry
find_stash_entry() {
  local stash_name="$1"
  local stash_index=$(git stash list | grep -n "$stash_name" | cut -d':' -f1)
  
  if [ -z "$stash_index" ]; then
    return 1
  fi
  
  # Convert to 0-based for git stash commands
  echo $((stash_index - 1))
}

# Function for random return messages
random_return_message() {
  local messages=(
    "🧠 Context restored! Back to where you left off."
    "🌀 Time travel complete! Returning to your previous work."
    "🦸 Super context switch! Your brain thanks you."
    "🌴 Swinging back to your original branch!"
    "🚀 Landing back at base camp. Work state restored."
  )
  
  # Get a random message
  echo "${messages[$RANDOM % ${#messages[@]}]}"
}

# Main function
main() {
  # Basic checks
  check_git_repo
  
  # Get the last location
  local last_location=$(get_last_location)
  if [ $? -ne 0 ]; then
    handle_error "No previous location found. Have you used 'gitmonkey pivot' or 'gitmonkey worktree:switch' before?"
  fi
  
  # Check if the location exists
  if [ ! -d "$last_location" ]; then
    handle_error "Previous location no longer exists: $last_location"
  fi
  
  # Get the branch at the last location
  local last_branch=$(cd "$last_location" && git branch --show-current)
  if [ $? -ne 0 ] || [ -z "$last_branch" ]; then
    # Just try to change to the directory without branch context
    echo "cd \"$last_location\""
    echo "echo \"⚠️ Returned to previous location, but could not determine branch context.\""
    exit 0
  fi
  
  # Get stash for the branch
  local stash_name=$(get_stash_for_branch "$last_branch")
  local stash_exists=$?
  
  # Print nice return message
  echo ""
  typewriter "$(random_return_message)" 0.01
  echo ""
  
  # Generate cd command to return to previous location
  echo "cd \"$last_location\""
  
  # If we have a stash, try to apply it
  if [ $stash_exists -eq 0 ] && [ -n "$stash_name" ]; then
    local stash_index=$(find_stash_entry "$stash_name")
    
    if [ $? -eq 0 ]; then
      # Apply the stash 
      echo "echo \"📦 Restoring your stashed changes from '$stash_name'...\""
      echo "git stash apply stash@{$stash_index} && git stash drop stash@{$stash_index} || echo \"⚠️ Failed to apply stash. Your changes are still in the stash list.\""
    else
      echo "echo \"⚠️ Could not find stash '$stash_name'. You might need to manually apply it with 'git stash list' and 'git stash apply'.\""
    fi
  fi
  
  # Remove pivot record regardless of stash application success
  remove_pivot_record "$last_branch"
  
  # Final message
  echo "echo \"✅ Returned to branch '$last_branch' at location: $last_location\""
}

# Execute main function
main
