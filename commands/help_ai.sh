#!/bin/bash

# ========= GIT MONKEY AI HELP COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Displays help information about AI features


display_splash "$THEME"
ascii_spell "AI Features Guide"

# Check if a markdown viewer is available
if command -v glow >/dev/null; then
  # Use glow for pretty markdown rendering
  glow "./docs/AI_USAGE_GUIDE.md"
elif command -v bat >/dev/null; then
  # Use bat as a fallback
  bat --style=plain "./docs/AI_USAGE_GUIDE.md"
else
  # Simple cat as a last resort
  cat "./docs/AI_USAGE_GUIDE.md"
fi

echo ""
echo "For more detailed information, see the full documentation in:"
echo "docs/AI_USAGE_GUIDE.md and docs/AI_INTEGRATION_PLAN.md"
echo ""
