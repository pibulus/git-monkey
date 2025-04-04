#!/bin/bash

# ========= GIT MONKEY CHEATSHEET =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Quick reference for common Git operations


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
        "cheat") echo "📝" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "cheat") echo "[REF]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "cheat") echo "📖" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "cheat") echo "🔭" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "cheat") echo "📝" ;;
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
cheat_emoji=$(get_theme_emoji "cheat")

# Process flags and arguments
category="$1"

# Function to show basic/essential commands
show_basics() {
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "$cheat_emoji Git Essentials: Basic Commands"
  else
    echo "GIT ESSENTIALS"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hey $IDENTITY! Here are the essential Git commands you'll use daily:"
  fi
  
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ SETUP & CONFIGURATION                                         │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ git init                   # Initialize a repository          │"
  echo "│ git clone <url>            # Clone a repository               │"
  echo "│ git config --global user.name \"Your Name\"                     │"
  echo "│ git config --global user.email \"email@example.com\"            │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ DAILY WORKFLOW                                                │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ git status                 # Check repository status          │"
  echo "│ git add <file>             # Stage file changes               │"
  echo "│ git add .                  # Stage all changes                │"
  echo "│ git commit -m \"message\"    # Commit changes                   │"
  echo "│ git pull                   # Fetch & merge remote changes     │"
  echo "│ git push                   # Send commits to remote           │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ BRANCHING                                                     │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ git branch                 # List branches                    │"
  echo "│ git branch <name>          # Create a branch                  │"
  echo "│ git checkout <name>        # Switch to a branch               │"
  echo "│ git checkout -b <name>     # Create & switch to a branch      │"
  echo "│ git merge <branch>         # Merge branch into current        │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ CHECKING CHANGES                                              │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ git diff                   # Show unstaged changes            │"
  echo "│ git diff --staged          # Show staged changes              │"
  echo "│ git log                    # Show commit history              │"
  echo "│ git log --oneline          # Show compact history             │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Git Monkey makes these easier, try:"
    echo "  gitmonkey branch new feature      # Create & switch branch"
    echo "  gitmonkey push                    # Smart push with tracking"
    echo "  gitmonkey history                 # Visualize Git history"
    echo ""
  fi
  
  # Record metrics
  local duration=$(end_timing "$start_time")
  record_command_time "cheatsheet_basics" "$duration")
  
  # Show terminal efficiency occasionally
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo "⚡ Terminal efficiency: Displayed this cheatsheet in $(printf "%.2f" "$duration") seconds!"
  fi
  
  return 0
}

# Function to show advanced commands
show_advanced() {
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "$cheat_emoji Git Advanced: Power User Commands"
  else
    echo "GIT ADVANCED COMMANDS"
  fi
  echo ""
  
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ UNDOING CHANGES                                               │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ git restore <file>          # Discard changes in a file       │"
  echo "│ git restore --staged <file> # Unstage a file                  │"
  echo "│ git reset HEAD~1            # Undo last commit, keep changes  │"
  echo "│ git reset --hard HEAD~1     # Undo last commit, discard changes│"
  echo "│ git revert <commit>         # Create new commit that undoes   │"
  echo "│                             # changes from specified commit   │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ REWRITING HISTORY                                             │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ git commit --amend          # Edit the last commit            │"
  echo "│ git rebase -i HEAD~3        # Interactive rebase last 3 commits│"
  echo "│ git cherry-pick <commit>    # Copy commit to current branch   │"
  echo "│ git rebase <branch>         # Replay commits on top of branch │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ TEMPORARY STORAGE                                             │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ git stash                   # Save changes for later          │"
  echo "│ git stash list              # List stashed changes            │"
  echo "│ git stash apply             # Apply stashed changes           │"
  echo "│ git stash pop               # Apply and remove stash          │"
  echo "│ git stash drop              # Delete stashed changes          │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ COLLABORATION                                                 │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ git fetch                   # Download remote changes         │"
  echo "│ git remote -v               # List remotes                    │"
  echo "│ git remote add <name> <url> # Add a remote repository         │"
  echo "│ git push -u origin <branch> # Push and set upstream           │"
  echo "│ git pull --rebase           # Pull with rebase instead of merge│"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Git Monkey alternatives for advanced operations:"
    echo "  gitmonkey undo last-commit    # Undo the last commit"
    echo "  gitmonkey stash save \"msg\"    # Stash changes with a message"
    echo "  gitmonkey conflict            # Handle merge conflicts"
    echo ""
  fi
  
  # Record metrics
  local duration=$(end_timing "$start_time")
  record_command_time "cheatsheet_advanced" "$duration")
  
  return 0
}

# Function to show Git workflows
show_workflows() {
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "$cheat_emoji Git Workflows: Common Patterns"
  else
    echo "GIT WORKFLOWS"
  fi
  echo ""
  
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ FEATURE BRANCH WORKFLOW                                       │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ # Start a new feature                                         │"
  echo "│ git checkout -b feature/name           # Create feature branch│"
  echo "│ # Make changes, then...                                       │"
  echo "│ git add .                              # Stage changes        │"
  echo "│ git commit -m \"Add feature X\"          # Commit changes      │"
  echo "│ git push -u origin feature/name        # Push to remote       │"
  echo "│ # Create PR on GitHub/GitLab, then after merge...             │"
  echo "│ git checkout main                      # Switch to main       │"
  echo "│ git pull                               # Get latest changes   │"
  echo "│ git branch -d feature/name             # Delete local branch  │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ KEEPING A BRANCH UP TO DATE                                   │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ # Method 1: Merge (safer, creates merge commit)               │"
  echo "│ git checkout feature/name              # Switch to feature    │"
  echo "│ git merge main                         # Merge main into it   │"
  echo "│                                                               │"
  echo "│ # Method 2: Rebase (cleaner history, rewrites commits)        │"
  echo "│ git checkout feature/name              # Switch to feature    │"
  echo "│ git rebase main                        # Rebase onto main     │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ RESOLVING CONFLICTS                                           │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ # When merge/rebase stops due to conflicts:                   │"
  echo "│ # 1. Edit files to resolve conflicts                          │"
  echo "│ # 2. Remove conflict markers (<<<<<<< HEAD, =======, >>>>>>>  │"
  echo "│ # 3. Stage the resolved files                                 │"
  echo "│ git add <resolved-files>                                      │"
  echo "│ # 4. Continue the operation                                   │"
  echo "│ git merge --continue  # For merge                             │"
  echo "│ git rebase --continue # For rebase                            │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Git Monkey provides simplified workflows:"
    echo "  gitmonkey branch new feature    # Start feature branch"
    echo "  gitmonkey push                  # Push with tracking"
    echo "  gitmonkey conflict resolve      # Interactive conflict resolution"
    echo ""
  fi
  
  # Record metrics
  local duration=$(end_timing "$start_time")
  record_command_time "cheatsheet_workflows" "$duration")
  
  return 0
}

# Function to show Git Monkey commands
show_gitmonkey() {
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "$cheat_emoji Git Monkey Command Reference"
  else
    echo "GIT MONKEY COMMANDS"
  fi
  echo ""
  
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ BASIC GIT MONKEY COMMANDS                                     │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ gitmonkey clone <url>       # Clone with interactive guidance │"
  echo "│ gitmonkey branch new <name> # Create and switch to branch     │"
  echo "│ gitmonkey push              # Push with automatic tracking    │"
  echo "│ gitmonkey stash             # Interactive stash management    │"
  echo "│ gitmonkey undo              # Safe undo operations menu       │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ ADVANCED GIT MONKEY FEATURES                                  │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ gitmonkey conflict          # Interactive conflict resolution │"
  echo "│ gitmonkey history           # Visualize Git history           │"
  echo "│ gitmonkey worktree          # Manage multiple working dirs    │"
  echo "│ gitmonkey fix               # Fix common dev issues           │"
  echo "│ gitmonkey open              # Open project in editor          │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  echo "┌───────────────────────────────────────────────────────────────┐"
  echo "│ LEARNING & CUSTOMIZATION                                      │"
  echo "├───────────────────────────────────────────────────────────────┤"
  echo "│ gitmonkey learn <topic>     # Interactive Git learning        │"
  echo "│ gitmonkey cheatsheet        # Quick command reference         │"
  echo "│ gitmonkey tips              # Get context-aware tips          │"
  echo "│ gitmonkey identity          # Configure your identity         │"
  echo "│ gitmonkey settings          # Customize Git Monkey            │"
  echo "└───────────────────────────────────────────────────────────────┘"
  echo ""
  
  # Record metrics
  local duration=$(end_timing "$start_time")
  record_command_time "cheatsheet_gitmonkey" "$duration")
  
  return 0
}

# Function to show a helpful reference card
show_reference() {
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$cheat_emoji Git Command Cheatsheet"
  else
    echo "GIT COMMAND REFERENCE"
  fi
  echo ""
  
  echo "SETUP & CONFIG"
  echo "  git init                  # Initialize git repository"
  echo "  git clone <url>           # Clone a repository"
  echo "  git config --global ...   # Set git configuration"
  echo ""
  
  echo "BASIC WORKFLOW"
  echo "  git status                # Show status"
  echo "  git add <file>            # Add file to staging"
  echo "  git add .                 # Add all changes to staging"
  echo "  git commit -m \"msg\"       # Commit with message"
  echo "  git push                  # Push to remote"
  echo "  git pull                  # Fetch & merge changes"
  echo ""
  
  echo "BRANCHING"
  echo "  git branch                # List branches"
  echo "  git branch <name>         # Create branch"
  echo "  git checkout <branch>     # Switch branches"
  echo "  git checkout -b <branch>  # Create & switch branch"
  echo "  git merge <branch>        # Merge into current branch"
  echo "  git branch -d <branch>    # Delete branch"
  echo ""
  
  echo "INSPECTING"
  echo "  git log                   # View commit history"
  echo "  git log --oneline         # Compact history"
  echo "  git log --graph           # Visual history"
  echo "  git diff                  # Changes not staged"
  echo "  git diff --staged         # Staged changes"
  echo "  git show <commit>         # View commit details"
  echo ""
  
  echo "UNDOING"
  echo "  git restore <file>        # Discard changes"
  echo "  git restore --staged <f>  # Unstage file"
  echo "  git reset HEAD~1          # Undo last commit"
  echo "  git commit --amend        # Edit last commit"
  echo "  git revert <commit>       # Revert a commit"
  echo ""
  
  echo "STASHING"
  echo "  git stash                 # Stash changes"
  echo "  git stash list            # List stashes"
  echo "  git stash pop             # Apply & remove stash"
  echo "  git stash apply           # Apply stash"
  echo ""
  
  echo "REMOTES"
  echo "  git remote -v             # List remotes"
  echo "  git remote add <name> <u> # Add remote"
  echo "  git fetch <remote>        # Get from remote"
  echo "  git pull <remote> <branch># Fetch & merge"
  echo "  git push <remote> <branch># Push to remote"
  echo "  git push -u origin <b>    # Push & set upstream"
  echo ""
  
  echo "ADVANCED"
  echo "  git rebase <branch>       # Rebase onto branch"
  echo "  git rebase -i HEAD~3      # Interactive rebase"
  echo "  git cherry-pick <commit>  # Copy commit"
  echo "  git bisect                # Binary search bugs"
  echo "  git worktree add <dir> <b># Add worktree"
  echo ""
  
  # Record metrics
  local duration=$(end_timing "$start_time")
  record_command_time "cheatsheet_reference" "$duration")
  
  return 0
}

# Show main cheatsheet usage/help
show_help() {
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$cheat_emoji Git Monkey Cheatsheet"
    echo ""
    echo "Hi $IDENTITY! Here's how to use the Git cheatsheet:"
  else
    echo "GIT CHEATSHEET USAGE"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "Available cheatsheet categories:"
    echo "  gitmonkey cheatsheet basics      # Essential daily Git commands"
    echo "  gitmonkey cheatsheet advanced    # Power user Git commands"
    echo "  gitmonkey cheatsheet workflows   # Common Git workflow patterns"
    echo "  gitmonkey cheatsheet gitmonkey   # Git Monkey specific commands"
    echo "  gitmonkey cheatsheet reference   # Compact command reference"
    echo ""
    echo "Examples:"
    echo "  gitmonkey cheatsheet basics      # Show basic commands"
    echo "  gitmonkey cheatsheet workflows   # Show common workflows"
  else
    echo "Usage: gitmonkey cheatsheet [basics|advanced|workflows|gitmonkey|reference]"
  fi
  
  echo ""
}

# Main function
main() {
  # Record starting time for performance tracking
  local start_time=$(start_timing)
  
  case "$category" in
    basics|basic|essential|essentials)
      show_basics
      ;;
    advanced|power|expert)
      show_advanced
      ;;
    workflows|patterns|flow)
      show_workflows
      ;;
    gitmonkey|monkey|gm)
      show_gitmonkey
      ;;
    reference|ref|compact|all)
      show_reference
      ;;
    help|--help|-h|"")
      show_help
      ;;
    *)
      echo "$error_emoji Unknown category: $category"
      show_help
      ;;
  esac
  
  # Record overall command time
  local total_duration=$(end_timing "$start_time")
  record_command_time "cheatsheet_total" "$total_duration"
}

# Run main function with all arguments
main
