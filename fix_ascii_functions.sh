#\!/bin/bash

# Script to keep ascii banner/spell functions but ensure consistent styling

# Create a function to check and fix a specific file
fix_ascii_functions() {
  local file="$1"
  
  # Check if the file includes ascii_art.sh
  if \! grep -q "ascii_art.sh" "$file" && (grep -q "ascii_spell" "$file" || grep -q "ascii_banner" "$file" || grep -q "ascii_toilet" "$file"); then
    echo "Adding ascii_art.sh import to $file"
    
    # Get the line number of the last source statement
    line_num=$(grep -n "source.*utils/" "$file" | tail -1 | cut -d: -f1 || echo "1")
    
    # Insert ascii_art.sh import after the last source line
    sed -i '' "${line_num}a\\
source \"\$PARENT_DIR/utils/ascii_art.sh\"" "$file" 2>/dev/null || \
    sed -i "${line_num}a\\
source \"\$PARENT_DIR/utils/ascii_art.sh\"" "$file"
  fi
}

# Find all command files
find ./commands -type f -name "*.sh" | while read -r file; do
  fix_ascii_functions "$file"
done

echo "ASCII function imports updated\!"
