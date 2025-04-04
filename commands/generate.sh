#!/bin/bash

# ========= GIT MONKEY GENERATE COMMAND =========
# Command to generate various code elements

source ./utils/style.sh
source ./utils/config.sh

# Function to show available generators
show_generators() {
  echo ""
  box "Git Monkey Generators"
  echo ""
  echo "Available generators:"
  echo ""
  echo "  🔄 crud      - Generate CRUD functionality for a table"
  echo "  📝 todo      - Generate a Todo app with CRUD operations"
  echo "  📰 blog      - Generate a simple Blog with posts and comments"
  echo "  👤 auth      - Generate authentication screens and flows"
  echo "  🛒 store     - Generate an e-commerce store with products"
  echo "  🎨 theme     - Change your UI theme for Git Monkey"
  echo ""
  echo "Usage: gitmonkey generate <type> [options]"
  echo ""
  echo "For help on specific generator:"
  echo "  gitmonkey generate <type> --help"
  echo ""
}

# Function to generate a todo app
generate_todo_app() {
  echo "🚀 Generating Todo App..."
  
  # Call CRUD generator with Todo-specific schema
  local todo_schema='{
    "id": "string",
    "title": "string",
    "description": "text",
    "status": "string",
    "priority": "int",
    "due_date": "datetime",
    "created_at": "datetime",
    "completed_at": "datetime"
  }'
  
  # Pass custom schema via environment variable and forward args
  export GITMONKEY_CUSTOM_SCHEMA="$todo_schema"
  ./commands/starter/tools/crud_generator.sh "$@" --table todos
}

# Function to generate a blog app
generate_blog_app() {
  echo "🚀 Generating Blog App..."
  
  # Call CRUD generator with Blog-specific schema for posts
  local posts_schema='{
    "id": "string",
    "title": "string",
    "content": "text",
    "author": "string",
    "published": "boolean",
    "tags": "string[]",
    "created_at": "datetime",
    "updated_at": "datetime"
  }'
  
  # Pass custom schema via environment variable and forward args
  export GITMONKEY_CUSTOM_SCHEMA="$posts_schema"
  ./commands/starter/tools/crud_generator.sh "$@" --table posts
}

# Main function
main() {
  # Check if a command is provided
  if [ -z "$1" ] || [ "$1" = "list" ]; then
    show_generators
    exit 0
  fi

  # Route to the appropriate generator based on the command
  case "$1" in
    crud)
      shift # Remove 'crud' from arguments
      ./commands/starter/tools/crud_generator.sh "$@"
      ;;
    todo)
      shift # Remove 'todo' from arguments
      generate_todo_app "$@"
      ;;
    blog)
      shift # Remove 'blog' from arguments
      generate_blog_app "$@"
      ;;
    auth)
      shift # Remove 'auth' from arguments
      echo "🔒 Auth generator coming soon!"
      echo "Try: gitmonkey generate crud --table users"
      exit 0
      ;;
    store)
      shift # Remove 'store' from arguments
      echo "🛒 Store generator coming soon!"
      echo "Try: gitmonkey generate crud --table products"
      exit 0
      ;;
    theme)
      # Allow changing theme preference
      echo "🎨 Changing theme preference..."
      ./commands/starter/tools/crud_generator.sh --change-theme
      exit 0
      ;;
    *)
      echo "❌ Unknown generator: $1"
      show_generators
      exit 1
      ;;
  esac
}

# Execute main function with all args
main "$@"
