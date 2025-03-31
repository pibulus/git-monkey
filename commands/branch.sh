#!/bin/bash

# ========= GIT MONKEY BRANCH TOOL =========

source ./utils/style.sh
source ./utils/config.sh

# Process flags
auto_yes=""
force=""

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
  esac
done

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
    
    # [Step 2] Show friendly explanation
    echo "🐒 The branch '$new_branch' already exists."
    echo "    Here's what's happening:"
    echo "    • You're trying to create a branch with a name that's already used"
    echo "    • Git Monkey can help you handle this situation"
    
    # [Step 3] Offer to fix it
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, just switch to existing branch
      echo "🔄 Switching to existing branch '$new_branch' instead..."
      git checkout "$new_branch"
      return $?
    else
      echo "What would you like to do?"
      echo "  1) Switch to the existing branch"
      echo "  2) Create a similar branch with a different name"
      echo "  3) Cancel branch creation"
      read -p "Enter option (1-3): " option
      
      case $option in
        1)
          echo "🔄 Switching to existing branch '$new_branch'..."
          checkout_with_changes_check "$new_branch"
          return $?
          ;;
        2)
          read -p "Enter a new branch name: " alternative_name
          if [ -z "$alternative_name" ]; then
            echo "❌ Branch name cannot be empty."
            return 1
          fi
          create_new_branch "$alternative_name"
          return $?
          ;;
        3)
          echo "👍 Cancelled branch creation."
          return 1
          ;;
        *)
          echo "❌ Invalid option. Cancelled branch creation."
          return 1
          ;;
      esac
    fi
  fi
  
  # Check for uncommitted changes before creating branch
  if has_uncommitted_changes && [ "$force" != "true" ]; then
    # [Step 1] Detect issue - uncommitted changes exist
    
    # [Step 2] Show friendly explanation
    echo "🐒 You have uncommitted changes while creating a new branch."
    echo "    Here's what's happening:"
    echo "    • Your working directory has unsaved modifications"
    echo "    • When you create a new branch, these changes will come with you"
    echo "    • This is usually fine, but you might want to commit first for cleaner history"
    
    # [Step 3] Offer to fix it
    if [ "$auto_yes" == "true" ]; then
      # With auto_yes, just proceed
      echo "🔄 Creating branch with uncommitted changes..."
    else
      echo "How would you like to proceed?"
      echo "  1) Create branch with uncommitted changes (they'll come with you)"
      echo "  2) Commit changes to current branch first, then create new branch"
      echo "  3) Cancel branch creation"
      read -p "Enter option (1-3): " option
      
      case $option in
        1)
          echo "🔄 Creating branch with uncommitted changes..."
          # Just continue with branch creation
          ;;
        2)
          echo "👍 Let's commit your changes first."
          read -p "Enter commit message: " commit_message
          if [ -z "$commit_message" ]; then
            commit_message="WIP: Changes before creating branch $new_branch"
          fi
          git add .
          git commit -m "$commit_message"
          if [ $? -ne 0 ]; then
            echo "❌ Failed to commit changes."
            return 1
          fi
          echo "✅ Changes committed successfully."
          # Now continue with branch creation
          ;;
        3)
          echo "👍 Cancelled branch creation."
          return 1
          ;;
        *)
          echo "❌ Invalid option. Cancelled branch creation."
          return 1
          ;;
      esac
    fi
  fi
  
  # Create the branch
  git checkout -b "$new_branch" || { 
    echo "❌ Something went wrong creating branch '$new_branch'"
    echo "$(random_fail)"
    return 1
  }
  
  rainbow_box "🌱 You're now on '$new_branch'"
  echo "$(random_success)"
  
  # [Step 4] Offer smart next steps
  echo ""
  echo "💡 Next steps you might want to consider:"
  echo "   • Make your changes and commit them: git add . && git commit -m \"your message\""
  echo "   • Push this branch remotely: gitmonkey push"
  echo "   • Create a worktree for easy context switching: gitmonkey worktree:add $new_branch"
  
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
  
  # Perform the merge
  echo "🔄 Merging '$source_branch' into '$target_branch'..."
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
      if [ $# -eq 0 ]; then
        echo "❌ No branch name provided."
        echo "Usage: gitmonkey branch new <branch-name>"
        exit 1
      fi
      create_new_branch "$1"
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
      echo "  gitmonkey branch switch <name>     - Switch to a branch"
      echo "  gitmonkey branch merge <src> [dst] - Merge <src> into [dst] (default: main)"
      echo "  gitmonkey branch delete <name>     - Delete a branch"
      echo "  gitmonkey branch list              - List all branches"
      echo ""
      echo "Options:"
      echo "  --yes, -y          - Auto-confirm prompts"
      echo "  --force, -f        - Override safety checks"
      echo ""
      ;;
    *)
      echo "❌ Unknown subcommand: $subcommand"
      echo "Run 'gitmonkey branch --help' for usage information."
      exit 1
      ;;
  esac
fi