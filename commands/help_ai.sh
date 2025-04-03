#!/bin/bash

# ========= GIT MONKEY AI HELP COMMAND =========
# Displays help information about AI features

source ./utils/style.sh
source ./utils/config.sh

say_hi
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