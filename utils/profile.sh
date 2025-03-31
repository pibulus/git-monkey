#!/bin/bash

# ========= GIT MONKEY USER PROFILE MANAGEMENT =========
# Handles tone stage tracking and user progression

# Load global config
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

# Profile file path
PROFILE_FILE="$MONKEY_HOME/profile.json"

# Initialize profile file if it doesn't exist
initialize_profile() {
  if [ ! -f "$PROFILE_FILE" ]; then
    # Create default profile
    cat > "$PROFILE_FILE" << EOF
{
  "user": "$(whoami)",
  "created_at": "$(date +"%Y-%m-%d")",
  "tone_stage": 0,
  "selected_theme": "jungle",
  "commands": {
    "total_run": 0,
    "unique_used": [],
    "last_run": null
  },
  "stats": {
    "successful_commands": 0,
    "failed_commands": 0,
    "tutorial_completed": false,
    "milestones_reached": []
  },
  "custom": {
    "title": null,
    "last_title_change": null
  }
}
EOF
    echo "Created new user profile at $PROFILE_FILE"
  fi
}

# Read profile data
get_profile() {
  # Initialize profile if it doesn't exist
  if [ ! -f "$PROFILE_FILE" ]; then
    initialize_profile
  fi
  
  # Return the profile data
  cat "$PROFILE_FILE"
}

# Get specific profile field
get_profile_field() {
  local field="$1"
  jq -r ".$field" "$PROFILE_FILE" 2>/dev/null || echo ""
}

# Update specific profile field
update_profile_field() {
  local field="$1"
  local value="$2"
  local temp_file=$(mktemp)
  
  jq --arg field "$field" --arg value "$value" \
    "if type[$field] == \"number\" then .$field = ($value | tonumber) 
     elif type[$field] == \"boolean\" then .$field = ($value == \"true\") 
     else .$field = \$value end" \
    "$PROFILE_FILE" > "$temp_file"
  
  mv "$temp_file" "$PROFILE_FILE"
}

# Update command stats
record_command_run() {
  local command="$1"
  local success="$2"  # true or false
  local temp_file=$(mktemp)
  
  # Get current profile
  local profile=$(cat "$PROFILE_FILE")
  
  # Update total run count
  local total_run=$(echo "$profile" | jq '.commands.total_run')
  total_run=$((total_run + 1))
  
  # Check if command is already in unique_used
  local unique_used=$(echo "$profile" | jq -r '.commands.unique_used | join(" ")')
  if [[ ! "$unique_used" =~ (^| )$command($| ) ]]; then
    # Add to unique_used
    echo "$profile" | jq --arg cmd "$command" '.commands.unique_used += [$cmd]' > "$temp_file"
    profile=$(cat "$temp_file")
  fi
  
  # Update last_run
  local now=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$profile" | jq --arg now "$now" '.commands.last_run = $now' > "$temp_file"
  profile=$(cat "$temp_file")
  
  # Update success/failure count
  if [ "$success" = "true" ]; then
    local success_count=$(echo "$profile" | jq '.stats.successful_commands')
    success_count=$((success_count + 1))
    echo "$profile" | jq --arg count "$success_count" '.stats.successful_commands = ($count | tonumber)' > "$temp_file"
  else
    local fail_count=$(echo "$profile" | jq '.stats.failed_commands')
    fail_count=$((fail_count + 1))
    echo "$profile" | jq --arg count "$fail_count" '.stats.failed_commands = ($count | tonumber)' > "$temp_file"
  fi
  profile=$(cat "$temp_file")
  
  # Update total_run
  echo "$profile" | jq --arg count "$total_run" '.commands.total_run = ($count | tonumber)' > "$temp_file"
  profile=$(cat "$temp_file")
  
  # Check for tone stage progress based on usage patterns
  update_tone_stage "$profile" > "$temp_file"
  
  # Save updated profile
  mv "$temp_file" "$PROFILE_FILE"
  
  # Clean up
  rm -f "$temp_file" 2>/dev/null
}

# Update tone stage based on usage patterns
update_tone_stage() {
  local profile="$1"
  local current_stage=$(echo "$profile" | jq '.tone_stage')
  local unique_count=$(echo "$profile" | jq '.commands.unique_used | length')
  local success_count=$(echo "$profile" | jq '.stats.successful_commands')
  local tutorial_completed=$(echo "$profile" | jq '.stats.tutorial_completed')

  # Define stage upgrade criteria
  # Stage 0 -> 1: Used 3+ different commands with success
  if [ "$current_stage" -eq 0 ] && [ "$unique_count" -ge 3 ] && [ "$success_count" -ge 3 ]; then
    echo "$profile" | jq '.tone_stage = 1'
    return
  fi
  
  # Stage 1 -> 2: Used 5+ commands, including advanced ones (branch, stash, etc.)
  if [ "$current_stage" -eq 1 ] && [ "$unique_count" -ge 5 ]; then
    local advanced_commands=$(echo "$profile" | jq -r '.commands.unique_used | join(" ")')
    # Check if used any of these advanced commands
    if [[ "$advanced_commands" =~ (branch|stash|undo|push) ]]; then
      echo "$profile" | jq '.tone_stage = 2'
      return
    fi
  fi
  
  # Stage 2 -> 3: Used worktrees, pivot, or other advanced features
  if [ "$current_stage" -eq 2 ]; then
    local power_commands=$(echo "$profile" | jq -r '.commands.unique_used | join(" ")')
    if [[ "$power_commands" =~ (worktree|pivot|return|whoami) ]]; then
      echo "$profile" | jq '.tone_stage = 3'
      return
    fi
  fi
  
  # Stage 3 -> 4: Used 10+ commands including generate or custom setups
  if [ "$current_stage" -eq 3 ] && [ "$unique_count" -ge 10 ]; then
    local expert_commands=$(echo "$profile" | jq -r '.commands.unique_used | join(" ")')
    if [[ "$expert_commands" =~ (generate|start|settings) ]]; then
      echo "$profile" | jq '.tone_stage = 4'
      return
    fi
  fi
  
  # Stage 4 -> 5: Completed tutorial or used all core Git features
  if [ "$current_stage" -eq 4 ]; then
    if [ "$tutorial_completed" = "true" ] || [ "$unique_count" -ge 15 ]; then
      echo "$profile" | jq '.tone_stage = 5'
      return
    fi
  fi
  
  # If no upgrades, return original profile
  echo "$profile"
}

# Manually set a tone stage (for tutorials, etc.)
set_tone_stage() {
  local stage="$1"
  # Ensure valid stage (0-5)
  if [[ "$stage" =~ ^[0-5]$ ]]; then
    update_profile_field "tone_stage" "$stage"
    echo "Tone stage updated to $stage"
    return 0
  else
    echo "Invalid tone stage: $stage (must be 0-5)"
    return 1
  fi
}

# Mark tutorial as completed
mark_tutorial_completed() {
  local temp_file=$(mktemp)
  
  cat "$PROFILE_FILE" | jq '.stats.tutorial_completed = true' > "$temp_file"
  mv "$temp_file" "$PROFILE_FILE"
  
  # Check if this completion should trigger a tone stage upgrade
  local current_stage=$(get_profile_field "tone_stage")
  if [ "$current_stage" -lt 5 ]; then
    set_tone_stage 5
  fi
  
  echo "Tutorial marked as completed!"
}

# Add a milestone achievement
add_milestone() {
  local milestone="$1"
  local temp_file=$(mktemp)
  
  # Add to milestones if not already present
  jq --arg milestone "$milestone" \
    '.stats.milestones_reached = (if .stats.milestones_reached | index($milestone) then .stats.milestones_reached else .stats.milestones_reached + [$milestone] end)' \
    "$PROFILE_FILE" > "$temp_file"
  
  mv "$temp_file" "$PROFILE_FILE"
  echo "Milestone added: $milestone"
}

# Get the current tone stage
get_tone_stage() {
  get_profile_field "tone_stage"
}

# Get selected theme
get_selected_theme() {
  local theme=$(get_profile_field "selected_theme")
  if [ -z "$theme" ]; then
    echo "jungle"  # Default theme
  else
    echo "$theme"
  fi
}

# Set selected theme
set_selected_theme() {
  local theme="$1"
  update_profile_field "selected_theme" "$theme"
  echo "Theme set to $theme"
}

# Update custom title
set_custom_title() {
  local title="$1"
  local temp_file=$(mktemp)
  
  # Update title and date
  local now=$(date +"%Y-%m-%d")
  jq --arg title "$title" --arg date "$now" \
    '.custom.title = $title | .custom.last_title_change = $date' \
    "$PROFILE_FILE" > "$temp_file"
  
  mv "$temp_file" "$PROFILE_FILE"
  echo "Custom title set to: $title"
}

# Get custom title
get_custom_title() {
  get_profile_field "custom.title"
}

# Initialize on source
initialize_profile