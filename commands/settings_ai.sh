#!/bin/bash

# ========= GIT MONKEY AI SETTINGS MANAGER =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Configure AI providers and manage API keys


# Get theme for styling
THEME=$(get_selected_theme 2>/dev/null || echo "jungle")

# Function to display a themed header
show_themed_header() {
  case "$THEME" in
    "jungle")
      echo -e "\e[33m"
      cat << 'EOF'
      🐒 🍌 🌴 AI MONKEY SETTINGS 🌴 🍌 🐒
       Teach this monkey some new tricks!
EOF
      echo -e "\e[0m"
      ;;
    "hacker")
      echo -e "\e[32m"
      cat << 'EOF'
  ╔═══════════════════════════════════════════╗
  ║ [AI] NEURAL INTEGRATION CONTROL PANEL     ║
  ║ > CONFIGURE MODEL ACCESS                  ║
  ╚═══════════════════════════════════════════╝
EOF
      echo -e "\e[0m"
      ;;
    "wizard")
      echo -e "\e[35m"
      cat << 'EOF'
       ✨ 🧙‍♂️ ✨  THE ARCANE AI CONFIGURATOR  ✨ 🧙‍♂️ ✨ 
        Bind thy AI familiar to thy service
EOF
      echo -e "\e[0m"
      ;;
    "cosmic")
      echo -e "\e[38;5;33m"
      cat << 'EOF'
       🌌 🚀 🌠  COSMIC AI NAVIGATOR  🌠 🚀 🌌
      Configure your interstellar AI assistant
EOF
      echo -e "\e[0m"
      ;;
    *)
      box "🧠 Git Monkey AI Settings"
      ;;
  esac
}

# Function to add/update an API key
add_api_key() {
  clear
  show_themed_header
  
  echo "Choose an AI provider to configure:"
  echo ""
  echo "1) OpenAI (GPT-4o)"
  echo "2) Claude (Anthropic)"
  echo "3) Gemini (Google)"
  echo "4) DeepSeek"
  echo "5) Cancel"
  echo ""
  
  read -p "Select provider (1-5): " provider_choice
  
  case "$provider_choice" in
    1)
      provider="OpenAI"
      info_url="https://platform.openai.com/api-keys"
      ;;
    2)
      provider="Claude"
      info_url="https://console.anthropic.com/settings/keys"
      ;;
    3)
      provider="Gemini"
      info_url="https://makersuite.google.com/app/apikey"
      ;;
    4)
      provider="DeepSeek"
      info_url="https://platform.deepseek.com/api_keys"
      ;;
    5)
      echo "Operation cancelled."
      return 0
      ;;
    *)
      echo "Invalid choice. Returning to main menu."
      return 1
      ;;
  esac
  
  echo ""
  echo "Setting up $provider API key"
  echo "Get your API key from: $info_url"
  echo ""
  echo "Your API key will be stored securely in $HOME/.gitmonkey/api_keys"
  echo "with read/write permissions only for your user account."
  echo ""
  
  # Check if key already exists
  local current_key=$(get_api_key "$provider")
  if [ -n "$current_key" ]; then
    echo "You already have a $provider API key configured."
    read -p "Do you want to update it? (y/n): " update_choice
    if [ "$update_choice" != "y" ] && [ "$update_choice" != "Y" ]; then
      echo "Operation cancelled."
      return 0
    fi
  fi
  
  # Get the API key with hidden input
  read -s -p "Enter your $provider API key: " api_key
  echo ""
  
  # Validate the key format
  if ! validate_api_key "$provider" "$api_key"; then
    echo "Error: The API key format appears to be invalid for $provider."
    echo "Please check that you've entered the correct key."
    return 1
  fi
  
  # Save the key
  if save_api_key "$provider" "$api_key"; then
    echo "✅ $provider API key saved successfully."
    
    # Set as default if it's the first provider
    if [ -z "$(get_default_ai_provider)" ]; then
      set_default_ai_provider "$provider"
      echo "✅ $provider set as your default AI provider."
    fi
  else
    echo "❌ Failed to save API key. Please try again."
    return 1
  fi
  
  return 0
}

# Function to set the default AI provider
set_default_provider() {
  clear
  show_themed_header
  
  # Get all configured providers
  local providers=$(get_all_providers)
  
  if [ -z "$providers" ]; then
    echo "No AI providers configured yet."
    echo "Please add an API key first."
    return 1
  fi
  
  echo "Choose your default AI provider:"
  echo ""
  
  # Display provider options
  local num=1
  local provider_array=()
  for provider in $providers; do
    echo "$num) $provider"
    provider_array+=("$provider")
    num=$((num + 1))
  done
  
  echo "$num) Cancel"
  echo ""
  
  # Get current default
  local current_default=$(get_default_ai_provider)
  if [ -n "$current_default" ]; then
    echo "Current default: $current_default"
  fi
  
  echo ""
  read -p "Select default provider (1-$num): " choice
  
  # Validate choice
  if [ "$choice" -eq "$num" ]; then
    echo "Operation cancelled."
    return 0
  fi
  
  if [ "$choice" -lt 1 ] || [ "$choice" -gt $((num-1)) ]; then
    echo "Invalid selection."
    return 1
  fi
  
  # Set the new default
  local selected_provider="${provider_array[$((choice-1))]}"
  set_default_ai_provider "$selected_provider"
  
  echo "✅ $selected_provider set as your default AI provider."
  return 0
}

# Function to remove an API key
remove_api_key() {
  clear
  show_themed_header
  
  # Get all configured providers
  local providers=$(get_all_providers)
  
  if [ -z "$providers" ]; then
    echo "No AI providers configured yet."
    return 1
  fi
  
  echo "Select a provider to remove:"
  echo ""
  
  # Display provider options
  local num=1
  local provider_array=()
  for provider in $providers; do
    echo "$num) $provider"
    provider_array+=("$provider")
    num=$((num + 1))
  done
  
  echo "$num) Cancel"
  echo ""
  
  read -p "Select provider to remove (1-$num): " choice
  
  # Validate choice
  if [ "$choice" -eq "$num" ]; then
    echo "Operation cancelled."
    return 0
  fi
  
  if [ "$choice" -lt 1 ] || [ "$choice" -gt $((num-1)) ]; then
    echo "Invalid selection."
    return 1
  fi
  
  # Get the selected provider
  local selected_provider="${provider_array[$((choice-1))]}"
  
  # Confirm removal
  read -p "Are you sure you want to remove the $selected_provider API key? (y/n): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Operation cancelled."
    return 0
  fi
  
  # Remove the key
  delete_api_key "$selected_provider"
  echo "✅ $selected_provider API key removed."
  
  return 0
}

# Function to set usage limits
set_usage_limits() {
  clear
  show_themed_header
  
  # Get current limit
  local current_limit=$(get_usage_limit)
  
  echo "Set your monthly usage limit (in US cents)"
  echo "This helps prevent unexpected API costs."
  echo ""
  echo "Current limit: $current_limit cents (approximately $$(echo "scale=2; $current_limit/100" | bc) USD)"
  echo ""
  echo "Recommended limits:"
  echo "- Light usage: 50 cents"
  echo "- Medium usage: 200 cents"
  echo "- Heavy usage: 500 cents"
  echo ""
  
  read -p "Enter new limit (in cents, or 0 for no limit): " new_limit
  
  # Validate input
  if ! [[ "$new_limit" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a number."
    return 1
  fi
  
  # Set the new limit
  set_usage_limit "$new_limit"
  
  if [ "$new_limit" -eq 0 ]; then
    echo "✅ Usage limit disabled."
  else
    echo "✅ Monthly usage limit set to $new_limit cents (approximately $$(echo "scale=2; $new_limit/100" | bc) USD)"
  fi
  
  return 0
}

# Function to view current usage
view_usage() {
  clear
  show_themed_header
  
  echo "AI Usage for current month:"
  echo ""
  
  # Get all configured providers
  local providers=$(get_all_providers)
  
  if [ -z "$providers" ]; then
    echo "No AI providers configured yet."
    return 1
  fi
  
  # Get usage for each provider
  local total_usage=0
  for provider in $providers; do
    local usage=$(get_current_usage "$provider")
    total_usage=$((total_usage + usage))
    
    # Estimate cost (very rough estimate)
    local cost=$(echo "scale=2; $usage / 1000 * 0.01" | bc 2>/dev/null || echo "0.00")
    
    echo "$provider: $usage tokens (est. $$cost)"
  done
  
  # Show total
  local total_cost=$(echo "scale=2; $total_usage / 1000 * 0.01" | bc 2>/dev/null || echo "0.00")
  echo ""
  echo "Total usage: $total_usage tokens (est. $$total_cost)"
  
  # Show limit
  local limit=$(get_usage_limit)
  local limit_dollars=$(echo "scale=2; $limit/100" | bc 2>/dev/null || echo "0.00")
  
  if [ "$limit" -eq 0 ]; then
    echo "Monthly limit: No limit set"
  else
    echo "Monthly limit: $$limit_dollars"
    
    # Calculate percentage used
    local limit_cents=$(echo "scale=0; $total_cost * 100" | bc 2>/dev/null || echo "0")
    local percentage=$(echo "scale=0; $limit_cents * 100 / $limit" | bc 2>/dev/null || echo "0")
    
    if [ "$percentage" -lt 50 ]; then
      echo "Usage: $percentage% of monthly limit (Good)"
    elif [ "$percentage" -lt 80 ]; then
      echo "Usage: $percentage% of monthly limit (Moderate)"
    else
      echo "Usage: $percentage% of monthly limit (High)"
    fi
  fi
  
  echo ""
  read -p "Press Enter to continue..."
  return 0
}

# Function to test AI integration
test_ai_integration() {
  clear
  show_themed_header
  
  # Check if any providers are configured
  if ! has_ai_providers; then
    echo "No AI providers configured yet."
    echo "Please add an API key first."
    return 1
  fi
  
  # Get the default provider or prompt for selection
  local provider=$(get_default_ai_provider)
  
  if [ -z "$provider" ]; then
    echo "No default provider set. Please select a provider:"
    
    # Get all configured providers
    local providers=$(get_all_providers)
    local num=1
    local provider_array=()
    
    for p in $providers; do
      echo "$num) $p"
      provider_array+=("$p")
      num=$((num + 1))
    done
    
    read -p "Select provider (1-$((num-1))): " choice
    
    if [ "$choice" -lt 1 ] || [ "$choice" -gt $((num-1)) ]; then
      echo "Invalid selection."
      return 1
    fi
    
    provider="${provider_array[$((choice-1))]}"
  fi
  
  echo "Testing connection to $provider..."
  echo ""
  
  # Simple test prompt
  local test_prompt="This is a test connection from Git Monkey. Please respond with a short greeting."
  
  # Show spinner
  echo -n "Connecting... "
  for i in {1..3}; do
    echo -n "."
    sleep 0.5
  done
  echo ""
  
  # Make the request
  local response=$(ai_request "$test_prompt" "$provider" false)
  local status=$?
  
  if [ $status -eq 0 ] && [ -n "$response" ]; then
    echo "✅ Connection successful!"
    echo ""
    echo "Response from $provider:"
    echo "----------------------------------------"
    echo "$response"
    echo "----------------------------------------"
    echo ""
    echo "Your AI integration is working correctly."
  else
    echo "❌ Connection failed!"
    echo ""
    echo "Error: $response"
    echo ""
    echo "Please check your API key and try again."
  fi
  
  echo ""
  read -p "Press Enter to continue..."
  return $status
}

# Function to show help for AI features
show_ai_help() {
  clear
  show_themed_header
  
  echo "📚 AI Features Help"
  echo ""
  echo "Git Monkey's AI integration enhances your Git experience with:"
  echo ""
  echo "1. 📝 Commit Message Suggestions"
  echo "   Use 'gitmonkey commit --suggest' to get AI-generated"
  echo "   commit messages based on your code changes."
  echo ""
  echo "2. 🌿 Smart Branch Naming"
  echo "   Use 'gitmonkey branch new --suggest' for AI-generated"
  echo "   branch name ideas based on your current work."
  echo ""
  echo "3. 🔍 Merge Risk Analysis"
  echo "   Use 'gitmonkey merge source target --analyze' to get"
  echo "   AI-powered analysis of potential merge conflicts."
  echo ""
  echo "4. 🤔 Git Help Assistant"
  echo "   Use 'gitmonkey ask \"how do I...\"' to get contextual"
  echo "   help with Git commands and concepts."
  echo ""
  echo "All these features adapt to your chosen theme and experience"
  echo "level to provide a personalized experience."
  echo ""
  echo "For best results, use the AI provider that works best for"
  echo "your region and use case."
  echo ""
  read -p "Press Enter to continue..."
  return 0
}

# Main menu function
main_menu() {
  while true; do
    clear
    show_themed_header
    
    # Show current status
    if has_ai_providers; then
      local default_provider=$(get_default_ai_provider)
      if [ -n "$default_provider" ]; then
        echo "✅ AI Integration: Active (using $default_provider)"
      else
        echo "⚠️ AI Integration: Configured but no default provider set"
      fi
    else
      echo "❌ AI Integration: Not configured"
    fi
    echo ""
    
    # Menu options
    echo "Select an option:"
    echo ""
    echo "1) Add/Update API Key"
    echo "2) Set Default Provider"
    echo "3) Remove API Key"
    echo "4) Set Usage Limits"
    echo "5) View Current Usage"
    echo "6) Test AI Integration"
    echo "7) AI Features Help"
    echo "8) Return to Main Menu"
    echo ""
    
    read -p "Choose an option (1-8): " menu_choice
    
    case "$menu_choice" in
      1) add_api_key ;;
      2) set_default_provider ;;
      3) remove_api_key ;;
      4) set_usage_limits ;;
      5) view_usage ;;
      6) test_ai_integration ;;
      7) show_ai_help ;;
      8) echo "Returning to main menu..."; return 0 ;;
      *) echo "Invalid choice. Please try again." ;;
    esac
    
    # Pause before returning to menu
    echo ""
    read -p "Press Enter to continue..."
  done
}

# Run the main menu
main_menu
