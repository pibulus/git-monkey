#!/bin/bash

# ========= GIT MONKEY COMMAND TRACKER =========
# Tracks command usage and manages tone stage progression

# Load utilities
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/profile.sh"
source "$(dirname "${BASH_SOURCE[0]}")/titles.sh"
source "$(dirname "${BASH_SOURCE[0]}")/identity.sh"

# Function to increment command usage and potentially advance tone stage
increment_command_usage() {
  local command="$1"
  
  # Get current profile data
  local profile_data=$(get_profile_data)
  local current_stage=$(get_tone_stage)
  local command_count=$(echo "$profile_data" | jq -r ".command_usage.total // 0")
  local command_variety=$(echo "$profile_data" | jq -r ".command_usage | keys | length")
  
  # Increment the command usage
  if [[ $(echo "$profile_data" | jq -r ".command_usage.\"$command\" // 0") -eq 0 ]]; then
    # First time using this command
    profile_data=$(echo "$profile_data" | jq ".command_usage.\"$command\" = 1")
  else
    # Increment existing command count
    profile_data=$(echo "$profile_data" | jq ".command_usage.\"$command\" = (.command_usage.\"$command\" // 0) + 1")
  fi
  
  # Increment total command count
  profile_data=$(echo "$profile_data" | jq ".command_usage.total = (.command_usage.total // 0) + 1")
  
  # Update profile data
  save_profile_data "$profile_data"
  
  # Check if tone stage should advance
  calculate_and_update_tone_stage
  
  # Get new tone stage
  local new_stage=$(get_tone_stage)
  
  # If tone stage advanced, show notification
  if [ "$new_stage" -gt "$current_stage" ]; then
    local new_title=$(get_monkey_title "$new_stage" "$(get_selected_theme)")
    
    # Theme-specific advancement messages
    local theme=$(get_selected_theme)
    local identity=$(get_full_identity)
    local advance_emoji="🎉"
    local advance_message="You've advanced to a new tone stage!"
    
    case "$theme" in
      "jungle")
        advance_emoji="🐒"
        advance_message="You've swung up to a new tone stage!"
        ;;
      "hacker")
        advance_emoji=">"
        advance_message="LEVEL UP: Tone stage advanced."
        ;;
      "wizard")
        advance_emoji="✨"
        advance_message="Your magical git powers have grown to a new tone stage!"
        ;;
      "cosmic")
        advance_emoji="🚀"
        advance_message="You've blasted off to a new tone stage!"
        ;;
    esac
    
    echo ""
    echo "$advance_emoji $advance_message"
    
    if [ "$new_stage" -le 3 ]; then
      echo "Congratulations, $identity! You are now a \"$new_title\"."
    else
      echo "You are now a \"$new_title\"."
    fi
    echo ""
  fi
}

# Function to execute a command and track its usage
execute_command() {
  local cmd="$1"
  shift
  local cmd_args=("$@")
  
  # Get current tone stage before execution
  local previous_stage=$(get_tone_stage)
  
  # Execute the command
  "./commands/${cmd}.sh" "${cmd_args[@]}"
  local exit_code=$?
  
  # Record command execution in profile
  local success="false"
  [ $exit_code -eq 0 ] && success="true"
  record_command_run "$cmd" "$success"
  
  # Check for tone stage advancement
  local current_stage=$(get_tone_stage)
  if [ "$current_stage" -gt "$previous_stage" ]; then
    # Tone stage advanced, show the message
    local new_title=$(get_monkey_title "$current_stage")
    echo ""
    echo "🎉 You've advanced to a new tone stage! You are now a \"$new_title\"."
    echo ""
  fi
  
  return $exit_code
}

# Function to show a greeting based on identity
show_greeting() {
  local greeting=$(generate_identity_greeting)
  echo "$greeting"
}

# Function to get command verbosity based on tone stage
get_command_verbosity() {
  local cmd="$1"
  local stage=$(get_tone_stage)
  
  # Define default verbosity level based on tone stage
  # Lower stages get more explanations, higher stages get more concise output
  case $stage in
    0|1)
      echo "verbose"  # Detailed explanations, extra tips
      ;;
    2|3)
      echo "normal"   # Standard output with basic tips
      ;;
    4|5)
      echo "minimal"  # Just the essential information
      ;;
    *)
      echo "normal"   # Default to normal verbosity
      ;;
  esac
}

# Function to get command help based on tone stage
get_tone_appropriate_help() {
  local cmd="$1"
  local stage=$(get_tone_stage)
  
  echo "Help for $cmd (Tone Stage $stage):"
  
  # Example of progressive disclosure based on tone stage
  case $stage in
    0|1)
      echo "Beginner-friendly help with detailed explanations"
      # Call the command's help with verbosity flag
      "./commands/${cmd}.sh" help --verbose
      ;;
    2|3)
      echo "Intermediate help with common options"
      "./commands/${cmd}.sh" help
      ;;
    4|5)
      echo "Advanced help with concise syntax"
      "./commands/${cmd}.sh" help --concise
      ;;
    *)
      "./commands/${cmd}.sh" help
      ;;
  esac
}