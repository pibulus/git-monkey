#!/bin/bash

# ========= GIT MONKEY MERGE TOOL =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Enhanced merge functionality with AI risk analysis


# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Process flags
auto_yes=""
force=""
analyze_mode=""

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
    --analyze|--ai)
      analyze_mode="true"
      shift
      ;;
  esac
done

# Show themed header based on current theme
show_themed_header() {
  local title="$1"
  
  case "$THEME" in
    "jungle")
      echo -e "\e[33m"
      echo "🐒 🍌 🌴 $title 🌴 🍌 🐒"
      echo -e "\e[0m"
      ;;
    "hacker")
      echo -e "\e[32m"
      echo "[ $title ]"
      echo -e "\e[0m"
      ;;
    "wizard")
      echo -e "\e[35m"
      echo "✨ $title ✨"
      echo -e "\e[0m"
      ;;
    "cosmic")
      echo -e "\e[38;5;33m"
      echo "🌌 $title 🌌"
      echo -e "\e[0m"
      ;;
    *)
      box "$title"
      ;;
  esac
}

# Function to check for uncommitted changes
has_uncommitted_changes() {
  if [ -n "$(git status --porcelain)" ]; then
    return 0  # Has changes
  else
    return 1  # No changes
  fi
}

# Function to analyze merge risks with AI
analyze_merge_risks() {
  local source_branch="$1"
  local target_branch="$2"
  
  # Check if AI is configured
  if ! has_ai_providers; then
    echo "❌ AI features are not configured yet."
    echo "Run 'gitmonkey settings ai' to set up AI integration."
    return 1
  fi
  
  # Get default provider
  local provider=$(get_default_ai_provider)
  
  if [ -z "$provider" ]; then
    echo "❌ No default AI provider set."
    echo "Run 'gitmonkey settings ai' to set a default provider."
    return 1
  fi
  
  # Check that both branches exist
  if ! git show-ref --verify --quiet refs/heads/"$source_branch"; then
    echo "❌ Branch '$source_branch' doesn't exist."
    return 1
  fi
  
  if ! git show-ref --verify --quiet refs/heads/"$target_branch"; then
    echo "❌ Branch '$target_branch' doesn't exist."
    return 1
  fi
  
  # Show themed header
  show_themed_header "MERGE RISK ANALYSIS"
  
  # Show what we're analyzing
  echo "Analyzing potential risks of merging:"
  echo "• Source branch: $source_branch"
  echo "• Target branch: $target_branch"
  echo ""
  
  # Theme-specific loading messages
  case "$THEME" in
    "jungle")
      echo "🐒 Monkey swinging through the branches to look for obstacles..."
      ;;
    "hacker")
      echo "> Executing differential branch analysis..."
      echo "> Scanning conflict vectors..."
      ;;
    "wizard")
      echo "🧙‍♂️ Divining the arcane patterns between branches..."
      ;;
    "cosmic")
      echo "🔭 Examining the gravitational interactions between code galaxies..."
      ;;
    *)
      echo "Analyzing potential merge conflicts and risks..."
      ;;
  esac
  echo ""
  
  # Get diff information
  local common_ancestor=$(git merge-base "$source_branch" "$target_branch")
  local source_diff=$(git diff --name-status "$common_ancestor" "$source_branch")
  local target_diff=$(git diff --name-status "$common_ancestor" "$target_branch")
  
  # Identify files changed in both branches
  local source_files=$(echo "$source_diff" | awk '{print $2}')
  local target_files=$(echo "$target_diff" | awk '{print $2}')
  local potential_conflicts=""
  
  for file in $source_files; do
    if echo "$target_files" | grep -q -F "$file"; then
      potential_conflicts="$potential_conflicts$file"$'\n'
    fi
  done
  
  # Check if there are merge conflicts without actually merging
  local conflict_check=$(git merge-tree "$common_ancestor" "$target_branch" "$source_branch")
  local has_conflicts=$(echo "$conflict_check" | grep -c "^<<<<<<<")
  
  # Get repo info
  local repo_name=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)" || echo "local repository")
  
  # Get commit counts and authors
  local source_commits=$(git rev-list --count "$common_ancestor..$source_branch")
  local target_commits=$(git rev-list --count "$common_ancestor..$target_branch")
  local source_authors=$(git log "$common_ancestor..$source_branch" --format="%an" | sort -u | wc -l | tr -d '[:space:]')
  local target_authors=$(git log "$common_ancestor..$target_branch" --format="%an" | sort -u | wc -l | tr -d '[:space:]')
  
  # Create a prompt based on the theme
  local prompt=""
  
  case "$THEME" in
    "jungle")
      prompt="You're Git Monkey - a helpful, jungle-themed Git assistant. I'm considering merging one branch into another. Analyze the risk level and provide advice. Use a light jungle theme but keep it primarily practical and professional.

Repository: $repo_name
Source branch: $source_branch ($source_commits commits by $source_authors authors since diverging)
Target branch: $target_branch ($target_commits commits by $target_authors authors since diverging)

Files changed in source:
$source_diff

Files changed in target:
$target_diff

Potential conflicts in these files:
$potential_conflicts

Raw conflict check (grep count: $has_conflicts):
${conflict_check:0:1000}

Please analyze and provide:
1. A risk assessment on a scale of 1-5 monkeys (1 = very safe, 5 = very risky)
2. A brief explanation of the risk factors
3. Specific recommendations to reduce risk
4. Whether I should proceed with caution or consider alternatives"
      ;;
    "hacker")
      prompt="You're an elite terminal-based Git assistant. Analyze the risk of merging between these Git branches. Use a technical, hacker-inspired tone but keep it primarily practical and professional.

Repository: $repo_name
Source branch: $source_branch ($source_commits commits by $source_authors authors since diverging)
Target branch: $target_branch ($target_commits commits by $target_authors authors since diverging)

Files changed in source:
$source_diff

Files changed in target:
$target_diff

Potential conflicts in these files:
$potential_conflicts

Raw conflict check (grep count: $has_conflicts):
${conflict_check:0:1000}

Please analyze and provide:
1. A risk assessment on a scale of 1-5 (1 = very safe, 5 = very risky)
2. A brief explanation of the risk factors
3. Specific recommendations to reduce risk
4. Whether I should proceed with caution or consider alternatives"
      ;;
    "wizard")
      prompt="You're a magical Git Wizard - a mystical Git assistant. Analyze the risks of merging between these Git branches. Use a magical, mystical tone but keep it primarily practical and professional.

Repository: $repo_name
Source branch: $source_branch ($source_commits commits by $source_authors authors since diverging)
Target branch: $target_branch ($target_commits commits by $target_authors authors since diverging)

Files changed in source:
$source_diff

Files changed in target:
$target_diff

Potential conflicts in these files:
$potential_conflicts

Raw conflict check (grep count: $has_conflicts):
${conflict_check:0:1000}

Please analyze and provide:
1. A risk assessment on a scale of 1-5 magical crystals (1 = very safe, 5 = very risky)
2. A brief explanation of the risk factors
3. Specific recommendations to reduce risk
4. Whether I should proceed with caution or consider alternatives"
      ;;
    "cosmic")
      prompt="You're the Cosmic Git Navigator - a space-themed Git assistant. Analyze the gravitational forces between these Git branches and the risk of merging them. Use a cosmic, space-themed tone but keep it primarily practical and professional.

Repository: $repo_name
Source branch: $source_branch ($source_commits commits by $source_authors authors since diverging)
Target branch: $target_branch ($target_commits commits by $target_authors authors since diverging)

Files changed in source:
$source_diff

Files changed in target:
$target_diff

Potential conflicts in these files:
$potential_conflicts

Raw conflict check (grep count: $has_conflicts):
${conflict_check:0:1000}

Please analyze and provide:
1. A risk assessment on a scale of 1-5 stars (1 = very safe, 5 = very risky)
2. A brief explanation of the risk factors
3. Specific recommendations to reduce risk
4. Whether I should proceed with caution or consider alternatives"
      ;;
    *)
      prompt="As a Git assistant, analyze the risk of merging between these Git branches. Use a professional tone.

Repository: $repo_name
Source branch: $source_branch ($source_commits commits by $source_authors authors since diverging)
Target branch: $target_branch ($target_commits commits by $target_authors authors since diverging)

Files changed in source:
$source_diff

Files changed in target:
$target_diff

Potential conflicts in these files:
$potential_conflicts

Raw conflict check (grep count: $has_conflicts):
${conflict_check:0:1000}

Please analyze and provide:
1. A risk assessment on a scale of 1-5 (1 = very safe, 5 = very risky)
2. A brief explanation of the risk factors
3. Specific recommendations to reduce risk
4. Whether I should proceed with caution or consider alternatives"
      ;;
  esac
  
  # Make the AI request with specific purpose to pass safety check
  local ai_response=$(ai_request "$prompt" "$provider" true 2 "merge_analysis")
  local request_status=$?
  
  if [ $request_status -ne 0 ] || [ -z "$ai_response" ]; then
    echo "❌ Failed to analyze merge risks."
    echo "Error: $ai_response"
    return 1
  fi
  
  # Display the response
  echo "=========================================="
  echo ""
  echo "$ai_response"
  echo ""
  echo "=========================================="
  echo ""
  
  # Ask user what to do based on the analysis
  echo "Based on this analysis, what would you like to do?"
  echo "1) Proceed with the merge"
  echo "2) Review specific files first"
  echo "3) Cancel merge"
  echo ""
  
  read -p "Your choice (1-3): " user_choice
  
  case "$user_choice" in
    1)
      # Proceed with merge
      echo "Proceeding with merge..."
      perform_merge "$source_branch" "$target_branch"
      return $?
      ;;
    2)
      # Review files - show potential conflict files for review
      echo "Files to review before merging:"
      if [ -n "$potential_conflicts" ]; then
        echo "$potential_conflicts" | nl
        
        # Ask for files to view
        read -p "Enter file number to view (or 0 to proceed with merge): " file_num
        
        if [ "$file_num" = "0" ]; then
          echo "Proceeding with merge..."
          perform_merge "$source_branch" "$target_branch"
          return $?
        elif [ -n "$file_num" ] && [ "$file_num" -gt 0 ]; then
          local file_to_view=$(echo "$potential_conflicts" | sed -n "${file_num}p")
          if [ -n "$file_to_view" ]; then
            echo "Showing $file_to_view in source and target branches:"
            echo ""
            echo "=== Source ($source_branch) ==="
            git show "$source_branch:$file_to_view" 2>/dev/null || echo "File not found in source branch"
            echo ""
            echo "=== Target ($target_branch) ==="
            git show "$target_branch:$file_to_view" 2>/dev/null || echo "File not found in target branch"
            echo ""
            
            # After showing the file, ask again what to do
            read -p "Proceed with merge now? (y/n): " proceed
            if [[ "$proceed" == "y" || "$proceed" == "Y" ]]; then
              perform_merge "$source_branch" "$target_branch"
              return $?
            else
              echo "Merge cancelled."
              return 1
            fi
          else
            echo "Invalid file number."
            return 1
          fi
        else
          echo "Invalid selection."
          return 1
        fi
      else
        echo "No potential conflict files identified."
        read -p "Proceed with merge? (y/n): " proceed
        if [[ "$proceed" == "y" || "$proceed" == "Y" ]]; then
          perform_merge "$source_branch" "$target_branch"
          return $?
        else
          echo "Merge cancelled."
          return 1
        fi
      fi
      ;;
    3|*)
      echo "Merge cancelled."
      return 1
      ;;
  esac
  
  return 0
}

# Function to perform the actual merge
perform_merge() {
  local source_branch="$1"
  local target_branch="$2"
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  
  # Check if we need to switch branches first
  if [ "$current_branch" != "$target_branch" ]; then
    echo "Switching to target branch '$target_branch' first..."
    git checkout "$target_branch"
    if [ $? -ne 0 ]; then
      echo "❌ Failed to switch to target branch."
      return 1
    fi
  fi
  
  # Perform the merge
  echo "Merging '$source_branch' into '$target_branch'..."
  git merge "$source_branch"
  local merge_status=$?
  
  if [ $merge_status -eq 0 ]; then
    # Successful merge
    rainbow_box "✅ Successfully merged '$source_branch' into '$target_branch'!"
    echo "$(display_success "$THEME")"
  else
    # Merge had conflicts or other issues
    echo "⚠️ Merge encountered issues."
    
    # Check for merge conflicts
    if git status | grep -q "You have unmerged paths"; then
      echo "🐒 Merge conflicts detected. You need to resolve them manually."
      echo "Files with conflicts:"
      git diff --name-only --diff-filter=U
      echo ""
      echo "To resolve conflicts:"
      echo "1. Edit the files to fix conflicts (look for <<<<<<< markers)"
      echo "2. Add the resolved files: git add <filename>"
      echo "3. Complete the merge: git commit"
      echo ""
      echo "Or to abort the merge: git merge --abort"
    else
      echo "❌ Merge failed for an unknown reason."
      echo "$(display_error "$THEME")"
    fi
  fi
  
  return $merge_status
}

# Main function to handle merging
main() {
  # Check if git repository
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "❌ Not a git repository. Please run this command in a git repository."
    return 1
  fi
  
  # Help mode
  if [[ "$1" == "help" || "$1" == "--help" ]]; then
    echo "🐒 Git Monkey Merge Command"
    echo ""
    echo "Usage:"
    echo "  gitmonkey merge                         - Interactive merge menu"
    echo "  gitmonkey merge <source> [target]       - Merge source into target branch (default: current)"
    echo "  gitmonkey merge <source> [target] --analyze - Analyze merge risks with AI before merging"
    echo ""
    echo "Options:"
    echo "  --yes, -y          - Auto-confirm prompts"
    echo "  --force, -f        - Override safety checks"
    echo "  --analyze, --ai    - Use AI to analyze merge risks"
    echo ""
    return 0
  fi
  
  # Check for uncommitted changes
  if has_uncommitted_changes && [ "$force" != "true" ]; then
    echo "❌ You have uncommitted changes. Please commit or stash them before merging."
    echo "Use --force to override this check if you know what you're doing."
    return 1
  fi
  
  # Interactive mode if no arguments
  if [ $# -eq 0 ]; then
    display_splash "$THEME"
    ascii_spell "Merge branches together"
    
    echo ""
    box "Merge Tool: Combine branches without fear"
    
    # Show all branches
    echo "🌿 Available branches:"
    git branch
    echo ""
    
    # Get source branch
    read -p "Which branch do you want to merge? " source_branch
    if [ -z "$source_branch" ]; then
      echo "❌ No source branch specified. Aborting."
      return 1
    fi
    
    # Get target branch
    read -p "Into which branch? (default: current branch) " target_branch
    if [ -z "$target_branch" ]; then
      target_branch=$(git rev-parse --abbrev-ref HEAD)
    fi
    
    # Ask about analysis
    read -p "Would you like an AI risk analysis first? (y/N) " analyze_choice
    if [[ "$analyze_choice" == "y" || "$analyze_choice" == "Y" ]]; then
      analyze_mode="true"
    fi
    
    # Perform merge or analysis
    if [ "$analyze_mode" = "true" ]; then
      analyze_merge_risks "$source_branch" "$target_branch"
    else
      perform_merge "$source_branch" "$target_branch"
    fi
  else
    # Command line mode
    source_branch="$1"
    
    # Target branch is second argument or current branch
    if [ $# -gt 1 ] && [[ "$2" != "--"* ]]; then
      target_branch="$2"
    else
      target_branch=$(git rev-parse --abbrev-ref HEAD)
    fi
    
    # Perform merge or analysis
    if [ "$analyze_mode" = "true" ]; then
      analyze_merge_risks "$source_branch" "$target_branch"
    else
      perform_merge "$source_branch" "$target_branch"
    fi
  fi
  
  return 0
}

# Run main function
main "$@"
