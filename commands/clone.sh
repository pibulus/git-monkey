#!/bin/bash

# ========= GIT MONKEY CLONE COMMAND =========

source ./utils/style.sh
source ./utils/config.sh

say_hi
ascii_spell "Let’s bring something down from the stars"

echo ""
typewriter "You're about to clone a GitHub repo into this folder." 0.02
echo "Think of it like inviting a new friend over to jam."
echo ""

read -p "🎸 Paste the GitHub repo URL: " repo_url

if [ -z "$repo_url" ]; then
  echo ""
  echo "🛑 No URL entered. That’s okay."
  echo "$(random_fail)"
  echo "💡 Try grabbing a GitHub HTTPS link from the repo’s main page."
  echo "If you need help, just ask or Google: clone a GitHub repo"
  exit 1
fi

# Extract folder name from URL
repo_name=$(basename -s .git "$repo_url")

echo ""
typewriter "Cloning '$repo_name' into this directory..." 0.02
echo ""

git clone "$repo_url"
status=$?

if [ $status -eq 0 ]; then
  rainbow_box "✅ Repo '$repo_name' cloned successfully!"
  typewriter "$(random_success)" 0.02
  echo ""
  read -p "🌈 Want to enter '$repo_name' right now? (y/n): " cdnow
  if [[ "$cdnow" =~ ^[Yy]$ ]]; then
    cd "$repo_name"
    echo ""
    echo "📁 Welcome to '$repo_name'. Here's what's inside:" | lolcat
    echo ""
    ls -la
    echo ""
  else
    echo ""
    echo "✨ All good. You know where it is when you're ready."
  fi
else
  echo ""
  echo "⚠️ Something didn't work. $(random_fail)"
  echo "💬 Here’s a gentle tip: $(random_tip)"
  echo ""
  echo "Try cloning again with:"
  echo "  git clone $repo_url" | lolcat
  echo ""
fi

