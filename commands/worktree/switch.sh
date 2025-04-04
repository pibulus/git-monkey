#!/bin/bash

# ========= GIT MONKEY WORKTREE SWITCH COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"
# Get current theme
THEME=$(get_selected_theme)


# Navigates to a worktree and remembers where you were


# Default worktree prefix (should match the one in worktree.sh)
WORKTREE_PREFIX="gm-"
WORKTREE_STATE_FILE="$HOME/.gitmonkey/worktrees.json"

# Process flags
auto_yes=""
force=""

for arg in "$@"; do
  case "$arg" in
    --yes|-y|--auto)
      auto_yes="true"
      shift
      ;;
    --force|-f)
      force="true"
      shift
      ;;
  esac
done

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

# Function to check for uncommitted changes
has_uncommitted_changes() {
  local dir="$1"
  local current_dir="$(pwd)"
  
  # If we're in the directory already, no need to cd
  if [ "$dir" != "$current_dir" ]; then
    cd "$dir" || return 1
  fi
  
  # Check for uncommitted changes
  if [ -n "$(git status --porcelain)" ]; then
    # Return to original directory if we changed
    if [ "$dir" != "$current_dir" ]; then
      cd "$current_dir" || true
    fi
    return 0  # Has changes
  else
    # Return to original directory if we changed
    if [ "$dir" != "$current_dir" ]; then
      cd "$current_dir" || true
    fi
    return 1  # No changes
  fi
}

# Function to get random switch messages
random_switch_message() {
  local messages=(
    "🐒 Swinging to a different branch tree!"
    "🌴 Climbing to a new development spot!"
    "🍌 Grabbing bananas from a different branch!"
    "🧠 Context switch complete! Your brain can stay focused."
    "🎯 Target acquired! You're now in a different code dimension."
  )
  
  # Get a random message
  echo "${messages[$RANDOM % ${#messages[@]}]}"
}

# Main function
main() {
  local branch_name="$1"
  
  if [ -z "$branch_name" ]; then
    handle_error "No branch name provided. Usage: gitmonkey worktree:switch <branch_name> [--yes] [--force]"
  fi
  
  # Check for uncommitted changes using the contextual help pattern
  if [ "$force" != "true" ] && has_uncommitted_changes "$(pwd)"; then
    # [Step 1] Detect issue - uncommitted changes exist
    
    # [Step 2] Show friendly explanation
    echo "🐒 Looks like you have uncommitted changes in your current worktree."
    echo "    Here's what's happening:"
    echo "    • You have local modifications that aren't committed"
    echo "    • Switching contexts without saving could lead to confusion later"
    echo "    • You have several options to handle this:"
    echo "      1. Commit your changes: git commit -m \"your message\""
    echo "      2. Stash your changes: git stash save \"your stash message\""
    echo "      3. Force switch anyway (if you know what you're doing)"
    
    # [Step 3] Offer to fix it
    proceed="false"
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, we'll stash automatically
      echo "🔄 Auto-stashing your changes before switching..."
      stash_name="gitmonkey_worktree_switch_$(date +"%Y%m%d_%H%M%S")"
      git stash save "$stash_name"
      if [ $? -eq 0 ]; then
        echo "✅ Changes stashed as: $stash_name"
        proceed="true"
      else
        handle_error "Failed to stash changes."
      fi
    else
      echo "How would you like to proceed?"
      echo "  1) Stash changes automatically"
      echo "  2) Stay here and commit manually"
      echo "  3) Force switch anyway"
      read -p "Enter option (1-3): " option
      
      case $option in
        1)
          # Stash changes
          stash_name="gitmonkey_worktree_switch_$(date +"%Y%m%d_%H%M%S")"
          echo "🔄 Stashing your changes as \"$stash_name\"..."
          git stash save "$stash_name"
          if [ $? -eq 0 ]; then
            echo "✅ Changes stashed successfully."
            proceed="true"
          else
            handle_error "Failed to stash changes."
          fi
          ;;
        2)
          echo "👍 Good choice. Commit your changes and try again."
          echo "   Run: git commit -m \"your message\""
          exit 0
          ;;
        3)
          echo "⚠️ Proceeding with uncommitted changes. This might lead to confusion later."
          proceed="true"
          ;;
        *)
          handle_error "Invalid option. Exiting."
          ;;
      esac
    fi
    
    # If we haven't decided to proceed, exit
    if [ "$proceed" != "true" ]; then
      exit 0
    fi
  fi
  
  # Save current location before switching
  record_location
  
  # Get the worktree path for the branch
  local worktree_path=$(get_worktree_path "$branch_name")
  
  # Apply contextual help for missing worktree
  if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
    # [Step 1] Detect issue - worktree doesn't exist
    
    # [Step 2] Show friendly explanation
    echo "🐒 Looks like there's no worktree for branch '$branch_name' yet."
    echo "    Here's what's happening:"
    echo "    • You're trying to switch to a worktree that doesn't exist"
    echo "    • Git Monkey can create it for you automatically"
    echo "    • This will set up a new directory linked to this repo"
    
    # [Step 3] Offer to fix it
    create_worktree="false"
    if [ "$auto_yes" == "true" ]; then
      create_worktree="true"
    else
      read -p "Want me to create a worktree for '$branch_name'? (Y/n): " answer
      if [[ "$answer" != "n" && "$answer" != "N" ]]; then
        create_worktree="true"
      fi
    fi
    
    # [Step 4] On confirmation, run the fix
    if [ "$create_worktree" == "true" ]; then
      echo "🌱 Creating new worktree for '$branch_name'..."
      ./commands/worktree/add.sh "$branch_name"
      # Get the path again after creation
      worktree_path=$(get_worktree_path "$branch_name")
      if [ -z "$worktree_path" ]; then
        handle_error "Failed to create worktree for '$branch_name'."
      fi
    else
      handle_error "No worktree found for branch '$branch_name'. Create one with 'gitmonkey worktree:add $branch_name'."
    fi
  fi
  
  # Print nice messages before switching
  echo ""
  typewriter "$(random_switch_message)" 0.01
  echo ""
  
  # Generate the cd command to be evaluated by the caller script
  # We can't cd directly here since it won't affect the parent shell
  echo "cd \"$worktree_path\""
  
  # Also try to open in VS Code if it's installed
  if command -v code >/dev/null 2>&1; then
    echo "code \"$worktree_path\" &>/dev/null &"
  fi
  
  # Provide a helpful tip
  echo "echo \"\" "
  echo "echo \"💡 To return to your previous location, use:\" "
  echo "echo \"   gitmonkey worktree:return\" "
  echo "echo \"\" "
}

# Execute main function with args
main "$@"
