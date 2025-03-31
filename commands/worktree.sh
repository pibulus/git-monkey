#!/bin/bash

# ========= GIT MONKEY WORKTREE COMMAND =========
# Create and manage Git worktrees with a monkey-friendly interface

source ./utils/style.sh
source ./utils/config.sh

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
  echo ""
  box "Git Monkey Worktree Commands"
  echo ""
  echo "🌴 Worktrees let you work on multiple branches at the same time, in different folders."
  echo "   No more stashing! Just jump between contexts without losing your flow."
  echo ""
  echo "Commands:"
  echo "  gitmonkey worktree:add <branch>      - Create a new worktree for a branch"
  echo "  gitmonkey worktree:list              - Show all your active worktrees"
  echo "  gitmonkey worktree:switch <branch>   - Jump to a worktree"
  echo "  gitmonkey worktree:remove <branch>   - Clean up a worktree you don't need"
  echo "  gitmonkey worktree                   - Shows this help message"
  echo ""
  echo "Learn more: gitmonkey learn worktrees"
  echo ""
}

# Check if in a git repo
check_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "❌ Not inside a Git repository."
    echo "   Please run this command inside a Git repository."
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
        echo "❌ Please specify a branch name."
        echo "Usage: gitmonkey worktree:add <branch>"
        exit 1
      fi
      check_git_repo
      ./commands/worktree/add.sh "$2"
      ;;
    "list"|":list"|"list:"|"worktree:list")
      check_git_repo
      ./commands/worktree/list.sh
      ;;
    "switch"|":switch"|"switch:"|"worktree:switch")
      if [ -z "$2" ]; then
        echo "❌ Please specify a branch name."
        echo "Usage: gitmonkey worktree:switch <branch>"
        exit 1
      fi
      check_git_repo
      ./commands/worktree/switch.sh "$2"
      ;;
    "remove"|":remove"|"remove:"|"worktree:remove")
      if [ -z "$2" ]; then
        echo "❌ Please specify a branch name."
        echo "Usage: gitmonkey worktree:remove <branch>"
        exit 1
      fi
      check_git_repo
      ./commands/worktree/remove.sh "$2" "$3"
      ;;
    "help"|"--help"|"-h")
      show_help
      ;;
    *)
      echo "❌ Unknown command: $1"
      show_help
      exit 1
      ;;
  esac
}

# Execute main function with all args
main "$@"