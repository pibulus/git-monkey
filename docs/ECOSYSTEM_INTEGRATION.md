# Ecosystem Integration: Git Monkey in the Broader Dev Landscape

This document outlines how Git Monkey seamlessly integrates with the broader development ecosystem, respecting that terminal operations exist alongside other tools and workflows.

## Core Philosophy

Git Monkey doesn't exist in isolation. We recognize that:
- People use multiple tools in their workflow
- Different tools have different strengths
- The goal is making users efficient, not advocating for one approach

## Editor Integration

### VSCode Integration

```bash
# commands/open.sh
open_in_vscode() {
  local path="$1"
  
  if [ -z "$path" ]; then
    path="."
  fi
  
  if command -v code &>/dev/null; then
    echo "$info_emoji Opening in VSCode..."
    code "$path"
  else
    echo "$warning_emoji VSCode not found in PATH."
    echo "To install the 'code' command, open VSCode and:"
    echo "  1. Press Cmd+Shift+P (or Ctrl+Shift+P on Windows/Linux)"
    echo "  2. Type 'shell command' and select 'Install code command in PATH'"
  fi
}
```

### Using the Right Tool for the Task

After certain operations, suggest appropriate tool follow-ups:

```bash
# After viewing a complex diff
if [ $(echo "$diff_output" | wc -l) -gt 20 ]; then
  echo ""
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "💡 Tip: For reviewing large changes, you might prefer:"
    echo "  gitmonkey open diff    # Opens this diff in your editor"
  fi
fi
```

## Project Setup Helpers

### Environment File Management

```bash
# commands/init/env.sh
setup_environment_files() {
  # Check for existing .env
  if [ -f ".env" ]; then
    echo "$warning_emoji .env file already exists."
    return
  fi
  
  echo "$info_emoji Setting up environment files..."
  
  # Create .env and .env.example
  echo "# Environment Variables" > .env.example
  echo "# Created by Git Monkey" >> .env.example
  
  # Detect project type and add appropriate variables
  if [ -f "package.json" ]; then
    # This is a Node.js project
    if grep -q "\"react\": " package.json; then
      echo "REACT_APP_API_URL=http://localhost:3000/api" >> .env.example
    elif grep -q "\"svelte\": " package.json; then
      echo "VITE_API_URL=http://localhost:3000/api" >> .env.example
    fi
  elif [ -f "requirements.txt" ]; then
    # This is a Python project
    echo "DEBUG=True" >> .env.example
    echo "DATABASE_URL=postgres://user:pass@localhost:5432/dbname" >> .env.example
  fi
  
  # Copy to .env
  cp .env.example .env
  
  # Add to .gitignore
  if [ -f ".gitignore" ]; then
    if ! grep -q "^\.env$" .gitignore; then
      echo ".env" >> .gitignore
      echo "$success_emoji Added .env to .gitignore"
    fi
  else
    echo ".env" > .gitignore
    echo "$success_emoji Created .gitignore with .env"
  fi
  
  echo "$success_emoji Environment files set up! Edit .env with your values."
}
```

### Node.js Project Helpers

```bash
# commands/fix/node.sh
fix_node_modules() {
  echo "$info_emoji Checking package manager..."
  
  if [ -f "yarn.lock" ]; then
    echo "🧶 Yarn project detected"
    
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "I'll clean and reinstall node_modules for you."
      echo "This might take a minute but often resolves dependency issues."
    fi
    
    rm -rf node_modules
    yarn install
    
    echo "$success_emoji Node modules reinstalled with yarn!"
  elif [ -f "package-lock.json" ]; then
    echo "📦 NPM project detected"
    
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "I'll clean and reinstall node_modules for you."
      echo "This might take a minute but often resolves dependency issues."
    fi
    
    rm -rf node_modules
    npm install
    
    echo "$success_emoji Node modules reinstalled with npm!"
  else
    echo "$error_emoji No yarn.lock or package-lock.json found."
    echo "Are you sure this is a Node.js project?"
  fi
}
```

## Cross-Platform Support

### Supporting Multiple Platforms

```bash
# utils/platform.sh
detect_platform() {
  case "$(uname -s)" in
    Darwin*)
      echo "macos"
      ;;
    Linux*)
      echo "linux"
      ;;
    CYGWIN*|MINGW*|MSYS*)
      echo "windows"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

get_platform_helper() {
  local platform=$(detect_platform)
  local helper_type="$1"
  
  case "$helper_type" in
    "open")
      case "$platform" in
        "macos")
          echo "open"
          ;;
        "linux")
          echo "xdg-open"
          ;;
        "windows")
          echo "start"
          ;;
        *)
          echo "echo"
          ;;
      esac
      ;;
    # More helper types...
  esac
}
```

### Platform-Specific Adjustments

```bash
# Clipboard functionality
copy_to_clipboard() {
  local text="$1"
  local platform=$(detect_platform)
  
  case "$platform" in
    "macos")
      echo "$text" | pbcopy
      ;;
    "linux")
      if command -v xclip &>/dev/null; then
        echo "$text" | xclip -selection clipboard
      elif command -v xsel &>/dev/null; then
        echo "$text" | xsel --clipboard
      else
        echo "$warning_emoji Clipboard utilities not found."
        echo "Install xclip or xsel for clipboard support."
        return 1
      fi
      ;;
    "windows")
      echo "$text" | clip
      ;;
    *)
      echo "$warning_emoji Clipboard not supported on this platform."
      return 1
      ;;
  esac
  
  if [ $? -eq 0 ]; then
    echo "$success_emoji Copied to clipboard!"
  fi
}
```

## Project Type Detection & Adaptation

```bash
# utils/project_detector.sh
detect_project_type() {
  # Check for common project markers
  if [ -f "package.json" ]; then
    # Node.js project, determine framework
    if grep -q "\"react\":" package.json; then
      echo "react"
    elif grep -q "\"svelte\":" package.json; then
      echo "svelte"
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
```

## Smart Project Commands

Based on project detection, offer framework-specific helpers:

```bash
# commands/project.sh
handle_project_command() {
  local project_type=$(detect_project_type)
  local command="$1"
  
  case "$project_type" in
    "react"|"svelte"|"vue"|"nextjs"|"nodejs")
      handle_node_project "$command"
      ;;
    "django"|"flask"|"python")
      handle_python_project "$command"
      ;;
    # Other project types...
    *)
      echo "$warning_emoji Couldn't determine project type."
      echo "Try running project-specific commands directly."
      ;;
  esac
}

handle_node_project() {
  local command="$1"
  
  case "$command" in
    "dev"|"start")
      echo "$info_emoji Starting development server..."
      npm run dev || npm start
      ;;
    "build")
      echo "$info_emoji Building project..."
      npm run build
      ;;
    "test")
      echo "$info_emoji Running tests..."
      npm test
      ;;
    "clean")
      echo "$info_emoji Cleaning node_modules..."
      fix_node_modules
      ;;
    *)
      echo "$error_emoji Unknown command: $command"
      echo "Available commands: dev, build, test, clean"
      ;;
  esac
}
```

## Terminal + GUI Synergy

Emphasize how terminal and GUI tools can work together:

```bash
# After complex merge operations
if [ "$TONE_STAGE" -le 3 ]; then
  echo "$info_emoji Terminal + GUI workflow tip:"
  echo "  1. Use terminal for fast operations (like you just did)"
  echo "  2. For complex merges, try: gitmonkey open merge"
  echo "     This will open your merge conflicts in your editor"
  echo "  3. Return to terminal for quick committing with: gitmonkey commit"
fi
```

## Framework-Specific Quick Commands

```bash
# commands/quickstart.sh
quickstart_project() {
  local project_type=$(detect_project_type)
  
  echo "$info_emoji Creating development quickstart for $project_type..."
  
  # Create a quickstart.sh script with common commands
  case "$project_type" in
    "svelte")
      cat > quickstart.sh << 'EOF'
#!/bin/bash
# Git Monkey Quickstart for Svelte

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Start development server
echo "🚀 Starting Svelte development server..."
npm run dev
EOF
      ;;
    # Other project types...
  esac
  
  chmod +x quickstart.sh
  
  echo "$success_emoji Created quickstart.sh - run with ./quickstart.sh"
}
```

---

By integrating smoothly with other tools and ecosystems, Git Monkey helps users build efficient workflows that use the right tool for each job while still emphasizing terminal efficiency when appropriate.