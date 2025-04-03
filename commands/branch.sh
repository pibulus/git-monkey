#!/bin/bash

# ========= GIT MONKEY BRANCH TOOL =========

source ./utils/style.sh
source ./utils/config.sh
source ./utils/profile.sh
source ./utils/identity.sh
source ./utils/ai_keys.sh
source ./utils/ai_request.sh

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
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        *) echo "🐒" ;;
      esac
      ;;
  esac
}

# Process flags
auto_yes=""
force=""
suggest_mode=""

for arg in "$@"; do
  case "$arg" in
    --yes|-y|--auto)
      auto_yes="true"
      shift
      ;;
    --force|-f)
      force="true"
      shift
      ;;
    --suggest|--ai)
      suggest_mode="true"
      shift
      ;;
  esac
done

# Function to suggest branch names with AI
suggest_branch_name() {
  # Check if AI is configured
  if ! has_ai_providers; then
    echo "❌ AI features are not configured yet."
    echo "Run 'gitmonkey settings ai' to set up AI integration."
    return 1
  fi
  
  # Get default provider
  local provider=$(get_default_ai_provider)
  
  if [ -z "$provider" ]; then
    echo "❌ No default AI provider set."
    echo "Run 'gitmonkey settings ai' to set a default provider."
    return 1
  fi
  
  # Get git context for better suggestions
  local context=""
  
  # Get recent commits
  local recent_commits=$(git log -5 --pretty=format:"%s" 2>/dev/null)
  
  # Get current branch
  local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  
  # Get open files
  local changed_files=$(git status -s 2>/dev/null | head -5)
  
  # Get repo name
  local repo_name=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)" || echo "local repository")
  
  # Show what we're doing
  # Theme-specific loading messages
  case "$THEME" in
    "jungle")
      echo "🐒 Monkey analyzing your work to suggest branch names..."
      ;;
    "hacker")
      echo "> Analyzing repository context..."
      echo "> Generating branch name vectors..."
      ;;
    "wizard")
      echo "🧙‍♂️ Consulting the magical branch naming oracle..."
      ;;
    "cosmic")
      echo "🔭 Scanning the code cosmos for branch name patterns..."
      ;;
    *)
      echo "Analyzing repository context for branch name suggestions..."
      ;;
  esac
  
  # Create a prompt based on the theme
  local prompt=""
  
  case "$THEME" in
    "jungle")
      prompt="You're Git Monkey - a helpful, jungle-themed Git assistant. I need suggestions for a Git branch name. Please look at my recent work and suggest 5 meaningful branch names following conventional branch naming patterns like feature/, fix/, chore/, docs/, etc.

Repository: $repo_name
Current branch: $current_branch
Recent commits:
$recent_commits
Current file changes:
$changed_files

Give me a list of 5 branch name suggestions, each on a new line. Each branch name should be less than 30 characters, use dashes or underscores as separators (no spaces), and clearly describe what the branch is for based on the context. Don't use bullet points or numbers in the output, just pure branch names."
      ;;
    "hacker")
      prompt="You're a terminal-based Git assistant with a hacker aesthetic. I need suggestions for a Git branch name. Generate 5 branch name suggestions based on the repository context. Follow conventional branch naming patterns like feature/, fix/, chore/, docs/, etc.

Repository: $repo_name
Current branch: $current_branch
Recent commits:
$recent_commits
Current file changes:
$changed_files

Output format: 5 branch names, one per line. Keep them under 30 characters, use dashes or underscores as separators (no spaces), and make them descriptive based on context. Pure branch names only, no formatting."
      ;;
    "wizard")
      prompt="You're a magical Git Wizard - a mystical Git assistant. Create 5 branch name suggestions for my repository. Follow conventional branch naming patterns like feature/, fix/, chore/, docs/, etc.

Repository: $repo_name
Current branch: $current_branch
Recent commits:
$recent_commits
Current file changes:
$changed_files

Provide 5 branch name suggestions, each on a new line. Names should be less than 30 characters, use dashes or underscores as separators (no spaces), and clearly describe what the branch is for based on the context. No bullet points or numbers, just pure branch names."
      ;;
    "cosmic")
      prompt="You're the Cosmic Git Navigator - a space-themed Git assistant. I need suggestions for a Git branch name that aligns with the cosmic flow of my repository. Suggest 5 branch names following conventional branch naming patterns like feature/, fix/, chore/, docs/, etc.

Repository: $repo_name
Current branch: $current_branch
Recent commits:
$recent_commits
Current file changes:
$changed_files

Return 5 branch name suggestions, one per line. Each branch name should be less than 30 characters, use dashes or underscores as separators (no spaces), and clearly describe what the branch is for based on the context. Output only the branch names with no additional formatting."
      ;;
    *)
      prompt="As a Git assistant, suggest 5 meaningful branch names based on this repository context. Follow conventional branch naming patterns like feature/, fix/, chore/, docs/, etc.

Repository: $repo_name
Current branch: $current_branch
Recent commits:
$recent_commits
Current file changes:
$changed_files

Return 5 branch name suggestions, one per line. Each branch name should be less than 30 characters, use dashes or underscores as separators (no spaces), and clearly describe what the branch is for based on the context. Output only the branch names with no additional formatting."
      ;;
  esac
  
  # Make the AI request
  local ai_response=$(ai_request "$prompt" "$provider" true 2)
  local request_status=$?
  
  if [ $request_status -ne 0 ] || [ -z "$ai_response" ]; then
    echo "❌ Failed to generate branch name suggestions."
    echo "Error: $ai_response"
    return 1
  fi
  
  # Clean up the response and extract the branch names
  local branch_suggestions=()
  while read -r line; do
    # Skip empty lines and lines with formatting characters
    if [ -n "$line" ] && [[ ! "$line" =~ \*|\-|[0-9]\. ]]; then
      branch_suggestions+=("$line")
    fi
  done <<< "$ai_response"
  
  # Show the suggestions
  echo ""
  echo "✅ Branch name suggestions ready!"
  echo ""
  
  # Show the suggestions with numbers
  for i in "${!branch_suggestions[@]}"; do
    echo "$((i+1))) ${branch_suggestions[$i]}"
  done
  
  echo ""
  echo "6) Enter a custom branch name"
  echo "7) Cancel"
  echo ""
  
  read -p "Choose a branch name (1-7): " branch_choice
  
  case "$branch_choice" in
    [1-5])
      # Check that we have enough suggestions
      if [ "${#branch_suggestions[@]}" -ge "$branch_choice" ]; then
        local selected_branch="${branch_suggestions[$((branch_choice-1))]}"
        create_new_branch "$selected_branch"
        return $?
      else
        echo "❌ Invalid selection."
        return 1
      fi
      ;;
    6)
      read -p "Enter your branch name: " custom_branch
      if [ -z "$custom_branch" ]; then
        echo "❌ Branch name cannot be empty."
        return 1
      fi
      create_new_branch "$custom_branch"
      return $?
      ;;
    7|*)
      echo "Branch creation cancelled."
      return 1
      ;;
  esac
  
  return 0
}

# Function to check for uncommitted changes
has_uncommitted_changes() {
  if [ -n "$(git status --porcelain)" ]; then
    return 0  # Has changes
  else
    return 1  # No changes
  fi
}

# Function to handle branch checkout with uncommitted changes
checkout_with_changes_check() {
  local target_branch="$1"
  
  # Don't check if force flag is set
  if [ "$force" == "true" ]; then
    git checkout "$target_branch"
    return $?
  fi
  
  # Check for uncommitted changes
  if has_uncommitted_changes; then
    # [Step 1] Detect issue - uncommitted changes exist
    
    # [Step 2] Show friendly explanation
    echo "🐒 Looks like you have uncommitted changes in your current branch."
    echo "    Here's what's happening:"
    echo "    • You have local modifications that aren't committed"
    echo "    • Switching branches now could cause confusion later"
    echo "    • Git Monkey can help you handle this situation"
    
    # [Step 3] Offer to fix it
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, stash automatically
      stash_name="gitmonkey_branch_switch_$(date +"%Y%m%d_%H%M%S")"
      echo "🔄 Auto-stashing your changes as '$stash_name'..."
      git stash save "$stash_name"
      if [ $? -ne 0 ]; then
        echo "❌ Failed to stash changes."
        return 1
      fi
      git checkout "$target_branch"
      return $?
    else
      echo "How would you like to proceed?"
      echo "  1) Stash changes automatically (can be restored later)"
      echo "  2) Commit changes to current branch first"
      echo "  3) Force switch (might cause issues if files overlap)"
      echo "  4) Cancel and stay on current branch"
      read -p "Enter option (1-4): " option
      
      case $option in
        1)
          # Stash changes
          stash_name="gitmonkey_branch_switch_$(date +"%Y%m%d_%H%M%S")"
          echo "🔄 Stashing your changes as '$stash_name'..."
          git stash save "$stash_name"
          if [ $? -ne 0 ]; then
            echo "❌ Failed to stash changes."
            return 1
          fi
          echo "✅ Changes stashed successfully."
          echo "💡 To restore these changes later, use: git stash apply stash^{/$stash_name}"
          git checkout "$target_branch"
          return $?
          ;;
        2)
          echo "👍 Good choice. Let's commit your changes first."
          read -p "Enter commit message: " commit_message
          if [ -z "$commit_message" ]; then
            commit_message="WIP: Changes before switching to $target_branch"
          fi
          git add .
          git commit -m "$commit_message"
          if [ $? -ne 0 ]; then
            echo "❌ Failed to commit changes."
            return 1
          fi
          echo "✅ Changes committed successfully."
          git checkout "$target_branch"
          return $?
          ;;
        3)
          echo "⚠️ Proceeding with uncommitted changes. This might lead to confusion later."
          git checkout "$target_branch"
          return $?
          ;;
        4)
          echo "👍 Staying on current branch. No changes made."
          return 1
          ;;
        *)
          echo "❌ Invalid option. Staying on current branch."
          return 1
          ;;
      esac
    fi
  else
    # No uncommitted changes, safe to proceed
    git checkout "$target_branch"
    return $?
  fi
}

# Function to handle branch creation
create_new_branch() {
  local new_branch="$1"
  
  # Validate branch name - no spaces or special chars except dash and underscore
  if [[ ! "$new_branch" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "🚫 Branch names should only contain letters, numbers, dashes and underscores."
    echo "Example: feature-user-login or bugfix_header"
    return 1
  fi
  
  # Check if branch already exists
  if git show-ref --verify --quiet refs/heads/"$new_branch"; then
    # [Step 1] Detect issue - branch already exists
    
    # Get theme-specific emojis
    info_emoji=$(get_theme_emoji "info")
    warning_emoji=$(get_theme_emoji "warning")
    success_emoji=$(get_theme_emoji "success")
    error_emoji=$(get_theme_emoji "error")
    
    # [Step 2] Show friendly explanation with tone-appropriate detail
    if [ "$TONE_STAGE" -le 2 ]; then
      # Beginners get detailed explanation with identity
      echo "$info_emoji Hey $IDENTITY! The branch '$new_branch' already exists."
      echo "    Here's what's happening:"
      echo "    • You're trying to create a branch with a name that's already used"
      echo "    • Git Monkey can help you handle this situation"
    elif [ "$TONE_STAGE" -le 3 ]; then
      # Intermediate users get medium explanation
      echo "$info_emoji Branch '$new_branch' already exists."
      echo "    You can switch to it or create a different branch."
    else
      # Expert users get minimal explanation
      echo "$info_emoji Branch '$new_branch' exists." 
    fi
    
    # [Step 3] Offer to fix it with tone-appropriate options
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, just switch to existing branch
      echo "🔄 Switching to existing branch '$new_branch' instead..."
      git checkout "$new_branch"
      return $?
    else
      # Adjust prompt based on tone stage
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "What would you like to do, $IDENTITY?"
      else 
        echo "Options:"
      fi
      
      echo "  1) Switch to the existing branch"
      echo "  2) Create a similar branch with a different name"
      echo "  3) Cancel branch creation"
      
      # Customize the prompt based on tone
      if [ "$TONE_STAGE" -le 2 ]; then
        read -p "$info_emoji Enter option (1-3): " option
      else
        read -p "Enter option (1-3): " option
      fi
      
      case $option in
        1)
          if [ "$TONE_STAGE" -le 3 ]; then
            echo "$info_emoji Switching to existing branch '$new_branch'..."
          else
            echo "Switching to '$new_branch'..."
          fi
          checkout_with_changes_check "$new_branch"
          return $?
          ;;
        2)
          if [ "$TONE_STAGE" -le 2 ]; then
            read -p "Enter a new branch name: " alternative_name
          else
            read -p "New branch name: " alternative_name
          fi
          
          if [ -z "$alternative_name" ]; then
            echo "$error_emoji Branch name cannot be empty."
            return 1
          fi
          create_new_branch "$alternative_name"
          return $?
          ;;
        3)
          if [ "$TONE_STAGE" -le 2 ]; then
            echo "👍 No problem, $IDENTITY! We've cancelled the branch creation."
          else
            echo "👍 Cancelled branch creation."
          fi
          return 1
          ;;
        *)
          echo "$error_emoji Invalid option. Cancelled branch creation."
          return 1
          ;;
      esac
    fi
  fi
  
  # Check for uncommitted changes before creating branch
  if has_uncommitted_changes && [ "$force" != "true" ]; then
    # [Step 1] Detect issue - uncommitted changes exist
    
    # Get theme-specific emojis
    info_emoji=$(get_theme_emoji "info")
    warning_emoji=$(get_theme_emoji "warning")
    success_emoji=$(get_theme_emoji "success")
    error_emoji=$(get_theme_emoji "error")
    
    # [Step 2] Show friendly explanation with tone-appropriate detail
    if [ "$TONE_STAGE" -le 2 ]; then
      # Beginners get detailed explanation with identity
      echo "$info_emoji $IDENTITY, I noticed you have uncommitted changes while creating a new branch."
      echo "    Here's what's happening:"
      echo "    • Your working directory has unsaved modifications"
      echo "    • When you create a new branch, these changes will come with you"
      echo "    • This is usually fine, but you might want to commit first for cleaner history"
    elif [ "$TONE_STAGE" -le 3 ]; then
      # Intermediate users get medium explanation
      echo "$info_emoji Uncommitted changes detected while creating branch."
      echo "    These changes will come with you to the new branch."
      echo "    Consider committing for cleaner history."
    else
      # Expert users get minimal explanation
      echo "$info_emoji Uncommitted changes detected."
    fi
    
    # [Step 3] Offer to fix it - with tone-appropriate prompting
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, just proceed
      echo "🔄 Creating branch with uncommitted changes..."
    else
      # Adjust prompt based on tone stage
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "How would you like to proceed, $IDENTITY?"
      else
        echo "Options:"
      fi
      
      echo "  1) Create branch with uncommitted changes (they'll come with you)"
      echo "  2) Commit changes to current branch first, then create new branch"
      echo "  3) Cancel branch creation"
      
      # Customize the prompt based on tone
      if [ "$TONE_STAGE" -le 2 ]; then
        read -p "$info_emoji Enter option (1-3): " option
      else
        read -p "Enter option (1-3): " option
      fi
      
      case $option in
        1)
          # Tone-appropriate response
          if [ "$TONE_STAGE" -le 3 ]; then
            echo "$info_emoji Creating branch with uncommitted changes..."
          else
            echo "Creating branch with changes..."
          fi
          # Just continue with branch creation
          ;;
        2)
          # Tone-appropriate response
          if [ "$TONE_STAGE" -le 2 ]; then
            echo "👍 Good choice, $IDENTITY! Let's commit your changes first."
            read -p "Enter a commit message that describes your changes: " commit_message
          else
            echo "👍 Committing changes first."
            read -p "Commit message: " commit_message
          fi
          
          if [ -z "$commit_message" ]; then
            commit_message="WIP: Changes before creating branch $new_branch"
          fi
          git add .
          git commit -m "$commit_message"
          if [ $? -ne 0 ]; then
            echo "$error_emoji Failed to commit changes."
            return 1
          fi
          
          # Success message based on tone
          if [ "$TONE_STAGE" -le 2 ]; then
            echo "$success_emoji Great! Changes committed successfully."
          else
            echo "$success_emoji Changes committed."
          fi
          # Now continue with branch creation
          ;;
        3)
          # Tone-appropriate response
          if [ "$TONE_STAGE" -le 2 ]; then
            echo "👍 No problem, $IDENTITY! We've cancelled the branch creation."
          else
            echo "👍 Branch creation cancelled."
          fi
          return 1
          ;;
        *)
          echo "$error_emoji Invalid option. Branch creation cancelled."
          return 1
          ;;
      esac
    fi
  fi
  
  # Create the branch
  # Get theme-specific emojis
  info_emoji=$(get_theme_emoji "info")
  warning_emoji=$(get_theme_emoji "warning")
  success_emoji=$(get_theme_emoji "success")
  error_emoji=$(get_theme_emoji "error")
  
  git checkout -b "$new_branch" || { 
    echo "$error_emoji Something went wrong creating branch '$new_branch'"
    echo "$(random_fail)"
    return 1
  }
  
  # Customize success message based on tone and theme
  if [ "$TONE_STAGE" -le 2 ]; then
    # Beginners get colorful enthusiasm
    rainbow_box "🌱 Awesome, $IDENTITY! You're now on '$new_branch'"
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get clear confirmation
    rainbow_box "🌱 Now on branch '$new_branch'"
  else
    # Expert users get minimal confirmation
    echo "$success_emoji Switched to new branch '$new_branch'"
  fi
  
  # Random success message for lower tone stages only
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "$(random_success)"
  fi
  
  # [Step 4] Offer smart next steps with tone-aware detail
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    # Beginners get detailed next steps with commands
    echo "$info_emoji Next steps you might want to consider, $IDENTITY:"
    echo "   • Make your changes and commit them: git add . && git commit -m \"your message\""
    echo "   • Push this branch remotely: gitmonkey push"
    echo "   • Create a worktree for easy context switching: gitmonkey worktree:add $new_branch"
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get more concise suggestions
    echo "$info_emoji Suggested next steps:"
    echo "   • Make changes and commit them"
    echo "   • Push: gitmonkey push"
    echo "   • Create worktree: gitmonkey worktree:add $new_branch"
  else
    # Expert users get minimal suggestions
    echo "$info_emoji Next: commit, push, or worktree:add"
  fi
  
  return 0
}

# Function to handle branch deletion with safety
delete_branch() {
  local branch_to_delete="$1"
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  
  # Can't delete the current branch
  if [ "$branch_to_delete" == "$current_branch" ]; then
    # [Step 1] Detect issue - trying to delete current branch
    
    # [Step 2] Show friendly explanation
    echo "🐒 You're trying to delete the branch you're currently on."
    echo "    Here's what's happening:"
    echo "    • Git won't let you delete your current branch"
    echo "    • You need to switch to a different branch first"
    
    # [Step 3] Offer to fix it
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, switch to main/master
      local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
      if [ -z "$default_branch" ]; then
        default_branch="main"
        git show-ref --verify --quiet refs/heads/main || default_branch="master"
      fi
      
      echo "🔄 Switching to '$default_branch' branch first..."
      checkout_with_changes_check "$default_branch"
      if [ $? -ne 0 ]; then
        echo "❌ Failed to switch branches."
        return 1
      fi
      # Now that we've switched, delete the original branch
      delete_branch "$branch_to_delete"
      return $?
    else
      echo "How would you like to proceed?"
      echo "  1) Switch to another branch first, then delete '$branch_to_delete'"
      echo "  2) Cancel deletion"
      read -p "Enter option (1-2): " option
      
      case $option in
        1)
          echo "🌴 Available branches to switch to:"
          git branch | grep -v "^*"
          read -p "Enter branch to switch to: " switch_to_branch
          if [ -z "$switch_to_branch" ]; then
            echo "❌ No branch specified."
            return 1
          fi
          echo "🔄 Switching to '$switch_to_branch'..."
          checkout_with_changes_check "$switch_to_branch"
          if [ $? -ne 0 ]; then
            echo "❌ Failed to switch branches."
            return 1
          fi
          # Now that we've switched, delete the original branch
          delete_branch "$branch_to_delete"
          return $?
          ;;
        2)
          echo "👍 Cancelled deletion."
          return 1
          ;;
        *)
          echo "❌ Invalid option. Cancelled deletion."
          return 1
          ;;
      esac
    fi
  fi
  
  # Check if the branch has unmerged changes
  if ! git branch --merged | grep -q "$branch_to_delete"; then
    # [Step 1] Detect issue - branch has unmerged changes
    
    # [Step 2] Show friendly explanation
    echo "🐒 The branch '$branch_to_delete' has changes that haven't been merged."
    echo "    Here's what's happening:"
    echo "    • Git is protecting you from losing potentially important work"
    echo "    • Deleting this branch might cause you to lose unique commits"
    
    # [Step 3] Offer to fix it
    if [ "$force" == "true" ]; then
      # With force flag, delete anyway
      echo "⚠️ Force deleting branch with unmerged changes..."
      git branch -D "$branch_to_delete"
      return $?
    elif [ "$auto_yes" == "true" ]; then
      # With auto_yes but no force, cancel for safety
      echo "❌ Cannot auto-delete branch with unmerged changes without --force flag."
      echo "   This is for your safety, to prevent accidental data loss."
      return 1
    else
      echo "How would you like to proceed?"
      echo "  1) Show unmerged commits to review what might be lost"
      echo "  2) Force delete anyway (⚠️ CANNOT BE UNDONE!)"
      echo "  3) Cancel deletion"
      read -p "Enter option (1-3): " option
      
      case $option in
        1)
          echo "🔍 Unmerged commits in '$branch_to_delete':"
          git log --graph --oneline --decorate "$current_branch..$branch_to_delete"
          echo ""
          read -p "Would you like to force delete this branch? (y/N): " confirm
          if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            git branch -D "$branch_to_delete"
            return $?
          else
            echo "👍 Cancelled deletion."
            return 1
          fi
          ;;
        2)
          read -p "⚠️ Are you ABSOLUTELY SURE? Unmerged work will be LOST FOREVER! (y/N): " confirm
          if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            git branch -D "$branch_to_delete"
            return $?
          else
            echo "👍 Cancelled deletion. Good call!"
            return 1
          fi
          ;;
        3)
          echo "👍 Cancelled deletion."
          return 1
          ;;
        *)
          echo "❌ Invalid option. Cancelled deletion."
          return 1
          ;;
      esac
    fi
  fi
  
  # Regular deletion for merged branches
  git branch -d "$branch_to_delete"
  status=$?
  
  if [ $status -eq 0 ]; then
    rainbow_box "💥 Deleted '$branch_to_delete'"
    echo "$(random_success)"
  else
    echo "❌ Failed to delete branch '$branch_to_delete'"
    echo "$(random_fail)"
  fi
  
  return $status
}

# Function to handle branch merging with safety
merge_branch() {
  local source_branch="$1"
  local target_branch="$2"
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  
  # Check that both branches exist
  if ! git show-ref --verify --quiet refs/heads/"$source_branch"; then
    echo "❌ Branch '$source_branch' doesn't exist."
    return 1
  fi
  
  if ! git show-ref --verify --quiet refs/heads/"$target_branch"; then
    echo "❌ Branch '$target_branch' doesn't exist."
    return 1
  fi
  
  # Check if we need to switch branches first
  if [ "$current_branch" != "$target_branch" ]; then
    # [Step 1] Detect issue - not on target branch
    
    # [Step 2] Show friendly explanation
    echo "🐒 You're currently on '$current_branch', not on '$target_branch'."
    echo "    Here's what's happening:"
    echo "    • To merge '$source_branch' into '$target_branch', we need to be on '$target_branch'"
    echo "    • Git Monkey can handle the branch switching for you"
    
    # [Step 3] Offer to fix it
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, switch automatically
      echo "🔄 Switching to '$target_branch' first..."
      checkout_with_changes_check "$target_branch"
      if [ $? -ne 0 ]; then
        echo "❌ Failed to switch to '$target_branch'."
        return 1
      fi
    else
      read -p "Switch to '$target_branch' first? (Y/n): " switch_confirm
      if [[ "$switch_confirm" != "n" && "$switch_confirm" != "N" ]]; then
        echo "🔄 Switching to '$target_branch'..."
        checkout_with_changes_check "$target_branch"
        if [ $? -ne 0 ]; then
          echo "❌ Failed to switch to '$target_branch'."
          return 1
        fi
      else
        echo "❌ Cannot merge without switching to the target branch."
        return 1
      fi
    fi
  fi
  
  # Check for potential merge conflicts before proceeding
  git merge-tree $(git merge-base HEAD "$source_branch") HEAD "$source_branch" | grep -q "^<<<<<<<" 
  has_conflicts=$?
  
  if [ $has_conflicts -eq 0 ] && [ "$force" != "true" ]; then
    # [Step 1] Detect issue - potential merge conflicts
    
    # [Step 2] Show friendly explanation
    echo "🐒 There might be merge conflicts when merging '$source_branch' into '$target_branch'."
    echo "    Here's what's happening:"
    echo "    • Both branches have changes to the same parts of some files"
    echo "    • Git will need your help to decide which changes to keep"
    
    # [Step 3] Offer to fix it
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, proceed anyway
      echo "⚠️ Proceeding with merge despite potential conflicts..."
    else
      echo "How would you like to proceed?"
      echo "  1) Show which files might have conflicts"
      echo "  2) Proceed with merge anyway (you'll need to resolve conflicts)"
      echo "  3) Cancel merge"
      read -p "Enter option (1-3): " option
      
      case $option in
        1)
          echo "🔍 Files with potential conflicts:"
          git diff --name-only --diff-filter=M "$target_branch"..."$source_branch"
          echo ""
          read -p "Proceed with merge? (y/N): " confirm
          if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "👍 Cancelled merge."
            return 1
          fi
          # Otherwise proceed with merge
          ;;
        2)
          # Proceed with merge
          ;;
        3)
          echo "👍 Cancelled merge."
          return 1
          ;;
        *)
          echo "❌ Invalid option. Cancelled merge."
          return 1
          ;;
      esac
    fi
  fi
  
  # Show animated merge visualization if available
  if [ -f "./commands/visualize.sh" ]; then
    # Use the theme-specific merge animation
    ./commands/visualize.sh --mode=merge "$source_branch" "$target_branch"
  else
    # Simple "merging" message as fallback with educational content based on tone
    if [ "$TONE_STAGE" -le 1 ]; then
      echo "🔄 Merging '$source_branch' into '$target_branch'..."
      echo ""
      echo "Hey $IDENTITY! I'm combining the changes from $source_branch into $target_branch."
      echo "This means all the new code from $source_branch will become part of $target_branch."
      echo "Think of it like combining ingredients to make a delicious recipe!"
      echo ""
    elif [ "$TONE_STAGE" -le 3 ]; then
      echo "🔄 Merging '$source_branch' into '$target_branch'..."
      echo "This will incorporate all commits from $source_branch that aren't already in $target_branch."
      echo ""
    else
      echo "🔄 Merging '$source_branch' into '$target_branch'..."
    fi
  fi
  
  # Perform the merge
  git merge "$source_branch"
  status=$?
  
  if [ $status -eq 0 ]; then
    rainbow_box "🪄 Merged '$source_branch' into '$target_branch'"
    echo "$(random_success)"
    
    # Suggest next steps
    echo ""
    echo "💡 Next steps you might want to consider:"
    echo "   • Push the changes: gitmonkey push"
    echo "   • Delete the merged branch if no longer needed: gitmonkey branch (delete option)"
    echo "   • View branch relationships: gitmonkey visualize"
  else
    echo "❌ Merge encountered issues."
    
    # Check for merge conflicts
    if git status | grep -q "You have unmerged paths"; then
      echo "🐒 You have merge conflicts that need to be resolved."
      echo "    Here's what you need to do:"
      echo "    1. Check which files have conflicts: git status"
      echo "    2. Edit the files to resolve conflicts (look for <<<<<<< markers)"
      echo "    3. Add the resolved files: git add <filename>"
      echo "    4. Complete the merge: git commit"
      echo ""
      echo "    Or if you want to abort the merge: git merge --abort"
    else
      echo "$(random_fail)"
    fi
  fi
  
  return $status
}

# Main branch interface
if [ $# -eq 0 ]; then
  # Interactive mode
  say_hi
  ascii_spell "Branches are just save slots for ideas"
  
  echo ""
  box "What do you want to do with branches?"
  
  PS3=$'\nChoose a branch action: '
  options=("Start a new branch" "Switch to a branch" "Merge a branch" "Delete a branch" "List all branches" "Go back")
  select opt in "${options[@]}"; do
    case $REPLY in
      1)
        read -p "🔧 Name your new branch: " newbranch
        if [ -z "$newbranch" ]; then
          echo "😬 Branch needs a name, mate."
          exit 1
        fi
        
        create_new_branch "$newbranch"
        break
        ;;
      2)
        echo "🌴 Existing branches:"
        git branch
        echo ""
        read -p "🛫 Enter the name of the branch to switch to: " branchname
        if [ -z "$branchname" ]; then
          echo "❌ No branch specified."
          exit 1
        fi
        
        checkout_with_changes_check "$branchname"
        if [ $? -eq 0 ]; then
          rainbow_box "🔄 Switched to '$branchname'"
        fi
        break
        ;;
      3)
        echo "🌴 Existing branches:"
        git branch
        echo ""
        read -p "🧩 Which branch do you want to merge? " mergebranch
        if [ -z "$mergebranch" ]; then
          echo "❌ No branch specified."
          exit 1
        fi
        
        read -p "Into which branch? (default: main): " targetbranch
        targetbranch=${targetbranch:-main}
        
        merge_branch "$mergebranch" "$targetbranch"
        break
        ;;
      4)
        echo "🌴 Existing branches:"
        git branch
        echo ""
        read -p "🗑️ Which branch do you want to delete? " delbranch
        if [ -z "$delbranch" ]; then
          echo "❌ No branch specified."
          exit 1
        fi
        
        delete_branch "$delbranch"
        break
        ;;
      5)
        echo "🌿 Here's what you've got:"
        git branch
        echo ""
        echo "* = current branch"
        echo ""
        git branch -vv
        echo ""
        echo "$(random_success)"
        break
        ;;
      6)
        echo "👋 Back to the main menu..."
        exit 0
        ;;
      *)
        echo "😵‍💫 Pick a number, not a banana."
        ;;
    esac
  done
else
  # Command-line mode with arguments
  subcommand="$1"
  shift
  
  case "$subcommand" in
    new|create)
      # Check if suggest mode is enabled
      if [ "$suggest_mode" = "true" ]; then
        suggest_branch_name
      elif [ $# -eq 0 ]; then
        echo "❌ No branch name provided."
        echo "Usage: gitmonkey branch new <branch-name>"
        echo "       gitmonkey branch new --suggest (for AI suggestions)"
        exit 1
      else
        create_new_branch "$1"
      fi
      ;;
    switch|checkout)
      if [ $# -eq 0 ]; then
        echo "❌ No branch name provided."
        echo "Usage: gitmonkey branch switch <branch-name>"
        exit 1
      fi
      checkout_with_changes_check "$1"
      if [ $? -eq 0 ]; then
        echo "✅ Switched to '$1'"
      fi
      ;;
    merge)
      if [ $# -lt 1 ]; then
        echo "❌ No branch name provided."
        echo "Usage: gitmonkey branch merge <source-branch> [target-branch]"
        exit 1
      fi
      source_branch="$1"
      target_branch="${2:-main}"
      merge_branch "$source_branch" "$target_branch"
      ;;
    delete|remove)
      if [ $# -eq 0 ]; then
        echo "❌ No branch name provided."
        echo "Usage: gitmonkey branch delete <branch-name>"
        exit 1
      fi
      delete_branch "$1"
      ;;
    list)
      echo "🌿 Local branches:"
      git branch -vv
      echo ""
      echo "💫 Remote branches:"
      git branch -r
      ;;
    help|--help)
      echo "🐒 Git Monkey Branch Command"
      echo ""
      echo "Usage:"
      echo "  gitmonkey branch                   - Interactive branch menu"
      echo "  gitmonkey branch new <name>        - Create a new branch"
      echo "  gitmonkey branch new --suggest     - Create a branch with AI name suggestions"
      echo "  gitmonkey branch switch <name>     - Switch to a branch"
      echo "  gitmonkey branch merge <src> [dst] - Merge <src> into [dst] (default: main)"
      echo "  gitmonkey branch delete <name>     - Delete a branch"
      echo "  gitmonkey branch list              - List all branches"
      echo ""
      echo "Options:"
      echo "  --yes, -y          - Auto-confirm prompts"
      echo "  --force, -f        - Override safety checks"
      echo "  --suggest, --ai    - Use AI for suggestions"
      echo ""
      ;;
    *)
      echo "❌ Unknown subcommand: $subcommand"
      echo "Run 'gitmonkey branch --help' for usage information."
      exit 1
      ;;
  esac
fi