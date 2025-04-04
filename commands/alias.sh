#!/bin/bash

# ========= GIT MONKEY ALIAS INSTALLER =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"




display_splash "$THEME"
ascii_spell "Installing your Git powers..."

# Core aliases with gentle, human-centered explanations
aliases=(
  "a:add . # Stage all changes"
  "c:commit -m # Commit with a message"
  "s:!git add . && git commit -m # 'Save': stage and commit together"
  "p:push # Push to GitHub"
  "pl:pull # Pull from GitHub"
  "lol:log --oneline --graph --all # Visual commit tree"
  "co:checkout # Switch branches"
  "new:checkout -b # Create & switch to a new branch"
  "m:merge # Merge another branch into this one"
  "d:branch -d # Delete a branch"
  "undo:reset --soft HEAD~1 # Undo last commit, keep your changes"
  "yikes:reset --hard origin/main # Reset to last pushed version"
  "resurrect:!git reflog && echo 'Use: git checkout -b fixit <hash>' # Recover lost commits via reflog"
)

echo ""
box "Here come your shortcuts… hold on tight 🐵"

# Loop to install each alias
for item in "${aliases[@]}"; do
  IFS=":" read -r alias cmd <<< "$item"
  git config --global alias."$alias" "$cmd"
done

# Confirmation + tips
rainbow_box "✅ Git Monkey aliases installed!"
echo ""
typewriter "$(display_success "$THEME")" 0.02
echo ""
echo "Here are a few to try:" | lolcat
echo "  git s \"message\"     → Save your work (add + commit)"
echo "  git lol              → See your Git history like a tree"
echo "  git new idea-branch  → Start a new branch"
echo "  git yikes            → Reset to the last pushed version"
echo "  git resurrect        → Recover lost commits (via reflog)"
echo ""
line
cowsay "You're now a monkey with a machete. Go explore the jungle." | lolcat -a -d 2

