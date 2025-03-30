#\!/bin/bash

# ========= GIT MONKEY GENERATE COMMAND =========
# Command to generate various code elements

source ./utils/style.sh
source ./utils/config.sh

# Main function
main() {
  # Check if a command is provided
  if [ -z "$1" ]; then
    echo "❌ Please specify what to generate (e.g., crud)"
    echo "Usage: gitmonkey generate <type> [options]"
    echo ""
    echo "Available generators:"
    echo "  crud    - Generate CRUD functionality for a specified backend"
    # Add more generators here as they are implemented
    exit 1
  fi

  # Route to the appropriate generator based on the command
  case "$1" in
    crud)
      shift # Remove 'crud' from arguments
      ./commands/starter/tools/crud_generator.sh "$@"
      ;;
    *)
      echo "❌ Unknown generator: $1"
      echo "Available generators:"
      echo "  crud    - Generate CRUD functionality for a specified backend"
      # Add more generators here as they are implemented
      exit 1
      ;;
  esac
}

# Execute main function with all args
main "$@"
