#!/bin/bash

# ========= GIT MONKEY COMMAND TRACKER =========
# Tracks command usage and manages tone stage progression

# Load utilities
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/profile.sh"
source "$(dirname "${BASH_SOURCE[0]}")/titles.sh"

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

# Function to show a greeting based on tone stage
show_greeting() {
  local greeting=$(generate_title_greeting)
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