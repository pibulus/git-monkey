#!/bin/bash

# ========= GIT MONKEY COMMIT HELPER =========
# Enhanced commit experience with AI suggestions

source ./utils/style.sh
source ./utils/config.sh
source ./utils/ai_keys.sh
source ./utils/ai_request.sh

# Get theme for styling
THEME=$(get_selected_theme 2>/dev/null || echo "jungle")

# Function to display a themed header
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

# Function to generate commit message with AI
generate_ai_commit() {
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
  
  # Check for staged changes
  local staged_files=$(git diff --cached --name-only 2>/dev/null)
  
  if [ -z "$staged_files" ]; then
    echo "❌ No changes staged for commit."
    echo "Use 'git add <file>' to stage changes first."
    return 1
  fi
  
  # Show what's being analyzed
  show_themed_header "AI COMMIT ANALYSIS"
  echo "Analyzing staged changes..."
  echo ""
  
  # Theme-specific loading messages
  case "$THEME" in
    "jungle")
      echo "🐒 Monkey analyzing code changes..."
      ;;
    "hacker")
      echo "> Scanning git diff structure..."
      echo "> Parsing code patterns..."
      ;;
    "wizard")
      echo "🧙‍♂️ Casting analysis spell on your code..."
      ;;
    "cosmic")
      echo "🔭 Observing code constellations..."
      ;;
    *)
      echo "Analyzing diff patterns..."
      ;;
  esac
  
  # Get git diff of staged changes
  local diff=$(git diff --cached 2>/dev/null)
  
  # Get last 3 commit messages for context
  local recent_commits=$(git log -3 --pretty=format:"%s" 2>/dev/null)
  
  # Create a prompt based on the theme
  local prompt=""
  
  case "$THEME" in
    "jungle")
      prompt="You're the Git Monkey - a helpful, jungle-themed Git assistant. Analyze this diff and suggest a good commit message that's clear and concise. Make it specific about what changed and why, but keep it under 72 characters if possible. Be practical but with a tiny hint of jungle fun.

Recent commit messages:
$recent_commits

Git diff of staged changes:
$diff"
      ;;
    "hacker")
      prompt="You're an elite terminal-based Git assistant. Analyze this diff and generate a technical, precise commit message. Focus on technical accuracy and clear communication of the change. Keep it under 72 characters if possible. Use conventional commits format (feat/fix/chore/docs/etc.) if appropriate based on the changes.

Recent commit messages:
$recent_commits

Git diff of staged changes:
$diff"
      ;;
    "wizard")
      prompt="You're a magical Git Wizard - a mystical Git assistant. Analyze this diff and craft an enchanting yet practical commit message. Be specific about what changed and why, while keeping it under 72 characters if possible. Add a tiny touch of magical flair but keep it professional enough for a real codebase.

Recent commit messages:
$recent_commits

Git diff of staged changes:
$diff"
      ;;
    "cosmic")
      prompt="You're the Cosmic Git Navigator - a space-themed Git assistant. Analyze this diff and create a commit message that's clear, specific, and concise. Focus on what changed and why, keeping it under 72 characters if possible. Add a subtle cosmic touch but keep it practical for real development.

Recent commit messages:
$recent_commits

Git diff of staged changes:
$diff"
      ;;
    *)
      prompt="Analyze this Git diff and suggest a professional, clear commit message that explains what changed and why. Keep it under 72 characters if possible. Focus on being specific and following good Git commit message practices.

Recent commit messages:
$recent_commits

Git diff of staged changes:
$diff"
      ;;
  esac
  
  # Make the AI request
  local ai_response=$(ai_request "$prompt" "$provider" true 2)
  local request_status=$?
  
  if [ $request_status -ne 0 ] || [ -z "$ai_response" ]; then
    echo "❌ Failed to generate commit message."
    echo "Error: $ai_response"
    return 1
  fi
  
  # Clean up the response to get just the commit message
  # (AI sometimes adds commentary or quotes around the message)
  local commit_message=$(echo "$ai_response" | head -n 1 | sed 's/^["'"'"']*//g' | sed 's/["'"'"']*$//g')
  
  # Trim to keep under 72 chars if needed
  if [ ${#commit_message} -gt 72 ]; then
    commit_message="${commit_message:0:69}..."
  fi
  
  echo ""
  echo "✅ AI suggestion ready!"
  echo ""
  echo -e "\e[1m$commit_message\e[0m"
  echo ""
  
  # Ask user what to do with the suggestion
  echo "What would you like to do?"
  echo "1) Use this message and commit"
  echo "2) Edit the message"
  echo "3) Generate another suggestion"
  echo "4) Cancel and exit"
  echo ""
  
  read -p "Your choice (1-4): " user_choice
  
  case "$user_choice" in
    1)
      # Use the message as-is
      git commit -m "$commit_message" 2>/dev/null
      local commit_status=$?
      
      if [ $commit_status -eq 0 ]; then
        echo "✅ Changes committed successfully!"
      else
        echo "❌ Commit failed. Please check git output for errors."
      fi
      ;;
    2)
      # Let user edit the message
      echo "$commit_message" > /tmp/git_monkey_commit_msg
      ${EDITOR:-nano} /tmp/git_monkey_commit_msg
      local edited_message=$(cat /tmp/git_monkey_commit_msg)
      rm /tmp/git_monkey_commit_msg
      
      git commit -m "$edited_message" 2>/dev/null
      local commit_status=$?
      
      if [ $commit_status -eq 0 ]; then
        echo "✅ Changes committed with edited message!"
      else
        echo "❌ Commit failed. Please check git output for errors."
      fi
      ;;
    3)
      # Generate another suggestion
      generate_ai_commit
      ;;
    4|*)
      echo "Commit cancelled."
      ;;
  esac
  
  return 0
}

# Main function
main() {
  # Check if git repository
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "❌ Not a git repository. Please run this command in a git repository."
    return 1
  fi
  
  # Parse arguments
  local suggest_mode=false
  
  for arg in "$@"; do
    case "$arg" in
      --suggest|--ai)
        suggest_mode=true
        shift
        ;;
    esac
  done
  
  if [ "$suggest_mode" = true ]; then
    # Generate AI-powered commit message
    generate_ai_commit
  else
    # Regular commit - show a prettier commit interface
    show_themed_header "GIT COMMIT"
    
    # Show staged files
    echo "Staged files for commit:"
    git diff --cached --name-only | sed 's/^/  /'
    echo ""
    
    # Prompt for commit message
    echo "Enter commit message:"
    read -e commit_msg
    
    if [ -z "$commit_msg" ]; then
      echo "❌ Empty commit message. Commit aborted."
      return 1
    fi
    
    # Perform the commit
    git commit -m "$commit_msg" 2>/dev/null
    local commit_status=$?
    
    if [ $commit_status -eq 0 ]; then
      echo "✅ Changes committed successfully!"
      
      # Suggest AI for next time
      echo ""
      echo "💡 Tip: Try 'gitmonkey commit --suggest' next time for AI-powered commit messages!"
    else
      echo "❌ Commit failed. Please check git output for errors."
    fi
  fi
  
  return 0
}

# Run main function
main "$@"