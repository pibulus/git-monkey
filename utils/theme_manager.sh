#\!/bin/bash

# ========= THEME MANAGER UTILITY =========
# Allows user to select and switch between different themes

# Include required utilities
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/style.sh"
source "$(dirname "$0")/ascii_art.sh"

# Available themes
AVAILABLE_THEMES=("jungle" "hacker" "wizard" "cosmic")

# Theme descriptions
THEME_DESCRIPTIONS=(
  "Playful explorer vibe with natural, organic elements"
  "Technical, precise language with l33t system references"
  "Mystical language with arcane and magical references"
  "Space-themed language with cosmic and galactic elements"
)

# Theme selection menu
select_theme() {
  clear
  display_menu_header
  
  echo "Choose your Git Monkey theme:"
  echo ""
  
  for i in "${\!AVAILABLE_THEMES[@]}"; do
    local theme="${AVAILABLE_THEMES[$i]}"
    local description="${THEME_DESCRIPTIONS[$i]}"
    
    if [ "$theme" = "$(get_selected_theme)" ]; then
      echo -e "  \033[1;32m[$((i+1))] ${theme^} \033[0m- $description \033[1;32m[ACTIVE]\033[0m"
    else
      echo -e "  [$((i+1))] ${theme^} - $description"
    fi
  done
  
  echo ""
  echo "Enter theme number (or q to quit): "
  read -r choice
  
  case "$choice" in
    q|Q)
      return
      ;;
    1|2|3|4)
      local new_theme="${AVAILABLE_THEMES[$((choice-1))]}"
      set_theme "$new_theme"
      echo ""
      echo "Theme switched to: ${new_theme^}"
      echo ""
      display_splash "$new_theme"
      echo ""
      display_greeting "$new_theme"
      ;;
    *)
      echo "Invalid choice. Please select 1-4 or q to quit."
      sleep 2
      select_theme
      ;;
  esac
}

# Set the current theme
set_theme() {
  local theme="$1"
  
  # Ensure it's a valid theme
  local valid=false
  for t in "${AVAILABLE_THEMES[@]}"; do
    if [ "$t" = "$theme" ]; then
      valid=true
      break
    fi
  done
  
  if [ "$valid" = true ]; then
    set_config "theme" "$theme"
    return 0
  else
    echo "Error: Invalid theme '$theme'"
    return 1
  fi
}

# Get the current selected theme
get_selected_theme() {
  local theme=$(get_config "theme")
  
  # Default to jungle if no theme set
  if [ -z "$theme" ]; then
    echo "jungle"
  else
    echo "$theme"
  fi
}

# Preview a specific theme
preview_theme() {
  local theme="$1"
  
  echo "Previewing theme: ${theme^}"
  echo "----------------"
  
  display_splash "$theme"
  echo ""
  
  echo "Sample greeting:"
  display_greeting "$theme"
  echo ""
  
  echo "Sample success:"
  display_success "$theme"
  echo ""
  
  echo "Sample error:"
  display_error "$theme"
  echo ""
  
  echo "Sample tip:"
  display_tip "$theme"
  echo ""
}

# This can be called directly to start the theme selector
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  select_theme
fi
