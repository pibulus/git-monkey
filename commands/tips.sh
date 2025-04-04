#!/bin/bash

# ========= GIT MONKEY TIPS & TRICKS =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"




display_splash "$THEME"
ascii_spell "Git wisdom for curious monkeys"

# Array of Git tips
tips=(
  "Use 'git add -p' to stage changes interactively and review each chunk"
  "Set up SSH keys to avoid typing passwords: github.com/settings/keys"
  "Use 'git bisect' to find which commit introduced a bug"
  "Try 'git stash' to temporarily save changes without committing"
  "Write better commit messages: 'Fix [what]' instead of just 'Fix bug'"
  "Learn to use git aliases to speed up your workflow"
  "Use branches liberally - they're cheap and keep work organized"
  "Commit early and often - small, focused commits are easier to review"
  "Before pushing, run 'git diff' to review your changes"
  "Use 'git pull --rebase' to avoid unnecessary merge commits"
  "Add 'git lol' alias to see a pretty commit graph"
  "The reflog is your safety net - nothing is truly lost in Git"
)

# Pick a random tip
random_index=$((RANDOM % ${#tips[@]}))
daily_tip="${tips[$random_index]}"

echo ""
box "🧠 Git Tip of the Day"
echo "  $daily_tip"
echo ""

# Let user cycle through more tips
echo "Press Enter for another tip, or 'q' to quit"
while read -r input; do
  [[ "$input" == "q" ]] && break
  
  random_index=$((RANDOM % ${#tips[@]}))
  daily_tip="${tips[$random_index]}"
  
  echo ""
  box "🧠 Git Tip"
  echo "  $daily_tip"
  echo ""
  echo "Press Enter for another tip, or 'q' to quit"
done

echo ""
typewriter "$(display_success "$THEME")" 0.02
echo ""
