#!/bin/bash

# Git Monkey - Smart Push Command
# Auto-sets upstream branch when pushing for the first time

# Load utils
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/style.sh"
source "$SCRIPT_DIR/../utils/config.sh"
source "$SCRIPT_DIR/../utils/profile.sh"
source "$SCRIPT_DIR/../utils/identity.sh"

# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Function to check if branch has upstream configured
has_upstream() {
  git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null
  return $?
}

# Function to check if autoSetupRemote is already configured
is_auto_setup_remote_configured() {
  local setting=$(git config --global push.autoSetupRemote)
  [[ "$setting" == "true" ]]
  return $?
}

# Check that we're in a git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "🙈 This doesn't seem to be a Git repository."
  echo "Try running: git init"
  exit 1
fi

# Get current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Handle different flags
force=""
noconfig=""
auto_yes=""

for arg in "$@"; do
  case $arg in
    --force|-f)
      force="--force"
      ;;
    --no-config)
      noconfig="true"
      ;;
    --yes|-y|--auto)
      auto_yes="true"
      ;;
  esac
done

# Check if we already have an upstream branch set
if has_upstream; then
  echo "🚀 Pushing '$current_branch' to remote..."
  git push $force

  # Add friendly success message
  if [ $? -eq 0 ]; then
    echo "✅ $(random_success)"
  else
    echo "❌ $(random_fail)"
    echo "💡 $(random_tip)"
  fi
  
  exit $?
fi

# No upstream branch, so we need to set it up
# Following the contextual help pattern:

# [Step 1] Detect issue - already done by has_upstream() check

# [Step 2] Show friendly explanation
# Using our theme and tone stage to adjust the message

# Get theme-specific emoji
theme_emoji=""
case "$THEME" in
  "jungle")
    theme_emoji="🐒"
    ;;
  "hacker")
    theme_emoji=">"
    ;;
  "wizard")
    theme_emoji="✨"
    ;;
  "cosmic")
    theme_emoji="🚀"
    ;;
  *)
    theme_emoji="🐒"
    ;;
esac

# Display appropriate greeting based on tone stage
if [ "$TONE_STAGE" -le 2 ]; then
  # Beginners get a personalized identity greeting
  echo "$theme_emoji Hey $IDENTITY! Looks like you're trying to push a branch that doesn't have an upstream yet."
else
  # Advanced users get a more direct message
  echo "$theme_emoji Branch '$current_branch' doesn't have an upstream yet."
fi

# Adjust explanation detail based on tone stage
if [ "$TONE_STAGE" -le 2 ]; then
  # Beginners get detailed explanation
  echo "    Here's what's happening:"
  echo "    • Your branch '$current_branch' exists only on your computer"
  echo "    • It needs to be connected to a remote branch before pushing"
  echo "    • Git Monkey can set this up automatically with:"
  echo "      git push --set-upstream origin $current_branch"
elif [ "$TONE_STAGE" -le 3 ]; then
  # Intermediate users get medium explanation
  echo "    This means your local '$current_branch' needs to be connected to a remote branch."
  echo "    Git Monkey can run: git push --set-upstream origin $current_branch"
else
  # Expert users get minimal explanation
  echo "    Need to run: git push --set-upstream origin $current_branch"
fi

# Check for remotes
remotes=$(git remote)
if [ -z "$remotes" ]; then
  echo "⛔ No remote repositories found."
  echo "Add a remote first: git remote add origin <repository-url>"
  exit 1
fi

# If multiple remotes, use 'origin' by default
remote="origin"
if [[ $(echo "$remotes" | wc -l) -gt 1 ]]; then
  echo "📝 Multiple remotes found. Using '$remote'."
fi

# [Step 3] Offer to fix it - with tone-appropriate prompting
proceed="true"
if [ "$auto_yes" != "true" ]; then
  # Adjust the prompt based on tone stage and identity
  if [ "$TONE_STAGE" -le 2 ]; then
    read -p "$theme_emoji Would you like me to set up the upstream branch and push for you, $IDENTITY? (Y/n): " answer
  elif [ "$TONE_STAGE" -le 3 ]; then
    read -p "$theme_emoji Set up upstream branch and push? (Y/n): " answer
  else
    read -p "$theme_emoji Set upstream & push? (Y/n): " answer
  fi
  
  if [[ "$answer" == "n" || "$answer" == "N" ]]; then
    proceed="false"
    
    # Tone-appropriate response to declining
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "👍 No problem. When you're ready, run:"
      echo "   git push --set-upstream $remote $current_branch"
    else
      echo "👍 Manual command: git push --set-upstream $remote $current_branch"
    fi
    exit 0
  fi
fi

# [Step 4] On confirmation, run the fix
if [ "$proceed" == "true" ]; then
  echo "🚀 Setting upstream and pushing: $remote/$current_branch"
  git push --set-upstream $force $remote $current_branch
fi

# Check if push was successful
push_result=$?
if [ $push_result -eq 0 ]; then
  # Success with theme-aware emoji
  success_emoji="✅"
  case "$THEME" in
    "jungle")
      success_emoji="🍌"
      ;;
    "hacker")
      success_emoji="[OK]"
      ;;
    "wizard")
      success_emoji="✨"
      ;;
    "cosmic")
      success_emoji="🚀"
      ;;
  esac
  
  # Tone-appropriate success message
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$success_emoji Awesome job, $IDENTITY! $(random_success)"
  else
    echo "$success_emoji $(random_success)"
  fi
  
  # Check if we should offer to configure autoSetupRemote
  # This is another application of the contextual help pattern
  if [ "$noconfig" != "true" ] && ! is_auto_setup_remote_configured; then
    # [Step 1] Detect issue - done via is_auto_setup_remote_configured()
    
    # Only suggest config changes for lower tone stages (0-3)
    if [ "$TONE_STAGE" -le 3 ]; then
      # [Step 2] Show friendly explanation with theme-appropriate styling
      echo ""
      echo "$theme_emoji I notice you're doing this manually each time a new branch is created."
      
      # Adjust explanation detail based on tone stage
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "    Git has a setting that can make this automatic for all future branches!"
        echo "    The setting is: git config --global push.autoSetupRemote true"
        echo "    This means you'll just need to type 'git push' for any new branch."
      else
        echo "    Setting push.autoSetupRemote=true would make this automatic."
      fi
      
      # [Step 3] Offer to fix it (only for lower tone stages)
      configure="false"
      if [ "$auto_yes" == "true" ]; then
        configure="true"
      else
        # Personalize the prompt for beginners
        if [ "$TONE_STAGE" -le 2 ]; then
          read -p "Would you like me to enable this setting for you, $IDENTITY? (Y/n): " answer
        else
          read -p "Enable push.autoSetupRemote? (Y/n): " answer
        fi
        
        if [[ "$answer" != "n" && "$answer" != "N" ]]; then
          configure="true"
        fi
      fi
      
      # [Step 4] On confirmation, run the fix
      if [ "$configure" == "true" ]; then
        git config --global push.autoSetupRemote true
        
        # Theme-based success message
        if [ "$TONE_STAGE" -le 2 ]; then
          echo "$success_emoji Configuration updated! New branches will automatically track their remote counterparts."
        else
          echo "$success_emoji push.autoSetupRemote=true configured."
        fi
      else
        if [ "$TONE_STAGE" -le 2 ]; then
          echo "👍 No problem! You can always enable this later with:"
          echo "   git config --global push.autoSetupRemote true"
        else
          echo "👍 Config unchanged."
        fi
      fi
    fi
  fi
else
  # Error with theme-aware emoji
  error_emoji="❌"
  case "$THEME" in
    "jungle")
      error_emoji="🙈"
      ;;
    "hacker")
      error_emoji="[ERROR]"
      ;;
    "wizard")
      error_emoji="⚠️"
      ;;
    "cosmic")
      error_emoji="☄️"
      ;;
  esac
  
  echo "$error_emoji $(random_fail)"
  
  # Apply contextual help for common push errors with tone-appropriate detail
  if [ $push_result -eq 128 ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$theme_emoji Looks like there might be permission issues with the remote repository."
      echo "    Check that you have the right credentials and repository access."
    else
      echo "$theme_emoji Possible permission issues. Check credentials and access."
    fi
  elif [ $push_result -eq 1 ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$theme_emoji The push was rejected. This could be because:"
      echo "    • The remote branch has newer changes (try 'git pull' first)"
      echo "    • You need to use '--force' for non-fast-forward changes"
      echo "    • There may be conflicts that need to be resolved"
    elif [ "$TONE_STAGE" -le 3 ]; then
      echo "$theme_emoji Push rejected. Try git pull first or use --force if appropriate."
    else
      echo "$theme_emoji Non-fast-forward update. Pull first or force push."
    fi
  fi
  
  # Only show tips for lower tone stages
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "💡 $(random_tip)"
  fi
fi

exit $?