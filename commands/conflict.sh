#!/bin/bash

# ========= GIT MONKEY CONFLICT RESOLUTION TOOL =========
# Interactive, educational tool for resolving merge conflicts

source ./utils/style.sh
source ./utils/config.sh
source ./utils/profile.sh
source ./utils/identity.sh
source ./utils/performance.sh

# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"  # Can be "info", "success", "error", "warning"
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        "conflict") echo "💥" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "conflict") echo "[CONFLICT]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "conflict") echo "⚔️" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "conflict") echo "🌪️" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "conflict") echo "💥" ;;
        *) echo "🐒" ;;
      esac
      ;;
  esac
}

# Get theme-specific emojis
info_emoji=$(get_theme_emoji "info")
success_emoji=$(get_theme_emoji "success")
error_emoji=$(get_theme_emoji "error")
warning_emoji=$(get_theme_emoji "warning")
conflict_emoji=$(get_theme_emoji "conflict")

# Process flags
auto_resolve=""
explain_mode=""
visual_mode=""

for arg in "$@"; do
  case "$arg" in
    --auto|-a)
      auto_resolve="true"
      shift
      ;;
    --explain|-e)
      explain_mode="true"
      shift
      ;;
    --visual|-v)
      visual_mode="true"
      shift
      ;;
  esac
done

# Function to check if there are merge conflicts
has_merge_conflicts() {
  if git ls-files -u | grep -q .; then
    return 0  # Has conflicts
  else
    return 1  # No conflicts
  fi
}

# Get conflicted files
get_conflicted_files() {
  git diff --name-only --diff-filter=U 2>/dev/null || echo ""
}

# Count conflict markers in a file
count_conflicts_in_file() {
  local file="$1"
  if [ -f "$file" ]; then
    grep -c "^<<<<<<< HEAD" "$file"
  else
    echo "0"
  fi
}

# Show conflict explanation
show_conflict_explanation() {
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "Understanding Git Conflicts"
  else 
    echo "GIT CONFLICT EXPLANATION"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hey $IDENTITY! Let's understand what's happening with these merge conflicts."
    echo ""
  fi
  
  echo "$conflict_emoji Merge conflicts happen when Git can't automatically combine changes."
  echo "   This usually occurs when different people modified the same lines."
  echo ""
  
  # Visual explanation with ASCII art
  echo "Here's what conflict markers look like in your files:"
  echo ""
  echo "┌────────────────────────────────────────────────────────┐"
  echo "│ <<<<<<< HEAD                                           │"
  echo "│ These lines are from the branch you're currently on    │"
  echo "│ (your changes)                                         │"
  echo "│ =======                                                │"
  echo "│ These lines are from the branch you're merging in      │"
  echo "│ (their changes)                                        │"
  echo "│ >>>>>>> branch-name                                    │"
  echo "└────────────────────────────────────────────────────────┘"
  echo ""
  
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "To resolve conflicts, you need to:"
    echo "1. Edit each conflicted file to keep the code you want"
    echo "2. Remove all conflict markers (<<<<<<< HEAD, =======, >>>>>>>)"
    echo "3. Save each file after editing"
    echo "4. git add the resolved files"
    echo "5. Complete the merge with git commit"
    echo ""
    
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "Git Monkey can help you resolve these conflicts step by step!"
      echo "Use 'gitmonkey conflict resolve' to start the interactive resolution process."
      echo ""
    fi
  fi
  
  echo "Remember: It's normal to have conflicts! They're just Git's way of"
  echo "asking for your help to decide which changes to keep."
  echo ""
}

# Show conflict status
show_conflict_status() {
  local start_time=$(start_timing)
  
  if ! has_merge_conflicts; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji Good news, $IDENTITY! You don't have any merge conflicts right now."
    else
      echo "$info_emoji No merge conflicts found."
    fi
    echo ""
    echo "If you're expecting conflicts but don't see any, you might:"
    echo "• Not be in the middle of a merge, rebase, or cherry-pick operation"
    echo "• Have already resolved all conflicts but not completed the merge"
    echo ""
    
    if git status | grep -q "All conflicts fixed but you are still merging"; then
      echo "$success_emoji All conflicts have been resolved! To complete the merge:"
      echo "  git commit"
      echo ""
    fi
    
    local duration=$(end_timing "$start_time")
    record_command_time "conflict_status_no_conflicts" "$duration"
    return 1
  fi
  
  # We have conflicts, show status
  local conflicted_files=($(get_conflicted_files))
  local conflict_count=${#conflicted_files[@]}
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$conflict_emoji $IDENTITY, you have merge conflicts in $conflict_count files:"
  else
    echo "$conflict_emoji Merge conflicts found in $conflict_count files:"
  fi
  
  echo ""
  
  # Show detailed stats for each file
  for file in "${conflicted_files[@]}"; do
    local count=$(count_conflicts_in_file "$file")
    if [ "$count" -eq 1 ]; then
      echo "   $file ($count conflict)"
    else
      echo "   $file ($count conflicts)"
    fi
  done
  
  echo ""
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "Options to resolve conflicts:"
    echo "  gitmonkey conflict resolve        # Interactive conflict resolution"
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "  gitmonkey conflict explain        # Understand conflict markers"
      echo "  gitmonkey conflict visual         # See changes side by side"
    fi
    echo "  gitmonkey conflict abort          # Cancel the merge operation"
    
    if [ "$TONE_STAGE" -le 2 ]; then
      echo ""
      echo "💡 Tip: Conflicts are normal, especially on active branches."
      echo "   Git Monkey can help make them easier to resolve."
    fi
  fi
  
  # Add performance tracking
  local duration=$(end_timing "$start_time")
  record_operation_time "conflict_check" "$duration"
  
  return 0
}

# Resolve a single file conflict
resolve_file_conflict() {
  local file="$1"
  local editor="${EDITOR:-vi}"  # Use default editor or vi
  local conflict_count=$(count_conflicts_in_file "$file")
  
  if [ ! -f "$file" ]; then
    echo "$error_emoji File not found: $file"
    return 1
  fi
  
  if [ "$conflict_count" -eq 0 ]; then
    echo "$info_emoji No conflicts found in this file. It may already be resolved."
    return 0
  fi
  
  # Use the auto-resolve flag if present, otherwise interactive mode
  if [ "$auto_resolve" = "true" ]; then
    # Show file with conflict markers
    echo "File: $file"
    echo "Conflicts: $conflict_count"
    
    # Show auto-resolve options
    echo ""
    echo "Auto-resolve options:"
    echo "  1) Keep our changes (current branch)"
    echo "  2) Keep their changes (merged branch)"
    echo "  3) Keep both changes"
    echo "  4) Skip this file (resolve manually later)"
    echo ""
    read -p "Choose option (1-4): " option
    
    case $option in
      1)
        # Keep our version
        sed -i.bak -e '/^<<<<<<< HEAD$/,/^=======$/!d' -e 's/^<<<<<<< HEAD$//' -e '/^=======$/d' "$file"
        ;;
      2)
        # Keep their version
        sed -i.bak -e '/^=======$/,/^>>>>>>> /!d' -e 's/^=======$//' -e '/^>>>>>>> /d' "$file"
        ;;
      3)
        # Keep both versions
        sed -i.bak -e 's/^<<<<<<< HEAD$//' -e 's/^=======$//' -e 's/^>>>>>>> .*//' "$file"
        ;;
      4)
        # Skip
        echo "Skipping $file"
        return 0
        ;;
      *)
        echo "$error_emoji Invalid option. Skipping $file"
        return 1
        ;;
    esac
    
    # Remove backup file
    rm -f "$file.bak"
    
    # Stage the resolved file
    git add "$file"
    echo "$success_emoji Resolved and staged $file"
    return 0
  else
    # Interactive mode - open in editor
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji Opening $file in your editor. Look for the conflict markers:"
      echo "  <<<<<<< HEAD"
      echo "  ======="
      echo "  >>>>>>> branch-name"
      echo ""
      echo "Edit the file to keep the code you want, and remove ALL markers."
      echo "Save and close the editor when done."
    else
      echo "$info_emoji Opening $file for editing. Remove ALL conflict markers."
    fi
    
    read -p "Press Enter to open in editor..." dummy
    
    # Open the file in the configured editor
    $editor "$file"
    
    # Check if conflicts are resolved
    if grep -q "^<<<<<<< HEAD" "$file"; then
      echo "$warning_emoji Conflict markers still exist in $file."
      echo "You need to resolve them before proceeding."
      read -p "Try again? (y/n): " try_again
      if [[ "$try_again" =~ ^[Yy]$ ]]; then
        resolve_file_conflict "$file"
      else
        echo "Skipping $file"
        return 0
      fi
    else
      # File looks resolved, stage it
      echo "$success_emoji Conflicts in $file appear to be resolved."
      read -p "Stage this file? (Y/n): " stage_file
      if [[ ! "$stage_file" =~ ^[Nn]$ ]]; then
        git add "$file"
        echo "$success_emoji Staged $file"
      else
        echo "File not staged."
      fi
      return 0
    fi
  fi
}

# Interactive conflict resolution for all files
resolve_all_conflicts() {
  local start_time=$(start_timing)
  
  if ! has_merge_conflicts; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji Good news, $IDENTITY! There are no conflicts to resolve right now."
    else
      echo "$info_emoji No conflicts to resolve."
    fi
    
    if git status | grep -q "All conflicts fixed but you are still merging"; then
      echo "$success_emoji All conflicts are resolved! To complete the merge:"
      echo "  git commit"
    fi
    
    return 0
  fi
  
  local conflicted_files=($(get_conflicted_files))
  local total_files=${#conflicted_files[@]}
  local resolved_count=0
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$conflict_emoji Let's resolve the conflicts in $total_files files, $IDENTITY."
    
    # Show conflict explanation for beginners
    if [ "$explain_mode" != "true" ]; then
      show_conflict_explanation
    fi
    
    echo "We'll go through each file one by one."
  else
    echo "$conflict_emoji Resolving conflicts in $total_files files."
  fi
  
  echo ""
  
  # Process each file
  for file in "${conflicted_files[@]}"; do
    echo "File $((resolved_count + 1))/$total_files: $file"
    resolve_file_conflict "$file"
    if [ $? -eq 0 ]; then
      resolved_count=$((resolved_count + 1))
    fi
    echo ""
  done
  
  # Show final status
  if [ "$resolved_count" -eq "$total_files" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      rainbow_box "$success_emoji All $total_files conflicts resolved! Great job, $IDENTITY!"
    else
      echo "$success_emoji All $total_files conflicts resolved."
    fi
    
    # Check if we're still merging
    if git status | grep -q "All conflicts fixed but you are still merging"; then
      echo ""
      echo "To complete the merge, commit your changes:"
      echo "  git commit"
      echo ""
      
      # Offer to create the commit for them
      if [ "$TONE_STAGE" -le 2 ]; then
        read -p "Would you like Git Monkey to commit the merge now? (y/N): " create_commit
        if [[ "$create_commit" =~ ^[Yy]$ ]]; then
          git commit
        fi
      fi
    fi
  else
    echo "$warning_emoji Resolved $resolved_count out of $total_files files."
    echo "You'll need to resolve the remaining files to complete the merge."
  fi
  
  # Record performance metrics
  local duration=$(end_timing "$start_time")
  record_operation_time "conflict_resolution" "$duration"
  
  # Show performance stats occasionally
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo ""
    echo "⚡ Terminal efficiency: Resolved conflicts in $(printf "%.1f" "$duration") seconds!"
    local time_saved=$(echo "30.0 - $duration" | bc -l)
    if (( $(echo "$time_saved > 0" | bc -l) )); then
      echo "   That's $(printf "%.1f" "$time_saved") seconds faster than typical GUI resolution!"
    fi
  fi
  
  return 0
}

# Visual conflict display function - shows conflicts side-by-side
show_visual_conflicts() {
  local start_time=$(start_timing)
  
  if ! has_merge_conflicts; then
    echo "$info_emoji No conflicts to visualize."
    return 1
  fi
  
  local conflicted_files=($(get_conflicted_files))
  local total_files=${#conflicted_files[@]}
  
  echo "$conflict_emoji Visual conflict display for $total_files files:"
  echo ""
  
  for file in "${conflicted_files[@]}"; do
    echo "File: $file"
    echo "-------------------------------------------------------------"
    
    # Define colors
    local ours_color="\033[32m"    # Green
    local theirs_color="\033[36m"  # Cyan
    local reset_color="\033[0m"    # Reset
    
    # Read the file and display conflicts visually
    local in_conflict=false
    local our_lines=""
    local their_lines=""
    
    while IFS= read -r line; do
      if [[ "$line" =~ ^<<<<<<< ]]; then
        in_conflict=true
        our_lines=""
        their_lines=""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "CONFLICT:"
      elif [[ "$line" =~ ^======= ]] && [ "$in_conflict" = true ]; then
        # Print our lines
        echo "OUR CHANGES (HEAD):"
        echo -e "${ours_color}${our_lines}${reset_color}"
        their_lines=""
      elif [[ "$line" =~ ^>>>>>>> ]] && [ "$in_conflict" = true ]; then
        # Print their lines
        echo "THEIR CHANGES (${line#>>>>>>> }):"
        echo -e "${theirs_color}${their_lines}${reset_color}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        in_conflict=false
      else
        if [ "$in_conflict" = true ]; then
          if [ -z "$their_lines" ]; then
            # Still in "our" section
            our_lines="${our_lines}${line}\n"
          else
            # In "their" section
            their_lines="${their_lines}${line}\n"
          fi
        else
          # Non-conflict line
          echo "$line"
        fi
      fi
    done < "$file"
    
    echo ""
    echo ""
  done
  
  echo "$info_emoji Use 'gitmonkey conflict resolve' to interactively resolve these conflicts."
  
  # Record performance metrics
  local duration=$(end_timing "$start_time")
  record_command_time "conflict_visualization" "$duration"
  
  return 0
}

# Abort the current merge
abort_merge() {
  # Check if we're actually in a merge
  if ! git status | grep -q "You have unmerged paths"; then
    echo "$error_emoji Not currently in the middle of a merge."
    return 1
  fi
  
  # Ask for confirmation if not in auto mode
  if [ "$auto_resolve" != "true" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$warning_emoji This will abort the current merge operation, $IDENTITY."
      echo "All conflicts and resolved conflicts will be discarded."
    else
      echo "$warning_emoji This will abort the current merge operation."
    fi
    
    read -p "Are you sure you want to abort? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Merge abort cancelled."
      return 1
    fi
  fi
  
  # Abort the merge
  git merge --abort
  
  if [ $? -eq 0 ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$success_emoji Merge aborted successfully! You're back to where you started, $IDENTITY."
    else
      echo "$success_emoji Merge aborted successfully."
    fi
  else
    echo "$error_emoji Failed to abort merge. Please check 'git status'."
  fi
  
  return 0
}

# Show usage help
show_help() {
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$conflict_emoji Git Monkey Conflict Resolution"
    echo ""
    echo "Hey $IDENTITY! Here's how to handle those pesky merge conflicts:"
  else
    echo "GIT MONKEY CONFLICT RESOLUTION"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Usage:"
    echo "  gitmonkey conflict               # Check for conflicts"
    echo "  gitmonkey conflict resolve       # Resolve conflicts interactively"
    echo "  gitmonkey conflict explain       # Learn about conflict markers"
    echo "  gitmonkey conflict visual        # See conflicts side by side"
    echo "  gitmonkey conflict abort         # Cancel the current merge"
    echo ""
    echo "Options:"
    echo "  --auto, -a    # Auto-resolve with simple options"
    echo "  --visual, -v  # Show visual conflict markers"
    echo "  --explain, -e # Show conflict explanation"
    echo ""
    echo "Example workflow:"
    echo "  1. Try to merge: git merge feature-branch"
    echo "  2. If there are conflicts: gitmonkey conflict resolve"
    echo "  3. Commit the merge when all conflicts are resolved"
    echo ""
  else
    echo "Commands:"
    echo "  conflict              # Check status"
    echo "  conflict resolve      # Interactive resolution"
    echo "  conflict visual       # Side-by-side view"
    echo "  conflict abort        # Cancel merge"
    echo "  conflict explain      # Show marker explanation"
    echo ""
    echo "Options: --auto (-a), --visual (-v), --explain (-e)"
  fi
}

# Main function
main() {
  local subcommand="${1:-status}"
  shift 2>/dev/null || true
  
  # Record starting time for performance tracking
  local start_time=$(start_timing)
  
  case "$subcommand" in
    status|check|"")
      show_conflict_status
      ;;
    explain|markers)
      show_conflict_explanation
      ;;
    resolve|fix)
      resolve_all_conflicts
      ;;
    visual|view)
      show_visual_conflicts
      ;;
    abort|cancel)
      abort_merge
      ;;
    help|--help|-h)
      show_help
      ;;
    *)
      echo "$error_emoji Unknown subcommand: $subcommand"
      show_help
      ;;
  esac
  
  # Record overall command time
  local total_duration=$(end_timing "$start_time")
  record_command_time "conflict_$subcommand" "$total_duration"
}

# Run main function with all arguments
main "$@"