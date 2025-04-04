#\!/bin/bash

# Script to update all random_* function calls to use the new themed message system

# Find all command files
find ./commands -type f -name "*.sh" | while read -r file; do
  echo "Checking $file..."
  
  # Replace random_greeting with display_greeting
  if grep -q "random_greeting" "$file"; then
    echo "  Updating random_greeting in $file"
    sed -i '' 's/random_greeting/display_greeting "$THEME"/g' "$file" 2>/dev/null || \
    sed -i 's/random_greeting/display_greeting "$THEME"/g' "$file"
  fi
  
  # Replace random_success with display_success
  if grep -q "random_success" "$file"; then
    echo "  Updating random_success in $file"
    sed -i '' 's/random_success/display_success "$THEME"/g' "$file" 2>/dev/null || \
    sed -i 's/random_success/display_success "$THEME"/g' "$file"
  fi
  
  # Replace random_fail with display_error
  if grep -q "random_fail" "$file"; then
    echo "  Updating random_fail in $file"
    sed -i '' 's/random_fail/display_error "$THEME"/g' "$file" 2>/dev/null || \
    sed -i 's/random_fail/display_error "$THEME"/g' "$file"
  fi
  
  # Replace random_tip with display_tip
  if grep -q "random_tip" "$file"; then
    echo "  Updating random_tip in $file"
    sed -i '' 's/random_tip/display_tip "$THEME"/g' "$file" 2>/dev/null || \
    sed -i 's/random_tip/display_tip "$THEME"/g' "$file"
  fi
  
  # Add THEME variable if it doesn't exist and the file was modified
  if grep -q "display_.*\"\$THEME\"" "$file" && \! grep -q "THEME=" "$file"; then
    echo "  Adding THEME variable to $file"
    # Find the first line after utility imports
    line_num=$(grep -n "source.*utils" "$file" | tail -1 | cut -d: -f1)
    line_num=$((line_num + 1))
    
    # Insert the THEME line
    sed -i '' "${line_num}i\\
# Get current theme\\
THEME=\$(get_selected_theme)\\
" "$file" 2>/dev/null || \
    sed -i "${line_num}i\\
# Get current theme\\
THEME=\$(get_selected_theme)\\
" "$file"
  fi
done

echo "Random message function replacement complete\!"
