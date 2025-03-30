#!/bin/bash

# ========= GIT MONKEY WIZARD MODE =========

source ./utils/style.sh
source ./utils/config.sh

say_hi
ascii_toilet "Wizard Mode"

ascii_spell "Careful... here be dragons."

echo ""
box "Welcome, traveler. Choose your spell wisely."
PS3=$'\nWhich incantation shall we cast? '
options=(
  "Recover lost commits (reflog & checkout)"
  "Cherry-pick a commit from another branch"
  "See visual commit graph (git lol)"
  "Undo staged changes (git restore)"
  "Clean untracked files (git clean)"
  "Return to menu"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1)
            echo ""
            typewriter "Running: git reflog" 0.015
            git reflog
            echo ""
            echo "To recover something, cast:"
            echo "  git checkout -b rescue-branch <hash>"
            echo ""
            echo "$(random_success)"
            break
            ;;
        2)
            read -p "🧩 From which branch do you want to cherry-pick? " cherry_branch
            read -p "🔮 What is the commit hash? " cherry_hash
            git checkout "$cherry_branch"
            git cherry-pick "$cherry_hash"
            rainbow_box "✨ That commit now lives here too."
            echo "$(random_success)"
            break
            ;;
        3)
            echo ""
            echo "🌳 Showing your commit forest:"
            git log --oneline --graph --all
            echo ""
            break
            ;;
        4)
            echo ""
            typewriter "Running: git restore --staged <file>" 0.015
            echo "This unstages a file but keeps changes."
            echo "Use: git restore --staged path/to/file"
            echo ""
            break
            ;;
        5)
            echo ""
            typewriter "Running: git clean -f -d" 0.015
            echo "⚠️ This deletes untracked files. Proceed with care."
            read -p "Do you want to run it now? (y/n): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
              git clean -f -d
              rainbow_box "🧼 Untracked files swept into the void."
              echo "$(random_success)"
            else
              echo "🫧 No worries, apprentice. The mess remains... for now."
            fi
            break
            ;;
        6)
            echo "✨ Portaling back to the main menu..."
            break
            ;;
        *)
            echo "This spell is not in your grimoire yet." ;;
    esac
done

