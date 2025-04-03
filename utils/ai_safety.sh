#!/bin/bash

# ========= GIT MONKEY AI SAFETY & GUARDRAILS =========
# Ensures AI features stay within Git Monkey's ecosystem and tone

source ./utils/style.sh
source ./utils/config.sh

# List of approved AI use cases
APPROVED_AI_CONTEXTS=(
  "commit_message"
  "branch_name"
  "merge_analysis"
  "git_help"
)

# Validate that an AI request is for an approved purpose
validate_ai_purpose() {
  local purpose="$1"
  
  for approved in "${APPROVED_AI_CONTEXTS[@]}"; do
    if [ "$purpose" = "$approved" ]; then
      return 0  # Valid purpose
    fi
  done
  
  return 1  # Invalid purpose
}

# Check if a prompt is trying to use the AI as a general chatbot
detect_chatbot_attempt() {
  local prompt="$1"
  local purpose="$2"
  
  # Skip explicit Git-related contexts
  if [ "$purpose" = "git_help" ] && [ "${#prompt}" -lt 200 ]; then
    return 1  # Not a chatbot attempt if it's a short, direct Git question
  fi
  
  # Check for common chatbot patterns not related to Git
  local red_flags=(
    "tell me about " 
    "what do you think " 
    "can you write " 
    "generate a " 
    "create a story" 
    "explain how" 
    "what is the meaning" 
    "who is"
    "where is"
    "when did"
  )
  
  for flag in "${red_flags[@]}"; do
    if [[ "$prompt" == *"$flag"* ]] && [[ "$prompt" != *"git"* ]] && [[ "$prompt" != *"branch"* ]] && [[ "$prompt" != *"commit"* ]] && [[ "$prompt" != *"merge"* ]]; then
      return 0  # Likely a chatbot attempt
    fi
  done
  
  # Check for non-Git-related questions
  if ! [[ "$prompt" =~ (git|branch|commit|merge|pull|push|rebase|clone|checkout|stash|fetch|repo|version control) ]]; then
    # If prompt doesn't contain common Git terms, it might be off-topic
    if [ ${#prompt} -gt 50 ]; then
      return 0  # Likely off-topic if relatively long
    fi
  fi
  
  return 1  # Appears to be Git-related
}

# Format response to fit Git Monkey's style for the given theme
format_ai_response() {
  local response="$1"
  local theme="$2"
  local tone_stage="$3"
  
  # Truncate overly verbose responses
  if [ ${#response} -gt 500 ] && [ "$tone_stage" -gt 2 ]; then
    # For advanced users, keep responses shorter
    response="${response:0:500}..."
  elif [ ${#response} -gt 1000 ]; then
    # Cap response length for everyone
    response="${response:0:1000}..."
  fi
  
  # Apply theme-specific styling to commands in response
  case "$theme" in
    "jungle")
      # Highlight Git commands with banana emoji
      response=$(echo "$response" | sed -E 's/`git ([^`]+)`/🍌 git \1 🍌/g')
      ;;
    "hacker")
      # Style Git commands with terminal markers
      response=$(echo "$response" | sed -E 's/`git ([^`]+)`/> git \1/g')
      ;;
    "wizard")
      # Style Git commands with sparkles
      response=$(echo "$response" | sed -E 's/`git ([^`]+)`/✨ git \1 ✨/g')
      ;;
    "cosmic")
      # Style Git commands with cosmic symbols
      response=$(echo "$response" | sed -E 's/`git ([^`]+)`/🌠 git \1 🌠/g')
      ;;
    *)
      # Default styling
      response=$(echo "$response" | sed -E 's/`git ([^`]+)`/git \1/g')
      ;;
  esac
  
  echo "$response"
}

# Check if a response looks like a generic AI output
detect_generic_response() {
  local response="$1"
  local theme="$2"
  
  # Check for generic AI introduction patterns
  if [[ "$response" =~ ^(I\'ll|Here\'s|Sure|As\ an\ AI|I\'m\ happy\ to|I\ can\ help|I\'d\ be\ happy|Certainly|Absolutely) ]]; then
    return 0  # Likely a generic AI introduction
  fi
  
  # Check for theme-appropriate language
  case "$theme" in
    "jungle")
      if ! [[ "$response" =~ (monkey|jungle|banana|swing|vine|tree|forest|wild) ]]; then
        # Jungle theme should have jungle-related words
        return 0  # Missing theme-appropriate language
      fi
      ;;
    "hacker")
      if ! [[ "$response" =~ (system|terminal|code|command|hack|analyze|scan|access) ]]; then
        # Hacker theme should have terminal/system terminology
        return 0  # Missing theme-appropriate language
      fi
      ;;
    "wizard")
      if ! [[ "$response" =~ (spell|magic|arcane|scroll|potion|enchant|mystical|wizard) ]]; then
        # Wizard theme should have magical terminology
        return 0  # Missing theme-appropriate language
      fi
      ;;
    "cosmic")
      if ! [[ "$response" =~ (star|cosmos|galaxy|orbit|space|cosmic|astral|celestial) ]]; then
        # Cosmic theme should have space terminology
        return 0  # Missing theme-appropriate language
      fi
      ;;
  esac
  
  return 1  # Appears to be appropriately themed
}

# Main safety gate function for AI requests
ai_safety_gate() {
  local prompt="$1"
  local purpose="$2"
  local theme="$3"
  local tone_stage="$4"
  
  # Check if purpose is approved
  if ! validate_ai_purpose "$purpose"; then
    echo "Git Monkey's AI can only help with Git-related tasks. Try using one of these features:"
    echo "• gitmonkey commit --suggest - AI-powered commit messages"
    echo "• gitmonkey branch new --suggest - AI-powered branch naming"
    echo "• gitmonkey merge source target --analyze - AI-powered merge analysis"
    echo "• gitmonkey ask \"git question\" - Help with Git commands"
    return 1
  fi
  
  # Check if prompt appears to be using AI as a chatbot
  if detect_chatbot_attempt "$prompt" "$purpose"; then
    echo "Git Monkey's AI features are focused on Git operations only."
    echo "To get help with Git, try asking a specific Git question like:"
    echo "  gitmonkey ask \"how do I undo my last commit?\""
    return 1
  fi
  
  # All checks passed
  return 0
}

# Filter AI response to ensure it stays in character
ai_response_filter() {
  local response="$1"
  local theme="$2"
  local tone_stage="$3"
  
  # Check if response is inappropriately generic
  if detect_generic_response "$response" "$theme"; then
    # Reformat into theme-appropriate response
    case "$theme" in
      "jungle")
        response="🐒 $response"
        ;;
      "hacker")
        response="> $response"
        ;;
      "wizard")
        response="✨ $response"
        ;;
      "cosmic")
        response="🌌 $response"
        ;;
      *)
        # Default styling
        ;;
    esac
  fi
  
  # Format the response based on theme and tone stage
  formatted_response=$(format_ai_response "$response" "$theme" "$tone_stage")
  
  echo "$formatted_response"
}