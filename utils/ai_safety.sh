#\!/bin/bash

# ========= GIT MONKEY AI SAFETY GUARDRAILS =========
# Ensures AI interactions stay within Git Monkey's ecosystem

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"

source "$DIR/style.sh"
source "$DIR/config.sh"

# Approved AI use cases
APPROVED_AI_CONTEXTS=(
  "commit_message"
  "branch_name"
  "merge_analysis"
  "git_help"
  "general"
)

# Safety gate to check if an AI request should be allowed
ai_safety_gate() {
  local prompt="$1"
  local purpose="$2"
  local theme="$3"
  local tone_stage="$4"
  
  # Check for purpose validation
  if \! validate_ai_purpose "$purpose"; then
    echo "Error: Invalid AI purpose '$purpose'"
    return 1
  fi
  
  # Check for non-Git content
  if \! validate_git_relevance "$prompt"; then
    echo "Error: This request doesn't appear to be related to Git or version control."
    echo "Git Monkey AI features are designed specifically for Git workflows."
    return 1
  }
  
  # All checks passed
  return 0
}

# Validate that an AI request is for an approved purpose
validate_ai_purpose() {
  local purpose="$1"
  
  for context in "${APPROVED_AI_CONTEXTS[@]}"; do
    if [ "$context" = "$purpose" ]; then
      return 0
    fi
  done
  
  # Not found in approved list
  return 1
}

# Check if prompt is related to Git
validate_git_relevance() {
  local prompt="$1"
  
  # Convert to lowercase for case-insensitive matching
  local lowercase_prompt=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')
  
  # Check for common Git related terms
  if [[ "$lowercase_prompt" =~ git|commit|branch|merge|push|pull|clone|repos|checkout|version|control|stash|work ]]; then
    return 0
  fi
  
  # More detailed check for Git commands
  if [[ "$lowercase_prompt" =~ add|status|log|diff|fetch|remote|tag|rebase|bisect|cherry ]]; then
    return 0
  fi
  
  # Not specific enough to Git
  return 1
}

# Filter AI responses to match our theme and style
ai_response_filter() {
  local response="$1"
  local theme="$2"
  local tone_stage="$3"
  
  # For now, just return the response directly
  # In the future, we could add more filtering based on theme
  echo "$response"
}
