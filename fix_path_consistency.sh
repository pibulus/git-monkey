#\!/bin/bash

# Script to add consistent DIR and PARENT_DIR variables to all command files

find ./commands -type f -name "*.sh" | xargs grep -L "DIR=" | while read -r file; do
  echo "Adding DIR and PARENT_DIR to $file"
  
  # Check if the file has a shebang line
  if head -n 1 "$file" | grep -q "^#\!/bin/bash"; then
    # Insert after shebang line
    sed -i '' "1a\\
\\
# Set directory paths for consistent imports\\
DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"\\
PARENT_DIR=\"\$(dirname \"\$DIR\")\"\\
" "$file" 2>/dev/null || \
    sed -i "1a\\
\\
# Set directory paths for consistent imports\\
DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"\\
PARENT_DIR=\"\$(dirname \"\$DIR\")\"\\
" "$file"
  else
    # Insert at the beginning of the file
    sed -i '' "1i\\
#\!/bin/bash\\
\\
# Set directory paths for consistent imports\\
DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"\\
PARENT_DIR=\"\$(dirname \"\$DIR\")\"\\
" "$file" 2>/dev/null || \
    sed -i "1i\\
#\!/bin/bash\\
\\
# Set directory paths for consistent imports\\
DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"\\
PARENT_DIR=\"\$(dirname \"\$DIR\")\"\\
" "$file"
  fi
  
  # Fix source lines to use PARENT_DIR
  sed -i '' 's|source \./utils/|source "$PARENT_DIR/utils/|g' "$file" 2>/dev/null || \
  sed -i 's|source \./utils/|source "$PARENT_DIR/utils/|g' "$file"
  
  # Add double quotes to prevent word splitting
  sed -i '' 's|source "$PARENT_DIR/utils/|source "$PARENT_DIR/utils/|g' "$file" 2>/dev/null || \
  sed -i 's|source "$PARENT_DIR/utils/|source "$PARENT_DIR/utils/|g' "$file"
  
  # Make sure the file is executable
  chmod +x "$file"
done

echo "Added consistent path variables to all command files"
