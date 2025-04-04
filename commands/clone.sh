#!/bin/bash

# ========= GIT MONKEY CLONE COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"




# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"  # Can be "info", "success", "error", "warning"
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        *) echo "🐒" ;;
      esac
      ;;
  esac
}

# Get theme-specific emojis
info_emoji=$(get_theme_emoji "info")
success_emoji=$(get_theme_emoji "success")
error_emoji=$(get_theme_emoji "error")
warning_emoji=$(get_theme_emoji "warning")

display_splash "$THEME"

# Use tone-appropriate introduction
if [ "$TONE_STAGE" -le 2 ]; then
  # Beginners get friendly, personalized introduction
  ascii_spell "Let's bring something down from the stars"
  echo ""
  typewriter "Hey $IDENTITY! You're about to clone a GitHub repo into this folder." 0.02
  echo "Think of it like inviting a new friend over to jam."
  echo ""
elif [ "$TONE_STAGE" -le 3 ]; then
  # Intermediate users get a lighter intro
  ascii_spell "Clone repository" 
  echo ""
  echo "You're about to clone a repository into this folder."
  echo ""
else
  # Expert users get minimal intro
  echo ""
  echo "Repository cloning"
  echo ""
fi

# Prompt with appropriate tone
if [ "$TONE_STAGE" -le 2 ]; then
  read -p "$info_emoji Paste the GitHub repo URL: " repo_url
else
  read -p "$info_emoji Repo URL: " repo_url
fi

if [ -z "$repo_url" ]; then
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$error_emoji No URL entered. That's okay, $IDENTITY!"
  else
    echo "$error_emoji No URL entered."
  fi
  echo "$(display_error "$THEME")"
  
  # Tone-appropriate help
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "💡 Try grabbing a GitHub HTTPS link from the repo's main page."
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "If you need help, just ask or Google: clone a GitHub repo"
    fi
  fi
  exit 1
fi

# Extract folder name from URL
repo_name=$(basename -s .git "$repo_url")

echo ""
if [ "$TONE_STAGE" -le 3 ]; then
  typewriter "Cloning '$repo_name' into this directory..." 0.02
  echo ""
else 
  echo "Cloning '$repo_name'..."
fi

# Measure clone performance
start_time=$(start_timing)

git clone "$repo_url"
status=$?

# Record performance data
duration=$(end_timing "$start_time")
record_command_time "clone" "$duration"
time_saved=$(record_operation_time "clone" "$duration")

if [ $status -eq 0 ]; then
  # Success message with tone-appropriate styling
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "$success_emoji Repo '$repo_name' cloned successfully!"
    typewriter "$(display_success "$THEME")" 0.02
    
    # Show performance data occasionally for beginners
    if (( $(echo "$duration < 5.0" | bc -l) )); then
      echo ""
      echo "⚡ Repository cloned in $(printf "%.1f" "$duration") seconds!"
    fi
    
    echo ""
    read -p "$info_emoji $IDENTITY, want to enter '$repo_name' right now? (y/n): " cdnow
  elif [ "$TONE_STAGE" -le 3 ]; then
    rainbow_box "$success_emoji '$repo_name' cloned successfully!"
    echo "$(display_success "$THEME")"
    
    # Show quick performance data for intermediate users
    if (( $(echo "$duration < 5.0" | bc -l) )); then
      echo "⚡ Done in $(printf "%.1f" "$duration")s"
    fi
    
    echo ""
    read -p "$info_emoji Enter the repo directory? (y/n): " cdnow
  else
    echo "$success_emoji '$repo_name' cloned in $(printf "%.1f" "$duration")s"
    read -p "Enter directory? (y/n): " cdnow
  fi
  
  if [[ "$cdnow" =~ ^[Yy]$ ]]; then
    cd "$repo_name"
    echo ""
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "📁 Welcome to '$repo_name', $IDENTITY! Here's what's inside:" | lolcat
    else
      echo "📁 Contents of '$repo_name':"
    fi
    echo ""
    ls -la
    echo ""
    
    # Offer to open in editor for a seamless workflow
    if [ "$TONE_STAGE" -le 3 ]; then
      read -p "$info_emoji Open this project in your editor? (y/n): " open_editor
      if [[ "$open_editor" =~ ^[Yy]$ ]]; then
        # Source the open command to use its functions directly
        source ./commands/open.sh
        
        # Open with appropriate editor
        open_in_editor
      fi
    fi
  else
    echo ""
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "✨ All good, $IDENTITY! You know where it is when you're ready."
      echo ""
      echo "💡 TIP: When you're ready to work on this project, use:"
      echo "   cd $repo_name"
      echo "   gitmonkey open         # To open in your editor"
    else
      echo "✨ Clone complete."
    fi
  fi
else
  echo ""
  echo "$error_emoji Something didn't work. $(display_error "$THEME")"
  
  # Tone-appropriate help
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "💡 Here's a tip: $(display_tip "$THEME")"
    echo ""
    echo "Try cloning again with:"
    echo "  git clone $repo_url" | lolcat
    echo ""
  else
    echo "Command: git clone $repo_url"
  fi
fi
