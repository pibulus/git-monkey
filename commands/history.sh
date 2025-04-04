#!/bin/bash

# ========= GIT MONKEY HISTORY VISUALIZATION =========
# Visual and interactive way to explore Git history

source ./utils/style.sh
source ./utils/config.sh
source ./utils/profile.sh
source ./utils/identity.sh
source ./utils/performance.sh

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
        "history") echo "📜" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "history") echo "[LOG]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "history") echo "📚" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "history") echo "🛰️" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "history") echo "📜" ;;
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
history_emoji=$(get_theme_emoji "history")

# Process flags
graph_view=""
branch_filter=""
count_limit="15"
author_filter=""
search_term=""
interactive=""

for arg in "$@"; do
  case "$arg" in
    --all|-a)
      count_limit="100"
      shift
      ;;
    --graph|-g)
      graph_view="true"
      shift
      ;;
    --branch=*)
      branch_filter="${arg#*=}"
      shift
      ;;
    --count=*|--limit=*)
      count_limit="${arg#*=}"
      shift
      ;;
    --author=*)
      author_filter="${arg#*=}"
      shift
      ;;
    --search=*)
      search_term="${arg#*=}"
      shift
      ;;
    --interactive|-i)
      interactive="true"
      shift
      ;;
  esac
done

# Function to show summary of recent activity
show_activity_summary() {
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$history_emoji Git Activity Summary"
  else
    echo "GIT ACTIVITY SUMMARY"
  fi
  echo ""
  
  # Get branch info
  local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -z "$current_branch" ]; then
    echo "$error_emoji Not in a git repository."
    return 1
  fi
  
  # Calculate stats
  local total_commits=$(git rev-list --count HEAD 2>/dev/null || echo "0")
  local authors_count=$(git shortlog -sn HEAD | wc -l | tr -d ' ')
  local branches_count=$(git branch | wc -l | tr -d ' ')
  local recent_commits=$(git log --since="7 days ago" --oneline | wc -l | tr -d ' ')
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hey $IDENTITY! Here's what's been happening in this repository:"
    echo ""
  fi
  
  echo "$history_emoji Repository overview:"
  echo "   Current branch: $current_branch"
  echo "   Total commits: $total_commits"
  echo "   Contributors: $authors_count"
  echo "   Branches: $branches_count"
  echo "   Commits in last 7 days: $recent_commits"
  echo ""
  
  # Recent activity
  echo "$history_emoji Recent activity:"
  if [ "$TONE_STAGE" -le 2 ]; then
    git log -n 5 --pretty=format:"   %C(yellow)%h%Creset %s - %C(green)%an%Creset, %ar" --abbrev-commit
  else 
    git log -n 5 --pretty=format:"   %h %s - %an, %ar" --abbrev-commit
  fi
  
  local duration=$(end_timing "$start_time")
  record_command_time "history_summary" "$duration"
  
  return 0
}

# Function to show commit history
show_commit_history() {
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$history_emoji Git Commit History"
  else
    echo "GIT COMMIT HISTORY"
  fi
  echo ""
  
  # Build the git log command based on flags
  local log_command="git log"
  
  # Apply filters
  [ -n "$branch_filter" ] && log_command="$log_command $branch_filter"
  [ -n "$author_filter" ] && log_command="$log_command --author=\"$author_filter\""
  [ -n "$search_term" ] && log_command="$log_command --grep=\"$search_term\""
  [ -n "$count_limit" ] && log_command="$log_command -n $count_limit"
  
  # Apply format
  if [ "$graph_view" = "true" ]; then
    # Graph view with colorized output
    if [ "$TONE_STAGE" -le 3 ]; then
      log_command="$log_command --graph --pretty=format:'%C(yellow)%h%Creset -%C(bold cyan)%d%Creset %s %C(green)(%ar) %C(blue)<%an>%Creset' --abbrev-commit"
    else
      log_command="$log_command --graph --oneline"
    fi
  else
    # List view
    if [ "$TONE_STAGE" -le 3 ]; then
      log_command="$log_command --pretty=format:'%C(yellow)%h%Creset - %s %C(green)(%ar) %C(blue)<%an>%Creset%C(bold cyan)%d%Creset' --abbrev-commit"
    else
      log_command="$log_command --oneline"
    fi
  fi
  
  # Execute the log command
  eval "$log_command"
  
  # Show count of displayed commits
  local shown_commits=$(eval "$log_command" | wc -l | tr -d ' ')
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$info_emoji Showing $shown_commits commits. Use flags to refine your view:"
    echo "   --graph (-g)     # Show branching graph"
    echo "   --all (-a)       # Show up to 100 commits instead of the default $count_limit"
    echo "   --branch=main    # Show commits for a specific branch"
    echo "   --author=name    # Filter by author"
    echo "   --search=term    # Search commit messages"
    echo ""
    echo "Example: gitmonkey history --graph --author=\"$IDENTITY\""
  else
    echo "$info_emoji Showing $shown_commits commits"
  fi
  
  local duration=$(end_timing "$start_time")
  record_command_time "history_log" "$duration")
  
  # Show performance insight
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )) && [ "$shown_commits" -gt 10 ]; then
    echo ""
    echo "⚡ Terminal efficiency: Displayed $shown_commits commits with visualization in $(printf "%.2f" "$duration") seconds!"
  fi
  
  return 0
}

# Function to show file history
show_file_history() {
  local file="$1"
  local start_time=$(start_timing)
  
  if [ -z "$file" ]; then
    echo "$error_emoji No file specified."
    return 1
  fi
  
  if [ ! -f "$file" ]; then
    echo "$error_emoji File not found: $file"
    return 1
  fi
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$history_emoji File History: $(basename "$file")"
  else
    echo "FILE HISTORY: $(basename "$file")"
  fi
  echo ""
  
  # Build the git log command for file history
  local log_command="git log"
  
  # Apply filters
  [ -n "$author_filter" ] && log_command="$log_command --author=\"$author_filter\""
  [ -n "$count_limit" ] && log_command="$log_command -n $count_limit"
  
  # Apply format
  if [ "$TONE_STAGE" -le 3 ]; then
    log_command="$log_command --pretty=format:'%C(yellow)%h%Creset - %s %C(green)(%ar) %C(blue)<%an>%Creset' --abbrev-commit"
  else
    log_command="$log_command --oneline"
  fi
  
  # Add the file path
  log_command="$log_command -- $file"
  
  # Execute the log command
  eval "$log_command"
  
  # Show count of displayed commits
  local shown_commits=$(eval "$log_command" | wc -l | tr -d ' ')
  
  echo ""
  echo "$info_emoji $shown_commits commits found for this file"
  
  # Show blame option
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "$info_emoji To see who wrote each line, try: gitmonkey history blame $file"
  fi
  
  local duration=$(end_timing "$start_time")
  record_command_time "history_file" "$duration")
  
  return 0
}

# Function to show blame view
show_blame() {
  local file="$1"
  local start_time=$(start_timing)
  
  if [ -z "$file" ]; then
    echo "$error_emoji No file specified."
    return 1
  fi
  
  if [ ! -f "$file" ]; then
    echo "$error_emoji File not found: $file"
    return 1
  fi
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$history_emoji Who Wrote What: $(basename "$file")"
  else
    echo "GIT BLAME: $(basename "$file")"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "This shows who last modified each line of code in $file:"
    echo ""
  fi
  
  # Run git blame with nice formatting
  if [ "$TONE_STAGE" -le 3 ]; then
    git blame --date=relative --color-lines "$file" | sed 's/^/  /'
  else
    git blame "$file" | sed 's/^/  /'
  fi
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$info_emoji For full file history: gitmonkey history file $file"
  fi
  
  local duration=$(end_timing "$start_time")
  record_command_time "history_blame" "$duration")
  
  return 0
}

# Interactive history browser
show_interactive_history() {
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$history_emoji Interactive History Browser"
  else
    echo "INTERACTIVE HISTORY BROWSER"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hey $IDENTITY! Let's explore your project's history together."
    echo ""
  fi
  
  # Save current head for reference
  local original_head=$(git rev-parse --short HEAD)
  
  # Show initial graph
  if [ "$TONE_STAGE" -le 3 ]; then
    git log -n 10 --graph --pretty=format:"%C(yellow)%h%Creset -%C(bold cyan)%d%Creset %s %C(green)(%ar) %C(blue)<%an>%Creset" --abbrev-commit
  else
    git log -n 10 --graph --oneline
  fi
  
  echo ""
  echo "$info_emoji Use this browser to navigate through your Git history."
  echo "Type 'help' for available commands, or 'exit' to quit."
  echo ""
  
  local continue=true
  while [ "$continue" = true ]; do
    read -p "$history_emoji history> " command args
    
    case "$command" in
      show|view)
        local commit="${args:-HEAD}"
        echo ""
        echo "Commit: $commit"
        echo "-----------------------------------"
        git show --stat --color "$commit"
        echo ""
        ;;
      next|more)
        local count="${args:-10}"
        echo ""
        if [ "$TONE_STAGE" -le 3 ]; then
          git log -n "$count" --graph --pretty=format:"%C(yellow)%h%Creset -%C(bold cyan)%d%Creset %s %C(green)(%ar) %C(blue)<%an>%Creset" --abbrev-commit
        else
          git log -n "$count" --graph --oneline
        fi
        echo ""
        ;;
      checkout|co)
        local commit="${args:-HEAD}"
        echo ""
        echo "Checking out: $commit"
        git checkout "$commit"
        echo ""
        ;;
      return)
        echo ""
        echo "Returning to original HEAD: $original_head"
        git checkout "$original_head"
        echo ""
        ;;
      diff)
        local commits=($args)
        if [ ${#commits[@]} -eq 2 ]; then
          echo ""
          echo "Diff between ${commits[0]} and ${commits[1]}:"
          git diff "${commits[0]}" "${commits[1]}"
        else
          echo ""
          echo "Usage: diff <commit1> <commit2>"
        fi
        echo ""
        ;;
      find|search)
        echo ""
        echo "Searching commits for: $args"
        git log --all --grep="$args" --pretty=format:"%C(yellow)%h%Creset - %s %C(green)(%ar) %C(blue)<%an>%Creset"
        echo ""
        ;;
      branches)
        echo ""
        echo "Branches and their latest commits:"
        git for-each-ref --sort=-committerdate refs/heads/ --format='%(color:yellow)%(refname:short)%(color:reset) - %(color:green)%(committerdate:relative)%(color:reset) - %(subject)'
        echo ""
        ;;
      help)
        echo ""
        echo "Available commands:"
        echo "  show [commit]      - Show details of a commit (default: HEAD)"
        echo "  next [count]       - Show more commits in the log (default: 10)"
        echo "  checkout <commit>  - Check out a specific commit"
        echo "  return             - Return to the original HEAD"
        echo "  diff <c1> <c2>     - Show diff between two commits"
        echo "  find <text>        - Search commit messages"
        echo "  branches           - List branches with latest commits"
        echo "  exit               - Exit interactive mode"
        echo ""
        ;;
      exit|quit)
        continue=false
        echo "Exiting interactive mode..."
        
        # Make sure we return to original HEAD
        git checkout "$original_head" &>/dev/null
        ;;
      *)
        echo ""
        echo "Unknown command: $command"
        echo "Type 'help' for available commands."
        echo ""
        ;;
    esac
  done
  
  local duration=$(end_timing "$start_time")
  record_command_time "history_interactive" "$duration")
  
  return 0
}

# Show usage help
show_help() {
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$history_emoji Git Monkey History Navigator"
    echo ""
    echo "Hey $IDENTITY! Here's how to explore your repository's history:"
  else
    echo "GIT HISTORY NAVIGATOR"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "Commands:"
    echo "  gitmonkey history                # Show repository summary and recent commits"
    echo "  gitmonkey history log            # Show detailed commit history"
    echo "  gitmonkey history file <path>    # Show history for a specific file"
    echo "  gitmonkey history blame <path>   # Show who wrote each line in a file"
    echo "  gitmonkey history interactive    # Start interactive history browser"
    echo ""
    echo "Options:"
    echo "  --graph, -g          # Show history with ASCII branch visualization"
    echo "  --all, -a            # Show more commits (up to 100)"
    echo "  --branch=<name>      # Filter by branch name"
    echo "  --author=<name>      # Filter by author"
    echo "  --search=<term>      # Search in commit messages"
    echo "  --count=<number>     # Limit output to specific number of commits"
    echo ""
    echo "Examples:"
    echo "  gitmonkey history log --graph --author=\"John\""
    echo "  gitmonkey history file src/app.js --count=5"
  else
    echo "Commands: history [log|file|blame|interactive] [path]"
    echo "Options: --graph, --all, --branch=X, --author=X, --search=X, --count=X" 
  fi
}

# Main function
main() {
  local subcommand="${1:-summary}"
  shift 2>/dev/null || true
  
  # Record starting time for performance tracking
  local start_time=$(start_timing)
  
  case "$subcommand" in
    summary|"")
      show_activity_summary
      ;;
    log|commits)
      show_commit_history
      ;;
    file)
      show_file_history "$1"
      ;;
    blame|who)
      show_blame "$1"
      ;;
    interactive|browser)
      show_interactive_history
      ;;
    help|--help|-h)
      show_help
      ;;
    *)
      echo "$error_emoji Unknown subcommand: $subcommand"
      show_help
      ;;
  esac
  
  # Record overall command time
  local total_duration=$(end_timing "$start_time")
  record_command_time "history_$subcommand" "$total_duration"
}

# Run main function with all arguments
main "$@"