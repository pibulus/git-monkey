#!/bin/bash

# ========= GIT MONKEY STASH MANAGER =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"




display_splash "$THEME"
ascii_spell "Stash your changes for safekeeping"

box "What would you like to do with your stash?"
PS3=$'\nChoose a stash action: '
options=(
  "Stash current changes (save for later)" 
  "Apply a stash (bring back changes)" 
  "List all stashes" 
  "Drop a stash (delete it)" 
  "Create a branch from stash"
  "Return to menu"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1)
            echo ""
            read -p "📝 Add a description for this stash (optional): " stash_msg
            
            if [ -z "$stash_msg" ]; then
                git stash push || {
                    echo "❌ Nothing to stash. Make some changes first!"
                    exit 1
                }
            else
                git stash push -m "$stash_msg" || {
                    echo "❌ Nothing to stash. Make some changes first!"
                    exit 1
                }
            fi
            
            rainbow_box "🧸 Changes safely stashed away"
            echo "$(display_success "$THEME")"
            break
            ;;
        2)
            echo ""
            echo "📦 Here are your available stashes:"
            git stash list
            
            if [ $? -ne 0 ] || [ -z "$(git stash list)" ]; then
                echo "🤔 No stashes found. Nothing to apply."
                break
            fi
            
            echo ""
            read -p "Which stash to apply? (number, e.g., 0): " stash_num
            
            if [[ ! "$stash_num" =~ ^[0-9]+$ ]]; then
                echo "❌ Please enter a valid stash number"
                break
            fi
            
            # Check if stash exists
            if ! git stash list | grep -q "stash@{$stash_num}"; then
                echo "❌ Stash $stash_num does not exist"
                break
            fi
            
            echo ""
            echo "Apply options:"
            echo "1) Apply stash (keep it in stash list)"
            echo "2) Pop stash (apply and remove from stash list)"
            read -p "Your choice (1/2): " apply_choice
            
            if [ "$apply_choice" = "1" ]; then
                git stash apply "stash@{$stash_num}"
                rainbow_box "✅ Applied stash@{$stash_num} (still in stash list)"
            elif [ "$apply_choice" = "2" ]; then
                git stash pop "stash@{$stash_num}"
                rainbow_box "✅ Popped stash@{$stash_num} (removed from stash list)"
            else
                echo "❌ Invalid choice"
                break
            fi
            
            echo "$(display_success "$THEME")"
            break
            ;;
        3)
            echo ""
            echo "📜 Here are your stashed changes:"
            if ! git stash list || [ -z "$(git stash list)" ]; then
                echo "No stashes found. All clear!"
            fi
            break
            ;;
        4)
            echo ""
            echo "🗑️ Here are your available stashes:"
            git stash list
            
            if [ $? -ne 0 ] || [ -z "$(git stash list)" ]; then
                echo "No stashes found. Nothing to drop."
                break
            fi
            
            echo ""
            read -p "Which stash to drop? (number, e.g., 0 or 'all' for everything): " drop_choice
            
            if [ "$drop_choice" = "all" ]; then
                read -p "⚠️ Are you sure you want to drop ALL stashes? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    git stash clear
                    rainbow_box "🧹 All stashes cleared"
                else
                    echo "Operation cancelled"
                    break
                fi
            elif [[ "$drop_choice" =~ ^[0-9]+$ ]]; then
                # Check if stash exists
                if ! git stash list | grep -q "stash@{$drop_choice}"; then
                    echo "❌ Stash $drop_choice does not exist"
                    break
                fi
                
                git stash drop "stash@{$drop_choice}"
                rainbow_box "🗑️ Stash@{$drop_choice} dropped"
            else
                echo "❌ Invalid choice"
                break
            fi
            
            echo "$(display_success "$THEME")"
            break
            ;;
        5)
            echo ""
            echo "🌱 Here are your available stashes:"
            git stash list
            
            if [ $? -ne 0 ] || [ -z "$(git stash list)" ]; then
                echo "No stashes found. Create a stash first."
                break
            fi
            
            echo ""
            read -p "Which stash to create branch from? (number, e.g., 0): " stash_num
            
            if [[ ! "$stash_num" =~ ^[0-9]+$ ]]; then
                echo "❌ Please enter a valid stash number"
                break
            fi
            
            # Check if stash exists
            if ! git stash list | grep -q "stash@{$stash_num}"; then
                echo "❌ Stash $stash_num does not exist"
                break
            fi
            
            read -p "🔧 Name for the new branch: " branch_name
            
            if [ -z "$branch_name" ]; then
                echo "❌ Branch needs a name"
                break
            fi
            
            # Validate branch name
            if [[ ! "$branch_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                echo "🚫 Branch names should only contain letters, numbers, dashes and underscores"
                break
            fi
            
            git stash branch "$branch_name" "stash@{$stash_num}"
            rainbow_box "🌱 Created new branch '$branch_name' from stash@{$stash_num}"
            echo "$(display_success "$THEME")"
            break
            ;;
        6)
            echo "Returning to menu..."
            break
            ;;
        *)
            echo "❌ Please select a valid option" ;;
    esac
done
