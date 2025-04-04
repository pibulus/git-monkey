#!/bin/bash

# ========= GIT MONKEY FIX COMMAND =========
# Fixes common development issues

source ./utils/style.sh
source ./utils/config.sh
source ./utils/profile.sh
source ./utils/identity.sh
source ./utils/performance.sh

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

# Detect project type
detect_project_type() {
  # Check for common project markers
  if [ -f "package.json" ]; then
    # Node.js project, determine framework
    if grep -q "\"svelte\":" package.json; then
      echo "svelte"
    elif grep -q "\"react\":" package.json; then
      echo "react"
    elif grep -q "\"vue\":" package.json; then
      echo "vue"
    elif grep -q "\"next\":" package.json; then
      echo "nextjs"
    elif grep -q "\"express\":" package.json; then
      echo "express"
    else
      echo "nodejs"
    fi
  elif [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
    # Python project
    if [ -f "manage.py" ]; then
      echo "django"
    elif [ -f "app.py" ] || [ -f "wsgi.py" ]; then
      echo "flask"
    else
      echo "python"
    fi
  elif [ -f "Gemfile" ]; then
    echo "ruby"
  elif [ -f "go.mod" ]; then
    echo "golang"
  elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
    echo "java"
  elif [ -f "composer.json" ]; then
    echo "php"
  else
    echo "unknown"
  fi
}

# Fix node_modules issues
fix_node_modules() {
  if [ ! -f "package.json" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$error_emoji I couldn't find a package.json file here, $IDENTITY."
      echo "Make sure you're in a Node.js project directory!"
    else
      echo "$error_emoji No package.json found."
    fi
    return 1
  fi
  
  # Start timing
  local start_time=$(start_timing)
  
  # Detect package manager
  if [ -f "yarn.lock" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji I detected you're using Yarn as your package manager!"
      echo ""
      echo "I'll fix your node_modules by:"
      echo "1. Removing the existing node_modules folder"
      echo "2. Reinstalling all dependencies with yarn"
      echo ""
      echo "This often fixes strange errors and 'module not found' issues."
    elif [ "$TONE_STAGE" -le 3 ]; then
      echo "$info_emoji Yarn project detected. Reinstalling dependencies..."
    else
      echo "$info_emoji Reinstalling with yarn..."
    fi
    
    rm -rf node_modules
    yarn install
    
  elif [ -f "pnpm-lock.yaml" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji I detected you're using pnpm as your package manager!"
      echo ""
      echo "I'll fix your node_modules by:"
      echo "1. Removing the existing node_modules folder"
      echo "2. Reinstalling all dependencies with pnpm"
      echo ""
      echo "This often fixes strange errors and 'module not found' issues."
    elif [ "$TONE_STAGE" -le 3 ]; then
      echo "$info_emoji pnpm project detected. Reinstalling dependencies..."
    else
      echo "$info_emoji Reinstalling with pnpm..."
    fi
    
    rm -rf node_modules
    pnpm install
    
  else
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji I detected you're using npm as your package manager!"
      echo ""
      echo "I'll fix your node_modules by:"
      echo "1. Removing the existing node_modules folder and package-lock.json"
      echo "2. Reinstalling all dependencies with npm"
      echo ""
      echo "This often fixes strange errors and 'module not found' issues."
    elif [ "$TONE_STAGE" -le 3 ]; then
      echo "$info_emoji npm project detected. Reinstalling dependencies..."
    else
      echo "$info_emoji Reinstalling with npm..."
    fi
    
    rm -rf node_modules package-lock.json
    npm install
  fi
  
  # End timing and record metrics
  local duration=$(end_timing "$start_time")
  record_command_time "fix_node_modules" "$duration"
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "$success_emoji All fixed! Your node_modules have been completely reinstalled."
    echo "This should resolve any dependency or module-related issues."
    echo ""
    echo "💡 If you're still having problems, check:"
    echo "   • Your Node.js version (some packages require specific versions)"
    echo "   • Package versions in package.json"
    echo "   • If any packages have peer dependency conflicts"
  elif [ "$TONE_STAGE" -le 3 ]; then
    echo "$success_emoji Dependencies reinstalled successfully in $(printf "%.1f" "$duration")s."
  else
    echo "$success_emoji Dependencies reinstalled."
  fi
  
  return 0
}

# Fix .env issues
fix_env_files() {
  # Check if .env already exists
  if [ -f ".env" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji I found an existing .env file, $IDENTITY."
      echo "Would you like me to create a template .env.example file based on it?"
      echo "(This is useful for team collaboration, showing what env vars are needed)"
      read -p "$info_emoji Create .env.example? (Y/n): " create_example
      
      if [[ "$create_example" != "n" && "$create_example" != "N" ]]; then
        # Extract keys without values to create example
        grep -v "^#" .env | sed 's/=.*/=YOUR_VALUE_HERE/' > .env.example
        echo "$success_emoji Created .env.example template!"
      fi
    else
      # Extract keys without values to create example
      grep -v "^#" .env | sed 's/=.*/=YOUR_VALUE_HERE/' > .env.example
      echo "$success_emoji Created .env.example from existing .env"
    fi
  else
    # Create new .env files
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji I'll help you set up environment variables for your project!"
      echo "Environment variables are secrets like API keys that shouldn't be in your code."
    elif [ "$TONE_STAGE" -le 3 ]; then
      echo "$info_emoji Setting up environment variables..."
    else
      echo "$info_emoji Creating .env files..."
    fi
    
    # Create .env.example template
    echo "# Environment Variables" > .env.example
    echo "# Created by Git Monkey" >> .env.example
    
    # Detect project type and add appropriate variables
    local project_type=$(detect_project_type)
    
    case "$project_type" in
      "svelte")
        echo "# Svelte environment variables" >> .env.example
        echo "VITE_API_URL=http://localhost:5000/api" >> .env.example
        ;;
      "react")
        echo "# React environment variables" >> .env.example
        echo "REACT_APP_API_URL=http://localhost:5000/api" >> .env.example
        ;;
      "nextjs")
        echo "# Next.js environment variables" >> .env.example
        echo "NEXT_PUBLIC_API_URL=http://localhost:5000/api" >> .env.example
        ;;
      "express")
        echo "# Express API environment variables" >> .env.example
        echo "PORT=3000" >> .env.example
        echo "NODE_ENV=development" >> .env.example
        echo "DATABASE_URL=mongodb://localhost:27017/mydb" >> .env.example
        ;;
      "nodejs")
        echo "# Node.js environment variables" >> .env.example
        echo "PORT=3000" >> .env.example
        echo "NODE_ENV=development" >> .env.example
        ;;
      "python"|"django"|"flask")
        echo "# Python environment variables" >> .env.example
        echo "DEBUG=True" >> .env.example
        echo "SECRET_KEY=your_secret_key_here" >> .env.example
        echo "DATABASE_URL=sqlite:///db.sqlite3" >> .env.example
        ;;
      *)
        echo "# Project environment variables" >> .env.example
        echo "# Add your environment variables here" >> .env.example
        ;;
    esac
    
    # Copy example to actual .env file
    cp .env.example .env
    
    # Add to .gitignore if not already there
    if [ -f ".gitignore" ]; then
      if ! grep -q "^\.env$" .gitignore; then
        echo "" >> .gitignore
        echo "# Environment variables" >> .gitignore
        echo ".env" >> .gitignore
        echo ".env.local" >> .gitignore
        
        if [ "$TONE_STAGE" -le 2 ]; then
          echo "$info_emoji Added .env to .gitignore to keep your secrets safe!"
        else
          echo "$info_emoji Updated .gitignore with .env"
        fi
      fi
    else
      echo ".env" > .gitignore
      echo ".env.local" >> .gitignore
      
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "$info_emoji Created .gitignore with .env to keep your secrets safe!"
      else
        echo "$info_emoji Created .gitignore with .env"
      fi
    fi
    
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$success_emoji Environment files created successfully!"
      echo ""
      echo "💡 What are .env files?"
      echo "   • .env - Your personal environment variables (not shared in Git)"
      echo "   • .env.example - Template showing what variables are needed (shared in Git)"
      echo ""
      echo "Now you can edit .env to add your actual API keys and secrets."
    elif [ "$TONE_STAGE" -le 3 ]; then
      echo "$success_emoji Environment files created. Edit .env to add your actual values."
    else
      echo "$success_emoji .env and .env.example created."
    fi
  fi
  
  return 0
}

# Fix .gitignore issues
fix_gitignore() {
  local custom_entries="${1:-}"
  
  if [ -f ".gitignore" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji I found an existing .gitignore file, $IDENTITY."
      echo "I'll update it with some common patterns you might want to ignore."
    else
      echo "$info_emoji Updating existing .gitignore..."
    fi
  else
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji Creating a new .gitignore file for you!"
      echo "This helps keep unnecessary files out of your Git repository."
    else
      echo "$info_emoji Creating .gitignore..."
    fi
    
    # Create empty file
    touch .gitignore
  fi
  
  # Common entries to check for based on project type
  local project_type=$(detect_project_type)
  local entries=()
  
  # Add common entries for all projects
  entries+=(".DS_Store")
  entries+=("Thumbs.db")
  entries+=(".env")
  entries+=(".env.local")
  entries+=(".idea/")
  entries+=(".vscode/")
  
  # Add project-specific entries
  case "$project_type" in
    "svelte"|"react"|"vue"|"nextjs"|"nodejs"|"express")
      entries+=("node_modules/")
      entries+=("npm-debug.log")
      entries+=("yarn-debug.log")
      entries+=("yarn-error.log")
      entries+=(".pnpm-debug.log")
      entries+=("dist/")
      entries+=("build/")
      entries+=("coverage/")
      ;;
    "python"|"django"|"flask")
      entries+=("__pycache__/")
      entries+=("*.py[cod]")
      entries+=("*$py.class")
      entries+=("venv/")
      entries+=("env/")
      entries+=(".venv/")
      entries+=(".env/")
      entries+=("*.sqlite3")
      ;;
  esac
  
  # Add custom entries if provided
  if [ -n "$custom_entries" ]; then
    IFS=',' read -ra custom_array <<< "$custom_entries"
    for entry in "${custom_array[@]}"; do
      entries+=("$entry")
    done
  fi
  
  # Add entries to .gitignore if they don't already exist
  for entry in "${entries[@]}"; do
    if ! grep -q "^$entry$" .gitignore; then
      echo "$entry" >> .gitignore
    fi
  done
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$success_emoji .gitignore updated with common patterns!"
    echo "This helps prevent unnecessary files from cluttering your repository."
  elif [ "$TONE_STAGE" -le 3 ]; then
    echo "$success_emoji .gitignore updated with common patterns for $project_type projects."
  else
    echo "$success_emoji .gitignore updated."
  fi
  
  return 0
}

# Fix large files accidentally committed
fix_large_files() {
  # Look for large files (>10MB)
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$info_emoji Looking for large files that shouldn't be in Git..."
  else
    echo "$info_emoji Scanning for large files..."
  fi
  
  # Find large files, excluding common binary directories
  local large_files=$(find . -type f -size +10M -not -path "*/node_modules/*" -not -path "*/build/*" -not -path "*/dist/*" -not -path "*/.git/*")
  
  if [ -z "$large_files" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$success_emoji Great! I didn't find any problematically large files, $IDENTITY."
    else
      echo "$success_emoji No large files found."
    fi
    return 0
  fi
  
  # Large files found
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$warning_emoji I found some large files that probably shouldn't be in Git:"
    echo "$large_files"
    echo ""
    echo "Large files in Git can cause slow clones and take up unnecessary space."
    echo "Here's what we can do:"
    echo "1. Add these files to .gitignore to prevent them being added in the future"
    echo "2. If they're already committed, use 'git filter-branch' to remove them (advanced)"
    
    read -p "$info_emoji Add these files to .gitignore? (Y/n): " add_to_ignore
    
    if [[ "$add_to_ignore" != "n" && "$add_to_ignore" != "N" ]]; then
      # Extract filenames/patterns to add to .gitignore
      for file in $large_files; do
        # Get relative path from repository root
        local rel_path=${file#./}
        
        # Add to .gitignore if not already there
        if ! grep -q "^$rel_path$" .gitignore 2>/dev/null; then
          echo "$rel_path" >> .gitignore
        fi
      done
      
      echo "$success_emoji Added large files to .gitignore!"
      echo "This will prevent them from being added to Git in the future."
      
      echo ""
      echo "💡 For files already committed to Git, you might want to look into:"
      echo "   • Git LFS for large file storage: https://git-lfs.github.com/"
      echo "   • git filter-branch to remove large files from history (advanced)"
    fi
  else
    echo "$warning_emoji Large files detected: $large_files"
    echo "Consider adding to .gitignore or using Git LFS."
  fi
  
  return 0
}

# Show usage
show_usage() {
  echo "Usage: gitmonkey fix <issue-type> [options]"
  echo ""
  echo "Issue Types:"
  echo "  node       - Fix node_modules issues by reinstalling dependencies"
  echo "  env        - Set up .env and .env.example files"
  echo "  gitignore  - Create or update .gitignore with common patterns"
  echo "  large      - Find and handle large files that shouldn't be in Git"
  echo ""
  echo "Examples:"
  echo "  gitmonkey fix node           # Fix node_modules issues"
  echo "  gitmonkey fix env            # Set up environment files"
  echo "  gitmonkey fix gitignore      # Update .gitignore"
  echo "  gitmonkey fix large          # Find large files"
}

# Main function
main() {
  # Check if any arguments were provided
  if [ $# -eq 0 ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji Hey $IDENTITY! What would you like me to fix for you?"
    else
      echo "$info_emoji Available fixes:"
    fi
    
    show_usage
    return 0
  fi
  
  # Parse arguments
  local issue_type="$1"
  shift
  
  case "$issue_type" in
    "node"|"modules"|"node_modules")
      fix_node_modules "$@"
      ;;
    "env"|"environment"|"env-files")
      fix_env_files "$@"
      ;;
    "gitignore"|"ignore")
      fix_gitignore "$@"
      ;;
    "large"|"large-files")
      fix_large_files "$@"
      ;;
    "help"|"--help"|"-h")
      show_usage
      ;;
    *)
      echo "$error_emoji Unknown issue type: $issue_type"
      show_usage
      return 1
      ;;
  esac
}

# Execute main function
main "$@"