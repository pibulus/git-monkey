#!/bin/bash

# ========= SVELTEKIT SETUP MODULE =========
# Sets up a new SvelteKit project

setup_sveltekit() {
  local project_name="$1"
  local project_path="$2"
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up SvelteKit." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  fi
  
  # Friendly intro
  typewriter "🚀 Setting up SvelteKit - a powerful framework for building web applications" 0.02
  echo ""
  
  # Navigate to parent directory if creating in a subfolder
  cd "$(dirname "$project_path")" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Create SvelteKit project with npm
  typewriter "Creating SvelteKit project..." 0.02
  
  if [ "$HEADLESS_MODE" = true ]; then
    # Non-interactive mode for automation
    # Customize these options based on preference
    npm create svelte@latest "$project_name" --quiet -- \
      --template skeleton \
      --types typescript \
      --eslint \
      --prettier \
      --playwright \
      --no-git > /dev/null 2>&1
  else
    # Interactive mode
    echo "✨ I'll guide you through the SvelteKit setup process."
    echo "You'll need to answer a few questions from the SvelteKit installer."
    echo ""
    echo "Recommended options:"
    echo "- 'Skeleton project' or 'Library' for minimalism"
    echo "- TypeScript for type safety"
    echo "- ESLint for code quality"
    echo "- Prettier for formatting"
    echo ""
    read -p "Press Enter to continue..." 
    echo ""
    
    npm create svelte@latest "$project_name" --quiet -- --no-git
  fi
  
  # Check if creation was successful
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Something went wrong creating the SvelteKit project." 0.02
    return 1
  fi
  
  # Navigate to the project directory
  cd "$project_name" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Install dependencies
  typewriter "Installing dependencies..." 0.02
  npm install > /dev/null 2>&1
  
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Something went wrong installing dependencies." 0.02
    return 1
  fi
  
  # Success message
  rainbow_box "✅ SvelteKit project created successfully!"
  echo "$(display_success "$THEME")"
  
  return 0
}