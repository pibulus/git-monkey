#!/bin/bash

# ========= GIT MONKEY UNDO & REVERT TOOL =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"




display_splash "$THEME"
ascii_spell "Rewind, reset, undo... breathe"

box "Choose your git undo move:"
PS3=$'\nPick a move: '
options=(
  "Undo last commit (but keep changes)"
  "Undo last commit completely"
  "Reset to last pushed version"
  "See full git history (reflog)"
  "Return to menu"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1)
            echo ""
            typewriter "Running: git reset --soft HEAD~1" 0.015
            git reset --soft HEAD~1
            rainbow_box "🔁 Commit undone. Your code is still here."
            echo "$(display_success "$THEME")"
            break
            ;;
        2)
            echo ""
            typewriter "Running: git reset --hard HEAD~1" 0.015
            read -p "⚠️ This will delete your last commit AND code changes. Are you SURE? (y/n): " sure
            if [[ "$sure" =~ ^[Yy]$ ]]; then
              git reset --hard HEAD~1
              rainbow_box "💀 Commit nuked. We go again."
              echo "$(display_success "$THEME")"
            else
              echo "😅 Phew. You dodged a bullet."
            fi
            break
            ;;
        3)
            echo ""
            typewriter "Running: git reset --hard origin/main" 0.015
            git reset --hard origin/main
            rainbow_box "🧼 Clean slate. Local matches remote."
            echo "$(display_success "$THEME")"
            break
            ;;
        4)
            echo ""
            typewriter "Showing git reflog — your entire history of HEAD moves..." 0.015
            echo ""
            git reflog
            echo ""
            echo "👉 You can recover lost commits with:"
            echo "git checkout -b rescue-branch <hash>"
            break
            ;;
        5)
            echo "Returning to the safe zone..."
            break
            ;;
        *)
            echo "⏪ Not quite. Pick a real option." ;;
    esac
done

