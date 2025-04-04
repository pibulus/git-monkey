#!/bin/bash

# ========= GIT MONKEY ASK - AI-POWERED GIT HELP =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Interactive assistant for Git questions


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

# Function to format command syntax
format_command() {
  local cmd="$1"
  echo -e "\e[1m\e[33m$cmd\e[0m"
}

# Function to highlight text
highlight_text() {
  local text="$1"
  echo -e "\e[1m$text\e[0m"
}

# Function to ask Git question with AI
ask_git_question() {
  local question="$1"
  
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
  
  # Get Git context
  local in_git_repo=false
  local git_context=""
  
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    in_git_repo=true
    
    # Current branch
    local current_branch=$(git branch --show-current 2>/dev/null)
    
    # Recent commits
    local recent_commits=$(git log -3 --pretty=format:"%h %s" 2>/dev/null || echo "No commits yet")
    
    # Git status
    local git_status=$(git status -s 2>/dev/null || echo "Unable to get status")
    
    # Remotes
    local remotes=$(git remote -v 2>/dev/null | grep fetch || echo "No remotes")
    
    # Repo name
    local repo_name=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)" || echo "Local repository")
    
    # Create context string
    git_context="Current Git context:
- Repository: $repo_name
- Current branch: $current_branch
- Recent commits:
$recent_commits
- Current status:
$git_status
- Remotes:
$remotes"
  else
    git_context="Not currently in a Git repository."
  fi
  
  # Show what we're doing
  show_themed_header "ASK GIT MONKEY"
  echo "Question: $(highlight_text "$question")"
  echo ""
  
  # Theme-specific loading messages
  case "$THEME" in
    "jungle")
      echo "🐒 Monkey searching through the Git trees..."
      ;;
    "hacker")
      echo "> Accessing Git knowledge base..."
      echo "> Analyzing query vectors..."
      ;;
    "wizard")
      echo "🧙‍♂️ Consulting the ancient Git scrolls..."
      ;;
    "cosmic")
      echo "🔭 Searching the Git cosmos for answers..."
      ;;
    *)
      echo "Searching for an answer..."
      ;;
  esac
  
  # Create a prompt based on the theme
  local prompt=""
  
  case "$THEME" in
    "jungle")
      prompt="You're Git Monkey - a helpful, jungle-themed Git assistant. Answer this Git question: \"$question\"

$git_context

Be genuinely helpful and accurate. Format your response with:
1. A direct, clear answer to the question
2. The exact command(s) to use, if applicable
3. A brief explanation if needed
4. Optional: A related tip that might help

Use jungle-themed language but keep it subtle and professional enough for real work. Format commands with markdown inline code blocks. Keep your answer thorough but concise."
      ;;
    "hacker")
      prompt="You're a terminal-based Git assistant with a hacker aesthetic. Answer this Git question: \"$question\"

$git_context

Format your response as a technical system output with:
1. A precise, technically accurate answer
2. The exact command syntax required, if applicable
3. Brief technical explanation of how the command works
4. Optional: A power-user tip related to the question

Use a technical, minimalist tone. Format commands as code blocks. Be thorough but efficient with your explanation."
      ;;
    "wizard")
      prompt="You're a magical Git Wizard - a mystical Git assistant. Answer this Git question: \"$question\"

$git_context

Format your response as magical guidance:
1. A clear explanation of the Git knowledge sought
2. The precise incantation (command) needed, if applicable
3. Wisdom about how the magic (command) functions
4. Optional: A related arcane secret that might aid the caster

Use mystical language but keep it subtle and professional enough for real work. Format commands with markdown inline code blocks. Be thorough but concise."
      ;;
    "cosmic")
      prompt="You're the Cosmic Git Navigator - a space-themed Git assistant. Answer this Git question: \"$question\"

$git_context

Structure your response like a space mission:
1. A clear answer charting the course forward
2. The exact coordinates (commands) needed, if applicable
3. Brief explanation of the underlying spacetime mechanics
4. Optional: A related cosmic insight that might help the explorer

Use space/cosmic themed language but keep it subtle and professional enough for real work. Format commands with markdown inline code blocks. Be thorough but concise."
      ;;
    *)
      prompt="As a Git assistant, answer this Git question: \"$question\"

$git_context

Format your response with:
1. A direct, clear answer to the question
2. The exact command(s) to use, if applicable
3. A brief explanation if needed
4. Optional: A related tip that might help

Format commands with markdown inline code blocks. Keep your answer thorough but concise."
      ;;
  esac
  
  # Make the AI request with specific purpose to pass safety check
  local ai_response=$(ai_request "$prompt" "$provider" true 2 "git_help")
  local request_status=$?
  
  if [ $request_status -ne 0 ] || [ -z "$ai_response" ]; then
    echo "❌ Failed to get an answer."
    echo "Error: $ai_response"
    return 1
  fi
  
  # Display the response with code highlighting
  echo ""
  echo "=========================================="
  echo ""
  
  # Replace markdown code blocks with terminal formatting
  formatted_response=$(echo "$ai_response" | sed -E 's/`([^`]+)`/\\\\e[1m\\\\e[33m\1\\\\e[0m/g')
  
  # Print the response with formatting
  echo -e "$formatted_response"
  
  echo ""
  echo "=========================================="
  echo ""
  
  # Extract commands for execution
  local commands=()
  
  # Extract code blocks
  while read -r line; do
    if [[ "$line" == *"\`"* ]]; then
      # Extract text between backticks
      local cmd=$(echo "$line" | grep -o '`[^`]*`' | sed 's/`//g')
      if [ -n "$cmd" ] && [[ "$cmd" == git* ]]; then
        commands+=("$cmd")
      fi
    fi
  done <<< "$ai_response"
  
  # If commands were found, offer to execute them
  if [ ${#commands[@]} -gt 0 ]; then
    echo "I found these Git commands in the answer:"
    echo ""
    
    for i in "${!commands[@]}"; do
      echo "$((i+1))) $(format_command "${commands[$i]}")"
    done
    
    echo ""
    echo "Would you like to execute any of these commands?"
    echo "Enter the number of the command to run, or 0 to exit."
    echo ""
    
    read -p "Your choice: " cmd_choice
    
    if [[ "$cmd_choice" =~ ^[0-9]+$ ]] && [ "$cmd_choice" -gt 0 ] && [ "$cmd_choice" -le ${#commands[@]} ]; then
      local selected_cmd="${commands[$((cmd_choice-1))]}"
      
      echo ""
      echo "Running: $(format_command "$selected_cmd")"
      echo ""
      
      # Execute the command
      eval "$selected_cmd"
      echo ""
      
      # Get result status
      local cmd_status=$?
      if [ $cmd_status -eq 0 ]; then
        echo "✅ Command executed successfully!"
      else
        echo "❌ Command exited with status $cmd_status."
      fi
    else
      echo "No command executed."
    fi
  fi
  
  return 0
}

# Main function
main() {
  # Check if a question was provided
  if [ $# -eq 0 ]; then
    show_themed_header "ASK GIT MONKEY"
    echo "Ask me any question about Git!"
    echo ""
    read -p "Your question: " user_question
    
    if [ -z "$user_question" ]; then
      echo "No question provided. Exiting."
      return 1
    fi
    
    ask_git_question "$user_question"
  else
    # Combine all arguments as the question
    local question="$*"
    ask_git_question "$question"
  fi
  
  return 0
}

# Run main function
main "$@"
