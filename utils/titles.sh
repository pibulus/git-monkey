#!/bin/bash

# ========= GIT MONKEY TITLE ENGINE =========
# Assigns themed, playful titles based on tone stage and theme

# Load utilities
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/profile.sh"

# Title pools by tone stage and theme
# Format: titles[stage][theme][index]

# Default/Jungle theme titles
JUNGLE_TITLES_0=("Banana Sprout" "Tiny Ape" "Monkeyling" "Branch Newbie" "Code Sapling")
JUNGLE_TITLES_1=("Commit Cub" "Branch Hopper" "Jungle Scout" "Curious Chimp" "Repo Ranger")
JUNGLE_TITLES_2=("Patch Prince" "Merge Monkey" "Tree Swinger" "Commit Crafter" "Code Climber")
JUNGLE_TITLES_3=("Git Whisperer" "Vibeonaut" "Branch Baron" "Jungle Jumper" "Canopy Cruiser")
JUNGLE_TITLES_4=("Chill Dog" "Diff Druid" "Repo Royalty" "Monkey Maven" "Jungle Guru")
JUNGLE_TITLES_5=("The Final Commit" "Cosmic Ape" "Git Guardian" "Jungle Legend" "Monkey Mastermind")

# Hacker theme titles
HACKER_TITLES_0=("Script Newbie" "Byte Baby" "Code Cadet" "Terminal Rookie" "Commit Novice")
HACKER_TITLES_1=("CLI Climber" "Hack Hobbyist" "Data Dabbler" "Repo Rookie" "Script Kiddie")
HACKER_TITLES_2=("Debug Detective" "Code Conjurer" "Binary Bandit" "Patch Pirate" "Merge Mage")
HACKER_TITLES_3=("Git Guru" "Console Cowboy" "Branch Breaker" "Shell Sorcerer" "Diff Detective")
HACKER_TITLES_4=("Deep Diver" "Kernel Killer" "Version Virtuoso" "Commit Cracker" "Terminal Templar")
HACKER_TITLES_5=("Ghost in the Git" "Code Commander" "Bash Boss" "System Savant" "Cyber Sage")

# Wizard theme titles
WIZARD_TITLES_0=("Spell Student" "Code Apprentice" "Magic Novice" "Script Scribe" "Wand Waver")
WIZARD_TITLES_1=("Scroll Keeper" "Potion Preparer" "Charm Coder" "Branch Bender" "Merge Magician")
WIZARD_TITLES_2=("Spell Slinger" "Code Conjurer" "Repository Ritualist" "Commit Caster" "Branch Bender")
WIZARD_TITLES_3=("Arcane Automator" "Git Illusionist" "Patch Prestidigitator" "Enchanted Engineer" "Merge Mystic")
WIZARD_TITLES_4=("Repo Ritualist" "Binary Battlemage" "Commit Conjurer" "Version Vizier" "Diff Diviner")
WIZARD_TITLES_5=("Code Archmage" "Git Grandmaster" "Tech Thaumaturge" "Merge Magus" "Digital Druid")

# Cosmic theme titles
COSMIC_TITLES_0=("Stardust Starter" "Astro Apprentice" "Orbit Observer" "Space Seedling" "Cosmic Coder")
COSMIC_TITLES_1=("Nebula Navigator" "Satellite Scripter" "Commit Cosmonaut" "Gravity Grabber" "Starship Starter")
COSMIC_TITLES_2=("Branch Voyager" "Merge Meteorite" "Planetary Programmer" "Solar Scripter" "Commit Comet")
COSMIC_TITLES_3=("Galactic Git" "Nebula Navigator" "Space-Time Shifter" "Astral Automator" "Celestial Coder")
COSMIC_TITLES_4=("Quantum Committer" "Constellation Crafter" "Galaxy Guardian" "Supernova Shipper" "Wormhole Weaver")
COSMIC_TITLES_5=("Cosmic Commander" "Universal Updater" "Star System Sage" "Black Hole Boss" "Infinite Integrator")

# Get a random title based on tone stage and theme
get_monkey_title() {
  local stage="$1"
  local theme="$2"
  
  # Default stage and theme if not provided
  if [ -z "$stage" ]; then
    stage=$(get_tone_stage)
  fi
  
  if [ -z "$theme" ]; then
    theme=$(get_selected_theme)
  fi
  
  # Ensure valid stage (0-5)
  if ! [[ "$stage" =~ ^[0-5]$ ]]; then
    stage=0  # Default to beginner if invalid
  fi
  
  # Select appropriate title array based on theme
  local titles_array=""
  case "$theme" in
    "jungle")
      eval "titles_array=(\"\${JUNGLE_TITLES_${stage}[@]}\")"
      ;;
    "hacker")
      eval "titles_array=(\"\${HACKER_TITLES_${stage}[@]}\")"
      ;;
    "wizard")
      eval "titles_array=(\"\${WIZARD_TITLES_${stage}[@]}\")"
      ;;
    "cosmic")
      eval "titles_array=(\"\${COSMIC_TITLES_${stage}[@]}\")"
      ;;
    *)
      # Default to jungle theme for unknown themes
      eval "titles_array=(\"\${JUNGLE_TITLES_${stage}[@]}\")"
      ;;
  esac
  
  # Get a random title from the array
  local array_length=${#titles_array[@]}
  if [ $array_length -gt 0 ]; then
    local random_index=$((RANDOM % array_length))
    echo "${titles_array[$random_index]}"
  else
    # Fallback title if array is empty
    echo "Git Explorer"
  fi
}

# Get a persistent title for the current user
# This will return the same title until tone stage changes
get_persistent_title() {
  local stage=$(get_tone_stage)
  local theme=$(get_selected_theme)
  
  # Check for custom title first
  local custom_title=$(get_custom_title)
  if [ -n "$custom_title" ] && [ "$custom_title" != "null" ]; then
    echo "$custom_title"
    return
  fi
  
  # Store title in the profile if not already set or if tone stage changed
  local current_title=$(get_profile_field "custom.title")
  local last_title_stage=$(get_profile_field "custom.last_title_stage")
  
  if [ -z "$current_title" ] || [ "$current_title" = "null" ] || [ "$last_title_stage" != "$stage" ]; then
    # Generate a new title and save it
    local new_title=$(get_monkey_title "$stage" "$theme")
    local temp_file=$(mktemp)
    
    jq --arg title "$new_title" --arg stage "$stage" \
      '.custom.title = $title | .custom.last_title_stage = ($stage | tonumber)' \
      "$PROFILE_FILE" > "$temp_file"
    
    mv "$temp_file" "$PROFILE_FILE"
    echo "$new_title"
  else
    # Return existing title
    echo "$current_title"
  fi
}

# Check for a tone stage advancement and return a new title if it occurred
check_for_title_advancement() {
  local previous_stage="$1"
  local current_stage=$(get_tone_stage)
  
  if [ "$current_stage" -gt "$previous_stage" ]; then
    local new_title=$(get_monkey_title "$current_stage")
    echo "🎉 You've advanced to a new tone stage! You are now a \"$new_title\"."
    
    # Update the stored title
    set_custom_title "$new_title"
    return 0
  fi
  
  return 1  # No advancement
}

# Generate a greeting based on title
generate_title_greeting() {
  local title=$(get_persistent_title)
  local greetings=(
    "Welcome back, $title."
    "Hello there, $title. Ready to code?"
    "🐒 Greetings, $title. Let's get to work."
    "The jungle awaits, $title!"
    "Back to the code canopy, $title!"
  )
  
  # Get a random greeting
  local random_index=$((RANDOM % ${#greetings[@]}))
  echo "${greetings[$random_index]}"
}

# Get current title with tone stage info (for whoami command)
get_title_with_info() {
  local title=$(get_persistent_title)
  local stage=$(get_tone_stage)
  local theme=$(get_selected_theme)
  
  echo "Current title: $title"
  echo "Tone stage: $stage/5"
  echo "Theme: $theme"
}

# List all available titles for a given stage (for debugging)
list_stage_titles() {
  local stage="$1"
  local theme="$2"
  
  if [ -z "$theme" ]; then
    theme=$(get_selected_theme)
  fi
  
  echo "Available titles for stage $stage ($theme theme):"
  
  case "$theme" in
    "jungle")
      eval "echo \"\${JUNGLE_TITLES_${stage}[@]}\""
      ;;
    "hacker")
      eval "echo \"\${HACKER_TITLES_${stage}[@]}\""
      ;;
    "wizard") 
      eval "echo \"\${WIZARD_TITLES_${stage}[@]}\""
      ;;
    "cosmic")
      eval "echo \"\${COSMIC_TITLES_${stage}[@]}\""
      ;;
  esac
}