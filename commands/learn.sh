#!/bin/bash

# ========= GIT MONKEY LEARN COMMAND =========
# Educational resources for Git Monkey features

source ./utils/style.sh
source ./utils/config.sh

# Function to show worktrees explanation
show_worktrees_explanation() {
  echo ""
  rainbow_box "Git Worktrees: The Multi-dimensional Git Superpower"
  echo ""
  
  echo "🧠 Worktrees are like parallel realities for your Git repository."
  echo "   You can work on multiple branches AT THE SAME TIME in different folders."
  echo "   No stashing. No losing your train of thought. No context switching tax."
  echo ""
  
  echo "How it works:"
  echo "1️⃣ Each worktree is a separate directory linked to your main repository"
  echo "2️⃣ Each worktree can be on a different branch"
  echo "3️⃣ Changes in one worktree don't affect others"
  echo "4️⃣ No need to commit or stash before switching contexts"
  echo ""
  
  echo "Example workflow:"
  echo "• You're working on feature-a in your main repo"
  echo "• Urgent bug comes in that needs fixing on main branch"
  echo "• Instead of stashing your changes:"
  echo "  $ gitmonkey worktree:add main"
  echo "  $ gitmonkey worktree:switch main"
  echo "• Fix the bug in the main worktree, commit and push"
  echo "• Then easily return to your feature-a work:"
  echo "  $ cd .. && cd your-original-repo"
  echo ""
  
  echo "Git Monkey makes it even easier:"
  echo "• Use 'gitmonkey pivot <branch>' to automatically stash and switch"
  echo "• Use 'gitmonkey return' to go back and restore your work"
  echo ""
  
  echo "Try it yourself:"
  echo "  gitmonkey worktree:add my-feature    # Create a worktree"
  echo "  gitmonkey worktree:switch my-feature # Switch to it"
  echo "  gitmonkey worktree:list              # See all worktrees"
  echo ""
  
  echo "Advanced worktree techniques:"
  echo "• Keep a worktree for each active feature/bug you're working on"
  echo "• Use worktrees for code reviews without disrupting your work"
  echo "• Experiment with risky changes in a separate worktree"
  echo ""
}

# Function to show smart push explanation
show_push_explanation() {
  echo ""
  rainbow_box "Smart Push: No More Upstream Headaches"
  echo ""
  
  echo "🚀 Git Monkey's smart push makes your Git workflow smoother."
  echo "   No more cryptic errors about upstream branches not being set."
  echo ""
  
  echo "The Problem:"
  echo "When you create a new branch and try to push for the first time,"
  echo "Git requires you to set an upstream branch with this verbose command:"
  echo "  git push --set-upstream origin your-branch-name"
  echo ""
  
  echo "Git Monkey's Solution:"
  echo "1️⃣ Just use 'gitmonkey push' for any branch"
  echo "2️⃣ If no upstream exists, it's automatically set up for you"
  echo "3️⃣ First-time push? No problem! Git Monkey handles the details"
  echo ""
  
  echo "Even Better:"
  echo "Git Monkey can configure Git to always set upstream automatically"
  echo "with a simple one-time setting: push.autoSetupRemote"
  echo ""
  
  echo "Commands to know:"
  echo "  gitmonkey push             # Smart push with auto-upstream setup"
  echo "  gitmonkey push --force     # Force push with auto-upstream if needed"
  echo "  gitmonkey push --no-config # Don't offer to configure global setting"
  echo ""
  
  echo "Pro tip:"
  echo "After using 'gitmonkey push' once on a branch, future pushes"
  echo "can use regular 'git push' since the upstream is already set."
  echo ""
}

# Function to show usage help
show_help() {
  echo ""
  box "Git Monkey Learn"
  echo ""
  echo "Learn about Git Monkey features and concepts:"
  echo ""
  echo "Usage:"
  echo "  gitmonkey learn <topic>"
  echo ""
  echo "Available topics:"
  echo "  worktrees    - Learn about Git worktrees and how they help your workflow"
  echo "  push         - Learn about Git Monkey's smart push functionality"
  # Add more topics here as they become available
  echo ""
}

# Main function
main() {
  # Check if a topic is provided
  if [ -z "$1" ]; then
    show_help
    exit 0
  fi

  # Handle topics
  case "$1" in
    "worktrees")
      show_worktrees_explanation
      ;;
    "push")
      show_push_explanation
      ;;
    *)
      echo "❌ Unknown topic: $1"
      show_help
      exit 1
      ;;
  esac
}

# Execute main function with all args
main "$@"