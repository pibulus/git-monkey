#!/bin/bash

# ========= GIT MONKEY PROJECT STARTER =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"



source ./commands/starter/starter_config.sh

# Source all modules
source ./commands/starter/frameworks/svelte_setup.sh
source ./commands/starter/frameworks/svelte_modern.sh
source ./commands/starter/frameworks/node_setup.sh
source ./commands/starter/frameworks/static_setup.sh
source ./commands/starter/ui/tailwind_setup.sh
source ./commands/starter/ui/daisyui_setup.sh
source ./commands/starter/ui/skeleton_setup.sh
source ./commands/starter/ui/shoelace_setup.sh
source ./commands/starter/ui/flowbite_setup.sh
source ./commands/starter/backends/supabase_setup.sh
source ./commands/starter/backends/xata_setup.sh
source ./commands/starter/extras/eslint_prettier_setup.sh
source ./commands/starter/extras/github_setup.sh

display_splash "$THEME"
ascii_spell "Create a new project with Soft Stack magic"

# Function to parse command-line arguments
parse_args() {
  POSITIONAL_ARGS=()
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      --preset)
        PRESET_NAME="$2"
        shift
        shift
        ;;
      --minimal)
        HEADLESS_MODE=true
        shift
        ;;
      --private)
        IS_PRIVATE_REPO=true
        shift
        ;;
      -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
      *)
        POSITIONAL_ARGS+=("$1") # Save positional args
        shift
        ;;
    esac
  done
  
  set -- "${POSITIONAL_ARGS[@]}" # Restore positional args
  
  # Get project name from positional args or prompt
  if [ -n "$1" ]; then
    PROJECT_NAME="$1"
  fi
}

# Function to get project name if not provided
get_project_name() {
  if [ -z "$PROJECT_NAME" ]; then
    read -p "🚀 Enter project name: " PROJECT_NAME
    
    if [ -z "$PROJECT_NAME" ]; then
      echo "❌ Project name is required."
      exit 1
    fi
  fi
  
  # Create project path
  PROJECT_PATH="$(pwd)/$PROJECT_NAME"
  
  # Check if directory already exists
  if [ -d "$PROJECT_PATH" ]; then
    read -p "⚠️ Directory already exists. Use it anyway? (y/n): " use_existing
    if [[ ! "$use_existing" =~ ^[Yy]$ ]]; then
      echo "Exiting..."
      exit 0
    fi
  fi
}

# Function to choose a framework
choose_framework() {
  if [ -n "$PRESET_NAME" ]; then
    # Load from preset
    load_preset "$PRESET_NAME"
    
    echo "✅ Loaded framework type from preset: $FRAMEWORK_TYPE"
  elif [ "$HEADLESS_MODE" = true ]; then
    # Use default
    FRAMEWORK_TYPE="svelte"
    echo "✅ Using default framework type: $FRAMEWORK_TYPE"
  else
    # Interactive mode
    echo ""
    box "Choose a Framework"
    PS3=$'\nSelect a framework type: '
    options=("SvelteKit (standard)" "SvelteKit (modern w/ server actions)" "Node.js (backend/CLI)" "Static Site (HTML/CSS/JS)")
    select opt in "${options[@]}"; do
      case $REPLY in
        1) FRAMEWORK_TYPE="svelte"; break ;;
        2) FRAMEWORK_TYPE="svelte-modern"; break ;;
        3) FRAMEWORK_TYPE="node"; break ;;
        4) FRAMEWORK_TYPE="static"; break ;;
        *) echo "Please enter a valid option (1-4)." ;;
      esac
    done
  fi
}

# Function to choose UI options
choose_ui_options() {
  if [ -n "$PRESET_NAME" ] || [ "$HEADLESS_MODE" = true ]; then
    # Options already set from preset or using defaults
    echo "✅ UI options set: Tailwind = $USE_TAILWIND, UI Kit = $UI_KIT"
  else
    # Interactive mode
    echo ""
    read -p "🎨 Do you want to use Tailwind CSS? (y/n): " use_tailwind
    if [[ "$use_tailwind" =~ ^[Yy]$ ]]; then
      USE_TAILWIND=true
      
      echo ""
      box "Choose a UI Kit"
      PS3=$'\nSelect a UI kit: '
      
      # Adjust options based on framework
      if [ "$FRAMEWORK_TYPE" = "svelte" ]; then
        options=(
          "DaisyUI (lightweight components)" 
          "Skeleton (made for SvelteKit)" 
          "Flowbite (feature-rich components)" 
          "Shoelace (framework-agnostic web components)"
          "None (just Tailwind)"
        )
        select opt in "${options[@]}"; do
          case $REPLY in
            1) UI_KIT="daisyui"; break ;;
            2) UI_KIT="skeleton"; break ;;
            3) UI_KIT="flowbite"; break ;;
            4) UI_KIT="shoelace"; break ;;
            5) UI_KIT="none"; break ;;
            *) echo "Please enter a valid option (1-5)." ;;
          esac
        done
      else
        # For non-Svelte projects
        options=(
          "DaisyUI (lightweight components)" 
          "Flowbite (feature-rich components)" 
          "Shoelace (framework-agnostic web components)"
          "None (just Tailwind)"
        )
        select opt in "${options[@]}"; do
          case $REPLY in
            1) UI_KIT="daisyui"; break ;;
            2) UI_KIT="flowbite"; break ;;
            3) UI_KIT="shoelace"; break ;;
            4) UI_KIT="none"; break ;;
            *) echo "Please enter a valid option (1-4)." ;;
          esac
        done
      fi
    else
      USE_TAILWIND=false
      UI_KIT="none"
    fi
  fi
}

# Function to choose backend options
choose_backend() {
  if [ -n "$PRESET_NAME" ] || [ "$HEADLESS_MODE" = true ]; then
    # Options already set from preset or using defaults
    echo "✅ Backend set: $BACKEND_TYPE"
  else
    # Interactive mode
    echo ""
    box "Choose a Backend"
    PS3=$'\nSelect a backend service: '
    options=(
      "Supabase (auth, DB, storage)" 
      "Xata (serverless DB, full-text search)" 
      "None (no backend)"
    )
    select opt in "${options[@]}"; do
      case $REPLY in
        1) BACKEND_TYPE="supabase"; break ;;
        2) BACKEND_TYPE="xata"; break ;;
        3) BACKEND_TYPE="none"; break ;;
        *) echo "Please enter a valid option (1-3)." ;;
      esac
    done
  fi
}

# Function to choose extra options
choose_extras() {
  if [ -n "$PRESET_NAME" ] || [ "$HEADLESS_MODE" = true ]; then
    # Options already set from preset or using defaults
    echo "✅ Extras set: ESLint = $USE_ESLINT, Prettier = $USE_PRETTIER, GitHub = $CREATE_GITHUB_REPO"
  else
    # Interactive mode
    echo ""
    box "Choose Extra Features"
    
    read -p "🧹 Add ESLint for code linting? (y/n): " use_eslint
    if [[ "$use_eslint" =~ ^[Yy]$ ]]; then
      USE_ESLINT=true
    fi
    
    read -p "✨ Add Prettier for code formatting? (y/n): " use_prettier
    if [[ "$use_prettier" =~ ^[Yy]$ ]]; then
      USE_PRETTIER=true
    fi
    
    read -p "🐙 Create GitHub repository? (y/n): " create_github
    if [[ "$create_github" =~ ^[Yy]$ ]]; then
      CREATE_GITHUB_REPO=true
      
      read -p "🔒 Make the repository private? (y/n): " is_private
      if [[ "$is_private" =~ ^[Yy]$ ]]; then
        IS_PRIVATE_REPO=true
      else
        IS_PRIVATE_REPO=false
      fi
    fi
    
    if command -v code &> /dev/null; then
      read -p "💻 Open project in VS Code when done? (y/n): " open_vscode
      if [[ "$open_vscode" =~ ^[Yy]$ ]]; then
        LAUNCH_VSCODE=true
      fi
    fi
    
    read -p "🚀 Start development server when done? (y/n): " start_dev
    if [[ "$start_dev" =~ ^[Yy]$ ]]; then
      START_DEV_SERVER=true
    fi
  fi
}

# Function to handle project creation
create_project() {
  # Create project directory if it doesn't exist
  mkdir -p "$PROJECT_PATH"
  
  # Create project based on framework type
  case "$FRAMEWORK_TYPE" in
    svelte)
      echo ""
      typewriter "🚀 Creating SvelteKit project..." 0.02
      setup_sveltekit "$PROJECT_NAME" "$PROJECT_PATH" || {
        echo "❌ Failed to set up SvelteKit project."
        exit 1
      }
      ;;
    svelte-modern)
      echo ""
      typewriter "🚀 Creating Modern SvelteKit project with server actions..." 0.02
      setup_modern_sveltekit "$PROJECT_NAME" "$PROJECT_PATH" || {
        echo "❌ Failed to set up Modern SvelteKit project."
        exit 1
      }
      ;;
    node)
      echo ""
      typewriter "🚀 Creating Node.js project..." 0.02
      setup_node "$PROJECT_NAME" "$PROJECT_PATH" true || {
        echo "❌ Failed to set up Node.js project."
        exit 1
      }
      ;;
    static)
      echo ""
      typewriter "🚀 Creating Static Site project..." 0.02
      setup_static "$PROJECT_NAME" "$PROJECT_PATH" || {
        echo "❌ Failed to set up Static Site project."
        exit 1
      }
      ;;
    *)
      echo "❌ Unknown framework type: $FRAMEWORK_TYPE"
      exit 1
      ;;
  esac
}

# Function to set up UI
setup_ui() {
  if [ "$USE_TAILWIND" = true ]; then
    echo ""
    typewriter "🎨 Setting up Tailwind CSS..." 0.02
    setup_tailwind "$PROJECT_PATH" "$FRAMEWORK_TYPE" || {
      echo "❌ Failed to set up Tailwind CSS."
    }
    
    # Set up the selected UI kit
    case "$UI_KIT" in
      daisyui)
        echo ""
        typewriter "🧩 Setting up DaisyUI components..." 0.02
        setup_daisyui "$PROJECT_PATH" "$FRAMEWORK_TYPE" || {
          echo "❌ Failed to set up DaisyUI."
        }
        ;;
        
      skeleton)
        echo ""
        typewriter "🧩 Setting up Skeleton UI components..." 0.02
        setup_skeleton "$PROJECT_PATH" "$FRAMEWORK_TYPE" || {
          echo "❌ Failed to set up Skeleton UI."
        }
        ;;
        
      flowbite)
        echo ""
        typewriter "🧩 Setting up Flowbite components..." 0.02
        setup_flowbite "$PROJECT_PATH" "$FRAMEWORK_TYPE" || {
          echo "❌ Failed to set up Flowbite."
        }
        ;;
        
      shoelace)
        echo ""
        typewriter "🧩 Setting up Shoelace web components..." 0.02
        setup_shoelace "$PROJECT_PATH" "$FRAMEWORK_TYPE" || {
          echo "❌ Failed to set up Shoelace."
        }
        ;;
        
      none)
        echo ""
        typewriter "✅ Using Tailwind CSS without additional UI components." 0.02
        ;;
        
      *)
        echo ""
        typewriter "⚠️ Unknown UI kit specified: $UI_KIT. Using just Tailwind CSS." 0.02
        ;;
    esac
  fi
}

# Function to set up backend
setup_backend() {
  if [ -n "$BACKEND_TYPE" ] && [ "$BACKEND_TYPE" != "none" ]; then
    echo ""
    typewriter "🔌 Setting up backend: $BACKEND_TYPE..." 0.02
    
    case "$BACKEND_TYPE" in
      supabase)
        setup_supabase "$PROJECT_PATH" "$FRAMEWORK_TYPE" || {
          echo "❌ Failed to set up Supabase."
        }
        ;;
      xata)
        setup_xata "$PROJECT_PATH" "$FRAMEWORK_TYPE" || {
          echo "❌ Failed to set up Xata."
        }
        ;;
      *)
        echo "❌ Unknown backend type: $BACKEND_TYPE"
        ;;
    esac
  fi
}

# Function to set up extras
setup_extras() {
  if [ "$USE_ESLINT" = true ] || [ "$USE_PRETTIER" = true ]; then
    echo ""
    typewriter "🧹 Setting up code quality tools..." 0.02
    setup_eslint_prettier "$PROJECT_PATH" "$FRAMEWORK_TYPE" || {
      echo "❌ Failed to set up ESLint and Prettier."
    }
  fi
  
  if [ "$CREATE_GITHUB_REPO" = true ]; then
    echo ""
    typewriter "🐙 Setting up GitHub repository..." 0.02
    setup_github "$PROJECT_NAME" "$PROJECT_PATH" "$IS_PRIVATE_REPO" || {
      echo "❌ Failed to set up GitHub repository."
    }
  fi
}

# Function to finalize and launch
finalize_project() {
  echo ""
  rainbow_box "✅ Project $PROJECT_NAME created successfully!"
  echo ""
  
  # Save as preset if requested and not using an existing preset
  if [ -z "$PRESET_NAME" ] && [ "$HEADLESS_MODE" != true ]; then
    read -p "💾 Would you like to save these settings as a preset for future projects? (y/n): " save_as_preset
    if [[ "$save_as_preset" =~ ^[Yy]$ ]]; then
      read -p "Enter a name for this preset (default: 'default'): " preset_name
      save_preset "${preset_name:-default}"
    fi
  fi
  
  # Launch VS Code if requested
  if [ "$LAUNCH_VSCODE" = true ] && command -v code &> /dev/null; then
    echo "🚀 Opening project in VS Code..."
    code "$PROJECT_PATH"
  fi
  
  # Start development server if requested
  if [ "$START_DEV_SERVER" = true ]; then
    echo "🚀 Starting development server..."
    cd "$PROJECT_PATH"
    
    case "$FRAMEWORK_TYPE" in
      svelte)
        echo "Running: npm run dev -- --open"
        npm run dev -- --open
        ;;
      node)
        if grep -q "\"dev\":" "package.json"; then
          echo "Running: npm run dev"
          npm run dev
        else
          echo "Running: node index.js"
          node index.js
        fi
        ;;
      static)
        if command -v npx &> /dev/null; then
          echo "Running: npx serve"
          npx serve
        else
          echo "To start a local server, run: npx serve"
        fi
        ;;
    esac
  else
    # Just provide instructions
    echo "📝 Getting Started:"
    echo "  cd $PROJECT_NAME"
    
    case "$FRAMEWORK_TYPE" in
      svelte)
        echo "  npm run dev -- --open"
        ;;
      node)
        if grep -q "\"dev\":" "$PROJECT_PATH/package.json"; then
          echo "  npm run dev"
        else
          echo "  node index.js"
        fi
        ;;
      static)
        echo "  npx serve  # To start a local server"
        ;;
    esac
  fi
  
  echo ""
  echo "$(display_success "$THEME")"
  echo ""
}

# Main function to orchestrate the process
main() {
  # Parse command-line arguments
  parse_args "$@"
  
  # Initialize project variables
  init_project_vars
  
  # Get project name
  get_project_name
  
  # Choose framework
  choose_framework
  
  # Choose UI options
  choose_ui_options
  
  # Choose backend
  choose_backend
  
  # Choose extras
  choose_extras
  
  # Print project summary
  print_summary
  
  # Confirm project creation
  if [ "$HEADLESS_MODE" != true ]; then
    read -p "🚀 Ready to create your project! Proceed? (y/n): " proceed
    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
      echo "Project creation cancelled."
      exit 0
    fi
  fi
  
  # Create the project
  create_project
  
  # Set up UI
  setup_ui
  
  # Set up backend
  setup_backend
  
  # Set up extras
  setup_extras
  
  # Finalize and launch
  finalize_project
}

# Run the main function with all arguments
main "$@"
