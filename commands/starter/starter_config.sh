#!/bin/bash

# Set directory paths for consistent imports
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"

# ========= GIT MONKEY STARTER CONFIG =========
# Shared configuration for the project starter wizard

# Set defaults
STARTER_HOME="$MONKEY_HOME/starter"
STARTER_PRESETS="$STARTER_HOME/presets"

# Create necessary directories
mkdir -p "$STARTER_PRESETS"

# Initialize project variables
init_project_vars() {
  # Project info
  PROJECT_NAME=""
  PROJECT_PATH=""
  
  # Framework selection
  FRAMEWORK_TYPE=""  # svelte, node, static
  
  # UI options
  USE_TAILWIND=false
  UI_KIT=""  # daisyui, skeleton, shadcn, shoelace, none
  
  # Backend options
  BACKEND_TYPE=""  # supabase, xata, pocketbase, none
  
  # Extras
  USE_ESLINT=false
  USE_PRETTIER=false
  CREATE_GITHUB_REPO=false
  LAUNCH_VSCODE=false
  START_DEV_SERVER=false
  
  # Mode
  HEADLESS_MODE=false
}

# Save configuration as preset
save_preset() {
  local preset_name="$1"
  
  if [ -z "$preset_name" ]; then
    preset_name="default"
  fi
  
  local preset_file="$STARTER_PRESETS/$preset_name.conf"
  
  cat > "$preset_file" << EOF
# Git Monkey Starter Preset: $preset_name
# Created: $(date)

# Project settings
FRAMEWORK_TYPE="$FRAMEWORK_TYPE"
USE_TAILWIND=$USE_TAILWIND
UI_KIT="$UI_KIT"
BACKEND_TYPE="$BACKEND_TYPE"
USE_ESLINT=$USE_ESLINT
USE_PRETTIER=$USE_PRETTIER
CREATE_GITHUB_REPO=$CREATE_GITHUB_REPO
LAUNCH_VSCODE=$LAUNCH_VSCODE
START_DEV_SERVER=$START_DEV_SERVER
EOF

  echo "✅ Saved preset: $preset_name"
}

# Load configuration preset
load_preset() {
  local preset_name="$1"
  
  if [ -z "$preset_name" ]; then
    preset_name="default"
  fi
  
  local preset_file="$STARTER_PRESETS/$preset_name.conf"
  
  if [ ! -f "$preset_file" ]; then
    echo "❌ Preset not found: $preset_name"
    return 1
  fi
  
  source "$preset_file"
# Get current theme
THEME=$(get_selected_theme)
  echo "✅ Loaded preset: $preset_name"
  return 0
}

# Check if a command exists
check_command() {
  local cmd="$1"
  if ! command -v "$cmd" &> /dev/null; then
    echo "❌ Required command not found: $cmd"
    return 1
  fi
  return 0
}

# Print project summary
print_summary() {
  echo ""
  box "Project Summary"
  echo "📂 Project Name: $PROJECT_NAME"
  echo "🔧 Framework: $FRAMEWORK_TYPE"
  
  if [ "$USE_TAILWIND" = true ]; then
    echo "🎨 Styling: Tailwind CSS"
    case "$UI_KIT" in
      daisyui)
        echo "🧩 UI Kit: DaisyUI (lightweight components)"
        ;;
      skeleton)
        echo "🧩 UI Kit: Skeleton (SvelteKit UI library)"
        ;;
      flowbite)
        echo "🧩 UI Kit: Flowbite (feature-rich components)"
        ;;
      shoelace)
        echo "🧩 UI Kit: Shoelace (framework-agnostic web components)"
        ;;
      none)
        echo "🧩 UI Kit: None (just Tailwind)"
        ;;
      *)
        [ -n "$UI_KIT" ] && echo "🧩 UI Kit: $UI_KIT"
        ;;
    esac
  else
    echo "🎨 Styling: Default CSS"
  fi
  
  if [ -n "$BACKEND_TYPE" ] && [ "$BACKEND_TYPE" != "none" ]; then
    case "$BACKEND_TYPE" in
      supabase)
        echo "🔌 Backend: Supabase (auth, DB, storage)"
        ;;
      xata)
        echo "🔌 Backend: Xata (serverless DB, full-text search)"
        ;;
      *)
        echo "🔌 Backend: $BACKEND_TYPE"
        ;;
    esac
  else
    echo "🔌 Backend: None"
  fi
  
  echo "✨ Extras:"
  [ "$USE_ESLINT" = true ] && echo "  ✓ ESLint"
  [ "$USE_PRETTIER" = true ] && echo "  ✓ Prettier"
  [ "$CREATE_GITHUB_REPO" = true ] && echo "  ✓ GitHub repo"
  [ "$LAUNCH_VSCODE" = true ] && echo "  ✓ VS Code launch"
  [ "$START_DEV_SERVER" = true ] && echo "  ✓ Start dev server"
  
  echo ""
}

# Initialize variables
init_project_vars