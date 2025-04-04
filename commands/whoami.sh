#!/bin/bash

# ========= GIT MONKEY WHOAMI COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Shows your current Git context in a monkey-friendly way


# State file locations
WORKTREE_STATE_FILE="$HOME/.gitmonkey/worktrees.json"

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

# Function to get repository name
get_repo_name() {
  basename -s .git $(git config --get remote.origin.url 2>/dev/null || echo "local-repository")
}

# Function to get current directory name
get_current_dir_name() {
  basename "$(pwd)"
}

# Function to check if current directory is a worktree
is_worktree() {
  # Main repository worktree has .git as a directory, linked worktrees have it as a file
  if [ -f "$(pwd)/.git" ]; then
    return 0  # Is a linked worktree
  else
    # Check if it's the main worktree
    if [ -d "$(pwd)/.git/worktrees" ]; then
      return 2  # Is the main worktree
    fi
    return 1  # Not a worktree
  fi
}

# Function to get uncommitted changes count
get_uncommitted_change_count() {
  git status --porcelain | wc -l | tr -d ' '
}

# Function to get current commit
get_current_commit() {
  git rev-parse --short HEAD 2>/dev/null || echo "none"
}

# Function to get last commit message
get_last_commit_message() {
  git log -1 --pretty=format:"%s" 2>/dev/null || echo "No commits yet"
}

# Function to get last commit author
get_last_commit_author() {
  git log -1 --pretty=format:"%an" 2>/dev/null || echo "Unknown"
}

# Function to get last commit time
get_last_commit_time() {
  git log -1 --pretty=format:"%cr" 2>/dev/null || echo "Never"
}

# Main function
main() {
  # Check if in a git repo
  check_git_repo
  
  # Get basic information
  local current_branch=$(get_current_branch)
  local repo_name=$(get_repo_name)
  local dir_name=$(get_current_dir_name)
  local worktree_status=$(is_worktree)
  local uncommitted_changes=$(get_uncommitted_change_count)
  local current_commit=$(get_current_commit)
  local last_commit_msg=$(get_last_commit_message)
  local last_commit_author=$(get_last_commit_author)
  local last_commit_time=$(get_last_commit_time)
  
  # Determine worktree type
  local worktree_type=""
  if [ $worktree_status -eq 0 ]; then
    worktree_type="📁 Linked worktree"
  elif [ $worktree_status -eq 2 ]; then
    worktree_type="🏠 Main repository"
  else
    worktree_type="🤔 Not a worktree"
  fi
  
  # Show header 
  echo ""
  box "🐵 Git Monkey Context"
  echo ""
  
  # Show user info and identity
  local user_title=$(get_persistent_title)
  local tone_stage=$(get_tone_stage)
  local identity_mode=$(get_identity_mode)
  local full_identity=$(get_full_identity)
  local user_name=$(get_user_real_name)
  local title_locked="No"
  
  if is_title_locked; then
    title_locked="Yes"
  fi
  
  echo "👤 User: $MONKEY_USER"
  echo "🏆 Title: $user_title (Tone Stage $tone_stage/5)"
  
  # Only show identity details if different from default system user
  if [ -n "$user_name" ] && [ "$user_name" != "null" ]; then
    echo "🎭 Identity: $full_identity"
    echo "🔒 Title Locked: $title_locked"
  fi
  echo ""
  
  # Show repository info
  echo "📂 Repository: $repo_name"
  echo "🌿 Branch: $current_branch"
  echo "📍 Directory: $(pwd)"
  echo "🔄 Status: $worktree_type"
  echo ""
  
  # Show commit info
  echo "📌 Current commit: $current_commit"
  echo "📝 Last commit: $last_commit_msg"
  echo "👤 Author: $last_commit_author, $last_commit_time"
  echo ""
  
  # Show changes
  if [ "$uncommitted_changes" -gt 0 ]; then
    echo "🚧 You have $uncommitted_changes uncommitted change(s)"
    echo ""
    echo "Uncommitted files:"
    git status --short | head -5
    if [ "$(git status --short | wc -l)" -gt 5 ]; then
      echo "... and more (see 'git status' for full list)"
    fi
  else
    echo "✅ Working tree clean - all changes committed"
  fi
  echo ""
  
  # Show helpful tips based on context
  echo "💡 Suggestions:"
  if [ "$uncommitted_changes" -gt 0 ]; then
    echo "• Save your work with: git commit -m \"your message\""
    echo "• Discard changes with: git restore <file>"
    echo "• Want to switch context? Try: gitmonkey pivot <branch>"
  else
    echo "• Ready to try another branch? Use: gitmonkey worktree:add <branch>"
    echo "• See all your worktrees with: gitmonkey worktree:list"
    echo "• Learn Git worktrees with: gitmonkey learn worktrees"
  fi
  echo ""
}

# Execute main function
main
