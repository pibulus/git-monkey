#!/bin/bash

# Git Monkey - Smart Push Command
# Auto-sets upstream branch when pushing for the first time

# Load utils
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/style.sh"
source "$SCRIPT_DIR/../utils/config.sh"

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
echo "🐒 Looks like you're trying to push a branch that doesn't have an upstream yet."
echo "    Here's what's happening:"
echo "    • Your branch '$current_branch' exists only on your computer"
echo "    • It needs to be connected to a remote branch before pushing"
echo "    • Git Monkey can set this up automatically with:"
echo "      git push --set-upstream origin $current_branch"

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

# [Step 3] Offer to fix it
proceed="true"
if [ "$auto_yes" != "true" ]; then
  read -p "Want me to set up the upstream branch and push? (Y/n): " answer
  if [[ "$answer" == "n" || "$answer" == "N" ]]; then
    proceed="false"
    echo "👍 No problem. When you're ready, run:"
    echo "   git push --set-upstream $remote $current_branch"
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
  echo "✅ $(random_success)"
  
  # Check if we should offer to configure autoSetupRemote
  # This is another application of the contextual help pattern
  if [ "$noconfig" != "true" ] && ! is_auto_setup_remote_configured; then
    # [Step 1] Detect issue - done via is_auto_setup_remote_configured()
    
    # [Step 2] Show friendly explanation
    echo ""
    echo "🐒 I notice you're doing this manually each time a new branch is created."
    echo "    Git has a setting that can make this automatic for all future branches!"
    echo "    The setting is: git config --global push.autoSetupRemote true"
    echo "    This means you'll just need to type 'git push' for any new branch."
    
    # [Step 3] Offer to fix it
    configure="false"
    if [ "$auto_yes" == "true" ]; then
      configure="true"
    else
      read -p "Would you like me to enable this setting for you? (Y/n): " answer
      if [[ "$answer" != "n" && "$answer" != "N" ]]; then
        configure="true"
      fi
    fi
    
    # [Step 4] On confirmation, run the fix
    if [ "$configure" == "true" ]; then
      git config --global push.autoSetupRemote true
      echo "✨ Configuration updated! New branches will automatically track their remote counterparts."
    else
      echo "👍 No problem! You can always enable this later with:"
      echo "   git config --global push.autoSetupRemote true"
    fi
  fi
else
  echo "❌ $(random_fail)"
  
  # Apply contextual help for common push errors
  if [ $push_result -eq 128 ]; then
    echo "🐒 Looks like there might be permission issues with the remote repository."
    echo "    Check that you have the right credentials and repository access."
  elif [ $push_result -eq 1 ]; then
    echo "🐒 The push was rejected. This could be because:"
    echo "    • The remote branch has newer changes (try 'git pull' first)"
    echo "    • You need to use '--force' for non-fast-forward changes"
    echo "    • There may be conflicts that need to be resolved"
  fi
  
  echo "💡 $(random_tip)"
fi

exit $?