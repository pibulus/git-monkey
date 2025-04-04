#!/bin/bash

# ========= GIT MONKEY CRUD INTEGRATOR =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Integrates the modern CRUD generator with the existing CRUD generator

# Import utilities

# Function to integrate modern CRUD options into the main generator
integrate_modern_crud() {
  # Get current tone stage and theme for context-aware help
  TONE_STAGE=$(get_tone_stage)
  THEME=$(get_selected_theme)
  IDENTITY=$(get_full_identity)
  
  # Source the modern CRUD generator
  source ./commands/starter/crud/modern_crud_generator.sh
  
  # Inject new function for generating CRUD operations with modern features
  generate_crud() {
    local project_path="$1"
    local backend_type="$2"
    local framework_type="$3"
    local table_name="$4"
    
    # Check if user wants to use modern CRUD features
    if [ "$USE_MODERN_FEATURES" = true ]; then
      case "$framework_type" in
        "svelte")
          # Use modern SvelteKit CRUD generator
          generate_modern_crud_sveltekit "$project_path" "$table_name" "$backend_type" "$options"
          ;;
        *)
          # Fall back to original CRUD generator for other frameworks
          echo "Modern CRUD features are currently only available for SvelteKit projects."
          echo "Falling back to standard CRUD generator."
          _original_generate_crud "$project_path" "$backend_type" "$framework_type" "$table_name"
          ;;
      esac
    else
      # Use original CRUD generator
      _original_generate_crud "$project_path" "$backend_type" "$framework_type" "$table_name"
    fi
  }
  
  # Display ASCII art for modern CRUD
  show_modern_ascii() {
    local theme_emoji=""
    
    case "$THEME" in
      "jungle")
        echo -e "\e[33m"
        cat << 'EOF'
     _____             _              _____  _____  _   _  _____ 
    |     |___ ___ ___|_|___ _____   |     ||  _  || | | ||   __|
    | | | | . |   | -_| |   |     |  |   --||     || | | ||  |  |
    |_|_|_|___|_|_|___|_|_|_|_|_|_|  |_____||__|__||_|___||_____|
                   🍌 ENHANCED BANANA EDITION 🍌                                        
EOF
        echo -e "\e[0m"
        ;;
      "hacker")
        echo -e "\e[32m"
        cat << 'EOF'
 _ _ _     _           ___ ___ ___ ___ 
| | | |___| |_ ___ ___|  _|  _| | |   |
| | | | . |  _| -_|  _|  _|  _| | | | |
|_____|___|_| |___|_| |_| |_| |___|___|
    [ADVANCED PROTOCOL ACTIVATED]                           
EOF
        echo -e "\e[0m"
        ;;
      "wizard")
        echo -e "\e[35m"
        cat << 'EOF'
 __    __    __    __    __    __    __    __ 
/\ \  /\ "-./  \  /\ \  /\ \  /\ \  /\ \  /\ \
\ \ \ \ \ \-./\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
 \ \_\ \ \_\ \ \_\ \ \_\ \ \_\ \ \_\ \ \_\ \ \_\
  \/_/  \/_/  \/_/  \/_/  \/_/  \/_/  \/_/  \/_/
      ✨ ENCHANTED GRIMOIRE EDITION ✨
EOF
        echo -e "\e[0m"
        ;;
      "cosmic")
        echo -e "\e[38;5;75m"
        cat << 'EOF'
    __  __           __                     
   /  |/  |___  ____/ /___  _______  ___    
  / /|_/ / __ \/ __  / __ \/ ___/ / / / __ \
 / /  / / /_/ / /_/ / /_/ / /  / /_/ / / / /
/_/  /_/\____/\__,_/\____/_/   \__,_/_/ /_/ 
   🚀 INTERSTELLAR EDITION 🚀              
EOF
        echo -e "\e[0m"
        ;;
      *)
        rainbow_text "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ Modern CRUD 2.0 ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
        ;;
    esac
  }
  
  # Add modern CRUD option to the help text
  _original_show_help="$(declare -f show_help)"
  eval "show_help() {
    $_original_show_help
    
    echo \"\"
    theme_text \"Advanced Options:\"
    echo \"  --modern      Generate CRUD with modern features:\"
    echo \"                Server Actions, Zod Validation, Optimistic UI, Real-time, Filtering\"
  }"
  
  # Modify the argument parser to handle the modern flag
  _original_parse_crud_args="$(declare -f parse_crud_args)"
  eval "parse_crud_args() {
    # Initialize modern features flag
    USE_MODERN_FEATURES=false
    
    $_original_parse_crud_args
    
    # Check for modern flag
    for arg in \"\$@\"; do
      if [ \"\$arg\" = \"--modern\" ]; then
        USE_MODERN_FEATURES=true
        break
      fi
    done
  }"
  
  # Update the introduction to show modern CRUD option
  _original_show_intro="$(declare -f show_intro)"
  eval "show_intro() {
    if [ \"\$USE_MODERN_FEATURES\" = true ]; then
      show_modern_ascii
    else
      $_original_show_intro
    fi
  }"
  
  # Store original generate_crud function
  _original_generate_crud="$(declare -f generate_crud)"
}

# Call the function when the script is sourced
integrate_modern_crud
