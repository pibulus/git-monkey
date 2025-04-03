#!/bin/bash

# ========= GIT MONKEY WELCOME & ONBOARDING =========
# A delightful first-time experience for new Git Monkey users

source ./utils/style.sh
source ./utils/config.sh
source ./utils/profile.sh
source ./utils/identity.sh
source ./utils/ai_keys.sh
source ./utils/ai_safety.sh

# Get current tone stage and identity
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)

# Default identity if not yet set
IDENTITY=${IDENTITY:-"friend"}

# Initialize variables
FIRST_TIME=true
THEME_SELECTED=false
IDENTITY_SET=false
SKIP_INTRO=false

# Check command line arguments
for arg in "$@"; do
  case "$arg" in
    --skip-intro)
      SKIP_INTRO=true
      shift
      ;;
    --reset)
      # Reset first-time status to run welcome again
      rm -f "$HOME/.gitmonkey/welcomed" 2>/dev/null
      shift
      ;;
  esac
done

# Check if it's the first time running
if [ -f "$HOME/.gitmonkey/welcomed" ]; then
  FIRST_TIME=false
fi

# Check if identity is already set
if [ -f "$HOME/.gitmonkey/identity" ]; then
  IDENTITY_SET=true
fi

# Check if theme is already selected
if [ -f "$HOME/.gitmonkey/theme" ]; then
  THEME_SELECTED=true
fi

# Function to create typing animation with variable speed
typing_speed_animation() {
  local text="$1"
  local min_speed="${2:-0.02}"
  local max_speed="${3:-0.08}"
  
  for ((i=0; i<${#text}; i++)); do
    # Random speed between min and max
    local speed=$(echo "scale=3; $min_speed + ($max_speed - $min_speed) * $RANDOM / 32767" | bc)
    echo -n "${text:$i:1}"
    sleep $speed
  done
  echo ""
}

# Function to pause for dramatic effect with option to skip
dramatic_pause() {
  local duration="${1:-1}"
  
  if [ "$SKIP_INTRO" = false ]; then
    sleep "$duration"
  fi
}

# Function to show a welcoming ASCII art intro
show_intro_animation() {
  clear
  
  # Slow reveal of title - letter by letter across multiple lines
  echo -n "G"
  sleep 0.1
  echo -n "i"
  sleep 0.1
  echo -n "t"
  sleep 0.2
  echo ""
  echo -n "   M"
  sleep 0.1
  echo -n "o"
  sleep 0.1
  echo -n "n"
  sleep 0.1
  echo -n "k"
  sleep 0.1
  echo -n "e"
  sleep 0.1
  echo -n "y"
  sleep 0.3
  
  dramatic_pause 0.5
  clear
  
  # Full title reveal with animation
  echo ""
  echo ""
  
  # Use theme-specific styling if possible
  case "$THEME" in
    "jungle")
      echo -e "\e[33m"  # Jungle yellow color
      cat << 'EOF'
      _____     _  _      __  __                 _              
     / ____|   (_)| |    |  \/  |               | |             
    | |   ___   _ | |_   | \  / |  ___   _ __   | | __  ___  _  _
    | |  / _ \ | || __|  | |\/| | / _ \ | '_ \  | |/ / / _ \| || |
    | |_| (_) || || |_   | |  | || (_) || | | | |   < |  __/| || |
     \____\___/|_| \__|  |_|  |_| \___/ |_| |_| |_|\_\ \___||_||_|
                   🐒  WHERE CODE GETS BANANAS  🍌                      
EOF
      echo -e "\e[0m"
      ;;
    "hacker")
      echo -e "\e[32m"  # Hacker green color
      cat << 'EOF'
  ▄████  ██▓▄▄▄█████▓   ███▄ ▄███▓ ▒█████   ███▄    █  ██ ▄█▀▓█████▓██   ██▓
 ██▒ ▀█▒▓██▒▓  ██▒ ▓▒  ▓██▒▀█▀ ██▒▒██▒  ██▒ ██ ▀█   █  ██▄█▒ ▓█   ▀ ▒██  ██▒
▒██░▄▄▄░▒██▒▒ ▓██░ ▒░  ▓██    ▓██░▒██░  ██▒▓██  ▀█ ██▒▓███▄░ ▒███    ▒██ ██░
░▓█  ██▓░██░░ ▓██▓ ░   ▒██    ▒██ ▒██   ██░▓██▒  ▐▌██▒▓██ █▄ ▒▓█  ▄  ░ ▐██▓░
░▒▓███▀▒░██░  ▒██▒ ░   ▒██▒   ░██▒░ ████▓▒░▒██░   ▓██░▒██▒ █▄░▒████▒ ░ ██▒▓░
 ░▒   ▒ ░▓    ▒ ░░     ░ ▒░   ░  ░░ ▒░▒░▒░ ░ ▒░   ▒ ▒ ▒ ▒▒ ▓▒░░ ▒░ ░  ██▒▒▒ 
  ░   ░  ▒ ░    ░      ░  ░      ░  ░ ▒ ▒░ ░ ░░   ░ ▒░░ ░▒ ▒░ ░ ░  ░▓██ ░▒░ 
░ ░   ░  ▒ ░  ░        ░      ░   ░ ░ ░ ▒     ░   ░ ░ ░ ░░ ░    ░   ▒ ▒ ░░  
      ░  ░                    ░       ░ ░           ░ ░  ░      ░  ░░ ░     
                   [ELEVATED ACCESS TO CODE SYSTEMS]                        
EOF
      echo -e "\e[0m"
      ;;
    "wizard")
      echo -e "\e[35m"  # Wizard purple color
      cat << 'EOF'
                         ✨*✨         
      .*.               ✨✨✨✨.              ✨*✨
    ✨✨✨✨✨            ✨✨✨✨✨✨✨          ✨✨✨✨✨✨
   ✨✨✨✨✨✨✨✨     ✨✨    ✨✨✨✨✨✨✨✨✨✨    ✨✨✨✨✨✨✨✨
    ✨✨✨✨✨✨✨✨✨   ✨✨✨✨   ✨✨✨✨✨✨✨✨✨✨   ✨✨✨✨✨✨✨
      ✨✨✨✨✨✨✨✨  ✨✨✨✨✨✨  ✨✨✨✨✨✨✨✨✨  ✨✨✨✨✨✨✨
        ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨   ✨✨✨✨✨✨✨✨
          ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨    ✨✨✨✨✨✨✨✨✨
            ✨✨✨✨✨✨✨✨✨✨✨✨    ✨✨✨✨✨✨✨✨✨
               ✨✨✨✨✨✨    ✨✨✨✨✨✨✨✨
                        ✨✨✨✨✨   
        ✨✨✨  THE ARCANE ART OF CODE  ✨✨✨
EOF
      echo -e "\e[0m"
      ;;
    "cosmic")
      echo -e "\e[38;5;33m"  # Cosmic blue color
      cat << 'EOF'
                   *       +
             '                  |
         ()    .-.,="``"=.    - o -
               '=/_       \     |
            *   |  '=._    |
                 \     `=./`,        '
              .   '=.__.=' `='      *
     +                         +
          O      *        '       .
     ┌─┐┬┌┬┐  ┌┬┐┌─┐┌┐┌┬┌─┌─┐┬ ┬
     │ ┬│ │    │││ ││││├┴┐├┤ └┬┘
     └─┘┴ ┴   ─┴┘└─┘┘└┘┴ ┴└─┘ ┴ 
      COSMIC VOYAGE THROUGH CODE
EOF
      echo -e "\e[0m"
      ;;
    *)
      # Default colorful ASCII art
      ascii_banner "Git Monkey"
      echo ""
      rainbow_text "WHERE CODE GETS BANANAS"
      ;;
  esac
  
  dramatic_pause 1.5
  echo ""
}

# Function to ask for user's name and personalize the experience with titles
ask_for_identity() {
  if [ "$IDENTITY_SET" = true ]; then
    # Identity already set - just load it
    IDENTITY=$(get_full_identity)
    typing_speed_animation "Welcome back, $IDENTITY! 👋" 0.02 0.05
    return 0
  fi
  
  # Create config directory if it doesn't exist
  mkdir -p "$HOME/.gitmonkey" 2>/dev/null
  
  dramatic_pause 0.5
  typing_speed_animation "Before we start, I'd love to know your name! 😊" 0.03 0.06
  dramatic_pause 0.3
  typing_speed_animation "(This helps me personalize your experience)" 0.02 0.04
  dramatic_pause 0.2
  
  read -p "What can I call you? " user_name
  
  if [ -z "$user_name" ]; then
    # Generate a random anonymous name if user doesn't provide one
    local anon_name=$(get_anonymous_name)
    user_name="$anon_name"
    typing_speed_animation "That's okay! I'll call you '$anon_name' for now." 0.02 0.05
    typing_speed_animation "You can change this anytime with 'gitmonkey identity name'." 0.02 0.04
    # Set name but mark as not custom
    set_user_name "$anon_name" "false"
  else
    typing_speed_animation "Nice to meet you, $user_name! 🎉" 0.02 0.05
    # Set as custom name
    set_user_name "$user_name" "true"
  fi
  
  # Generate and assign a title
  dramatic_pause 0.5
  typing_speed_animation "Now, let me think of a title for you..." 0.03 0.06
  dramatic_pause 1
  
  # Get a title based on current theme and beginning tone stage
  local title=$(get_monkey_title "0" "$THEME")
  set_custom_title "$title"
  
  # Set identity mode to combo (name + title)
  set_identity_mode "3"
  
  # Get the full identity now
  IDENTITY=$(get_full_identity)
  
  # Show the full identity with animation
  typing_speed_animation "💫 From now on, I'll call you:" 0.03 0.06
  dramatic_pause 0.5
  
  # Show with rainbow effect
  rainbow_text "✨ $IDENTITY ✨"
  
  typing_speed_animation "As you use Git Monkey more, you'll earn new titles! 🏆" 0.03 0.05
  typing_speed_animation "You can change this anytime with 'gitmonkey identity'." 0.02 0.04
  
  dramatic_pause 1
  return 0
}

# Function to select and save theme
select_theme() {
  if [ "$THEME_SELECTED" = true ]; then
    # Theme already set - just load it
    THEME=$(get_selected_theme)
    typing_speed_animation "I see you're using the $THEME theme. Good choice! 👍" 0.02 0.05
    return 0
  fi
  
  typing_speed_animation "Let's make Git Monkey feel just right for you, $IDENTITY! 🎨" 0.02 0.06
  dramatic_pause 0.5
  typing_speed_animation "Pick a theme that matches your style:" 0.02 0.05
  
  dramatic_pause 0.5
  # Clear screen for theme selection
  clear
  
  echo ""
  box "🎨 Choose Your Adventure Theme"
  echo ""
  
  # Show theme options with previews
  echo -e "\e[33m1) 🐒 Jungle - A playful, tropical experience with monkeys and bananas\e[0m"
  echo "   Perfect for those who like fun, colorful interfaces"
  echo ""
  
  echo -e "\e[32m2) 💻 Hacker - Matrix-inspired technical theme with a cyberpunk feel\e[0m"
  echo "   Great for those who love the classic terminal aesthetic"
  echo ""
  
  echo -e "\e[35m3) ✨ Wizard - Magical theme with spells and enchantments\e[0m"
  echo "   For those who see coding as a magical art"
  echo ""
  
  echo -e "\e[38;5;33m4) 🌌 Cosmic - Space-themed adventure through the code cosmos\e[0m"
  echo "   For explorers and those who think big"
  echo ""
  
  # Get user choice
  read -p "Choose your theme (1-4): " theme_choice
  
  # Set theme based on choice
  case "$theme_choice" in
    1)
      THEME="jungle"
      typing_speed_animation "🌴 Welcome to the jungle! Let's swing through some code!" 0.02 0.05
      ;;
    2)
      THEME="hacker"
      typing_speed_animation "💻 ACCESS GRANTED. TERMINAL INTERFACE INITIALIZED." 0.02 0.04
      ;;
    3)
      THEME="wizard"
      typing_speed_animation "✨ The arcane knowledge of code is now at your fingertips!" 0.02 0.06
      ;;
    4)
      THEME="cosmic"
      typing_speed_animation "🚀 Preparing for launch into the code cosmos!" 0.02 0.05
      ;;
    *)
      THEME="jungle"
      typing_speed_animation "🌴 Jungle theme selected by default. You can change it later!" 0.02 0.05
      ;;
  esac
  
  # Save theme for future sessions
  echo "THEME=\"$THEME\"" > "$HOME/.gitmonkey/theme"
  THEME_SELECTED=true
  
  dramatic_pause 1
  return 0
}

# Function to show a quick tour of key features
show_quick_tour() {
  # Clear screen for the tour
  clear
  
  # Theme-specific tour title
  case "$THEME" in
    "jungle")
      echo -e "\e[33m"
      cat << 'EOF'
    _____             _____ _           _____                     _      _ 
   |_   _|__  _   _  |_   _| |__   ___ |_   _|__  _   _ _ __     | |    (_)
     | |/ _ \| | | |   | | | '_ \ / _ \  | |/ _ \| | | | '__|    | |    | |
     | | (_) | |_| |   | | | | | |  __/  | | (_) | |_| | |    _  | |__  | |
     |_|\___/ \__,_|   |_| |_| |_|\___|  |_|\___/ \__,_|_|   (_) |_____||_|
                                                                                 
EOF
      echo -e "\e[0m"
      ;;
    "hacker")
      echo -e "\e[32m"
      cat << 'EOF'
 _____ _   _ _____  ___ ____  _____    _   _ _____ _____         _____ ___  _   _ ____  
|_   _| | | |_   _|/ _ \___ \|_   _|  | | | | ____|_   _|       |_   _/ _ \| | | |  _ \ 
  | | | | | | | | | | | |__) | | |    | |_| |  _|   | |    ___    | || | | | | | | |_) |
  | | | |_| | | | | |_| / __/  | |    |  _  | |___  | |   |___|   | || |_| | |_| |  _ < 
  |_|  \___/  |_|  \___/_____| |_|    |_| |_|_____| |_|           |_| \___/ \___/|_| \_\
                                                                                         
EOF
      echo -e "\e[0m"
      ;;
    "wizard")
      echo -e "\e[35m"
      cat << 'EOF'
 .-') _   ('-.                           .-')     .-') _          ('-.     
(  OO) )_(  OO)                         ( OO ).  ( OO ) )       _(  OO)    
/     '._(,------. ,--.      ,--.      (_)---\_) /    '._      (,------. 
|'--...__)|  .---'|  |.-')  |  |.-')   /    _ |  |'--...__)     |  .---' 
'--.  .--'|  |    |  | OO ) |  | OO )  \  :   '.  '--.  .--'    |  |     
   |  |  (|  '--. |  |'-. ' |  |'-. '   '..''.)     |  |       (|  '--.  
   |  |   |  .--'(|  |<     (|  |<     .-._)<)      |  |        |  .--'  
   |  |   |  '--.'|  | \.-. |  | \.-. \       /     |  |        |  `---. 
   '--'   '--'   '`--'  `--'`--'  `--' `-----'      '--'        `------' 
EOF
      echo -e "\e[0m"
      ;;
    "cosmic")
      echo -e "\e[38;5;33m"
      cat << 'EOF'
╔╦╗╦ ╦╔═╗  ╔═╗╔═╗╔╦╗╔═╗╦  ╔═╗╔╦╗╔═╗  ╔╦╗╔═╗╦ ╦╦═╗
 ║ ╠═╣║╣───║  ║ ║║║║╠═╝║  ║╣  ║ ║╣    ║ ║ ║║ ║╠╦╝
 ╩ ╩ ╩╚═╝  ╚═╝╚═╝╩ ╩╩  ╩═╝╚═╝ ╩ ╚═╝   ╩ ╚═╝╚═╝╩╚═
EOF
      echo -e "\e[0m"
      ;;
    *)
      rainbow_box "🚀 The Complete Tour! 🚀"
      ;;
  esac
  
  dramatic_pause 1
  
  # Introduction to the tour
  typing_speed_animation "Let's take a quick tour of what Git Monkey can do for you, $IDENTITY!" 0.02 0.06
  dramatic_pause 0.8
  typing_speed_animation "Here are the 6 superpowers you now have:" 0.02 0.05
  echo ""
  dramatic_pause 1
  
  # Feature 1: Git Visualization
  echo -e "${HEADER_COLOR}1. Git Visualization${RESET_COLOR}"
  typing_speed_animation "Git can be confusing, so I make it visual! Try these:" 0.02 0.05
  echo "   ${success_emoji} gitmonkey visualize - See branch relationships"
  echo "   ${success_emoji} gitmonkey history - Explore your project's timeline"
  echo ""
  dramatic_pause 1
  
  # Feature 2: Project Creation
  echo -e "${HEADER_COLOR}2. Magic Project Creation${RESET_COLOR}"
  typing_speed_animation "Start new projects in seconds without memorizing commands:" 0.02 0.05
  echo "   ${success_emoji} gitmonkey starter - Set up complete projects"
  echo "   ${success_emoji} gitmonkey clone - Clone repositories with visual feedback"
  echo ""
  dramatic_pause 1
  
  # Feature 3: CRUD Generation
  echo -e "${HEADER_COLOR}3. CRUD Superpowers${RESET_COLOR}"
  typing_speed_animation "Create a complete app with database features:" 0.02 0.05
  echo "   ${success_emoji} gitmonkey generate crud - Build a working app with forms"
  echo "   ${success_emoji} gitmonkey schema - Design database schemas visually"
  echo ""
  dramatic_pause 1
  
  # Feature 4: Educational Tools
  echo -e "${HEADER_COLOR}4. Learning Tools${RESET_COLOR}"
  typing_speed_animation "I'll help you learn as you go:" 0.02 0.05
  echo "   ${success_emoji} gitmonkey learn - Interactive coding tutorials"
  echo "   ${success_emoji} gitmonkey cheatsheet - Quick reference for commands"
  echo ""
  dramatic_pause 1
  
  # Feature 5: AI Assistance
  echo -e "${HEADER_COLOR}5. AI-Powered Assistance${RESET_COLOR}"
  typing_speed_animation "Let AI help you with tricky Git tasks:" 0.02 0.05
  echo "   ${success_emoji} gitmonkey commit --suggest - Get AI-generated commit messages"
  echo "   ${success_emoji} gitmonkey branch new --suggest - Smart branch naming"
  echo "   ${success_emoji} gitmonkey merge --analyze - Risk analysis before merging"
  echo "   ${success_emoji} gitmonkey ask \"how do I...\" - Git questions in plain language"
  echo ""
  dramatic_pause 1
  
  # Feature 6: Developer Experience
  echo -e "${HEADER_COLOR}6. Enhanced Developer Experience${RESET_COLOR}"
  typing_speed_animation "Work smarter, not harder:" 0.02 0.05
  echo "   ${success_emoji} gitmonkey alias - Create custom shortcuts"
  echo "   ${success_emoji} gitmonkey undo - Fix mistakes easily"
  echo ""
  dramatic_pause 1
  
  # Closing the tour
  echo ""
  rainbow_box "Ready to get started?"
  typing_speed_animation "Let's try your first command together! 🎯" 0.03 0.06
  dramatic_pause 0.5
  return 0
}

# Function to offer AI integration setup
offer_ai_setup() {
  echo ""
  dramatic_pause 0.5
  
  # Theme-specific AI introduction
  case "$THEME" in
    "jungle")
      typing_speed_animation "🌴 Want to give your monkey some extra intelligence? 🧠" 0.02 0.06
      ;;
    "hacker")
      typing_speed_animation "💻 NEURAL NETWORK INTEGRATION AVAILABLE" 0.02 0.05
      typing_speed_animation "ACCESS AI ASSISTANCE MODULES?" 0.02 0.05
      ;;
    "wizard")
      typing_speed_animation "✨ Would you like to summon an AI familiar to assist your coding journey? ✨" 0.02 0.06
      ;;
    "cosmic")
      typing_speed_animation "🌌 Connect to the cosmic intelligence network?" 0.02 0.05
      typing_speed_animation "AI can guide your interstellar code voyage!" 0.02 0.05
      ;;
    *)
      typing_speed_animation "Would you like to enable AI assistance in Git Monkey?" 0.02 0.05
      ;;
  esac
  
  echo ""
  typing_speed_animation "Git Monkey can use AI to:" 0.02 0.04
  echo "  • Suggest better commit messages"
  echo "  • Help name branches meaningfully"
  echo "  • Analyze merge risks"
  echo "  • Answer Git questions in context"
  echo ""
  
  read -p "Set up AI integration now? (y/n): " setup_ai
  
  if [ "$setup_ai" = "y" ] || [ "$setup_ai" = "Y" ]; then
    # Show themed provider selection
    clear
    
    # Theme-specific header for AI selection
    case "$THEME" in
      "jungle")
        echo -e "\e[33m"
        cat << 'EOF'
        🧠  🐒  BOOST YOUR MONKEY'S BRAINPOWER  🐒  🧠
EOF
        echo -e "\e[0m"
        ;;
      "hacker")
        echo -e "\e[32m"
        cat << 'EOF'
        ┌───────────────────────────────────────┐
        │  NEURAL NETWORK PROVIDER SELECTION    │
        │  CHOOSE INTELLIGENCE VECTOR           │
        └───────────────────────────────────────┘
EOF
        echo -e "\e[0m"
        ;;
      "wizard")
        echo -e "\e[35m"
        cat << 'EOF'
           ✨ ✨ ✨  ARCANE AI FAMILIAR  ✨ ✨ ✨
           Choose your magical intelligence source
EOF
        echo -e "\e[0m"
        ;;
      "cosmic")
        echo -e "\e[38;5;33m"
        cat << 'EOF'
         🌌  COSMIC INTELLIGENCE NETWORK  🌌
             Select your stellar AI guide
EOF
        echo -e "\e[0m"
        ;;
      *)
        box "🧠 Select AI Provider"
        ;;
    esac
    
    echo ""
    typing_speed_animation "Git Monkey can connect to different AI providers. Choose one:" 0.02 0.04
    echo ""
    
    echo "1) OpenAI (GPT-4o) - Excellent for code understanding, widely used"
    echo "2) Claude (Anthropic) - Strong reasoning, clear explanations"
    echo "3) Gemini (Google) - Good performance with competitive pricing"
    echo "4) DeepSeek - Open-source foundation, specialized for code"
    echo "5) Skip for now (set up later)"
    echo ""
    
    read -p "Select provider (1-5): " provider_choice
    
    case "$provider_choice" in
      1)
        provider="OpenAI"
        provider_url="https://platform.openai.com/api-keys"
        ;;
      2)
        provider="Claude"
        provider_url="https://console.anthropic.com/settings/keys"
        ;;
      3)
        provider="Gemini"
        provider_url="https://makersuite.google.com/app/apikey"
        ;;
      4)
        provider="DeepSeek"
        provider_url="https://platform.deepseek.com/api_keys"
        ;;
      5|*)
        typing_speed_animation "No problem! You can set up AI later with 'gitmonkey settings ai'" 0.02 0.04
        return 0
        ;;
    esac
    
    echo ""
    typing_speed_animation "You'll need an API key for $provider." 0.02 0.04
    typing_speed_animation "You can get one from: $provider_url" 0.02 0.04
    echo ""
    
    read -s -p "Enter your $provider API key (input will be hidden): " api_key
    echo ""
    
    if [ -z "$api_key" ]; then
      typing_speed_animation "No key entered. You can set up AI later with 'gitmonkey settings ai'" 0.02 0.04
      return 0
    fi
    
    # Initialize key management and save the key
    source ./utils/ai_keys.sh
    initialize_ai_keys_file
    save_api_key "$provider" "$api_key"
    set_default_ai_provider "$provider"
    
    # Theme-specific success message
    case "$THEME" in
      "jungle")
        typing_speed_animation "🍌 Monkey brain upgraded! Your jungle guide is now super smart!" 0.02 0.05
        ;;
      "hacker")
        typing_speed_animation "> NEURAL NETWORK ONLINE. AI SYSTEMS INITIALIZED." 0.02 0.04
        ;;
      "wizard")
        typing_speed_animation "✨ Your AI familiar has been summoned successfully! ✨" 0.02 0.06
        ;;
      "cosmic")
        typing_speed_animation "🌌 Cosmic intelligence successfully connected to your terminal!" 0.02 0.05
        ;;
      *)
        typing_speed_animation "✅ AI setup complete!" 0.02 0.04
        ;;
    esac
    
    echo ""
    typing_speed_animation "You can manage AI settings anytime with:" 0.02 0.04
    echo "   gitmonkey settings ai"
    echo ""
    dramatic_pause 1
  else
    typing_speed_animation "No problem! You can enable AI features later with:" 0.02 0.04
    echo "   gitmonkey settings ai"
    echo ""
    dramatic_pause 1
  fi
  
  return 0
}

# Function to guide user through their first command
guide_first_command() {
  echo ""
  typing_speed_animation "Let's see what Git Monkey can do with a simple command." 0.03 0.06
  dramatic_pause 0.5
  
  # Theme-specific first command suggestion
  case "$THEME" in
    "jungle")
      typing_speed_animation "Try typing: gitmonkey branch" 0.03 0.06
      typing_speed_animation "(This shows branches in your jungle 🌴)" 0.02 0.05
      ;;
    "hacker")
      typing_speed_animation "Try typing: gitmonkey status" 0.03 0.06
      typing_speed_animation "(This scans your repository state 🔍)" 0.02 0.05
      ;;
    "wizard")
      typing_speed_animation "Try typing: gitmonkey visualize" 0.03 0.06
      typing_speed_animation "(This reveals the magical structure of your project ✨)" 0.02 0.05
      ;;
    "cosmic")
      typing_speed_animation "Try typing: gitmonkey starter" 0.03 0.06
      typing_speed_animation "(This launches a new cosmic project 🚀)" 0.02 0.05
      ;;
    *)
      typing_speed_animation "Try typing: gitmonkey help" 0.03 0.06
      typing_speed_animation "(This shows all available commands 📚)" 0.02 0.05
      ;;
  esac
  
  echo ""
  typing_speed_animation "After that, try 'gitmonkey starter' to create your first project!" 0.02 0.05
  echo ""
  
  # Create a marker file to indicate user has been welcomed
  touch "$HOME/.gitmonkey/welcomed"
  
  return 0
}

# Main function to run the welcome sequence
main() {
  # Check if first time and not skipping intro
  if [ "$FIRST_TIME" = true ] && [ "$SKIP_INTRO" = false ]; then
    show_intro_animation
    ask_for_identity
    select_theme
    show_quick_tour
    offer_ai_setup
    guide_first_command
  elif [ "$SKIP_INTRO" = true ]; then
    # Just do minimal introduction without animations
    echo "Welcome to Git Monkey!"
    
    # Make sure we have required settings
    if [ "$IDENTITY_SET" = false ]; then
      ask_for_identity
    fi
    
    if [ "$THEME_SELECTED" = false ]; then
      select_theme
    fi
    
    # Create welcomed marker if needed
    touch "$HOME/.gitmonkey/welcomed"
  else
    # Not first time, but specifically requested welcome again
    typing_speed_animation "Welcome back to Git Monkey, $IDENTITY!" 0.02 0.04
    echo ""
    typing_speed_animation "Need a refresher? Try 'gitmonkey help' or 'gitmonkey tutorial'." 0.02 0.04
  fi
  
  return 0
}

# Run main function
main "$@"