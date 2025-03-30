#!/bin/bash

# ========= GIT MONKEY INSTALLER =========

echo ""
echo "🍌 Welcome to Git Monkey Setup 🐒"
echo "Installing magic, shortcuts, and style…"
echo ""

# Create folders
mkdir -p utils commands

# Check if we're installing from the current directory structure or a starter directory
if [ -d "./starter" ]; then
    # Using starter directory
    cp ./starter/alias.sh ./commands/alias.sh
    cp ./starter/clone.sh ./commands/clone.sh
    cp ./starter/branch.sh ./commands/branch.sh
    cp ./starter/undo.sh ./commands/undo.sh
    cp ./starter/wizard.sh ./commands/wizard.sh
    cp ./starter/tips.sh ./commands/tips.sh
    cp ./starter/stash.sh ./commands/stash.sh
    cp ./starter/settings.sh ./commands/settings.sh
    cp ./starter/tutorial.sh ./commands/tutorial.sh
    cp ./starter/style.sh ./utils/style.sh
    cp ./starter/config.sh ./utils/config.sh
else
    # Just make sure all scripts are in the right place
    # No copying needed if files are already in the right location
    echo "Using existing scripts in place..."
fi

# Make all scripts executable
chmod +x ./commands/*.sh
chmod +x ./utils/*.sh

# Add helpful alias to run Git Monkey CLI
echo ""
read -p "🐵 Would you like to add 'gitmonkey' as a command? (y/n): " monkeyok
if [[ "$monkeyok" =~ ^[Yy]$ ]]; then
  # Make the script executable
  chmod +x "$(pwd)/gitmonkey.sh"
  
  # Add to path options
  echo "alias gitmonkey='bash $(pwd)/gitmonkey.sh'" >> ~/.bashrc
  echo "alias gitmonkey='bash $(pwd)/gitmonkey.sh'" >> ~/.zshrc
  
  # Create symbolic link option
  read -p "📲 Would you like to create a global 'gitmonkey' command? (y/n): " symlinkopt
  if [[ "$symlinkopt" =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/bin" ]; then
      # If ~/bin exists and is in PATH
      ln -sf "$(pwd)/gitmonkey.sh" "$HOME/bin/gitmonkey"
      chmod +x "$HOME/bin/gitmonkey"
      echo "✅ Created gitmonkey command in ~/bin/"
    elif [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
      # If /usr/local/bin exists and is writable
      sudo ln -sf "$(pwd)/gitmonkey.sh" "/usr/local/bin/gitmonkey"
      sudo chmod +x "/usr/local/bin/gitmonkey"
      echo "✅ Created gitmonkey command in /usr/local/bin/"
    else
      echo "❌ Could not find a suitable bin directory in PATH."
      echo "✅ Added 'gitmonkey' alias to your shell config instead."
    fi
  else
    echo "✅ Added 'gitmonkey' alias to your shell config."
  fi
  
  echo "🎉 Restart your terminal to use the 'gitmonkey' command."
else
  echo "💤 No worries. You can still run it with:"
  echo "  bash $(pwd)/gitmonkey.sh"
fi

echo ""
echo "🎉 Git Monkey is ready. Type:"
echo "  bash gitmonkey.sh"
echo "or:"
echo "  gitmonkey"
echo ""

