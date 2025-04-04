#\!/bin/bash

# ========= ASCII ART & SPLASH SCREEN UTILITY =========

# Include style utilities
source "$(dirname "$0")/style.sh"

# Display theme-specific ASCII splash
display_splash() {
  local theme="$1"
  local filename=""
  
  # Default to jungle if no theme provided
  if [ -z "$theme" ]; then
    theme="jungle"
  fi
  
  # Try theme-specific splash first
  if [ -f "$(dirname "$0")/../assets/ascii/$theme/splash.txt" ]; then
    filename="$(dirname "$0")/../assets/ascii/$theme/splash.txt"
  else
    # Fall back to jungle splash if theme splash doesn't exist
    filename="$(dirname "$0")/../assets/ascii/jungle/splash.txt"
  fi
  
  # Display with colors if available
  if command -v lolcat >/dev/null; then
    cat "$filename" | lolcat
  else
    cat "$filename"
  fi
  
  echo ""
}

# Display menu header
display_menu_header() {
  local filename="$(dirname "$0")/../assets/ascii/menu/header.txt"
  
  if [ -f "$filename" ]; then
    if command -v lolcat >/dev/null; then
      cat "$filename" | lolcat
    else
      cat "$filename"
    fi
  else
    echo "=============================="
    echo "       GIT MONKEY MENU       "
    echo "=============================="
  fi
  
  echo ""
}

# Display menu footer
display_menu_footer() {
  local filename="$(dirname "$0")/../assets/ascii/menu/footer.txt"
  
  if [ -f "$filename" ]; then
    if command -v lolcat >/dev/null; then
      cat "$filename" | lolcat
    else
      cat "$filename"
    fi
  else
    echo "=============================="
    echo " [↑/↓] Navigate  [Enter] Select  [q] Quit "
    echo "=============================="
  fi
  
  echo ""
}

# Get a random message of a specific type for a theme
get_random_message() {
  local message_type="$1"  # greeting, success, error, tips
  local theme="$2"
  local filename=""
  
  # Default to jungle if no theme provided
  if [ -z "$theme" ]; then
    theme="jungle"
  fi
  
  # Try theme-specific message file first
  if [ -f "$(dirname "$0")/../assets/messages/$message_type/$theme.txt" ]; then
    filename="$(dirname "$0")/../assets/messages/$message_type/$theme.txt"
  else
    # Fall back to jungle messages if theme messages don't exist
    filename="$(dirname "$0")/../assets/messages/$message_type/jungle.txt"
  fi
  
  # Check if the file exists and has content
  if [ -f "$filename" ] && [ -s "$filename" ]; then
    # Get a random line from the file
    local line_count=$(wc -l < "$filename")
    local random_line=$((RANDOM % line_count + 1))
    sed -n "${random_line}p" "$filename"
  else
    # Fallback message if file doesn't exist or is empty
    case "$message_type" in
      greeting)
        echo "🐒 Welcome to Git Monkey\!"
        ;;
      success)
        echo "✅ Operation completed successfully\!"
        ;;
      error)
        echo "❌ Something went wrong\!"
        ;;
      tips)
        echo "💡 Try 'git status' to see the current state of your repository."
        ;;
      *)
        echo "Git Monkey is here to help\!"
        ;;
    esac
  fi
}

# Display a random greeting for the current theme
display_greeting() {
  local theme="$1"
  
  # Default to jungle if no theme provided
  if [ -z "$theme" ]; then
    theme=$(get_selected_theme 2>/dev/null || echo "jungle")
  fi
  
  get_random_message "greeting" "$theme"
}

# Display a random success message for the current theme
display_success() {
  local theme="$1"
  
  # Default to jungle if no theme provided
  if [ -z "$theme" ]; then
    theme=$(get_selected_theme 2>/dev/null || echo "jungle")
  fi
  
  get_random_message "success" "$theme"
}

# Display a random error message for the current theme
display_error() {
  local theme="$1"
  
  # Default to jungle if no theme provided
  if [ -z "$theme" ]; then
    theme=$(get_selected_theme 2>/dev/null || echo "jungle")
  fi
  
  get_random_message "error" "$theme"
}

# Display a random tip for the current theme
display_tip() {
  local theme="$1"
  
  # Default to jungle if no theme provided
  if [ -z "$theme" ]; then
    theme=$(get_selected_theme 2>/dev/null || echo "jungle")
  fi
  
  get_random_message "tips" "$theme"
}
