#\!/bin/bash

# Final script to fix any remaining issues

# Remove our temporary scripts
echo "Cleaning up temporary scripts..."
rm -f update_utils_imports.sh fix_random_messages.sh fix_say_hi.sh fix_ascii_functions.sh add_missing_theme.sh fix_path_consistency.sh check_command_files.sh fix_last_issues.sh

# Make sure all scripts have executable permissions
echo "Setting executable permissions on all scripts..."
find ./commands -type f -name "*.sh" -exec chmod +x {} \;
find ./utils -type f -name "*.sh" -exec chmod +x {} \;
chmod +x ./bin/git-monkey
chmod +x ./gitmonkey.sh
chmod +x ./install.sh

echo "All cleanup tasks completed\!"
