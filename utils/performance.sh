#!/bin/bash

# ========= GIT MONKEY PERFORMANCE TRACKER =========
# Tracks and reports on execution times to subtly demonstrate CLI efficiency

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/profile.sh"

# File to store performance metrics
PERFORMANCE_DATA_FILE="$HOME/.gitmonkey/performance.json"

# Make sure our data file exists with basic structure
initialize_performance_data() {
  if [ ! -f "$PERFORMANCE_DATA_FILE" ]; then
    mkdir -p "$(dirname "$PERFORMANCE_DATA_FILE")" 2>/dev/null
    echo '{"commands":{}, "operations":{}, "totals":{"time_saved":0, "operations_count":0}}' > "$PERFORMANCE_DATA_FILE"
  fi
}

# Start timing an operation
start_timing() {
  # Store start time in milliseconds
  local start_time=$(date +%s.%N)
  echo "$start_time"
}

# End timing and return duration
end_timing() {
  local start_time="$1"
  local end_time=$(date +%s.%N)
  
  # Calculate duration in seconds with millisecond precision
  local duration=$(echo "$end_time - $start_time" | bc)
  echo "$duration"
}

# Record the time for a command execution
record_command_time() {
  local command="$1"
  local duration="$2"
  
  initialize_performance_data
  
  # Load current data
  local data=$(cat "$PERFORMANCE_DATA_FILE")
  
  # Update command timings
  local command_data=$(echo "$data" | jq --arg cmd "$command" --arg dur "$duration" \
    '.commands[$cmd] = (.commands[$cmd] // {"count": 0, "total_time": 0, "times": []}) | 
     .commands[$cmd].count = (.commands[$cmd].count + 1) | 
     .commands[$cmd].total_time = (.commands[$cmd].total_time + ($dur | tonumber)) | 
     .commands[$cmd].times = (.commands[$cmd].times + [($dur | tonumber)]) | 
     .commands[$cmd].avg_time = (.commands[$cmd].total_time / .commands[$cmd].count)')
  
  # Save updated data
  echo "$command_data" > "$PERFORMANCE_DATA_FILE"
}

# Record the time for a specific operation (like commit, branch creation, etc.)
record_operation_time() {
  local operation="$1"
  local duration="$2"
  
  initialize_performance_data
  
  # Load current data
  local data=$(cat "$PERFORMANCE_DATA_FILE")
  
  # Research-based reference times for common operations (in seconds)
  # These are conservative estimates for equivalent GUI operations
  # We use these to calculate efficiency gains without direct comparison
  local reference_time=0
  case "$operation" in
    "commit")
      reference_time=8.0
      ;;
    "branch_create")
      reference_time=7.0
      ;;
    "push")
      reference_time=5.0
      ;;
    "status_check")
      reference_time=3.0
      ;;
    "checkout")
      reference_time=5.0
      ;;
    "merge")
      reference_time=10.0
      ;;
    "conflict_resolution")
      reference_time=30.0
      ;;
    *)
      reference_time=3.0
      ;;
  esac
  
  # Calculate time saved (if faster than reference)
  local time_saved=0
  if (( $(echo "$reference_time > $duration" | bc -l) )); then
    time_saved=$(echo "$reference_time - $duration" | bc)
  fi
  
  # Update operation timings
  local operation_data=$(echo "$data" | jq --arg op "$operation" --arg dur "$duration" --arg ref "$reference_time" --arg saved "$time_saved" \
    '.operations[$op] = (.operations[$op] // {"count": 0, "total_time": 0, "times": [], "reference_time": 0, "time_saved": 0}) | 
     .operations[$op].count = (.operations[$op].count + 1) | 
     .operations[$op].total_time = (.operations[$op].total_time + ($dur | tonumber)) | 
     .operations[$op].times = (.operations[$op].times + [($dur | tonumber)]) | 
     .operations[$op].avg_time = (.operations[$op].total_time / .operations[$op].count) |
     .operations[$op].reference_time = ($ref | tonumber) |
     .operations[$op].time_saved = (.operations[$op].time_saved + ($saved | tonumber)) |
     .totals.time_saved = (.totals.time_saved + ($saved | tonumber)) |
     .totals.operations_count = (.totals.operations_count + 1)')
  
  # Save updated data
  echo "$operation_data" > "$PERFORMANCE_DATA_FILE"
  
  # Return the time saved for potential feedback
  echo "$time_saved"
}

# Get average time for an operation
get_avg_time() {
  local operation="$1"
  
  initialize_performance_data
  
  # Load current data
  local data=$(cat "$PERFORMANCE_DATA_FILE")
  
  # Get average time
  local avg_time=$(echo "$data" | jq -r --arg op "$operation" '.operations[$op].avg_time // 0')
  
  echo "$avg_time"
}

# Get total time saved across all operations
get_total_time_saved() {
  initialize_performance_data
  
  # Load current data
  local data=$(cat "$PERFORMANCE_DATA_FILE")
  
  # Get total time saved
  local time_saved=$(echo "$data" | jq -r '.totals.time_saved // 0')
  
  echo "$time_saved"
}

# Show performance improvements message (called occasionally)
show_performance_insight() {
  local tone_stage=${1:-$(get_tone_stage)}
  local time_saved=$(get_total_time_saved)
  
  # Only show for earlier tone stages and only sometimes
  if [ "$tone_stage" -le 3 ] && (( RANDOM % 5 == 0 )); then
    if (( $(echo "$time_saved > 10" | bc -l) )); then
      # Format time saved nicely
      local minutes=$(echo "scale=1; $time_saved / 60" | bc)
      
      # Show message
      echo ""
      echo "⚡ Git Monkey has saved you approximately $minutes minutes so far!"
      
      # More detailed breakdown for very early tone stages
      if [ "$tone_stage" -le 1 ]; then
        echo "   This is time you're saving by using the terminal efficiently."
      fi
    fi
  fi
}

# Time a command execution with tone-appropriate feedback
time_command_with_feedback() {
  local command="$1"
  local operation_type="$2"
  local tone_stage=${3:-$(get_tone_stage)}
  
  # Start timing
  local start_time=$(start_timing)
  
  # Execute the command (rest of the script will handle the actual command)
  # We just record the timing here
  
  # Later, at the end of the command execution, call:
  # local duration=$(end_timing "$start_time")
  # record_command_time "$command" "$duration"
  # local time_saved=$(record_operation_time "$operation_type" "$duration")
  
  # Optionally provide feedback based on tone stage
  # if [ "$tone_stage" -le 2 ] && (( $(echo "$duration < 1.0" | bc -l) )); then
  #   echo "✨ Done in $(printf "%.2f" "$duration")s!"
  # fi
}

# Initialize on source
initialize_performance_data