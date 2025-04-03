#!/bin/bash

# ========= GIT MONKEY AI API KEY MANAGEMENT =========
# Secure handling of API keys for AI integrations

# Constants
AI_KEYS_FILE="$HOME/.gitmonkey/api_keys"
AI_CONFIG_FILE="$HOME/.gitmonkey/ai_config"

# Initialize the API keys file with secure permissions
initialize_ai_keys_file() {
  # Create parent directory if it doesn't exist
  mkdir -p "$HOME/.gitmonkey" 2>/dev/null
  
  # Create empty keys file if it doesn't exist
  if [ ! -f "$AI_KEYS_FILE" ]; then
    echo "{}" > "$AI_KEYS_FILE"
    # Set secure permissions (read/write only for owner)
    chmod 600 "$AI_KEYS_FILE"
  fi
  
  # Create config file if it doesn't exist
  if [ ! -f "$AI_CONFIG_FILE" ]; then
    echo '{"default_provider":"","usage_limit":50}' > "$AI_CONFIG_FILE"
    chmod 600 "$AI_CONFIG_FILE"
  fi
}

# Save an API key for a provider
save_api_key() {
  local provider="$1"
  local api_key="$2"
  
  # Make sure the key file exists
  initialize_ai_keys_file
  
  # Read the current keys
  local keys_json=$(cat "$AI_KEYS_FILE")
  
  # Updated JSON with new key (using jq if available, or simple replacement if not)
  if command -v jq >/dev/null; then
    # Use jq for proper JSON handling if available
    local updated_json=$(echo "$keys_json" | jq --arg provider "$provider" --arg key "$api_key" '. + {($provider): $key}')
    echo "$updated_json" > "$AI_KEYS_FILE"
  else
    # Simple replacement for environments without jq
    if [[ "$keys_json" == "{}" ]]; then
      # Empty JSON object
      echo "{\"$provider\":\"$api_key\"}" > "$AI_KEYS_FILE"
    else
      # Add to existing JSON
      # Remove the closing brace, add new key-value pair, and close the JSON object
      keys_json="${keys_json%\}}"
      if [[ "$keys_json" != "{" ]]; then
        # Add comma if this isn't the first key
        keys_json="$keys_json,"
      fi
      echo "$keys_json\"$provider\":\"$api_key\"}" > "$AI_KEYS_FILE"
    fi
  fi
  
  # If no default provider is set, make this the default
  if [ -z "$(get_default_ai_provider)" ]; then
    set_default_ai_provider "$provider"
  fi
  
  # Ensure secure permissions
  chmod 600 "$AI_KEYS_FILE"
  
  return 0
}

# Get an API key for a provider
get_api_key() {
  local provider="$1"
  
  # Make sure the file exists
  initialize_ai_keys_file
  
  # Read the key using jq if available
  if command -v jq >/dev/null; then
    local api_key=$(jq -r --arg provider "$provider" '.[$provider] // empty' "$AI_KEYS_FILE")
    echo "$api_key"
  else
    # Simple grep approach for environments without jq
    local api_key=$(grep -o "\"$provider\":\"[^\"]*\"" "$AI_KEYS_FILE" | cut -d':' -f2 | tr -d '"')
    echo "$api_key"
  fi
}

# Delete an API key for a provider
delete_api_key() {
  local provider="$1"
  
  # Make sure the file exists
  initialize_ai_keys_file
  
  # Read the current keys
  local keys_json=$(cat "$AI_KEYS_FILE")
  
  # Update JSON by removing the provider
  if command -v jq >/dev/null; then
    # Use jq for proper JSON handling if available
    local updated_json=$(echo "$keys_json" | jq --arg provider "$provider" 'del(.[$provider])')
    echo "$updated_json" > "$AI_KEYS_FILE"
  else
    # Simple replacement for environments without jq
    # This is a simplified approach that may not work for all JSON structures
    local updated_json=$(echo "$keys_json" | sed -E "s/\"$provider\":\"[^\"]*\"(,)?//g" | sed 's/,}/}/g' | sed 's/{,/{/g')
    echo "$updated_json" > "$AI_KEYS_FILE"
  fi
  
  # If this was the default provider, clear the default
  local default_provider=$(get_default_ai_provider)
  if [ "$default_provider" = "$provider" ]; then
    set_default_ai_provider ""
  fi
  
  return 0
}

# Set the default AI provider
set_default_ai_provider() {
  local provider="$1"
  
  # Make sure the file exists
  initialize_ai_keys_file
  
  # Update config
  if command -v jq >/dev/null; then
    # Use jq for proper JSON handling if available
    local config=$(cat "$AI_CONFIG_FILE")
    local updated_config=$(echo "$config" | jq --arg provider "$provider" '.default_provider = $provider')
    echo "$updated_config" > "$AI_CONFIG_FILE"
  else
    # Simple replacement
    local config=$(cat "$AI_CONFIG_FILE")
    local updated_config=$(echo "$config" | sed -E "s/\"default_provider\":\"[^\"]*\"/\"default_provider\":\"$provider\"/g")
    echo "$updated_config" > "$AI_CONFIG_FILE"
  fi
  
  return 0
}

# Get the default AI provider
get_default_ai_provider() {
  # Make sure the file exists
  initialize_ai_keys_file
  
  if command -v jq >/dev/null; then
    # Use jq for proper JSON handling if available
    local provider=$(jq -r '.default_provider // empty' "$AI_CONFIG_FILE")
    echo "$provider"
  else
    # Simple grep approach for environments without jq
    local provider=$(grep -o "\"default_provider\":\"[^\"]*\"" "$AI_CONFIG_FILE" | cut -d':' -f2 | tr -d '"')
    echo "$provider"
  fi
}

# Get all configured providers
get_all_providers() {
  # Make sure the file exists
  initialize_ai_keys_file
  
  if command -v jq >/dev/null; then
    # Use jq to get all keys (provider names)
    local providers=$(jq -r 'keys | join(" ")' "$AI_KEYS_FILE")
    echo "$providers"
  else
    # Simple grep approach for environments without jq
    local providers=$(grep -o "\"[^\"]*\":" "$AI_KEYS_FILE" | tr -d '"' | tr -d ':' | tr '\n' ' ')
    echo "$providers"
  fi
}

# Check if any AI providers are configured
has_ai_providers() {
  local providers=$(get_all_providers)
  if [ -z "$providers" ]; then
    return 1
  else
    return 0
  fi
}

# Set the monthly usage limit (in cents)
set_usage_limit() {
  local limit="$1"
  
  # Make sure the file exists
  initialize_ai_keys_file
  
  # Update config
  if command -v jq >/dev/null; then
    # Use jq for proper JSON handling if available
    local config=$(cat "$AI_CONFIG_FILE")
    local updated_config=$(echo "$config" | jq --arg limit "$limit" '.usage_limit = ($limit | tonumber)')
    echo "$updated_config" > "$AI_CONFIG_FILE"
  else
    # Simple replacement
    local config=$(cat "$AI_CONFIG_FILE")
    local updated_config=$(echo "$config" | sed -E "s/\"usage_limit\":[0-9]+/\"usage_limit\":$limit/g")
    echo "$updated_config" > "$AI_CONFIG_FILE"
  fi
  
  return 0
}

# Get the monthly usage limit
get_usage_limit() {
  # Make sure the file exists
  initialize_ai_keys_file
  
  if command -v jq >/dev/null; then
    # Use jq for proper JSON handling if available
    local limit=$(jq -r '.usage_limit // 50' "$AI_CONFIG_FILE")
    echo "$limit"
  else
    # Simple grep approach for environments without jq
    local limit=$(grep -o "\"usage_limit\":[0-9]*" "$AI_CONFIG_FILE" | cut -d':' -f2)
    if [ -z "$limit" ]; then
      echo "50"  # Default limit
    else
      echo "$limit"
    fi
  fi
}

# Validate an API key format - basic format checks for common providers
validate_api_key() {
  local provider="$1"
  local api_key="$2"
  
  case "$provider" in
    "OpenAI")
      # OpenAI keys start with "sk-" and are 51 characters
      if [[ "$api_key" == sk-* ]] && [ ${#api_key} -ge 30 ]; then
        return 0
      else
        return 1
      fi
      ;;
    "Claude")
      # Claude keys start with "sk-ant-" and are longer
      if [[ "$api_key" == sk-ant-* ]] && [ ${#api_key} -ge 35 ]; then
        return 0
      else
        return 1
      fi
      ;;
    "Gemini")
      # Gemini keys start with "AIza" and are longer
      if [[ "$api_key" == AIza* ]] && [ ${#api_key} -ge 30 ]; then
        return 0
      else
        return 1
      fi
      ;;
    "DeepSeek")
      # DeepSeek keys should start with sk-dpk-
      if [[ "$api_key" == sk-dpk-* ]] && [ ${#api_key} -ge 30 ]; then
        return 0
      else
        return 1
      fi
      ;;
    *)
      # For unknown providers, just check if the key isn't empty
      if [ -n "$api_key" ]; then
        return 0
      else
        return 1
      fi
      ;;
  esac
}

# Initialize on source
initialize_ai_keys_file