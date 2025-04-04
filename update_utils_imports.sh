#\!/bin/bash

# Script to standardize utility imports across all command files
# This will ensure consistent path references and available functions

# Define the standard import template
STANDARD_IMPORTS='
# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"
'

# Process all command files
echo "Updating utility imports for command files..."
find ./commands -type f -name "*.sh" | while read -r file; do
  # Skip files we've already updated
  if grep -q 'DIR="$( cd "$( dirname "${BASH_SOURCE\[0\]}" )" && pwd )"' "$file"; then
    echo "Skipping already updated file: $file"
    continue
  fi
  
  # Check if file has old-style imports
  if grep -q 'source ./utils/' "$file"; then
    echo "Updating imports for: $file"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Write the shebang line if it exists
    if grep -q '^#\!/bin/bash' "$file"; then
      head -n 1 "$file" > "$temp_file"
    else
      echo '#\!/bin/bash' > "$temp_file"
    fi
    
    # Add a blank line
    echo "" >> "$temp_file"
    
    # Find and append the original comment section if it exists
    if grep -q '^# =' "$file"; then
      grep '^# =' "$file" >> "$temp_file"
      echo "" >> "$temp_file"
    fi
    
    # Add the standard imports
    echo "$STANDARD_IMPORTS" >> "$temp_file"
    
    # Get the content of the file after the imports
    grep -v 'source ./utils/' "$file" | grep -v '^#\!/bin/bash' | grep -v '^# =' >> "$temp_file"
    
    # Replace the original file
    mv "$temp_file" "$file"
    chmod +x "$file"
  fi
done

echo "Import standardization complete\!"
