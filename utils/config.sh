#!/bin/bash

# ========= GLOBAL CONFIG =========

MONKEY_VERSION="v4.0"
MONKEY_THEME="hacker"
MONKEY_USER=$(whoami)
MONKEY_HOME="$HOME/.gitmonkey"

# Create necessary directories
mkdir -p "$MONKEY_HOME/logs"
mkdir -p "$MONKEY_HOME/config"

# Path to user config file
CONFIG_FILE="$MONKEY_HOME/config/settings.conf"

# Default settings
ENABLE_ANIMATIONS="true"
ENABLE_ASCII_ART="true"
ENABLE_COLORS="true"
VERBOSITY_LEVEL="normal"  # minimal, normal, verbose

# Load user config if exists
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

# Function to save config
save_config() {
  cat > "$CONFIG_FILE" << EOF
# Git Monkey User Configuration
# Edit this file to customize your experience

ENABLE_ANIMATIONS="$ENABLE_ANIMATIONS"
ENABLE_ASCII_ART="$ENABLE_ASCII_ART"
ENABLE_COLORS="$ENABLE_COLORS"
VERBOSITY_LEVEL="$VERBOSITY_LEVEL"
EOF
  echo "Settings saved to $CONFIG_FILE"
}

# Create default config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  save_config
fi

# Update settings function (for other scripts to use)
update_setting() {
  local setting="$1"
  local value="$2"
  
  case "$setting" in
    animations) ENABLE_ANIMATIONS="$value" ;;
    ascii) ENABLE_ASCII_ART="$value" ;;
    colors) ENABLE_COLORS="$value" ;;
    verbosity) VERBOSITY_LEVEL="$value" ;;
    *) echo "Unknown setting: $setting"; return 1 ;;
  esac
  
  save_config
  return 0
}

