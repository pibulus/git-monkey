#!/bin/bash

# ========= GIT MONKEY VISUALIZATION TOOL =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Visual representation of git information with theme-specific styling


# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        "branch") echo "🌿" ;;
        "commit") echo "🥜" ;;
        "merge") echo "🦧" ;;
        "diff") echo "🦁" ;;
        "time") echo "🕰️" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "branch") echo "[BRN]" ;;
        "commit") echo "[COM]" ;;
        "merge") echo "[MRG]" ;;
        "diff") echo "[DIF]" ;;
        "time") echo "[TIM]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "branch") echo "🌿" ;;
        "commit") echo "🔮" ;;
        "merge") echo "⚡" ;;
        "diff") echo "🧪" ;;
        "time") echo "⏳" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "branch") echo "🌍" ;;
        "commit") echo "🛸" ;;
        "merge") echo "🔭" ;;
        "diff") echo "🪐" ;;
        "time") echo "⌛" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "ℹ️" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "branch") echo "🌿" ;;
        "commit") echo "📦" ;;
        "merge") echo "🔄" ;;
        "diff") echo "📊" ;;
        "time") echo "⏰" ;;
        *) echo "ℹ️" ;;
      esac
      ;;
  esac
}

# Get theme-specific emojis
info_emoji=$(get_theme_emoji "info")
success_emoji=$(get_theme_emoji "success") 
error_emoji=$(get_theme_emoji "error")
warning_emoji=$(get_theme_emoji "warning")
branch_emoji=$(get_theme_emoji "branch")
commit_emoji=$(get_theme_emoji "commit")
merge_emoji=$(get_theme_emoji "merge")
diff_emoji=$(get_theme_emoji "diff")
time_emoji=$(get_theme_emoji "time")

# Process flags
show_all=false
count_limit=10
view_mode="branches"
branch_filter=""
since_date=""
animate=true

# Parse command-line arguments
for arg in "$@"; do
  case "$arg" in
    --all|-a)
      show_all=true
      shift
      ;;
    --count=*|--limit=*)
      count_limit="${arg#*=}"
      shift
      ;;
    --mode=*)
      view_mode="${arg#*=}"
      shift
      ;;
    --branch=*)
      branch_filter="${arg#*=}"
      shift
      ;;
    --since=*)
      since_date="${arg#*=}"
      shift
      ;;
    --no-animate)
      animate=false
      shift
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
  esac
done

# Show help function
show_help() {
  echo ""
  box "Git Monkey Visualization Tool"
  echo ""
  echo "Visually represent git information with theme-specific styling."
  echo ""
  echo "Usage:"
  echo "  gitmonkey visualize                 # Show branch relationship map"
  echo "  gitmonkey visualize --mode=TYPE     # Choose visualization type"
  echo "  gitmonkey visualize --branch=NAME   # Filter by branch"
  echo ""
  echo "Options:"
  echo "  --mode=TYPE      Visualization type (branches, heatmap, snapshots)"
  echo "  --branch=NAME    Filter to specific branch"
  echo "  --all, -a        Show all branches/commits"
  echo "  --count=N        Limit to N items"
  echo "  --since=DATE     Show items since date (e.g. '1 week ago')"
  echo "  --no-animate     Disable animations"
  echo "  --help, -h       Show this help message"
  echo ""
  echo "Examples:"
  echo "  gitmonkey visualize"
  echo "  gitmonkey visualize --mode=heatmap --since='1 month ago'"
  echo "  gitmonkey visualize --mode=snapshots --branch=main"
  echo ""
}

# Function to draw branch relationship map
draw_branch_relationship_map() {
  echo ""
  echo -e "${HEADER_COLOR}${branch_emoji} Branch Relationship Map${RESET_COLOR}"
  echo ""
  
  # Educational explanation based on tone level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners get a friendly, detailed explanation
    echo "Hey $IDENTITY! This map shows how your branches relate to each other."
    echo "Think of branches as parallel versions of your code that can be worked on separately."
    echo "• Branches ahead of others have commits the other branch doesn't have yet"
    echo "• Branches behind others are missing some commits from that branch"
    echo "• Merged branches have had their changes incorporated into another branch"
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get a concise but still helpful explanation
    echo "This visualization shows branch relationships and commit differences."
    echo "It highlights merge status, ahead/behind commit counts, and your current position."
    echo ""
  fi
  
  # Get current branch
  current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  
  # If show_all, get all branches, otherwise limit
  if [ "$show_all" = true ]; then
    branches=$(git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | head -n 30)
  else
    branches=$(git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | head -n $count_limit)
  fi
  
  # If branch_filter is specified, only show that branch and directly related branches
  if [ -n "$branch_filter" ]; then
    filtered_branches="$branch_filter"
    
    # Find branches that are merged into the filtered branch
    merged_branches=$(git branch --merged "$branch_filter" | grep -v "\*" | sed 's/^ *//' | grep -v "^$branch_filter$")
    
    # Find branches that the filtered branch is merged into
    for b in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
      if [ "$b" != "$branch_filter" ] && git branch --merged "$b" | grep -q "$branch_filter"; then
        filtered_branches="$filtered_branches $b"
      fi
    done
    
    # Combine all related branches
    branches="$branch_filter $merged_branches $filtered_branches"
    branches=$(echo "$branches" | tr ' ' '\n' | sort -u)
  fi

  # Get branch relationships
  declare -A branch_info=()
  declare -A branch_merged=()
  declare -A branch_ahead=()
  declare -A branch_behind=()
  declare -A branch_commits=()
  
  # Collect info for each branch
  for branch in $branches; do
    # Get last commit date
    commit_date=$(git show -s --format=%ci $branch)
    branch_info[$branch]="$commit_date"
    
    # Get number of commits
    commit_count=$(git rev-list --count $branch)
    branch_commits[$branch]="$commit_count"
    
    # Check if merged with other branches
    for other in $branches; do
      if [ "$branch" != "$other" ]; then
        # Check if branch is merged into other
        if git branch --merged "$other" | grep -q "$branch$"; then
          branch_merged["$branch|$other"]=1
        fi
        
        # Check commits ahead/behind
        ahead_behind=$(git rev-list --left-right --count $branch...$other)
        ahead=$(echo $ahead_behind | cut -f1)
        behind=$(echo $ahead_behind | cut -f2)
        
        branch_ahead["$branch|$other"]=$ahead
        branch_behind["$branch|$other"]=$behind
      fi
    done
  done
  
  # Draw the branch map based on theme
  case "$THEME" in
    "jungle")
      draw_jungle_branch_map "$branches" "$current_branch"
      ;;
    "hacker")
      draw_hacker_branch_map "$branches" "$current_branch"
      ;;
    "wizard")
      draw_wizard_branch_map "$branches" "$current_branch"
      ;;
    "cosmic")
      draw_cosmic_branch_map "$branches" "$current_branch"
      ;;
    *)
      draw_default_branch_map "$branches" "$current_branch"
      ;;
  esac
  
  return 0
}

# Draw branch map in jungle theme
draw_jungle_branch_map() {
  local branches="$1"
  local current_branch="$2"
  local branch_array=()
  
  # Convert branches to array
  while IFS= read -r branch; do
    branch_array+=("$branch")
  done <<< "$branches"
  
  # Draw a tree-like structure for branches
  echo -e "\e[33m"  # Jungle yellow color
  echo "              🌴  JUNGLE BRANCH MAP  🌴"
  echo "              =========================="
  echo ""
  echo "                 🌳 MAIN TRUNK 🌳"
  echo "                       |"
  echo "                       |"
  echo "                       ⬇️"
  echo ""
  
  # Process each branch
  for ((i=0; i<${#branch_array[@]}; i++)); do
    branch="${branch_array[$i]}"
    
    # Highlight current branch
    if [ "$branch" = "$current_branch" ]; then
      prefix="🐒 YOU ARE HERE → "
      branch_display="\e[1;33m$branch\e[0;33m"
    else
      if [ $i -eq 0 ]; then
        prefix="  🍌 "
      else
        prefix="  🌿 "
      fi
      branch_display="$branch"
    fi
    
    # Draw the branch
    echo -e "$prefix$branch_display"
    
    # Draw relationships with other branches
    for ((j=0; j<${#branch_array[@]}; j++)); do
      other="${branch_array[$j]}"
      if [ "$branch" != "$other" ]; then
        ahead="${branch_ahead["$branch|$other"]}"
        behind="${branch_behind["$branch|$other"]}"
        
        if [ -n "$ahead" ] && [ -n "$behind" ] && ([ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]); then
          if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            echo -e "      ├──🐿️ Swinging with $other ($ahead ahead, $behind behind)"
          elif [ "$ahead" -gt 0 ]; then
            echo -e "      ├──🍃 Ahead of $other by $ahead banana commits"
          elif [ "$behind" -gt 0 ]; then
            echo -e "      ├──🥥 Behind $other by $behind banana commits"
          fi
        fi
        
        if [ "${branch_merged["$branch|$other"]}" = "1" ]; then
          echo -e "      ├──🌺 Merged into $other"
        fi
        
        if [ "${branch_merged["$other|$branch"]}" = "1" ]; then
          echo -e "      ├──🦧 $other is merged here"
        fi
      fi
    done
    
    # Add branch commit count
    commit_count="${branch_commits[$branch]}"
    if [ -n "$commit_count" ]; then
      echo -e "      └──🥜 $commit_count banana commits"
    fi
    
    echo ""
  done
  
  echo -e "\e[0m"  # Reset color
}

# Draw branch map in hacker theme
draw_hacker_branch_map() {
  local branches="$1"
  local current_branch="$2"
  local branch_array=()
  
  # Convert branches to array
  while IFS= read -r branch; do
    branch_array+=("$branch")
  done <<< "$branches"
  
  # Draw a network-like structure for branches
  echo -e "\e[32m"  # Hacker green color
  echo "┌───────────────────────────────────────────┐"
  echo "│           NETWORK BRANCH TOPOLOGY         │"
  echo "└───────────────────────────────────────────┘"
  echo ""
  echo "INITIALIZING BRANCH SCAN..."
  echo "MAPPING NODES..."
  echo ""
  
  # Process each branch
  for ((i=0; i<${#branch_array[@]}; i++)); do
    branch="${branch_array[$i]}"
    
    # Highlight current branch
    if [ "$branch" = "$current_branch" ]; then
      branch_display="\e[1;32m[ACTIVE_NODE] $branch\e[0;32m"
    else
      branch_display="[NODE_${i}] $branch"
    fi
    
    # Draw the branch
    echo -e "$branch_display"
    
    # Draw relationships with other branches
    for ((j=0; j<${#branch_array[@]}; j++)); do
      other="${branch_array[$j]}"
      if [ "$branch" != "$other" ]; then
        ahead="${branch_ahead["$branch|$other"]}"
        behind="${branch_behind["$branch|$other"]}"
        
        if [ -n "$ahead" ] && [ -n "$behind" ] && ([ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]); then
          if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            echo -e "  ├──[DIVERGENT] WITH ${other} (${ahead}+, ${behind}-)"
          elif [ "$ahead" -gt 0 ]; then
            echo -e "  ├──[AHEAD] OF ${other} BY ${ahead} COMMITS"
          elif [ "$behind" -gt 0 ]; then
            echo -e "  ├──[BEHIND] ${other} BY ${behind} COMMITS"
          fi
        fi
        
        if [ "${branch_merged["$branch|$other"]}" = "1" ]; then
          echo -e "  ├──[MERGED] INTO ${other}"
        fi
        
        if [ "${branch_merged["$other|$branch"]}" = "1" ]; then
          echo -e "  ├──[MERGED_IN] ${other} -> ${branch}"
        fi
      fi
    done
    
    # Add branch commit count
    commit_count="${branch_commits[$branch]}"
    if [ -n "$commit_count" ]; then
      echo -e "  └──[COMMIT_COUNT] ${commit_count}"
    fi
    
    echo ""
  done
  
  echo "BRANCH MAPPING COMPLETE"
  echo -e "\e[0m"  # Reset color
}

# Draw branch map in wizard theme
draw_wizard_branch_map() {
  local branches="$1"
  local current_branch="$2"
  local branch_array=()
  
  # Convert branches to array
  while IFS= read -r branch; do
    branch_array+=("$branch")
  done <<< "$branches"
  
  # Draw a magical structure for branches
  echo -e "\e[35m"  # Wizard purple color
  echo "          ✨🧙 ARCANE BRANCH CODEX 🧙✨"
  echo "          ~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo ""
  echo "The Great Grimoire of Code Branches:"
  echo ""
  
  # Process each branch
  for ((i=0; i<${#branch_array[@]}; i++)); do
    branch="${branch_array[$i]}"
    
    # Highlight current branch
    if [ "$branch" = "$current_branch" ]; then
      branch_display="\e[1;35m$branch ⬅️ Your Current Spell\e[0;35m"
    else
      branch_display="$branch"
    fi
    
    # Draw the branch
    echo -e "📜 Spell Branch: $branch_display"
    
    # Draw relationships with other branches
    for ((j=0; j<${#branch_array[@]}; j++)); do
      other="${branch_array[$j]}"
      if [ "$branch" != "$other" ]; then
        ahead="${branch_ahead["$branch|$other"]}"
        behind="${branch_behind["$branch|$other"]}"
        
        if [ -n "$ahead" ] && [ -n "$behind" ] && ([ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]); then
          if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            echo -e "  │  ✨ Dual arcane link with $other (Cast $ahead ahead, Need $behind)"
          elif [ "$ahead" -gt 0 ]; then
            echo -e "  │  🧙 $ahead spells ahead of $other"
          elif [ "$behind" -gt 0 ]; then
            echo -e "  │  🔮 Missing $behind incantations from $other"
          fi
        fi
        
        if [ "${branch_merged["$branch|$other"]}" = "1" ]; then
          echo -e "  │  ⚡ Energies channeled into $other"
        fi
        
        if [ "${branch_merged["$other|$branch"]}" = "1" ]; then
          echo -e "  │  💫 $other essence flows within"
        fi
      fi
    done
    
    # Add branch commit count
    commit_count="${branch_commits[$branch]}"
    if [ -n "$commit_count" ]; then
      echo -e "  └──📚 $commit_count magical incantations inscribed"
    fi
    
    echo ""
  done
  
  echo -e "\e[0m"  # Reset color
}

# Draw branch map in cosmic theme
draw_cosmic_branch_map() {
  local branches="$1"
  local current_branch="$2"
  local branch_array=()
  
  # Convert branches to array
  while IFS= read -r branch; do
    branch_array+=("$branch")
  done <<< "$branches"
  
  # Draw a space-themed structure for branches
  echo -e "\e[38;5;33m"  # Cosmic blue color
  echo "         🚀 🛰️  CELESTIAL BRANCH MAP  🌠 🪐"
  echo "         =================================="
  echo ""
  echo "Mapping the stellar branches of your codeverse..."
  echo ""
  
  # Process each branch
  for ((i=0; i<${#branch_array[@]}; i++)); do
    branch="${branch_array[$i]}"
    
    # Highlight current branch
    if [ "$branch" = "$current_branch" ]; then
      branch_display="\e[1;38;5;33m🛸 $branch (Your current position)\e[0;38;5;33m"
    else
      if [ $i -eq 0 ]; then
        prefix="🌌 "
      else
        prefix="🌟 "
      fi
      branch_display="$prefix$branch"
    fi
    
    # Draw the branch
    echo -e "$branch_display"
    
    # Draw relationships with other branches
    for ((j=0; j<${#branch_array[@]}; j++)); do
      other="${branch_array[$j]}"
      if [ "$branch" != "$other" ]; then
        ahead="${branch_ahead["$branch|$other"]}"
        behind="${branch_behind["$branch|$other"]}"
        
        if [ -n "$ahead" ] && [ -n "$behind" ] && ([ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]); then
          if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            echo -e "    │  🌠 Divergent orbit with $other ($ahead ahead, $behind behind)"
          elif [ "$ahead" -gt 0 ]; then
            echo -e "    │  🚀 $ahead light-years ahead of $other"
          elif [ "$behind" -gt 0 ]; then
            echo -e "    │  ☄️ $behind light-years behind $other"
          fi
        fi
        
        if [ "${branch_merged["$branch|$other"]}" = "1" ]; then
          echo -e "    │  🪐 Merged into the $other galaxy"
        fi
        
        if [ "${branch_merged["$other|$branch"]}" = "1" ]; then
          echo -e "    │  🌍 $other has been absorbed into this solar system"
        fi
      fi
    done
    
    # Add branch commit count
    commit_count="${branch_commits[$branch]}"
    if [ -n "$commit_count" ]; then
      echo -e "    └──💫 $commit_count cosmic transmissions"
    fi
    
    echo ""
  done
  
  echo -e "\e[0m"  # Reset color
}

# Draw default branch map
draw_default_branch_map() {
  local branches="$1"
  local current_branch="$2"
  local branch_array=()
  
  # Convert branches to array
  while IFS= read -r branch; do
    branch_array+=("$branch")
  done <<< "$branches"
  
  # Draw a standard structure for branches
  echo "              Branch Relationship Map"
  echo "              ======================="
  echo ""
  
  # Process each branch
  for ((i=0; i<${#branch_array[@]}; i++)); do
    branch="${branch_array[$i]}"
    
    # Highlight current branch
    if [ "$branch" = "$current_branch" ]; then
      branch_display="\e[1m$branch (current)\e[0m"
    else
      branch_display="$branch"
    fi
    
    # Draw the branch
    echo -e "🌿 $branch_display"
    
    # Draw relationships with other branches
    for ((j=0; j<${#branch_array[@]}; j++)); do
      other="${branch_array[$j]}"
      if [ "$branch" != "$other" ]; then
        ahead="${branch_ahead["$branch|$other"]}"
        behind="${branch_behind["$branch|$other"]}"
        
        if [ -n "$ahead" ] && [ -n "$behind" ] && ([ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]); then
          if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            echo -e "  ├── Diverged from $other ($ahead ahead, $behind behind)"
          elif [ "$ahead" -gt 0 ]; then
            echo -e "  ├── Ahead of $other by $ahead commits"
          elif [ "$behind" -gt 0 ]; then
            echo -e "  ├── Behind $other by $behind commits"
          fi
        fi
        
        if [ "${branch_merged["$branch|$other"]}" = "1" ]; then
          echo -e "  ├── Merged into $other"
        fi
        
        if [ "${branch_merged["$other|$branch"]}" = "1" ]; then
          echo -e "  ├── $other is merged here"
        fi
      fi
    done
    
    # Add branch commit count
    commit_count="${branch_commits[$branch]}"
    if [ -n "$commit_count" ]; then
      echo -e "  └── $commit_count commits"
    fi
    
    echo ""
  done
}

# Function to draw commit heatmap
draw_commit_heatmap() {
  echo ""
  echo -e "${HEADER_COLOR}${commit_emoji} Commit Activity Heatmap${RESET_COLOR}"
  echo ""
  
  # Educational explanation based on tone level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners get a friendly, detailed explanation
    echo "Hey $IDENTITY! This heatmap shows when and how much you've been coding."
    echo "Each symbol represents commits (saved changes) on a particular day."
    echo "• More commits = more intense symbols (more coding activity)"
    echo "• Empty spaces mean no coding activity on that day"
    echo "This is a great way to track your progress and coding habits over time!"
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get a concise but still helpful explanation
    echo "This heatmap visualizes commit frequency and distribution over time."
    echo "Intensity of symbols correlates with commit volume on each day."
    echo ""
  fi
  
  # Set date range
  if [ -z "$since_date" ]; then
    since_date="1 month ago"
  fi
  
  # Get timestamps of commits
  commit_timestamps=$(git log --since="$since_date" --format="%at" $branch_filter)
  
  # Format into days
  commit_days=()
  while read -r timestamp; do
    if [ -n "$timestamp" ]; then
      day=$(date -r "$timestamp" "+%Y-%m-%d")
      commit_days+=("$day")
    fi
  done <<< "$commit_timestamps"
  
  # Count commits per day
  declare -A day_counts
  for day in "${commit_days[@]}"; do
    if [ -n "${day_counts[$day]}" ]; then
      day_counts[$day]=$((day_counts[$day] + 1))
    else
      day_counts[$day]=1
    fi
  done
  
  # Get list of all days in range (even with no commits)
  start_date=$(date -d "$since_date" "+%Y-%m-%d")
  end_date=$(date "+%Y-%m-%d")
  
  # Draw the heatmap based on theme
  case "$THEME" in
    "jungle")
      draw_jungle_heatmap
      ;;
    "hacker")
      draw_hacker_heatmap
      ;;
    "wizard")
      draw_wizard_heatmap
      ;;
    "cosmic")
      draw_cosmic_heatmap
      ;;
    *)
      draw_default_heatmap
      ;;
  esac
  
  return 0
}

# Draw heatmap in jungle theme
draw_jungle_heatmap() {
  echo -e "\e[33m"  # Jungle yellow color
  echo "🌴 JUNGLE COMMIT GROWTH CHART 🌴"
  echo "==============================="
  
  # Generate report of total commits
  total_commits=0
  for key in "${!day_counts[@]}"; do
    total_commits=$((total_commits + day_counts[$key]))
  done
  
  echo -e "🐒 Tracked $total_commits banana commits since $since_date"
  echo ""
  
  # Format current date for display
  month_display=$(date "+%B %Y")
  echo "Jungle growth for $month_display:"
  echo ""
  
  # Get current date parts
  current_year=$(date "+%Y")
  current_month=$(date "+%m")
  
  # Calculate days in current month
  days_in_month=$(cal "$current_month" "$current_year" | grep -v "^$" | tail -1 | awk '{print $NF}')
  
  # Create month header
  echo -ne "    "
  for d in $(seq 1 $days_in_month); do
    if (( d < 10 )); then
      echo -n " "
    fi
    echo -n "$d "
  done
  echo ""
  
  # Create week rows
  echo -n "    "
  for d in $(seq 1 $days_in_month); do
    week_day=$(date -d "$current_year-$current_month-$d" "+%u")
    if [ "$week_day" -eq 1 ]; then
      echo -n "M "
    elif [ "$week_day" -eq 3 ]; then
      echo -n "W "
    elif [ "$week_day" -eq 5 ]; then
      echo -n "F "
    else
      echo -n "· "
    fi
  done
  echo ""
  
  # Create heatmap
  echo -n "    "
  for d in $(seq 1 $days_in_month); do
    # Format date as YYYY-MM-DD
    if [ "$d" -lt 10 ]; then
      date_key="${current_year}-${current_month}-0${d}"
    else
      date_key="${current_year}-${current_month}-${d}"
    fi
    
    # Get count for this day
    count=${day_counts[$date_key]:-0}
    
    # Draw appropriate banana growth
    if [ "$count" -eq 0 ]; then
      echo -n "· "
    elif [ "$count" -eq 1 ]; then
      echo -n "🌱 "
    elif [ "$count" -eq 2 ]; then
      echo -n "🌿 "
    elif [ "$count" -le 4 ]; then
      echo -n "🍌 "
    else
      echo -n "🍍 "
    fi
  done
  echo ""
  
  # Legend
  echo ""
  echo "Banana Growth Chart:"
  echo "· = No commits"
  echo "🌱 = 1 commit"
  echo "🌿 = 2 commits"
  echo "🍌 = 3-4 commits"
  echo "🍍 = 5+ commits"
  echo ""
  
  echo -e "\e[0m"  # Reset color
}

# Draw heatmap in hacker theme
draw_hacker_heatmap() {
  echo -e "\e[32m"  # Hacker green color
  echo "┌───────────────────────────────────────┐"
  echo "│ COMMIT FREQUENCY ANALYSIS MODULE v2.0 │"
  echo "└───────────────────────────────────────┘"
  
  # Generate report of total commits
  total_commits=0
  for key in "${!day_counts[@]}"; do
    total_commits=$((total_commits + day_counts[$key]))
  done
  
  echo "SCANNING TIMEFRAME: SINCE $since_date"
  echo "COMMITS IDENTIFIED: $total_commits"
  echo "GENERATING VISUALIZATION..."
  echo ""
  
  # Format current date for display
  month_display=$(date "+%Y-%m")
  echo "ACTIVITY MATRIX [$month_display]:"
  echo ""
  
  # Get current date parts
  current_year=$(date "+%Y")
  current_month=$(date "+%m")
  
  # Calculate days in current month
  days_in_month=$(cal "$current_month" "$current_year" | grep -v "^$" | tail -1 | awk '{print $NF}')
  
  # Create day markers (abbreviated)
  echo -ne "    "
  for d in $(seq 1 $days_in_month); do
    if (( d % 5 == 0 )); then
      if (( d < 10 )); then
        echo -n " "
      fi
      echo -n "$d "
    else
      echo -n "· "
    fi
  done
  echo ""
  
  # Create heatmap
  echo -n "    "
  for d in $(seq 1 $days_in_month); do
    # Format date as YYYY-MM-DD
    if [ "$d" -lt 10 ]; then
      date_key="${current_year}-${current_month}-0${d}"
    else
      date_key="${current_year}-${current_month}-${d}"
    fi
    
    # Get count for this day
    count=${day_counts[$date_key]:-0}
    
    # Draw appropriate indicator
    if [ "$count" -eq 0 ]; then
      echo -n "· "
    elif [ "$count" -eq 1 ]; then
      echo -n "░ "
    elif [ "$count" -eq 2 ]; then
      echo -n "▒ "
    elif [ "$count" -le 4 ]; then
      echo -n "▓ "
    else
      echo -n "█ "
    fi
  done
  echo ""
  
  # Legend
  echo ""
  echo "ACTIVITY LEVELS:"
  echo "· = NO DATA [0]"
  echo "░ = LOW ACTIVITY [1]"
  echo "▒ = MEDIUM ACTIVITY [2]"
  echo "▓ = HIGH ACTIVITY [3-4]"
  echo "█ = CRITICAL ACTIVITY [5+]"
  echo ""
  echo "ANALYSIS COMPLETE"
  echo -e "\e[0m"  # Reset color
}

# Draw heatmap in wizard theme
draw_wizard_heatmap() {
  echo -e "\e[35m"  # Wizard purple color
  echo "✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨"
  echo "✨     MYSTICAL COMMIT CALENDAR     ✨"
  echo "✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨ ✨"
  
  # Generate report of total commits
  total_commits=0
  for key in "${!day_counts[@]}"; do
    total_commits=$((total_commits + day_counts[$key]))
  done
  
  echo ""
  echo "🧙 The magical aura shows $total_commits spells cast since $since_date"
  echo ""
  
  # Format current date for display
  month_display=$(date "+%B")
  echo "Arcane energies for the Moon of $month_display:"
  echo ""
  
  # Get current date parts
  current_year=$(date "+%Y")
  current_month=$(date "+%m")
  
  # Calculate days in current month
  days_in_month=$(cal "$current_month" "$current_year" | grep -v "^$" | tail -1 | awk '{print $NF}')
  
  # Create day markers
  echo -ne "    "
  for d in $(seq 1 $days_in_month); do
    if (( d % 7 == 1 )); then
      if (( d < 10 )); then
        echo -n " "
      fi
      echo -n "$d "
    else
      echo -n "· "
    fi
  done
  echo ""
  
  # Create heatmap
  echo -n "    "
  for d in $(seq 1 $days_in_month); do
    # Format date as YYYY-MM-DD
    if [ "$d" -lt 10 ]; then
      date_key="${current_year}-${current_month}-0${d}"
    else
      date_key="${current_year}-${current_month}-${d}"
    fi
    
    # Get count for this day
    count=${day_counts[$date_key]:-0}
    
    # Draw appropriate magical symbol
    if [ "$count" -eq 0 ]; then
      echo -n "· "
    elif [ "$count" -eq 1 ]; then
      echo -n "✧ "
    elif [ "$count" -eq 2 ]; then
      echo -n "⋆ "
    elif [ "$count" -le 4 ]; then
      echo -n "✨ "
    else
      echo -n "🔮 "
    fi
  done
  echo ""
  
  # Legend
  echo ""
  echo "Spell Intensity Symbols:"
  echo "·  = No magical activity"
  echo "✧  = A minor incantation"
  echo "⋆  = A proper spell"
  echo "✨ = Powerful conjurations"
  echo "🔮 = Archmage-level magic!"
  echo ""
  
  echo -e "\e[0m"  # Reset color
}

# Draw heatmap in cosmic theme
draw_cosmic_heatmap() {
  echo -e "\e[38;5;33m"  # Cosmic blue color
  echo "   🌌  🌠  COSMIC COMMIT CONSTELLATION  🛸  🌌"
  echo "   =========================================="
  
  # Generate report of total commits
  total_commits=0
  for key in "${!day_counts[@]}"; do
    total_commits=$((total_commits + day_counts[$key]))
  done
  
  echo ""
  echo "🚀 Detected $total_commits cosmic transmissions since $since_date"
  echo ""
  
  # Format current date for display
  month_display=$(date "+%B %Y")
  echo "Stellar activity for $month_display:"
  echo ""
  
  # Get current date parts
  current_year=$(date "+%Y")
  current_month=$(date "+%m")
  
  # Calculate days in current month
  days_in_month=$(cal "$current_month" "$current_year" | grep -v "^$" | tail -1 | awk '{print $NF}')
  
  # Create cosmic calendar
  echo -ne "    "
  for d in $(seq 1 $days_in_month); do
    if (( d % 5 == 0 )); then
      if (( d < 10 )); then
        echo -n " "
      fi
      echo -n "$d "
    else
      echo -n "· "
    fi
  done
  echo ""
  
  # Create heatmap
  echo -n "    "
  for d in $(seq 1 $days_in_month); do
    # Format date as YYYY-MM-DD
    if [ "$d" -lt 10 ]; then
      date_key="${current_year}-${current_month}-0${d}"
    else
      date_key="${current_year}-${current_month}-${d}"
    fi
    
    # Get count for this day
    count=${day_counts[$date_key]:-0}
    
    # Draw appropriate cosmic object
    if [ "$count" -eq 0 ]; then
      echo -n "· "
    elif [ "$count" -eq 1 ]; then
      echo -n "⋆ "
    elif [ "$count" -eq 2 ]; then
      echo -n "✦ "
    elif [ "$count" -le 4 ]; then
      echo -n "🌟 "
    else
      echo -n "🌠 "
    fi
  done
  echo ""
  
  # Legend
  echo ""
  echo "Celestial Activity Scale:"
  echo "·  = Empty space"
  echo "⋆  = Star dust"
  echo "✦  = Small star"
  echo "🌟 = Bright star"
  echo "🌠 = Supernova!"
  echo ""
  
  echo -e "\e[0m"  # Reset color
}

# Draw default heatmap
draw_default_heatmap() {
  echo "          Commit Activity Heatmap"
  echo "          ======================="
  
  # Generate report of total commits
  total_commits=0
  for key in "${!day_counts[@]}"; do
    total_commits=$((total_commits + day_counts[$key]))
  done
  
  echo "Found $total_commits commits since $since_date"
  echo ""
  
  # Format current date for display
  month_display=$(date "+%B %Y")
  echo "Activity for $month_display:"
  echo ""
  
  # Get current date parts
  current_year=$(date "+%Y")
  current_month=$(date "+%m")
  
  # Calculate days in current month
  days_in_month=$(cal "$current_month" "$current_year" | grep -v "^$" | tail -1 | awk '{print $NF}')
  
  # Create day markers
  echo -ne "    "
  for d in $(seq 1 $days_in_month); do
    if (( d % 5 == 0 )); then
      if (( d < 10 )); then
        echo -n " "
      fi
      echo -n "$d "
    else
      echo -n "· "
    fi
  done
  echo ""
  
  # Create heatmap
  echo -n "    "
  for d in $(seq 1 $days_in_month); do
    # Format date as YYYY-MM-DD
    if [ "$d" -lt 10 ]; then
      date_key="${current_year}-${current_month}-0${d}"
    else
      date_key="${current_year}-${current_month}-${d}"
    fi
    
    # Get count for this day
    count=${day_counts[$date_key]:-0}
    
    # Draw appropriate block
    if [ "$count" -eq 0 ]; then
      echo -n "· "
    elif [ "$count" -eq 1 ]; then
      echo -n "▪ "
    elif [ "$count" -eq 2 ]; then
      echo -n "▪▪ "
      d=$((d+1))
    elif [ "$count" -le 4 ]; then
      echo -n "▪▪▪ "
      d=$((d+1))
    else
      echo -n "█ "
    fi
  done
  echo ""
  
  # Legend
  echo ""
  echo "Activity Level:"
  echo "· = No commits"
  echo "▪ = 1 commit"
  echo "▪▪ = 2 commits"
  echo "▪▪▪ = 3-4 commits"
  echo "█ = 5+ commits"
  echo ""
}

# Function to show time-travel snapshot comparison
show_snapshot_comparison() {
  echo ""
  echo -e "${HEADER_COLOR}${time_emoji} Time-Travel Snapshot Comparison${RESET_COLOR}"
  echo ""
  
  # Educational explanation based on tone level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners get a friendly, detailed explanation
    echo "Hey $IDENTITY! This is like a time machine for your code!"
    echo "I'm showing you what files have changed between two points in your project history."
    echo "• Files marked 'added' are new files that didn't exist before"
    echo "• Files marked 'removed' existed before but were deleted"
    echo "• Files marked 'modified' have had their contents changed"
    echo "This helps you understand what changes happened over time in your project."
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get a concise but still helpful explanation
    echo "This visualization compares project structure between commits."
    echo "It provides a directory-level diff showing added, modified, and removed files."
    echo ""
  fi
  
  # Get current commit
  current_commit=$(git rev-parse HEAD)
  
  # Check if comparing with specific branch
  if [ -n "$branch_filter" ]; then
    compare_with="$branch_filter"
    compare_commit=$(git rev-parse "$branch_filter")
  else
    # Default to comparing with HEAD~3 (3 commits back)
    compare_with="HEAD~${count_limit}"
    compare_commit=$(git rev-parse "HEAD~${count_limit}" 2>/dev/null || git rev-parse "HEAD~1")
  fi
  
  # Get commit details for both commits
  current_details=$(git show -s --format="%h (%s)" "$current_commit")
  compare_details=$(git show -s --format="%h (%s)" "$compare_commit")
  
  # Calculate number of commits between
  commit_count=$(git rev-list --count "$compare_commit".."$current_commit")
  
  echo "📸 Project Snapshot Comparison ($commit_count commits apart)"
  echo ""
  echo "  Current: $current_details"
  echo "  Comparing with: $compare_details"
  echo ""
  
  # Get file changes
  files_added=$(git diff --name-status "$compare_commit" "$current_commit" | grep "^A" | wc -l | tr -d ' ')
  files_deleted=$(git diff --name-status "$compare_commit" "$current_commit" | grep "^D" | wc -l | tr -d ' ')
  files_modified=$(git diff --name-status "$compare_commit" "$current_commit" | grep "^M" | wc -l | tr -d ' ')
  
  echo "Files changed: $files_added added, $files_deleted removed, $files_modified modified"
  echo ""
  
  # Get directory structures for both commits
  # Create temporary directory for checkout
  temp_dir=$(mktemp -d)
  
  # Draw directory structures based on theme
  case "$THEME" in
    "jungle")
      draw_jungle_snapshot_comparison
      ;;
    "hacker")
      draw_hacker_snapshot_comparison
      ;;
    "wizard")
      draw_wizard_snapshot_comparison
      ;;
    "cosmic")
      draw_cosmic_snapshot_comparison
      ;;
    *)
      draw_default_snapshot_comparison
      ;;
  esac
  
  # Clean up temporary directory
  rm -rf "$temp_dir"
  
  return 0
}

# Draw snapshot comparison in jungle theme
draw_jungle_snapshot_comparison() {
  echo -e "\e[33m"  # Jungle yellow color
  
  # Get list of directories with changes
  changed_dirs=$(git diff --name-only "$compare_commit" "$current_commit" | sed 's/\/[^\/]*$//' | sort -u)
  
  echo "🌴 JUNGLE TIME VINES 🌴"
  echo "Before:                   After:"
  
  # Draw before and after structures side by side with jungle-themed symbols
  for dir in $changed_dirs; do
    # Skip empty directories
    if [ -z "$dir" ]; then
      continue
    fi
    
    # Get files in this directory for both commits
    old_files=$(git ls-tree -r --name-only "$compare_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    new_files=$(git ls-tree -r --name-only "$current_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    
    # Draw directory name
    echo -e "🌳 $dir/               🌳 $dir/"
    
    # Combine all file names for processing
    all_files=$(echo -e "$old_files\n$new_files" | sort -u)
    
    # Display files with status indicators
    while IFS= read -r file; do
      # Skip empty lines
      if [ -z "$file" ]; then
        continue
      fi
      
      # Determine file status
      in_old=$(echo "$old_files" | grep -F -x "$file")
      in_new=$(echo "$new_files" | grep -F -x "$file")
      
      if [ -n "$in_old" ] && [ -n "$in_new" ]; then
        # File exists in both - check if modified
        if git diff --quiet "$compare_commit" "$current_commit" -- "$dir/$file" 2>/dev/null; then
          old_indicator="  $file"
          new_indicator="  $file"
        else
          old_indicator="  $file"
          new_indicator="  $file (🍌 modified)"
        fi
      elif [ -n "$in_old" ]; then
        # File removed
        old_indicator="  $file"
        new_indicator="  (🙈 removed)"
      elif [ -n "$in_new" ]; then
        # File added
        old_indicator="  "
        new_indicator="  $file (🐒 added)"
      fi
      
      # Display file status for both sides
      printf "%-24s %-24s\n" "$old_indicator" "$new_indicator"
    done <<< "$all_files"
    
    echo ""
  done
  
  echo -e "\e[0m"  # Reset color
}

# Draw snapshot comparison in hacker theme
draw_hacker_snapshot_comparison() {
  echo -e "\e[32m"  # Hacker green color
  
  # Get list of directories with changes
  changed_dirs=$(git diff --name-only "$compare_commit" "$current_commit" | sed 's/\/[^\/]*$//' | sort -u)
  
  echo "┌─────────────────────────────────────────────────┐"
  echo "│        TEMPORAL CODEBASE DIFFERENTIATOR         │"
  echo "└─────────────────────────────────────────────────┘"
  echo ""
  echo "[SNAPSHOT_A]                [SNAPSHOT_B]"
  
  # Draw before and after structures side by side with hacker-themed symbols
  for dir in $changed_dirs; do
    # Skip empty directories
    if [ -z "$dir" ]; then
      continue
    fi
    
    # Get files in this directory for both commits
    old_files=$(git ls-tree -r --name-only "$compare_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    new_files=$(git ls-tree -r --name-only "$current_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    
    # Draw directory name
    echo -e "[DIR] $dir/               [DIR] $dir/"
    
    # Combine all file names for processing
    all_files=$(echo -e "$old_files\n$new_files" | sort -u)
    
    # Display files with status indicators
    while IFS= read -r file; do
      # Skip empty lines
      if [ -z "$file" ]; then
        continue
      fi
      
      # Determine file status
      in_old=$(echo "$old_files" | grep -F -x "$file")
      in_new=$(echo "$new_files" | grep -F -x "$file")
      
      if [ -n "$in_old" ] && [ -n "$in_new" ]; then
        # File exists in both - check if modified
        if git diff --quiet "$compare_commit" "$current_commit" -- "$dir/$file" 2>/dev/null; then
          old_indicator="  $file"
          new_indicator="  $file"
        else
          old_indicator="  $file"
          new_indicator="  $file [MODIFIED]"
        fi
      elif [ -n "$in_old" ]; then
        # File removed
        old_indicator="  $file"
        new_indicator="  [DELETED]"
      elif [ -n "$in_new" ]; then
        # File added
        old_indicator="  "
        new_indicator="  $file [NEW]"
      fi
      
      # Display file status for both sides
      printf "%-24s %-24s\n" "$old_indicator" "$new_indicator"
    done <<< "$all_files"
    
    echo ""
  done
  
  echo "[DIFF_COMPLETE]"
  echo -e "\e[0m"  # Reset color
}

# Draw snapshot comparison in wizard theme
draw_wizard_snapshot_comparison() {
  echo -e "\e[35m"  # Wizard purple color
  
  # Get list of directories with changes
  changed_dirs=$(git diff --name-only "$compare_commit" "$current_commit" | sed 's/\/[^\/]*$//' | sort -u)
  
  echo "✨ MAGICAL TIMELINE SCRYING ✨"
  echo ""
  echo "Past Vision:               Present Reality:"
  
  # Draw before and after structures side by side with wizard-themed symbols
  for dir in $changed_dirs; do
    # Skip empty directories
    if [ -z "$dir" ]; then
      continue
    fi
    
    # Get files in this directory for both commits
    old_files=$(git ls-tree -r --name-only "$compare_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    new_files=$(git ls-tree -r --name-only "$current_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    
    # Draw directory name
    echo -e "📜 $dir/               📜 $dir/"
    
    # Combine all file names for processing
    all_files=$(echo -e "$old_files\n$new_files" | sort -u)
    
    # Display files with status indicators
    while IFS= read -r file; do
      # Skip empty lines
      if [ -z "$file" ]; then
        continue
      fi
      
      # Determine file status
      in_old=$(echo "$old_files" | grep -F -x "$file")
      in_new=$(echo "$new_files" | grep -F -x "$file")
      
      if [ -n "$in_old" ] && [ -n "$in_new" ]; then
        # File exists in both - check if modified
        if git diff --quiet "$compare_commit" "$current_commit" -- "$dir/$file" 2>/dev/null; then
          old_indicator="  $file"
          new_indicator="  $file"
        else
          old_indicator="  $file"
          new_indicator="  $file (✨ transformed)"
        fi
      elif [ -n "$in_old" ]; then
        # File removed
        old_indicator="  $file"
        new_indicator="  (🧙 vanished)"
      elif [ -n "$in_new" ]; then
        # File added
        old_indicator="  "
        new_indicator="  $file (🔮 conjured)"
      fi
      
      # Display file status for both sides
      printf "%-24s %-24s\n" "$old_indicator" "$new_indicator"
    done <<< "$all_files"
    
    echo ""
  done
  
  echo -e "\e[0m"  # Reset color
}

# Draw snapshot comparison in cosmic theme
draw_cosmic_snapshot_comparison() {
  echo -e "\e[38;5;33m"  # Cosmic blue color
  
  # Get list of directories with changes
  changed_dirs=$(git diff --name-only "$compare_commit" "$current_commit" | sed 's/\/[^\/]*$//' | sort -u)
  
  echo "🌌 TEMPORAL COSMIC SHIFT 🌌"
  echo ""
  echo "Past Galaxy:               Current Dimension:"
  
  # Draw before and after structures side by side with cosmic-themed symbols
  for dir in $changed_dirs; do
    # Skip empty directories
    if [ -z "$dir" ]; then
      continue
    fi
    
    # Get files in this directory for both commits
    old_files=$(git ls-tree -r --name-only "$compare_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    new_files=$(git ls-tree -r --name-only "$current_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    
    # Draw directory name
    echo -e "🌌 $dir/               🌌 $dir/"
    
    # Combine all file names for processing
    all_files=$(echo -e "$old_files\n$new_files" | sort -u)
    
    # Display files with status indicators
    while IFS= read -r file; do
      # Skip empty lines
      if [ -z "$file" ]; then
        continue
      fi
      
      # Determine file status
      in_old=$(echo "$old_files" | grep -F -x "$file")
      in_new=$(echo "$new_files" | grep -F -x "$file")
      
      if [ -n "$in_old" ] && [ -n "$in_new" ]; then
        # File exists in both - check if modified
        if git diff --quiet "$compare_commit" "$current_commit" -- "$dir/$file" 2>/dev/null; then
          old_indicator="  $file"
          new_indicator="  $file"
        else
          old_indicator="  $file"
          new_indicator="  $file (🌠 evolved)"
        fi
      elif [ -n "$in_old" ]; then
        # File removed
        old_indicator="  $file"
        new_indicator="  (🕳️ collapsed)"
      elif [ -n "$in_new" ]; then
        # File added
        old_indicator="  "
        new_indicator="  $file (🌟 born)"
      fi
      
      # Display file status for both sides
      printf "%-24s %-24s\n" "$old_indicator" "$new_indicator"
    done <<< "$all_files"
    
    echo ""
  done
  
  echo -e "\e[0m"  # Reset color
}

# Draw default snapshot comparison
draw_default_snapshot_comparison() {
  # Get list of directories with changes
  changed_dirs=$(git diff --name-only "$compare_commit" "$current_commit" | sed 's/\/[^\/]*$//' | sort -u)
  
  echo "Before:                   After:"
  
  # Draw before and after structures side by side
  for dir in $changed_dirs; do
    # Skip empty directories
    if [ -z "$dir" ]; then
      continue
    fi
    
    # Get files in this directory for both commits
    old_files=$(git ls-tree -r --name-only "$compare_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    new_files=$(git ls-tree -r --name-only "$current_commit" "$dir" 2>/dev/null | sed "s|$dir/||" | sort)
    
    # Draw directory name
    echo -e "$dir/                   $dir/"
    
    # Combine all file names for processing
    all_files=$(echo -e "$old_files\n$new_files" | sort -u)
    
    # Display files with status indicators
    while IFS= read -r file; do
      # Skip empty lines
      if [ -z "$file" ]; then
        continue
      fi
      
      # Determine file status
      in_old=$(echo "$old_files" | grep -F -x "$file")
      in_new=$(echo "$new_files" | grep -F -x "$file")
      
      if [ -n "$in_old" ] && [ -n "$in_new" ]; then
        # File exists in both - check if modified
        if git diff --quiet "$compare_commit" "$current_commit" -- "$dir/$file" 2>/dev/null; then
          old_indicator="  $file"
          new_indicator="  $file"
        else
          old_indicator="  $file"
          new_indicator="  $file (modified)"
        fi
      elif [ -n "$in_old" ]; then
        # File removed
        old_indicator="  $file"
        new_indicator="  (removed)"
      elif [ -n "$in_new" ]; then
        # File added
        old_indicator="  "
        new_indicator="  $file (added)"
      fi
      
      # Display file status for both sides
      printf "%-24s %-24s\n" "$old_indicator" "$new_indicator"
    done <<< "$all_files"
    
    echo ""
  done
}

# Function to simulate merge animation
animate_merge() {
  local source_branch="$1"
  local target_branch="$2"
  
  # Skip animation if disabled
  if [ "$animate" = false ]; then
    return 0
  fi
  
  echo ""
  
  # Educational explanation based on tone level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners get a friendly, detailed explanation
    echo "Hey $IDENTITY! Watch what happens when we merge branches!"
    echo "Merging is like combining the changes from one branch into another."
    echo "• The code from '$source_branch' is moving into '$target_branch'"
    echo "• After merging, '$target_branch' will have all the changes from both branches"
    echo "• This animation visualizes this process to help you understand what's happening"
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get a concise but still helpful explanation
    echo "This animation visualizes the merge process from '$source_branch' into '$target_branch'."
    echo "It represents how changes flow from the source branch into the target branch."
    echo ""
  fi
  
  # Draw animation based on theme
  case "$THEME" in
    "jungle")
      animate_jungle_merge "$source_branch" "$target_branch"
      ;;
    "hacker")
      animate_hacker_merge "$source_branch" "$target_branch"
      ;;
    "wizard")
      animate_wizard_merge "$source_branch" "$target_branch"
      ;;
    "cosmic")
      animate_cosmic_merge "$source_branch" "$target_branch"
      ;;
    *)
      animate_default_merge "$source_branch" "$target_branch"
      ;;
  esac
  
  echo ""
  return 0
}

# Animate merge in jungle theme
animate_jungle_merge() {
  local source_branch="$1"
  local target_branch="$2"
  
  echo -e "\e[33m"  # Jungle yellow color
  echo "Swinging $source_branch into $target_branch..."
  
  # Frame 1
  echo ""
  echo "  🌴 $target_branch"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  🌴 $source_branch"
  sleep 0.5
  clear
  
  # Frame 2
  echo "Swinging $source_branch into $target_branch..."
  echo ""
  echo "  🌴 $target_branch"
  echo "  │"
  echo "  🐒"
  echo "  │"
  echo "  🌴 $source_branch"
  sleep 0.5
  clear
  
  # Frame 3
  echo "Swinging $source_branch into $target_branch..."
  echo ""
  echo "  🌴 $target_branch"
  echo "  🐒"
  echo "  │"
  echo "  │"
  echo "  🌴 $source_branch"
  sleep 0.5
  clear
  
  # Frame 4
  echo "Swinging $source_branch into $target_branch..."
  echo ""
  echo "  🍌 $target_branch (merged!)"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  🌿 $source_branch"
  
  echo -e "\e[0m"  # Reset color
}

# Animate merge in hacker theme
animate_hacker_merge() {
  local source_branch="$1"
  local target_branch="$2"
  
  echo -e "\e[32m"  # Hacker green color
  echo "MERGING $source_branch INTO $target_branch..."
  
  # Frame 1
  echo ""
  echo "  [TARGET] $target_branch"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  [SOURCE] $source_branch"
  sleep 0.5
  clear
  
  # Frame 2
  echo "MERGING $source_branch INTO $target_branch..."
  echo ""
  echo "  [TARGET] $target_branch"
  echo "  │"
  echo "  [ . ]"
  echo "  │"
  echo "  [SOURCE] $source_branch"
  sleep 0.5
  clear
  
  # Frame 3
  echo "MERGING $source_branch INTO $target_branch..."
  echo ""
  echo "  [TARGET] $target_branch"
  echo "  [ . ]"
  echo "  │"
  echo "  │"
  echo "  [SOURCE] $source_branch"
  sleep 0.5
  clear
  
  # Frame 4
  echo "MERGING $source_branch INTO $target_branch..."
  echo ""
  echo "  [TARGET_UPDATED] $target_branch"
  echo "  │"
  echo "  │< DATA TRANSFER COMPLETE"
  echo "  │"
  echo "  [SOURCE_MERGED] $source_branch"
  
  echo -e "\e[0m"  # Reset color
}

# Animate merge in wizard theme
animate_wizard_merge() {
  local source_branch="$1"
  local target_branch="$2"
  
  echo -e "\e[35m"  # Wizard purple color
  echo "✨ Casting the Merge Spell: $source_branch into $target_branch ✨"
  
  # Frame 1
  echo ""
  echo "  📜 $target_branch"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  📜 $source_branch"
  sleep 0.5
  clear
  
  # Frame 2
  echo "✨ Casting the Merge Spell: $source_branch into $target_branch ✨"
  echo ""
  echo "  📜 $target_branch"
  echo "  │"
  echo "  ✨"
  echo "  │"
  echo "  📜 $source_branch"
  sleep 0.5
  clear
  
  # Frame 3
  echo "✨ Casting the Merge Spell: $source_branch into $target_branch ✨"
  echo ""
  echo "  📜 $target_branch"
  echo "  ✨"
  echo "  │"
  echo "  │"
  echo "  📜 $source_branch"
  sleep 0.5
  clear
  
  # Frame 4
  echo "✨ Casting the Merge Spell: $source_branch into $target_branch ✨"
  echo ""
  echo "  🔮 $target_branch (enchanted!)"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  📜 $source_branch (essence transferred)"
  
  echo -e "\e[0m"  # Reset color
}

# Animate merge in cosmic theme
animate_cosmic_merge() {
  local source_branch="$1"
  local target_branch="$2"
  
  echo -e "\e[38;5;33m"  # Cosmic blue color
  echo "🚀 Initiating Interstellar Transfer: $source_branch ➡️ $target_branch 🛰️"
  
  # Frame 1
  echo ""
  echo "  🌍 $target_branch"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  🌑 $source_branch"
  sleep 0.5
  clear
  
  # Frame 2
  echo "🚀 Initiating Interstellar Transfer: $source_branch ➡️ $target_branch 🛰️"
  echo ""
  echo "  🌍 $target_branch"
  echo "  │"
  echo "  🚀"
  echo "  │"
  echo "  🌑 $source_branch"
  sleep 0.5
  clear
  
  # Frame 3
  echo "🚀 Initiating Interstellar Transfer: $source_branch ➡️ $target_branch 🛰️"
  echo ""
  echo "  🌍 $target_branch"
  echo "  🚀"
  echo "  │"
  echo "  │"
  echo "  🌑 $source_branch"
  sleep 0.5
  clear
  
  # Frame 4
  echo "🚀 Initiating Interstellar Transfer: $source_branch ➡️ $target_branch 🛰️"
  echo ""
  echo "  🌠 $target_branch (enhanced!)"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  🌑 $source_branch (data transferred)"
  
  echo -e "\e[0m"  # Reset color
}

# Animate default merge
animate_default_merge() {
  local source_branch="$1"
  local target_branch="$2"
  
  echo "Merging $source_branch into $target_branch..."
  
  # Frame 1
  echo ""
  echo "  $target_branch"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  $source_branch"
  sleep 0.5
  clear
  
  # Frame 2
  echo "Merging $source_branch into $target_branch..."
  echo ""
  echo "  $target_branch"
  echo "  │"
  echo "  ↑"
  echo "  │"
  echo "  $source_branch"
  sleep 0.5
  clear
  
  # Frame 3
  echo "Merging $source_branch into $target_branch..."
  echo ""
  echo "  $target_branch"
  echo "  ↑"
  echo "  │"
  echo "  │"
  echo "  $source_branch"
  sleep 0.5
  clear
  
  # Frame 4
  echo "Merging $source_branch into $target_branch..."
  echo ""
  echo "  $target_branch (merged!)"
  echo "  │"
  echo "  │"
  echo "  │"
  echo "  $source_branch"
}

# Main function
main() {
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "$error_emoji Not in a git repository."
    return 1
  fi
  
  # Run the appropriate visualization based on mode
  case "$view_mode" in
    "branches")
      draw_branch_relationship_map
      ;;
    "heatmap")
      draw_commit_heatmap
      ;;
    "snapshots")
      show_snapshot_comparison
      ;;
    "merge")
      # Animate a merge if source and target branch are provided
      if [ -n "$1" ] && [ -n "$2" ]; then
        animate_merge "$1" "$2"
      else
        echo "$error_emoji Source and target branches are required for merge animation."
        return 1
      fi
      ;;
    *)
      # Default to branch map
      draw_branch_relationship_map
      ;;
  esac
  
  return 0
}

# Call main function with arguments
main "$@"
