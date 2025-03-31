#!/bin/bash

# ========= GIT MONKEY IDENTITY SYSTEM =========
# Manages user's personalized identity combining name and title

# Load utilities
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/profile.sh"
source "$(dirname "${BASH_SOURCE[0]}")/titles.sh"

# Anonymous name options
ANON_NAMES=(
  "Mysterious Banana"
  "Anon-Ape"
  "Secret Simian"
  "Unknown Primate"
  "Shadow Coder"
  "Nameless Monkey"
  "Ghost Climber"
  "Mystery Coder"
  "Jungle Stranger"
  "Anonymous Ape"
)

# Identity modes
# 1 = Name only
# 2 = Title only
# 3 = Combo (Name + Title)
DEFAULT_IDENTITY_MODE=3

# Initialize identity fields in profile
initialize_identity() {
  local temp_file=$(mktemp)
  
  # Get current profile
  cat "$PROFILE_FILE" > "$temp_file"
  
  # Check if identity is initialized
  if ! jq -e '.identity' "$temp_file" > /dev/null 2>&1; then
    # Create identity object
    jq '. += {
      "identity": {
        "name": null,
        "display_name": null,
        "custom_name": false,
        "identity_mode": 3,
        "title_locked": false
      }
    }' "$temp_file" > "$PROFILE_FILE"
  fi
  
  rm -f "$temp_file"
}

# Get user's real name
get_user_real_name() {
  get_profile_field "identity.name"
}

# Get user's display name
get_user_display_name() {
  local name=$(get_profile_field "identity.display_name")
  
  # If no display name, use system username
  if [ -z "$name" ] || [ "$name" = "null" ]; then
    name="$MONKEY_USER"
  fi
  
  echo "$name"
}

# Get anonymous name
get_anonymous_name() {
  local seed_value="${MONKEY_USER}_$(date +%m%d)"
  local array_size=${#ANON_NAMES[@]}
  
  # Generate a consistent hash-based index
  local hash_value=$(echo -n "$seed_value" | cksum | cut -d ' ' -f 1)
  local index=$((hash_value % array_size))
  
  echo "${ANON_NAMES[$index]}"
}

# Get identity mode
get_identity_mode() {
  local mode=$(get_profile_field "identity.identity_mode")
  
  if [ -z "$mode" ] || [ "$mode" = "null" ]; then
    mode="$DEFAULT_IDENTITY_MODE"
  fi
  
  echo "$mode"
}

# Check if title is locked
is_title_locked() {
  local locked=$(get_profile_field "identity.title_locked")
  
  if [ "$locked" = "true" ]; then
    return 0  # true
  else
    return 1  # false
  fi
}

# Set user's real name
set_user_name() {
  local name="$1"
  local custom="${2:-true}"
  local temp_file=$(mktemp)
  
  # Set name in profile
  jq --arg name "$name" --arg custom "$custom" \
    '.identity.name = $name | .identity.display_name = $name | .identity.custom_name = ($custom == "true")' \
    "$PROFILE_FILE" > "$temp_file"
  
  mv "$temp_file" "$PROFILE_FILE"
}

# Set identity mode
set_identity_mode() {
  local mode="$1"
  local temp_file=$(mktemp)
  
  # Validate mode
  if [[ ! "$mode" =~ ^[1-3]$ ]]; then
    echo "Invalid identity mode: $mode (must be 1, 2, or 3)"
    return 1
  fi
  
  # Set identity mode in profile
  jq --arg mode "$mode" '.identity.identity_mode = ($mode | tonumber)' \
    "$PROFILE_FILE" > "$temp_file"
  
  mv "$temp_file" "$PROFILE_FILE"
  
  echo "Identity mode set to: $mode"
}

# Lock or unlock title
set_title_lock() {
  local lock_state="$1"  # "true" or "false"
  local temp_file=$(mktemp)
  
  # Set title lock in profile
  jq --arg lock "$lock_state" '.identity.title_locked = ($lock == "true")' \
    "$PROFILE_FILE" > "$temp_file"
  
  mv "$temp_file" "$PROFILE_FILE"
  
  if [ "$lock_state" = "true" ]; then
    echo "Title locked! Your current title won't change until unlocked."
  else
    echo "Title unlocked! Your title may change as you progress."
  fi
}

# Generate a full identity string based on identity mode
get_full_identity() {
  local mode=$(get_identity_mode)
  local name=""
  local title=""
  
  # Get user's name with fallback
  name=$(get_user_real_name)
  if [ -z "$name" ] || [ "$name" = "null" ]; then
    # Use display name or anonymous name based on need
    local display_custom=$(get_profile_field "identity.custom_name")
    if [ "$display_custom" = "true" ]; then
      name=$(get_user_display_name)
    else
      name=$(get_anonymous_name)
    fi
  fi
  
  # Get user's title
  title=$(get_persistent_title)
  
  # Format based on identity mode
  case "$mode" in
    1)  # Name only
      echo "$name"
      ;;
    2)  # Title only
      echo "$title"
      ;;
    3)  # Combo
      echo "$name the $title"
      ;;
    *)
      # Default to combo
      echo "$name the $title"
      ;;
  esac
}

# Generate a greeting using identity
generate_identity_greeting() {
  local identity=$(get_full_identity)
  local greetings=(
    "Welcome back, $identity!"
    "Hello again, $identity!"
    "🐒 Greetings, $identity!"
    "Good to see you, $identity!"
    "The jungle awaits, $identity!"
  )
  
  # Get a random greeting
  local random_index=$((RANDOM % ${#greetings[@]}))
  echo "${greetings[$random_index]}"
}

# Preview identity format
preview_identity() {
  local mode="$1"
  
  # If no mode provided, use current mode
  if [ -z "$mode" ]; then
    mode=$(get_identity_mode)
  fi
  
  # Temporarily set mode
  local original_mode=$(get_identity_mode)
  set_identity_mode "$mode"
  
  # Generate and show preview
  local identity=$(get_full_identity)
  local greeting="Welcome back, $identity!"
  
  echo "Preview for identity mode $mode:"
  echo "  $greeting"
  
  # Restore original mode
  set_identity_mode "$original_mode"
}

# Get a new random title
randomize_title() {
  local stage=$(get_tone_stage)
  local theme=$(get_selected_theme)
  local new_title=$(get_monkey_title "$stage" "$theme")
  
  # Don't update if title is locked
  if is_title_locked; then
    echo "📝 Your title is currently locked. Unlock it first with: gitmonkey identity lock off"
    return 1
  fi
  
  set_custom_title "$new_title"
  echo "✨ Your new title is: $new_title"
}

# Initialize identity fields on load
initialize_identity