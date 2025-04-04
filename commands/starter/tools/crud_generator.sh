#!/bin/bash

# ========= GIT MONKEY CRUD GENERATOR =========
# Generates ready-to-use, working CRUD templates based on framework and backend

# Source utilities
source ./utils/style.sh
source ./utils/config.sh
source ./commands/starter/starter_config.sh

# Default values
DEFAULT_TABLE_NAME="crudTable"
MINIMAL_MODE=false
FORMLESS_MODE=false
MOCK_DATA_MODE=false
SHOW_HELP=false
DETECTED_SCHEMA=""
THEME="default"
CHANGE_THEME=false

# Function to parse command-line arguments
parse_crud_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --minimal)
        MINIMAL_MODE=true
        shift
        ;;
      --formless)
        FORMLESS_MODE=true
        shift
        ;;
      --mock)
        MOCK_DATA_MODE=true
        shift
        ;;
      --table)
        TABLE_NAME="$2"
        shift
        shift
        ;;
      --help)
        SHOW_HELP=true
        shift
        ;;
      --theme)
        THEME="$2"
        shift
        shift
        ;;
      --change-theme)
        CHANGE_THEME=true
        shift
        ;;
      *)
        # Assume positional arguments: project_path backend_type framework_type table_name
        if [ -z "$PROJECT_PATH" ]; then
          PROJECT_PATH="$1"
        elif [ -z "$BACKEND_TYPE" ]; then
          BACKEND_TYPE="$1"
        elif [ -z "$FRAMEWORK_TYPE" ]; then
          FRAMEWORK_TYPE="$1"
        elif [ -z "$TABLE_NAME" ]; then
          TABLE_NAME="$1"
        fi
        shift
        ;;
    esac
  done

  # Set defaults if values aren't provided
  TABLE_NAME="${TABLE_NAME:-$DEFAULT_TABLE_NAME}"
  
  # Validate theme
  if [ "$THEME" != "default" ] && [ "$THEME" != "hacker" ] && [ "$THEME" != "jungle" ] && [ "$THEME" != "zen" ]; then
    echo "⚠️ Unknown theme: $THEME. Using default theme."
    THEME="default"
  fi
}

# Function to validate inputs
validate_inputs() {
  # Validate project path
  if [ -z "$PROJECT_PATH" ]; then
    handle_error "Project path is required."
    return 1
  fi

  if [ ! -d "$PROJECT_PATH" ]; then
    handle_error "Project directory does not exist: $PROJECT_PATH"
    return 1
  fi

  # Validate backend type
  if [ -z "$BACKEND_TYPE" ]; then
    select_backend
    if [ -z "$BACKEND_TYPE" ]; then
      handle_error "Backend type is required (xata or supabase)."
      return 1
    fi
  fi

  if [ "$BACKEND_TYPE" != "xata" ] && [ "$BACKEND_TYPE" != "supabase" ]; then
    handle_error "Backend type must be 'xata' or 'supabase'."
    return 1
  fi

  # Validate framework type
  if [ -z "$FRAMEWORK_TYPE" ]; then
    select_framework
    if [ -z "$FRAMEWORK_TYPE" ]; then
      handle_error "Framework type is required (svelte, node, or static)."
      return 1
    fi
  fi

  if [ "$FRAMEWORK_TYPE" != "svelte" ] && [ "$FRAMEWORK_TYPE" != "node" ] && [ "$FRAMEWORK_TYPE" != "static" ]; then
    handle_error "Framework type must be 'svelte', 'node', or 'static'."
    return 1
  fi

  # Validate table name (simple validation)
  if [[ ! "$TABLE_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
    handle_error "Table name must contain only letters, numbers, and underscores."
    return 1
  fi

  return 0
}

# Function to handle errors
handle_error() {
  local error_message="$1"
  echo "❌ Error: $error_message"
  
  # Suggest fixes based on error type
  if [[ "$error_message" == *"Backend type"* ]]; then
    echo "ℹ️ Available backend types:"
    echo "   - xata: Serverless database with search functionality 🔍"
    echo "   - supabase: Firebase alternative with PostgreSQL power 🔥"
  elif [[ "$error_message" == *"Framework type"* ]]; then
    echo "ℹ️ Available framework types:"
    echo "   - svelte: Full-stack framework with routing and backend (recommended) ⚡"
    echo "   - node: Backend-focused framework for APIs and custom servers 🔧"
    echo "   - static: Simple HTML/CSS/JS for frontend-only demos 🍭"
  elif [[ "$error_message" == *"Project directory"* ]]; then
    echo "ℹ️ Make sure to run this command from your project's root directory"
  fi
  
  return 1
}

# Theme-specific styling functions
# ===========================

# Apply theme-specific styling to text
theme_text() {
  local text="$1"
  
  case "$THEME" in
    hacker)
      # Green hacker text
      echo -e "\e[32m$text\e[0m"
      ;;
    jungle)
      # Yellowish-green jungle text
      echo -e "\e[33m$text\e[0m"
      ;;
    zen)
      # Soft blue zen text
      echo -e "\e[38;5;111m$text\e[0m"
      ;;
    *)
      # Default - no special coloring
      echo "$text"
      ;;
  esac
}

# Create a theme-specific box
theme_box() {
  local title="$1"
  
  case "$THEME" in
    hacker)
      echo -e "\e[32m┌───────────[ $title ]───────────┐"
      echo "│                                  │"
      echo "└──────────────────────────────────┘\e[0m"
      ;;
    jungle)
      echo -e "\e[33m~*~*~*~*~*~*~ $title ~*~*~*~*~*~*~"
      echo "     (🍌)      (🐒)      (🌴)     "
      echo "~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~\e[0m"
      ;;
    zen)
      echo -e "\e[38;5;111m                                  "
      echo "       ✧ $title ✧       "
      echo "                                  \e[0m"
      ;;
    *)
      # Default - use standard box
      box "$title"
      ;;
  esac
}

# Theme-specific typewriter effect
theme_typewriter() {
  local text="$1"
  local speed="${2:-0.03}"
  
  case "$THEME" in
    hacker)
      # Faster, hacker-style typing
      for i in $(seq 0 ${#text}); do
        echo -ne "\e[32m${text:0:$i}\e[0m"
        echo -ne "\r"
        sleep $(echo "$speed / 2" | bc -l)
      done
      echo -e "\e[32m$text\e[0m"
      ;;
    jungle)
      # Normal speed with jungle color
      for i in $(seq 0 ${#text}); do
        echo -ne "\e[33m${text:0:$i}\e[0m"
        echo -ne "\r"
        sleep $speed
      done
      echo -e "\e[33m$text\e[0m"
      ;;
    zen)
      # Slower, more deliberate pace for zen
      for i in $(seq 0 ${#text}); do
        echo -ne "\e[38;5;111m${text:0:$i}\e[0m"
        echo -ne "\r"
        sleep $(echo "$speed * 1.5" | bc -l)
      done
      echo -e "\e[38;5;111m$text\e[0m"
      ;;
    *)
      # Default - use standard typewriter
      typewriter "$text" "$speed"
      ;;
  esac
}

# Theme-specific success message
theme_success_message() {
  case "$THEME" in
    hacker)
      echo "MISSION ACCOMPLISHED. ACCESS GRANTED."
      ;;
    jungle)
      echo "🐒 Oo-oo ah-ah! Your code is swinging from the vines!"
      ;;
    zen)
      echo "✨ The path is clear. Your journey continues."
      ;;
    *)
      echo "✅ CRUD scaffolding complete! Go forth and monkey around."
      ;;
  esac
}

# Theme-specific failure message
theme_failure_message() {
  case "$THEME" in
    hacker)
      echo "SYSTEM FAILURE. REBOOT SEQUENCE INITIATED."
      ;;
    jungle)
      echo "🙈 Monkey fumbled! Watch out for those banana peels!"
      ;;
    zen)
      echo "🌿 A moment of pause. The path needs clearing."
      ;;
    *)
      echo "❌ Hmm... we hit a banana peel. Let's try another approach."
      ;;
  esac
}

# Function to select a backend with explanatory tooltips
select_backend() {
  echo ""
  theme_box "Choose a Backend"
  echo ""
  
  case "$THEME" in
    hacker)
      echo -e "\e[32m[1] SUPABASE   – POSTGRESQL DATABASE SYSTEM\e[0m"
      echo -e "\e[32m     > AUTH, STORAGE, REALTIME DATA CAPABILITIES\e[0m"
      echo ""
      echo -e "\e[32m[2] XATA       – SERVERLESS DATABASE PLATFORM\e[0m"
      echo -e "\e[32m     > SEARCH FUNCTIONALITY, ANALYTICS ENGINE\e[0m"
      ;;
    jungle)
      echo -e "\e[33m[1] Supabase   – The mighty jungle SQL tree 🌳\e[0m"
      echo -e "\e[33m     🔥 Big banana features: auth, storage, realtime updates\e[0m"
      echo ""
      echo -e "\e[33m[2] Xata       – The quick vine climber 🦥\e[0m"
      echo -e "\e[33m     🔍 Perfect for when monkeys need to find things fast\e[0m"
      ;;
    zen)
      echo -e "\e[38;5;111m[1] Supabase   ✧ The flowing river (complete ecosystem)\e[0m"
      echo -e "\e[38;5;111m     ✨ Contains many waters: auth, storage, subscriptions\e[0m"
      echo ""
      echo -e "\e[38;5;111m[2] Xata       ✧ The quiet pond (focused simplicity)\e[0m"
      echo -e "\e[38;5;111m     🔍 Reflects what you seek with its search abilities\e[0m"
      ;;
    *)
      echo "[1] Supabase   – Firebase alternative with SQL power"
      echo "     🔥 Auth, storage, realtime subscriptions included"
      echo ""
      echo "[2] Xata       – Serverless database with search"
      echo "     🔍 Great for apps that need search functionality"
      ;;
  esac
  echo ""
  
  # Custom PS3 prompt based on theme
  case "$THEME" in
    hacker)
      PS3=$'\n\e[32mSELECT DATABASE [1-2]:\e[0m '
      ;;
    jungle)
      PS3=$'\n\e[33mSwing to which database? [1-2]:\e[0m '
      ;;
    zen)
      PS3=$'\n\e[38;5;111mWhich path calls to you? [1-2]:\e[0m '
      ;;
    *)
      PS3=$'\nSelect a backend: '
      ;;
  esac
  
  options=("Supabase" "Xata")
  select opt in "${options[@]}"; do
    case $REPLY in
      1) 
        BACKEND_TYPE="supabase"
        case "$THEME" in
          hacker)
            echo -e "\e[32m✓ SUPABASE SELECTED: POSTGRESQL-BASED DATABASE SYSTEM ACTIVATED\e[0m"
            ;;
          jungle)
            echo -e "\e[33m🌴 Supabase jungle selected! Big tree with lots of bananas!\e[0m"
            ;;
          zen)
            echo -e "\e[38;5;111m✨ Supabase chosen. You flow with the river of features.\e[0m"
            ;;
          *)
            echo "✅ Selected Supabase: An open source Firebase alternative with PostgreSQL database"
            ;;
        esac
        break 
        ;;
      2) 
        BACKEND_TYPE="xata"
        case "$THEME" in
          hacker)
            echo -e "\e[32m✓ XATA SELECTED: SERVERLESS DATABASE WITH SEARCH CAPABILITIES ENGAGED\e[0m"
            ;;
          jungle)
            echo -e "\e[33m🦥 Xata vines selected! Quick and nimble with great search powers!\e[0m"
            ;;
          zen)
            echo -e "\e[38;5;111m✨ Xata chosen. The pond reflects what you seek.\e[0m"
            ;;
          *)
            echo "✅ Selected Xata: A serverless database platform with built-in search and analytics"
            ;;
        esac
        break 
        ;;
      *) 
        case "$THEME" in
          hacker)
            echo -e "\e[31mINVALID SELECTION. ENTER VALUE BETWEEN 1-2.\e[0m"
            ;;
          jungle)
            echo "🙈 Oops! That's not a vine we can swing on. Choose 1 or 2!"
            ;;
          zen)
            echo "🌿 This path is not visible to us. Please choose 1 or 2."
            ;;
          *)
            echo "Please enter a valid option (1-2)."
            ;;
        esac
        ;;
    esac
  done
  
  # Small pause to let the user read the description
  sleep 1
}

# Function to select a framework with explanatory tooltips
select_framework() {
  echo ""
  theme_box "Choose a Framework"
  echo ""
  
  case "$THEME" in
    hacker)
      echo -e "\e[32m[1] SVELTEKIT  – FULL-STACK FRAMEWORK [RECOMMENDED]\e[0m"
      echo -e "\e[32m     > COMPREHENSIVE APP DEVELOPMENT WITH ROUTING AND BACKEND\e[0m"
      echo ""
      echo -e "\e[32m[2] NODE.JS    – SERVER FRAMEWORK WITH MANUAL CONTROL\e[0m"
      echo -e "\e[32m     > BACKEND APIS AND CUSTOM SERVER IMPLEMENTATION\e[0m"
      echo ""
      echo -e "\e[32m[3] STATIC     – PURE CLIENT-SIDE IMPLEMENTATION\e[0m"
      echo -e "\e[32m     > HTML/CSS/JS FOR FRONTEND PRESENTATION LAYER\e[0m"
      ;;
    jungle)
      echo -e "\e[33m[1] SvelteKit  – The whole jungle package (recommended)\e[0m"
      echo -e "\e[33m     🍌 For monkey business with all the bells and whistles\e[0m"
      echo ""
      echo -e "\e[33m[2] Node.js    – Just the jungle floor, you build the trees\e[0m"
      echo -e "\e[33m     🌱 For monkeys who like to craft their own vines\e[0m"
      echo ""
      echo -e "\e[33m[3] Static     – Just the treetops, no roots\e[0m"
      echo -e "\e[33m     🌞 Simple jungle canopy, perfect for showing off\e[0m"
      ;;
    zen)
      echo -e "\e[38;5;111m[1] SvelteKit  ✧ The complete journey (recommended)\e[0m"
      echo -e "\e[38;5;111m     ⚡ A path with both contemplation and action\e[0m"
      echo ""
      echo -e "\e[38;5;111m[2] Node.js    ✧ The mindful craftsman's way\e[0m"
      echo -e "\e[38;5;111m     🔧 For those who seek control over their path\e[0m"
      echo ""
      echo -e "\e[38;5;111m[3] Static     ✧ The simple essence\e[0m"
      echo -e "\e[38;5;111m     🍃 Pure form without complexity or attachment\e[0m"
      ;;
    *)
      echo "[1] SvelteKit  – Our default full-stack setup (recommended)"
      echo "     ⚡ For building full apps with routing, backend, etc."
      echo ""
      echo "[2] Node.js    – Just the backend, more control if you know what you're doing"
      echo "     🔧 Great for custom APIs and servers"
      echo ""
      echo "[3] Static     – Just HTML, CSS, JS. No backend."
      echo "     🍭 Super simple, for frontend-only demos"
      ;;
  esac
  echo ""
  
  # Custom PS3 prompt based on theme
  case "$THEME" in
    hacker)
      PS3=$'\n\e[32mSELECT FRAMEWORK [1-3]:\e[0m '
      ;;
    jungle)
      PS3=$'\n\e[33mWhich jungle path? [1-3]:\e[0m '
      ;;
    zen)
      PS3=$'\n\e[38;5;111mWhich way resonates with you? [1-3]:\e[0m '
      ;;
    *)
      PS3=$'\nSelect a framework: '
      ;;
  esac
  
  options=("SvelteKit" "Node.js" "Static")
  select opt in "${options[@]}"; do
    case $REPLY in
      1) 
        FRAMEWORK_TYPE="svelte"
        case "$THEME" in
          hacker)
            echo -e "\e[32m✓ SVELTEKIT SELECTED: FULL-STACK FRAMEWORK INITIALIZED\e[0m"
            ;;
          jungle)
            echo -e "\e[33m🌴 SvelteKit jungle selected! The complete monkey experience!\e[0m"
            ;;
          zen)
            echo -e "\e[38;5;111m✨ SvelteKit chosen. A balanced path of frontend and backend.\e[0m"
            ;;
          *)
            echo "✅ Selected SvelteKit: A modern meta-framework for building full-stack web applications with server rendering"
            ;;
        esac
        break 
        ;;
      2) 
        FRAMEWORK_TYPE="node"
        case "$THEME" in
          hacker)
            echo -e "\e[32m✓ NODE.JS SELECTED: SERVER-SIDE JAVASCRIPT RUNTIME ENGAGED\e[0m"
            ;;
          jungle)
            echo -e "\e[33m🌱 Node.js jungle floor selected! Build your own trees!\e[0m"
            ;;
          zen)
            echo -e "\e[38;5;111m✨ Node.js chosen. The craftsman's path of backend mastery.\e[0m"
            ;;
          *)
            echo "✅ Selected Node.js: A JavaScript runtime for building backend applications and APIs"
            ;;
        esac
        break 
        ;;
      3) 
        FRAMEWORK_TYPE="static" 
        case "$THEME" in
          hacker)
            echo -e "\e[32m✓ STATIC SELECTED: CLIENT-SIDE ONLY IMPLEMENTATION ENGAGED\e[0m"
            ;;
          jungle)
            echo -e "\e[33m🌞 Static treetops selected! Simple but beautiful canopy!\e[0m"
            ;;
          zen)
            echo -e "\e[38;5;111m✨ Static chosen. The pure essence of frontend, free from complexity.\e[0m"
            ;;
          *)
            echo "✅ Selected Static: Pure HTML, CSS, and JavaScript for simple websites with no server-side processing"
            ;;
        esac
        break 
        ;;
      *) 
        case "$THEME" in
          hacker)
            echo -e "\e[31mINVALID SELECTION. ENTER VALUE BETWEEN 1-3.\e[0m"
            ;;
          jungle)
            echo "🙈 Oops! That path doesn't exist in our jungle. Choose 1-3!"
            ;;
          zen)
            echo "🌿 This number does not align with available paths. Please choose 1, 2, or 3."
            ;;
          *)
            echo "Please enter a valid option (1-3)."
            ;;
        esac
        ;;
    esac
  done
  
  # Small pause to let the user read the description
  sleep 1
}

# Function to show help
show_help() {
  echo ""
  theme_box "Git Monkey CRUD Generator"
  echo ""
  theme_text "Usage:"
  echo "  gitmonkey generate crud [options] [project_path] [backend_type] [framework_type] [table_name]"
  echo ""
  theme_text "Examples:"
  echo "  gitmonkey generate crud                        # Interactive mode"
  echo "  gitmonkey generate crud ./my-project           # Start with project path"
  echo "  gitmonkey generate crud ./project xata svelte users # Specify all parameters"
  echo ""
  theme_text "Options:"
  echo "  --minimal     Generate minimal CRUD (no extra features)"
  echo "  --formless    Generate API endpoints only (no UI forms)"
  echo "  --mock        Include mock data in the generated CRUD"
  echo "  --table NAME  Specify table name"
  echo "  --help        Show this help message"
  echo "  --theme TYPE  Choose visual theme (default, hacker, jungle, zen)"
  echo ""
  theme_text "Backends:"
  echo "  • xata     - Serverless database with search 🔍"
  echo "  • supabase - Firebase alternative with PostgreSQL power 🔥"
  echo ""
  theme_text "Frameworks:"
  echo "  • svelte - Full-stack framework with routing (recommended) ⚡"
  echo "  • node   - Backend-focused framework for APIs 🔧"
  echo "  • static - Simple HTML/CSS/JS for frontend demos 🍭"
  echo ""
  theme_text "Themes:"
  echo "  • default - Standard Git Monkey styling"
  echo "  • hacker  - Green glow, boxy retro UI 💻"
  echo "  • jungle  - ASCII vines and bananas 🍌"
  echo "  • zen     - Calm text, spacing, soft styling 🧘"
  echo ""
  echo "Learn more: https://git-monkey.dev/docs/crud-generator"
  echo ""
}

# Function to select a theme interactively
select_theme() {
  clear
  echo ""
  box "🎨 Choose Your Theme Experience"
  echo ""
  echo "Pick a visual theme for your CRUD generation experience:"
  echo ""
  echo "1) 🦍 Default   - Standard Git Monkey experience"
  echo "   Classic Git Monkey styling with colorful boxes and helpful tips"
  echo ""
  echo "2) 💻 Hacker    - Green glow, retro terminal vibes"
  echo "   For when you want to feel like you're in a cyberpunk movie"
  echo ""
  echo "3) 🌴 Jungle    - ASCII vines, bananas, and monkey business"
  echo "   Embrace your inner primate with jungle-themed UI"
  echo ""
  echo "4) 🧘 Zen       - Calm blues, soft spacing, minimal design"
  echo "   A peaceful, distraction-free coding experience"
  echo ""
  
  # Store selection in config file if it exists
  local config_file="$HOME/.gitmonkey/config"
  local config_dir="$HOME/.gitmonkey"
  
  read -p "Select theme [1-4]: " theme_selection
  
  case "$theme_selection" in
    2)
      THEME="hacker"
      echo "🖥️  Hacker theme activated. Welcome to the matrix..."
      ;;
    3)
      THEME="jungle"
      echo "🐒 Jungle theme activated. Oo-oo ah-ah!"
      ;;
    4)
      THEME="zen"
      echo "✨ Zen theme activated. Breathe in... breathe out..."
      ;;
    *)
      THEME="default"
      echo "🦍 Default theme activated. Classic monkey business!"
      ;;
  esac
  
  # Try to save theme preference if directory exists or can be created
  if [ -d "$config_dir" ] || mkdir -p "$config_dir" 2>/dev/null; then
    echo "THEME=\"$THEME\"" > "$config_dir/theme"
    echo "Theme preference saved!"
  fi
  
  sleep 1
  clear
}

# Function to load theme preference
load_theme_preference() {
  local theme_file="$HOME/.gitmonkey/theme"
  
  # Check if theme preference exists
  if [ -f "$theme_file" ]; then
    source "$theme_file"
    echo "🎨 Loaded theme preference: $THEME"
  else
    # If a theme was specified on command line, don't override it
    if [ -z "$THEME" ] || [ "$THEME" = "default" ]; then
      # Ask if first time
      echo "🎨 It looks like this is your first time using the CRUD generator."
      read -p "Would you like to choose a theme? (y/n): " choose_theme
      if [[ "$choose_theme" =~ ^[Yy]$ ]]; then
        select_theme
      else
        THEME="default"
        echo "Using default theme. You can change this later with --theme option."
      fi
    fi
  fi
}

# Main function that's called when script is executed directly
main() {
  # Check for help flag first
  for arg in "$@"; do
    if [ "$arg" = "--help" ]; then
      show_help
      return 0
    fi
  done
  
  # Process command-line arguments
  parse_crud_args "$@"
  
  # Handle theme change request
  if [ "$CHANGE_THEME" = true ]; then
    select_theme
    echo "✨ Theme updated successfully! Your next CRUD generation will use this theme."
    return 0
  fi
  
  # Load theme preference if not explicitly set via command line
  # Only try to load if not set by args (check arg list for --theme)
  if ! echo "$*" | grep -q -- "--theme"; then
    load_theme_preference
  fi
  
  # If no arguments provided, go into full interactive mode
  if [ $# -eq 0 ]; then
    show_intro
    select_project_path || return 1
    select_backend
    select_framework
    
    # Ask for table name
    echo ""
    theme_box "Table Name"
    echo ""
    
    case "$THEME" in
      hacker)
        echo -e "\e[32mENTER TABLE IDENTIFIER:\e[0m"
        ;;
      jungle)
        echo "🐒 What animal species are we tracking in the jungle? (e.g., monkeys, bananas, trees)"
        ;;
      zen)
        echo "✨ What concept shall we bring into form? (e.g., thoughts, journals, projects)"
        ;;
      *)
        echo "What should we name your table? (e.g., users, products, posts)"
        ;;
    esac
    
    read -p "> " input_table
    if [ -n "$input_table" ]; then
      TABLE_NAME="$input_table"
    else
      echo "⚠️ Using default table name: $DEFAULT_TABLE_NAME"
      TABLE_NAME="$DEFAULT_TABLE_NAME"
    fi
  fi
  
  # Validate inputs
  validate_inputs || return 1
  
  # Check for existing schema
  detect_schema "$PROJECT_PATH" "$BACKEND_TYPE" "$TABLE_NAME"
  
  # Generate CRUD
  if generate_crud "$PROJECT_PATH" "$BACKEND_TYPE" "$FRAMEWORK_TYPE" "$TABLE_NAME"; then
    show_success "$TABLE_NAME"
    return 0
  else
    show_failure "Failed to generate CRUD components"
    return 1
  fi
}

# Function to show introduction
show_intro() {
  echo ""
  
  case "$THEME" in
    hacker)
      echo -e "\e[32m"
      cat << 'EOF'
 _____  _____  _   _  _____      _____   _____ 
/  __ \/  __ \| | | ||  _  |    /  ___| |  ___|
| /  \/| |  \/| | | || | | |    \ `--.  | |__  
| |    | | __ | | | || | | |     `--. \ |  __| 
| \__/\| |_\ \| |_| |\ \_/ // /\/\__/ / | |___ 
 \____/ \____/ \___/  \___/ \_/\____/  \____/ 
EOF
      echo -e "\e[0m"
      theme_typewriter "INITIALIZING CRUD SEQUENCE... STAND BY FOR SYSTEM ACCESS" 0.01
      ;;
    jungle)
      echo -e "\e[33m"
      cat << 'EOF'
  ,d88b.d88b,   
  88888888888   
  `Y8888888Y'   
    `Y888Y'     
      `Y'       
    ,--.--._    
---'._`.   |----
       `.  |    
       _.'  |   
-----'-'    `---
EOF
      echo -e "\e[0m"
      theme_typewriter "🌴 Welcome to the jungle! Let's build something wild!" 0.01
      ;;
    zen)
      echo -e "\e[38;5;111m"
      cat << 'EOF'


   _    _    _    _    _  
  / \  / \  / \  / \  / \ 
 ( C )( R )( U )( D )( ~ )
  \_/  \_/  \_/  \_/  \_/ 


EOF
      echo -e "\e[0m"
      theme_typewriter "✨ Welcome to a peaceful journey of creation..." 0.02
      ;;
    *)
      rainbow_box "Welcome to the CRUD Generator"
      typewriter "🧠 CRUD = Create, Read, Update, Delete — the essential building blocks of most apps." 0.01
      ;;
  esac
  
  echo ""
  theme_text "This tool will help you scaffold a complete CRUD interface for your application,"
  theme_text "saving you hours of repetitive coding and letting you focus on what makes your app unique."
  echo ""
  sleep 1
}

# Function to select project path interactively
select_project_path() {
  echo ""
  theme_box "Choose Project Path"
  echo ""
  
  # Default to current directory
  local default_path="$(pwd)"
  
  theme_text "Where should we create your CRUD components?"
  
  case "$THEME" in
    hacker)
      echo "INPUT DESTINATION PATH OR PRESS [ENTER] FOR CURRENT DIRECTORY:"
      ;;
    jungle)
      echo "🌴 Which jungle path should we swing to? (Enter for current tree)"
      ;;
    zen)
      echo "✨ Where shall we plant our garden? (Enter for here)"
      ;;
    *)
      echo "Press Enter to use current directory, or type a different path:"
      ;;
  esac
  
  read -p "> " input_path
  
  # Use default if nothing entered
  PROJECT_PATH="${input_path:-$default_path}"
  
  # Check if directory exists
  if [ ! -d "$PROJECT_PATH" ]; then
    case "$THEME" in
      hacker)
        echo -e "\e[31m⚠️ DIRECTORY NOT FOUND. CREATE NEW? (y/n)\e[0m"
        ;;
      jungle)
        echo "🙊 That tree doesn't exist! Plant a new one? (y/n)"
        ;;
      zen)
        echo "🌱 This path is not yet formed. Shall we create it? (y/n)"
        ;;
      *)
        echo "⚠️ Directory doesn't exist. Create it? (y/n)"
        ;;
    esac
    
    read -p "> " create_dir
    if [[ "$create_dir" =~ ^[Yy]$ ]]; then
      mkdir -p "$PROJECT_PATH" || {
        handle_error "Failed to create directory: $PROJECT_PATH"
        return 1
      }
      
      case "$THEME" in
        hacker)
          echo -e "\e[32m✓ DIRECTORY CREATED: $PROJECT_PATH\e[0m"
          ;;
        jungle)
          echo "🌴 New jungle path created: $PROJECT_PATH"
          ;;
        zen)
          echo "✨ Path formed: $PROJECT_PATH"
          ;;
        *)
          echo "✅ Directory created: $PROJECT_PATH"
          ;;
      esac
    else
      handle_error "Directory must exist to continue"
      return 1
    fi
  fi
  
  case "$THEME" in
    hacker)
      echo -e "\e[32m✓ TARGET ACQUIRED: $PROJECT_PATH\e[0m"
      ;;
    jungle)
      echo "🌴 Swinging to jungle path: $PROJECT_PATH"
      ;;
    zen)
      echo "🧘 Path selected with mindfulness: $PROJECT_PATH"
      ;;
    *)
      echo "✅ Using project path: $PROJECT_PATH"
      ;;
  esac
  
  return 0
}

# Source modern CRUD integrator if it exists
if [ -f "./commands/starter/crud/crud_integrator.sh" ]; then
  source ./commands/starter/crud/crud_integrator.sh
fi

# Call main function passing all arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi