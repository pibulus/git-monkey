#\!/bin/bash

# ========= GIT MONKEY AI REQUEST HANDLER =========
# Central service for all AI provider interactions

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"

source "$DIR/ai_keys.sh"
source "$DIR/style.sh"
source "$DIR/config.sh"

# Set up caching directory
AI_CACHE_DIR="$HOME/.gitmonkey/ai_cache"
mkdir -p "$AI_CACHE_DIR" 2>/dev/null

# Cache TTL in seconds (24 hours)
CACHE_TTL=86400

# Import safety module
source "$DIR/ai_safety.sh"
# Import safety module
source "$DIR/ai_safety.sh"

# Rest of file content below...
# Set up caching directory
AI_CACHE_DIR="$HOME/.gitmonkey/ai_cache"
mkdir -p "$AI_CACHE_DIR" 2>/dev/null

# Cache TTL in seconds (24 hours)
CACHE_TTL=86400

# Import safety module
source "$DIR/ai_safety.sh"

# Main AI request function with added safety guardrails
ai_request() {
  local prompt="$1"
  local provider="$2"
  local cache_allowed="${3:-true}"
  local max_retries="${4:-2}"
  local purpose="${5:-general}"
  
  # Get current theme and tone stage for context-appropriate responses
  local theme=$(get_selected_theme 2>/dev/null || echo "jungle")
  local tone_stage=$(get_tone_stage 2>/dev/null || echo "3")
  
  # Run the safety gate check
  if ! ai_safety_gate "$prompt" "$purpose" "$theme" "$tone_stage"; then
    # Safety gate rejected the request
    return 1
  fi
  
  # If no provider specified, use default
  if [ -z "$provider" ]; then
    provider=$(get_default_ai_provider)
    
    # If still no provider, show error and exit
    if [ -z "$provider" ]; then
      echo "Error: No AI provider configured. Run 'gitmonkey settings ai' to set up."
      return 1
    fi
  fi
  
  # Get API key for the provider
  local api_key=$(get_api_key "$provider")
  if [ -z "$api_key" ]; then
    echo "Error: No API key found for $provider. Run 'gitmonkey settings ai' to set up."
    return 1
  fi
  
  # Check usage limits before making the request
  if ! check_usage_limit; then
    echo "Error: Monthly usage limit has been reached. You can adjust your limit in 'gitmonkey settings ai'."
    return 1
  fi
  
  # Generate a cache key if caching is allowed
  local cache_key=""
  if [ "$cache_allowed" = true ]; then
    cache_key=$(generate_cache_key "$prompt" "$provider")
    
    # Check cache for existing response
    local cached_response=$(check_cache "$cache_key")
    if [ -n "$cached_response" ]; then
      # Even for cached responses, track minimal token usage for stats
      track_usage "$provider" 1 "" ""
      
      # Apply theme-specific formatting to cached response
      local filtered_response=$(ai_response_filter "$cached_response" "$theme" "$tone_stage")
      echo "$filtered_response"
      return 0
    fi
  fi
  
  # Add theme-specific context to the prompt
  local themed_prompt=""
  case "$theme" in
    "jungle")
      themed_prompt="As Git Monkey with a playful jungle theme, you are a Git assistant that uses friendly language with occasional monkey and jungle references. Keep responses concise, practical and focused on Git. $prompt"
      ;;
    "hacker")
      themed_prompt="As Git Monkey with a hacker theme, you are a Git assistant that uses technical, precise language with occasional terminal and system references. Keep responses concise, practical and focused on Git. $prompt"
      ;;
    "wizard")
      themed_prompt="As Git Monkey with a wizard theme, you are a Git assistant that uses mystical language with occasional magic references. Keep responses concise, practical and focused on Git. $prompt"
      ;;
    "cosmic")
      themed_prompt="As Git Monkey with a cosmic theme, you are a Git assistant that uses space-themed language with occasional cosmic references. Keep responses concise, practical and focused on Git. $prompt"
      ;;
    *)
      themed_prompt="As Git Monkey, you are a Git assistant focused on practical Git help. Keep responses concise and focused only on Git commands and workflows. $prompt"
      ;;
  esac
  
  # Make the API request with retries
  local response=""
  local attempt=0
  local success=false
  
  while [ $attempt -lt $max_retries ] && [ "$success" = false ]; do
    attempt=$((attempt + 1))
    
    # Attempt the API request with the themed prompt
    response=$(make_api_request "$themed_prompt" "$provider" "$api_key")
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] && [ -n "$response" ]; then
      success=true
    else
      # Wait before retrying (exponential backoff)
      sleep $((2 ** attempt))
    fi
  done
  
  if [ "$success" = false ]; then
    echo "Error: Failed to get response from $provider after $max_retries attempts."
    return 1
  fi
  
  # Filter the response to ensure it stays in character and follows our guidelines
  local filtered_response=$(ai_response_filter "$response" "$theme" "$tone_stage")
  
  # Track usage with enhanced information
  track_usage "$provider" 0 "$prompt" "$filtered_response"
  
  # Cache the successful filtered response if caching is allowed
  if [ "$cache_allowed" = true ] && [ -n "$cache_key" ]; then
    update_cache "$cache_key" "$filtered_response"
  fi
  
  echo "$filtered_response"
  return 0
}

# Process Git context to enhance prompts
process_git_context() {
  local base_prompt="$1"
  
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    # Not in a git repo, return original prompt
    echo "$base_prompt"
    return 0
  fi
  
  # Get current branch
  local current_branch=$(git branch --show-current 2>/dev/null)
  
  # Get recent commits (last 3)
  local recent_commits=$(git log -3 --oneline 2>/dev/null)
  
  # Get repo name
  local repo_name=$(basename -s .git $(git config --get remote.origin.url 2>/dev/null) 2>/dev/null)
  if [ -z "$repo_name" ]; then
    repo_name="local repository"
  fi
  
  # Prepare Git context
  local git_context="Git Context:
- Repository: $repo_name
- Current Branch: $current_branch
- Recent Commits:
$recent_commits"

  # Combine with original prompt
  echo "$git_context

$base_prompt"
  return 0
}

# Make provider-specific API request
make_api_request() {
  local prompt="$1"
  local provider="$2"
  local api_key="$3"
  
  # Ensure curl is available
  if ! command -v curl &>/dev/null; then
    echo "Error: curl is required for AI requests but was not found."
    return 1
  fi
  
  case "$provider" in
    "OpenAI")
      make_openai_request "$prompt" "$api_key"
      return $?
      ;;
    "Claude")
      make_claude_request "$prompt" "$api_key"
      return $?
      ;;
    "Gemini")
      make_gemini_request "$prompt" "$api_key"
      return $?
      ;;
    "DeepSeek")
      make_deepseek_request "$prompt" "$api_key"
      return $?
      ;;
    *)
      echo "Error: Unsupported AI provider: $provider"
      return 1
      ;;
  esac
}

# Make OpenAI API request
make_openai_request() {
  local prompt="$1"
  local api_key="$2"
  
  # Prepare the request data
  local request_data=$(cat <<EOF
{
  "model": "gpt-4o",
  "messages": [
    {"role": "system", "content": "You are a helpful Git assistant integrated with Git Monkey. Keep responses concise, practical, and focused on helping users solve their Git and development workflow challenges."},
    {"role": "user", "content": "$prompt"}
  ],
  "temperature": 0.3,
  "max_tokens": 500
}
EOF
)

  # Make the API request
  local response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $api_key" \
    -d "$request_data")
  
  # Check for errors
  if [[ "$response" == *"error"* ]]; then
    echo "OpenAI API error: $(echo "$response" | grep -o '"message":"[^"]*"')"
    return 1
  fi
  
  # Extract the content
  if command -v jq &>/dev/null; then
    echo "$response" | jq -r '.choices[0].message.content'
  else
    # Fallback without jq
    echo "$response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4
  fi
  
  return 0
}

# Make Claude API request
make_claude_request() {
  local prompt="$1"
  local api_key="$2"
  
  # Prepare the request data
  local request_data=$(cat <<EOF
{
  "model": "claude-3-haiku-20240307",
  "max_tokens": 500,
  "messages": [
    {"role": "user", "content": "$prompt"}
  ]
}
EOF
)

  # Make the API request
  local response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $api_key" \
    -H "anthropic-version: 2023-06-01" \
    -d "$request_data")
  
  # Check for errors
  if [[ "$response" == *"error"* ]]; then
    echo "Claude API error: $(echo "$response" | grep -o '"message":"[^"]*"')"
    return 1
  fi
  
  # Extract the content
  if command -v jq &>/dev/null; then
    echo "$response" | jq -r '.content[0].text'
  else
    # Fallback without jq
    echo "$response" | grep -o '"text":"[^"]*"' | cut -d'"' -f4
  fi
  
  return 0
}

# Make Gemini API request
make_gemini_request() {
  local prompt="$1"
  local api_key="$2"
  
  # URL encode the prompt
  prompt=$(echo "$prompt" | sed 's/ /%20/g' | sed 's/\n/%0A/g')
  
  # Make the API request
  local response=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$api_key" \
    -H "Content-Type: application/json" \
    -d "{\"contents\":[{\"parts\":[{\"text\":\"$prompt\"}]}],\"generationConfig\":{\"temperature\":0.3,\"maxOutputTokens\":500}}")
  
  # Check for errors
  if [[ "$response" == *"error"* ]]; then
    echo "Gemini API error: $(echo "$response" | grep -o '"message":"[^"]*"')"
    return 1
  fi
  
  # Extract the content
  if command -v jq &>/dev/null; then
    echo "$response" | jq -r '.candidates[0].content.parts[0].text'
  else
    # Fallback without jq
    echo "$response" | grep -o '"text":"[^"]*"' | cut -d'"' -f4
  fi
  
  return 0
}

# Make DeepSeek API request
make_deepseek_request() {
  local prompt="$1"
  local api_key="$2"
  
  # Prepare the request data
  local request_data=$(cat <<EOF
{
  "model": "deepseek-chat",
  "messages": [
    {"role": "user", "content": "$prompt"}
  ],
  "temperature": 0.3,
  "max_tokens": 500
}
EOF
)

  # Make the API request
  local response=$(curl -s -X POST "https://api.deepseek.com/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $api_key" \
    -d "$request_data")
  
  # Check for errors
  if [[ "$response" == *"error"* ]]; then
    echo "DeepSeek API error: $(echo "$response" | grep -o '"message":"[^"]*"')"
    return 1
  fi
  
  # Extract the content
  if command -v jq &>/dev/null; then
    echo "$response" | jq -r '.choices[0].message.content'
  else
    # Fallback without jq
    echo "$response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4
  fi
  
  return 0
}

# Generate a cache key for a prompt and provider
generate_cache_key() {
  local prompt="$1"
  local provider="$2"
  
  # Create an MD5 hash of the prompt + provider as the cache key
  if command -v md5sum &>/dev/null; then
    echo -n "${prompt}_${provider}" | md5sum | cut -d' ' -f1
  elif command -v md5 &>/dev/null; then
    echo -n "${prompt}_${provider}" | md5
  else
    # Fallback to a simple hash if md5 is not available
    echo "${prompt}_${provider}" | cksum | cut -d' ' -f1
  fi
}

# Check if a cached response exists and is valid
check_cache() {
  local cache_key="$1"
  local cache_file="$AI_CACHE_DIR/$cache_key"
  
  # Check if cache file exists
  if [ ! -f "$cache_file" ]; then
    return 1
  fi
  
  # Check if cache is expired
  local file_timestamp=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
  local current_timestamp=$(date +%s)
  local age=$((current_timestamp - file_timestamp))
  
  if [ $age -gt $CACHE_TTL ]; then
    # Cache is expired, remove it
    rm "$cache_file" 2>/dev/null
    return 1
  fi
  
  # Cache is valid, return its contents
  cat "$cache_file"
  return 0
}

# Update the cache with a new response
update_cache() {
  local cache_key="$1"
  local response="$2"
  local cache_file="$AI_CACHE_DIR/$cache_key"
  
  # Ensure cache directory exists
  mkdir -p "$AI_CACHE_DIR" 2>/dev/null
  
  # Create JSON structure with metadata for smarter caching
  local timestamp=$(date +%s)
  local content_hash=""
  
  # Generate a hash of the response content if available
  if command -v md5sum &>/dev/null; then
    content_hash=$(echo -n "$response" | md5sum | cut -d' ' -f1)
  elif command -v md5 &>/dev/null; then
    content_hash=$(echo -n "$response" | md5)
  else
    content_hash=$(echo "$response" | cksum | cut -d' ' -f1)
  fi
  
  # Create a metadata JSON
  local metadata=$(cat <<EOF
{
  "timestamp": $timestamp,
  "content_hash": "$content_hash",
  "ttl": $CACHE_TTL,
  "content": $(echo "$response" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
}
EOF
)
  
  # Write to cache file
  echo "$metadata" > "$cache_file"
  
  # Clean up old cache files
  clean_old_cache
  
  # Maintain cache size limit (max 100 cache files)
  limit_cache_size 100
  
  return 0
}

# Check if a cached response exists and is valid with improved logic
check_cache() {
  local cache_key="$1"
  local cache_file="$AI_CACHE_DIR/$cache_key"
  
  # Check if cache file exists
  if [ ! -f "$cache_file" ]; then
    return 1
  fi
  
  # Try to parse the cache file as JSON
  local file_content=$(cat "$cache_file")
  
  # Check if it's a valid JSON cache entry
  if [[ "$file_content" == "{"* ]]; then
    # It's a JSON format cache entry
    
    # Extract timestamp from the JSON
    local cached_timestamp=0
    if command -v jq &>/dev/null; then
      cached_timestamp=$(echo "$file_content" | jq -r '.timestamp // 0')
    else
      # Simple grep approach for environments without jq
      cached_timestamp=$(echo "$file_content" | grep -o '"timestamp":[0-9]*' | cut -d':' -f2)
    fi
    
    # Check if timestamp is valid
    if [ -z "$cached_timestamp" ] || [ "$cached_timestamp" = "null" ]; then
      cached_timestamp=0
    fi
    
    # Check if cache is expired
    local current_timestamp=$(date +%s)
    local age=$((current_timestamp - cached_timestamp))
    
    # Get TTL from cache if available, otherwise use default
    local cache_ttl=$CACHE_TTL
    if command -v jq &>/dev/null; then
      local json_ttl=$(echo "$file_content" | jq -r '.ttl // 0')
      if [ -n "$json_ttl" ] && [ "$json_ttl" != "null" ] && [ "$json_ttl" -gt 0 ]; then
        cache_ttl=$json_ttl
      fi
    fi
    
    if [ $age -gt $cache_ttl ]; then
      # Cache is expired, remove it
      rm "$cache_file" 2>/dev/null
      return 1
    fi
    
    # Extract the content from the JSON
    if command -v jq &>/dev/null; then
      echo "$file_content" | jq -r '.content' | sed 's/\\n/\n/g'
    else
      # Simple grep approach for environments without jq
      # This is a simplified approach that may not work for all JSON structures
      echo "$file_content" | grep -o '"content":"[^"]*"' | cut -d':' -f2- | sed 's/^"//;s/"$//;s/\\n/\n/g'
    fi
    
    return 0
  else
    # It's the old format (just plain text)
    # Check if cache is expired using file timestamp
    local file_timestamp=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
    local current_timestamp=$(date +%s)
    local age=$((current_timestamp - file_timestamp))
    
    if [ $age -gt $CACHE_TTL ]; then
      # Cache is expired, remove it
      rm "$cache_file" 2>/dev/null
      return 1
    fi
    
    # Cache is valid, return its contents
    cat "$cache_file"
    return 0
  fi
}

# Clean up old cache files
clean_old_cache() {
  # Find and remove expired cache files
  local current_time=$(date +%s)
  
  # Create a temporary file to log deleted files (for debugging)
  local log_file="$AI_CACHE_DIR/cleanup_log.txt"
  echo "Cache cleanup on $(date)" > "$log_file"
  
  if command -v find &>/dev/null; then
    # Linux version - but we need to check content too
    # So we'll use a hybrid approach
    find "$AI_CACHE_DIR" -type f -not -name "cleanup_log.txt" | while read -r file; do
      if [ -f "$file" ]; then
        # First check if it's a JSON format cache
        local file_content=$(cat "$file")
        if [[ "$file_content" == "{"* ]] && command -v jq &>/dev/null; then
          # It's JSON, extract the timestamp and TTL
          local cached_timestamp=$(echo "$file_content" | jq -r '.timestamp // 0')
          local cache_ttl=$(echo "$file_content" | jq -r '.ttl // 0' || echo "$CACHE_TTL")
          
          if [ -z "$cached_timestamp" ] || [ "$cached_timestamp" = "null" ]; then
            cached_timestamp=0
          fi
          
          if [ -z "$cache_ttl" ] || [ "$cache_ttl" = "null" ]; then
            cache_ttl=$CACHE_TTL
          fi
          
          local age=$((current_time - cached_timestamp))
          if [ $age -gt $cache_ttl ]; then
            echo "Removing expired JSON cache: $file (age: $age, ttl: $cache_ttl)" >> "$log_file"
            rm "$file" 2>/dev/null
          fi
        else
          # Use file timestamp for non-JSON or when jq is not available
          local file_time=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
          local age=$((current_time - file_time))
          
          if [ $age -gt $CACHE_TTL ]; then
            echo "Removing expired plain cache: $file (age: $age)" >> "$log_file"
            rm "$file" 2>/dev/null
          fi
        fi
      fi
    done
  else
    # Simple alternative for environments without find
    for file in "$AI_CACHE_DIR"/*; do
      if [ -f "$file" ] && [ "$file" != "$log_file" ]; then
        # Check if it's a JSON format cache
        local file_content=$(cat "$file")
        if [[ "$file_content" == "{"* ]] && command -v jq &>/dev/null; then
          # It's JSON, extract the timestamp and TTL
          local cached_timestamp=$(echo "$file_content" | jq -r '.timestamp // 0')
          local cache_ttl=$(echo "$file_content" | jq -r '.ttl // 0' || echo "$CACHE_TTL")
          
          if [ -z "$cached_timestamp" ] || [ "$cached_timestamp" = "null" ]; then
            cached_timestamp=0
          fi
          
          if [ -z "$cache_ttl" ] || [ "$cache_ttl" = "null" ]; then
            cache_ttl=$CACHE_TTL
          fi
          
          local age=$((current_time - cached_timestamp))
          if [ $age -gt $cache_ttl ]; then
            echo "Removing expired JSON cache: $file (age: $age, ttl: $cache_ttl)" >> "$log_file"
            rm "$file" 2>/dev/null
          fi
        else
          # Use file timestamp for non-JSON or when jq is not available
          local file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
          local age=$((current_time - file_time))
          
          if [ $age -gt $CACHE_TTL ]; then
            echo "Removing expired plain cache: $file (age: $age)" >> "$log_file"
            rm "$file" 2>/dev/null
          fi
        fi
      fi
    done
  fi
  
  return 0
}

# Limit the total number of cache files to prevent excessive disk usage
limit_cache_size() {
  local max_files="$1"
  
  # Count current cache files
  local cache_count=$(ls -1 "$AI_CACHE_DIR" | grep -v "cleanup_log.txt" | wc -l | tr -d '[:space:]')
  
  # If we exceed the limit, remove the oldest files
  if [ "$cache_count" -gt "$max_files" ]; then
    local excess=$((cache_count - max_files))
    
    if command -v find &>/dev/null; then
      # Find the oldest files based on modification time and remove them
      find "$AI_CACHE_DIR" -type f -not -name "cleanup_log.txt" -printf "%T@ %p\n" | sort -n | head -n "$excess" | cut -d' ' -f2- | xargs rm 2>/dev/null
    else
      # Simple alternative for environments without find
      # List files with their modification times, sort, and remove the oldest
      local files_with_times=""
      for file in "$AI_CACHE_DIR"/*; do
        if [ -f "$file" ] && [ "$file" != "$AI_CACHE_DIR/cleanup_log.txt" ]; then
          local file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
          files_with_times="$files_with_times$file_time $file"$'\n'
        fi
      done
      
      echo "$files_with_times" | sort -n | head -n "$excess" | cut -d' ' -f2- | while read -r file; do
        rm "$file" 2>/dev/null
      done
    fi
    
    echo "Removed $excess old cache files to stay under the limit of $max_files" >> "$AI_CACHE_DIR/cleanup_log.txt"
  fi
  
  return 0
}

# Enhanced token estimation for better usage tracking
estimate_tokens() {
  local text="$1"
  
  # If empty, return 0
  if [ -z "$text" ]; then
    echo "0"
    return 0
  fi
  
  # Estimate tokens based on characters (rough approximation)
  # On average, 1 token ~= 4 characters in English
  local char_count=${#text}
  local estimated_tokens=$((char_count / 4))
  
  # Add a margin to be safe
  estimated_tokens=$((estimated_tokens + 20))
  
  echo "$estimated_tokens"
  return 0
}

# Track API usage with enhanced metadata
track_usage() {
  local provider="$1"
  local tokens_used="${2:-0}"
  local prompt="$3"
  local response="$4"
  local usage_file="$HOME/.gitmonkey/ai_usage"
  local usage_detail_dir="$HOME/.gitmonkey/ai_usage_details"
  
  # Ensure usage directories exist
  mkdir -p "$HOME/.gitmonkey" 2>/dev/null
  mkdir -p "$usage_detail_dir" 2>/dev/null
  touch "$usage_file" 2>/dev/null
  
  # If tokens_used is 0 and we have prompt/response, estimate tokens
  if [ "$tokens_used" -eq 0 ] && [ -n "$prompt" ]; then
    # Estimate prompt tokens
    local prompt_tokens=$(estimate_tokens "$prompt")
    
    # Estimate response tokens if available
    local response_tokens=0
    if [ -n "$response" ]; then
      response_tokens=$(estimate_tokens "$response")
    fi
    
    # Total tokens
    tokens_used=$((prompt_tokens + response_tokens))
  fi
  
  # Get current month and year
  local current_month=$(date +%m)
  local current_year=$(date +%Y)
  local month_key="${current_year}_${current_month}"
  local day_key="${current_year}${current_month}$(date +%d)"
  
  # Save detailed usage entry for this request
  local timestamp=$(date +%s)
  local detailed_usage_file="$usage_detail_dir/${month_key}_${provider}.json"
  
  # Create detailed usage entry
  local detail_entry=$(cat <<EOF
{"timestamp": $timestamp, "tokens": $tokens_used, "provider": "$provider", "date": "$(date)"}
EOF
)
  
  # Append to detailed log
  echo "$detail_entry" >> "$detailed_usage_file"
  
  # Update the monthly usage data
  if command -v jq &>/dev/null && [ -f "$usage_file" ] && [ -s "$usage_file" ]; then
    # Try to use jq for JSON handling if available and file exists and is not empty
    local usage_json=$(cat "$usage_file")
    
    # Check if it's valid JSON
    if echo "$usage_json" | jq . >/dev/null 2>&1; then
      # It's valid JSON
      
      # Update the JSON with the new tokens
      if echo "$usage_json" | jq -e ".\"$month_key\".\"$provider\"" >/dev/null 2>&1; then
        # Key exists, update it
        local current_tokens=$(echo "$usage_json" | jq -r ".\"$month_key\".\"$provider\"")
        local new_tokens=$((current_tokens + tokens_used))
        local updated_json=$(echo "$usage_json" | jq --arg mk "$month_key" --arg pv "$provider" --argjson nt "$new_tokens" '.[$mk][$pv] = $nt')
        echo "$updated_json" > "$usage_file"
      else
        # Key doesn't exist, add it
        local updated_json=""
        if echo "$usage_json" | jq -e ".\"$month_key\"" >/dev/null 2>&1; then
          # Month exists but provider doesn't
          updated_json=$(echo "$usage_json" | jq --arg mk "$month_key" --arg pv "$provider" --argjson t "$tokens_used" '.[$mk][$pv] = $t')
        else
          # Month doesn't exist
          updated_json=$(echo "$usage_json" | jq --arg mk "$month_key" --arg pv "$provider" --argjson t "$tokens_used" '.[$mk] = {($pv): $t}')
        fi
        echo "$updated_json" > "$usage_file"
      fi
    else
      # Not valid JSON, create a new one
      echo "{\"$month_key\": {\"$provider\": $tokens_used}}" > "$usage_file"
    fi
  else
    # Simple text-based approach if jq is not available
    if grep -q "$month_key:$provider:" "$usage_file" 2>/dev/null; then
      # Update existing entry
      local current_tokens=$(grep "$month_key:$provider:" "$usage_file" | cut -d':' -f3)
      local new_tokens=$((current_tokens + tokens_used))
      sed -i "s/$month_key:$provider:$current_tokens/$month_key:$provider:$new_tokens/" "$usage_file" 2>/dev/null
      
      # Mac compatibility fix if the above fails
      if [ $? -ne 0 ]; then
        sed -i "" "s/$month_key:$provider:$current_tokens/$month_key:$provider:$new_tokens/" "$usage_file" 2>/dev/null
      fi
    else
      # Add new entry
      echo "$month_key:$provider:$tokens_used" >> "$usage_file"
    fi
  fi
  
  # Check if we're approaching the usage limit
  check_usage_limit_notification
  
  return 0
}

# Enhanced notification for usage limits
check_usage_limit_notification() {
  local current_usage=$(get_current_usage)
  local limit=$(get_usage_limit)
  
  # Convert tokens to estimated cost (very rough estimate)
  # Assuming avg cost of $0.01 per 1000 tokens
  local estimated_cost=$(echo "scale=2; $current_usage / 1000 * 0.01" | bc 2>/dev/null)
  
  if [ -z "$estimated_cost" ]; then
    # Fallback if bc is not available
    estimated_cost=$((current_usage / 100000))
  fi
  
  # Compare with limit (converting to cents)
  local estimated_cents=$(echo "scale=0; $estimated_cost * 100" | bc 2>/dev/null)
  
  if [ -z "$estimated_cents" ]; then
    # Fallback
    estimated_cents=$((current_usage / 1000))
  fi
  
  # Get the percentage of the limit
  local percentage=0
  if [ "$limit" -gt 0 ]; then
    percentage=$(echo "scale=0; $estimated_cents * 100 / $limit" | bc 2>/dev/null || echo "0")
  fi
  
  # Check notification flag to avoid repeated warnings
  local notification_flag="$HOME/.gitmonkey/ai_usage_notified"
  
  # Issue warning at 75% usage
  if [ "$percentage" -ge 75 ] && [ ! -f "$notification_flag" ]; then
    echo "⚠️  WARNING: You have used approximately $percentage% of your monthly AI usage limit."
    echo "    Current usage: ~$$estimated_cost of $$((limit/100)) limit"
    echo "    Adjust your limit in 'gitmonkey settings ai' if needed."
    touch "$notification_flag"
  fi
  
  # Reset notification flag on the first day of the month
  if [ "$(date +%d)" = "01" ] && [ -f "$notification_flag" ]; then
    rm "$notification_flag" 2>/dev/null
  fi
  
  return 0
}

# Get usage for the current month
get_current_usage() {
  local provider="$1"
  local usage_file="$HOME/.gitmonkey/ai_usage"
  
  # Check if usage file exists
  if [ ! -f "$usage_file" ]; then
    echo "0"
    return 0
  fi
  
  # Get current month and year
  local current_month=$(date +%m)
  local current_year=$(date +%Y)
  local month_key="${current_year}_${current_month}"
  
  if [ -z "$provider" ]; then
    # Sum all providers for the current month
    local total=0
    while read -r line; do
      if [[ "$line" == "$month_key:"* ]]; then
        local tokens=$(echo "$line" | cut -d':' -f3)
        total=$((total + tokens))
      fi
    done < "$usage_file"
    echo "$total"
  else
    # Get usage for specific provider
    local usage=$(grep "$month_key:$provider:" "$usage_file" 2>/dev/null | cut -d':' -f3)
    if [ -z "$usage" ]; then
      echo "0"
    else
      echo "$usage"
    fi
  fi
  
  return 0
}

# Check if usage is within limits
check_usage_limit() {
  local current_usage=$(get_current_usage)
  local limit=$(get_usage_limit)
  
  # Convert tokens to estimated cost (very rough estimate)
  # Assuming avg cost of $0.01 per 1000 tokens
  local estimated_cost=$(echo "scale=2; $current_usage / 1000 * 0.01" | bc 2>/dev/null)
  
  if [ -z "$estimated_cost" ]; then
    # Fallback if bc is not available
    estimated_cost=$((current_usage / 100000))
  fi
  
  # Compare with limit (converting to cents)
  local estimated_cents=$(echo "scale=0; $estimated_cost * 100" | bc 2>/dev/null)
  
  if [ -z "$estimated_cents" ]; then
    # Fallback
    estimated_cents=$((current_usage / 1000))
  fi
  
  if [ "$estimated_cents" -gt "$limit" ]; then
    return 1
  else
    return 0
  fi
}