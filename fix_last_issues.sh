#\!/bin/bash

# Fix the remaining issues with shebang lines

# Fix menu.sh
sed -i '' '1s/^/#\!/bin\/bash\n\n/' ./commands/menu.sh 2>/dev/null || \
sed -i '1s/^/#\!/bin\/bash\n\n/' ./commands/menu.sh

# Fix settings.sh
sed -i '' '1s/^/#\!/bin\/bash\n\n/' ./commands/settings.sh 2>/dev/null || \
sed -i '1s/^/#\!/bin\/bash\n\n/' ./commands/settings.sh

# Fix welcome.sh
sed -i '' '1s/^/#\!/bin\/bash\n\n/' ./commands/welcome.sh 2>/dev/null || \
sed -i '1s/^/#\!/bin\/bash\n\n/' ./commands/welcome.sh

echo "Fixed remaining issues"
