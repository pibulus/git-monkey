#!/bin/bash

# ========= GIT MONKEY WORKTREE LIST COMMAND =========
# Lists all worktrees with helpful information

source ./utils/style.sh
source ./utils/config.sh

# State file location
WORKTREE_STATE_FILE="$HOME/.gitmonkey/worktrees.json"

# Function to get current branch
get_current_branch() {
  git branch --show-current
}

# Function to get shorthand commit message
get_commit_message() {
  local branch="$1"
  local message=$(git log -1 --pretty=format:"%s" "$branch" 2>/dev/null)
  
  # Truncate if too long
  if [ ${#message} -gt 50 ]; then
    message="${message:0:47}..."
  fi
  
  echo "$message"
}

# Function to check if a path is the current directory
is_current_directory() {
  local path="$1"
  local current_path=$(pwd)
  
  if [ "$path" = "$current_path" ]; then
    return 0
  else
    return 1
  fi
}

# Main function
main() {
  # Get all worktrees from git
  local git_worktrees=$(git worktree list --porcelain)
  if [ $? -ne 0 ]; then
    echo "❌ Failed to list worktrees."
    exit 1
  fi
  
  # Get our tracked worktrees
  local tracked_worktrees=$(jq -r '.worktrees[] | "\(.branch) \(.path)"' "$WORKTREE_STATE_FILE" 2>/dev/null)
  
  # Get current branch
  local current_branch=$(get_current_branch)
  
  # Print header
  box "🌴 Git Monkey Worktrees"
  echo ""
  
  # Check if we have any worktrees
  if [ -z "$git_worktrees" ]; then
    echo "No worktrees found. Create one with:"
    echo "  gitmonkey worktree:add <branch>"
    exit 0
  fi
  
  # Parse and display worktrees
  local parsed_worktrees=()
  local main_worktree=""
  
  # First find the main worktree
  while IFS= read -r line; do
    if [[ $line == worktree* ]]; then
      local path=${line#worktree }
      if [[ $(git -C "$path" rev-parse --is-bare-repository) == "false" ]] && [[ -z $(git -C "$path" rev-parse --git-path ../worktrees 2>/dev/null) ]]; then
        main_worktree="$path"
        break
      fi
    fi
  done < <(echo "$git_worktrees")
  
  # Process each worktree
  local current_path=""
  local current_branch=""
  local is_bare=""
  local is_detached=""
  
  while IFS= read -r line; do
    if [[ $line == worktree* ]]; then
      current_path=${line#worktree }
    elif [[ $line == branch* ]]; then
      current_branch=${line#branch refs/heads/}
    elif [[ $line == detached ]]; then
      is_detached="true"
    elif [[ $line == bare ]]; then
      is_bare="true"
    elif [[ -z $line ]]; then
      # Empty line indicates end of a worktree entry
      if [[ -n $current_path ]]; then
        # Skip bare repositories
        if [[ $is_bare != "true" ]]; then
          # Determine if this is the main worktree or a linked one
          local worktree_type="📁"
          if [[ $current_path == $main_worktree ]]; then
            worktree_type="🏠"
          fi
          
          # Determine branch name
          local branch_display="$current_branch"
          if [[ $is_detached == "true" ]]; then
            branch_display="(detached HEAD)"
          fi
          
          # Check if this is where we are currently
          local active_marker="⚪"
          if is_current_directory "$current_path"; then
            active_marker="🟢"
          fi
          
          # Add to our list
          parsed_worktrees+=("$active_marker $worktree_type $current_path 🌿 $branch_display")
        fi
        
        # Reset variables for the next worktree
        current_path=""
        current_branch=""
        is_bare=""
        is_detached=""
      fi
    fi
  done < <(echo "$git_worktrees")
  
  # Process the last worktree if needed
  if [[ -n $current_path ]] && [[ $is_bare != "true" ]]; then
    local worktree_type="📁"
    if [[ $current_path == $main_worktree ]]; then
      worktree_type="🏠"
    fi
    
    local branch_display="$current_branch"
    if [[ $is_detached == "true" ]]; then
      branch_display="(detached HEAD)"
    fi
    
    local active_marker="⚪"
    if is_current_directory "$current_path"; then
      active_marker="🟢"
    fi
    
    parsed_worktrees+=("$active_marker $worktree_type $current_path 🌿 $branch_display")
  fi
  
  # Display the worktrees
  if [ ${#parsed_worktrees[@]} -eq 0 ]; then
    echo "No worktrees found. Create one with:"
    echo "  gitmonkey worktree:add <branch>"
    exit 0
  fi
  
  echo "STATUS  LOCATION                           BRANCH"
  echo "---------------------------------------------------"
  for worktree in "${parsed_worktrees[@]}"; do
    echo "$worktree"
    
    # If this worktree is on a branch, show last commit
    local parts=($worktree)
    local branch=${parts[4]}
    if [[ $branch != "(detached" ]]; then
      local commit_msg=$(get_commit_message "$branch")
      if [[ -n $commit_msg ]]; then
        echo "        ↳ Last commit: $commit_msg"
      fi
    fi
    echo ""
  done
  
  echo ""
  echo "🔍 Legend:"
  echo "  🟢 Current location"
  echo "  ⚪ Other worktree"
  echo "  🏠 Main repository"
  echo "  📁 Linked worktree"
  echo ""
  
  # Add help text for new users
  echo "💡 Tip: Switch to a worktree with:"
  echo "  gitmonkey worktree:switch <branch>"
  echo ""
}

# Execute main function
main