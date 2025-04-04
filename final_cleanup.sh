#\!/bin/bash

# Remove temporary verification scripts
rm -f fix_imports.sh fix_ai_imports.sh final_verification.sh

# Create a README file for splash directory
cat > assets/ascii/splash/README.md << 'EOF'
# Splash Screen Assets

This directory contains general splash screens that are used when no specific
theme is active or for the initial welcome screen.
EOF

# Fix the final import
sed -i '' -e 's|source ./utils/ai_safety.sh|source "$DIR/ai_safety.sh"|g' utils/ai_request.sh 2>/dev/null || \
sed -i -e 's|source ./utils/ai_safety.sh|source "$DIR/ai_safety.sh"|g' utils/ai_request.sh

echo "Final cleanup complete\!"
