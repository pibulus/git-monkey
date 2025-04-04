#\!/bin/bash

# Script to add THEME variable to all command files that don't have it

find ./commands -type f -name "*.sh" | xargs grep -L "THEME=" | while read -r file; do
  echo "Adding THEME variable to $file"
  
  # Get the first line number after the imports
  line_num=$(grep -n "source" "$file" | tail -1 | cut -d: -f1 || echo "4")
  line_num=$((line_num + 1))
  
  # Insert the THEME variable
  sed -i '' "${line_num}i\\
# Get current theme\\
THEME=\$(get_selected_theme)\\
" "$file" 2>/dev/null || \
  sed -i "${line_num}i\\
# Get current theme\\
THEME=\$(get_selected_theme)\\
" "$file"
done

echo "Added THEME variable to all command files"
