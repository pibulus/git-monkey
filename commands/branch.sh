#!/bin/bash

# ========= GIT MONKEY BRANCH TOOL =========

source ./utils/style.sh
source ./utils/config.sh

say_hi
ascii_spell "Branches are just save slots for ideas"

echo ""
box "What do you want to do with branches?"

PS3=$'\nChoose a branch action: '
options=("Start a new branch" "Switch to a branch" "Merge a branch into main" "Delete a branch" "List all branches" "Go back")
select opt in "${options[@]}"; do
    case $REPLY in
        1)
            read -p "🔧 Name your new branch: " newbranch
            if [ -z "$newbranch" ]; then
              echo "😬 Branch needs a name, mate."
              exit 1
            fi
            
            # Validate branch name - no spaces or special chars except dash and underscore
            if [[ ! "$newbranch" =~ ^[a-zA-Z0-9_-]+$ ]]; then
              echo "🚫 Branch names should only contain letters, numbers, dashes and underscores."
              echo "Example: feature-user-login or bugfix_header"
              exit 1
            fi
            
            # Check if branch already exists
            if git show-ref --verify --quiet refs/heads/"$newbranch"; then
              echo "🚫 Branch '$newbranch' already exists. Try a different name."
              exit 1
            fi
            
            git checkout -b "$newbranch" || { 
              echo "❌ Something went wrong creating branch '$newbranch'"
              echo "$(random_fail)"
              exit 1
            }
            
            rainbow_box "🌱 You're now on '$newbranch'"
            echo "$(random_success)"
            break
            ;;
        2)
            echo "🌴 Existing branches:"
            git branch
            echo ""
            read -p "🛫 Enter the name of the branch to switch to: " branchname
            git checkout "$branchname"
            rainbow_box "🔄 Switched to '$branchname'"
            break
            ;;
        3)
            read -p "🧩 Which branch do you want to merge into main? " mergebranch
            git checkout main
            git merge "$mergebranch"
            rainbow_box "🪄 Merged '$mergebranch' into 'main'"
            echo "$(random_success)"
            break
            ;;
        4)
            git branch
            echo ""
            read -p "🗑️ Which branch do you want to delete? " delbranch
            git branch -d "$delbranch"
            rainbow_box "💥 Deleted '$delbranch'"
            break
            ;;
        5)
            echo "🌿 Here's what you've got:"
            git branch
            echo ""
            echo "$(random_success)"
            break
            ;;
        6)

