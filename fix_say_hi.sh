#\!/bin/bash

# Script to replace say_hi with display_splash calls

# Find all command files with say_hi
find ./commands -type f -name "*.sh" -exec grep -l "say_hi" {} \; | while read -r file; do
  echo "Updating $file..."
  
  # Replace say_hi with display_splash
  sed -i '' 's/say_hi/display_splash "$THEME"/g' "$file" 2>/dev/null || \
  sed -i 's/say_hi/display_splash "$THEME"/g' "$file"
  
  # Add THEME variable if it doesn't exist
  if \! grep -q "THEME=" "$file"; then
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

echo "say_hi replacement complete\!"
