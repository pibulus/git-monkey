#!/bin/bash

# ========= GIT MONKEY SCHEMA COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Visual schema designer and generator for database models


# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Process arguments
output_format="typescript+zod"
visual_mode="true"
output_path=""
help_mode="false"

# Parse command-line arguments
for arg in "$@"; do
  case "$arg" in
    --format=*)
      output_format="${arg#*=}"
      shift
      ;;
    --output=*)
      output_path="${arg#*=}"
      shift
      ;;
    --no-visual)
      visual_mode="false"
      shift
      ;;
    --help|-h)
      help_mode="true"
      shift
      ;;
  esac
done

# Function to show help
show_help() {
  echo ""
  box "Git Monkey Schema Designer"
  echo ""
  echo "A visual tool for designing database schemas and generating"
  echo "TypeScript types and Zod validation schemas."
  echo ""
  echo "Usage:"
  echo "  gitmonkey schema                   # Interactive mode with visual UI"
  echo "  gitmonkey schema --format=TYPE     # Specify output format"
  echo "  gitmonkey schema --output=PATH     # Specify output path"
  echo "  gitmonkey schema --no-visual       # Disable ASCII visualization"
  echo ""
  echo "Options:"
  echo "  --format=TYPE    Output format (typescript+zod, prisma, sql)"
  echo "  --output=PATH    Path to save generated schema"
  echo "  --no-visual      Disable ASCII visualization"
  echo "  --help, -h       Show this help message"
  echo ""
  echo "Examples:"
  echo "  gitmonkey schema"
  echo "  gitmonkey schema --format=typescript+zod --output=./src/lib/schema.ts"
  echo ""
}

# Show help if requested
if [ "$help_mode" = "true" ]; then
  show_help
  exit 0
fi

# Main function to handle schema operations
main() {
  # Execute the schema designer tool
  ./commands/starter/tools/schema_designer.sh "$@"
}

# Call main with all arguments
main "$@"
