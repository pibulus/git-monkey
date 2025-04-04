#!/bin/bash

# ========= GIT MONKEY LEARN COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Educational resources for Git Monkey features


# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"  # Can be "info", "success", "error", "warning"
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        "learn") echo "🧠" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "learn") echo "//" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "learn") echo "📚" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "learn") echo "🔭" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "learn") echo "🧠" ;;
        *) echo "🐒" ;;
      esac
      ;;
  esac
}

# Get theme-specific emojis
info_emoji=$(get_theme_emoji "info")
success_emoji=$(get_theme_emoji "success")
error_emoji=$(get_theme_emoji "error")
warning_emoji=$(get_theme_emoji "warning")
learn_emoji=$(get_theme_emoji "learn")

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

# Function to show branch explanation with visual ASCII art
show_branch_explanation() {
  # Start timing to record learning session
  local start_time=$(start_timing)
  
  # Different explanations based on tone stage
  if [ "$TONE_STAGE" -le 2 ]; then
    # Beginner explanation with personal touch
    echo ""
    rainbow_box "Git Branches: Parallel Universes for Your Code"
    echo ""
    
    echo "Hey $IDENTITY! Let's explore Git branches."
    echo ""
    echo "$learn_emoji Branches let you work on different versions of your code at the same time."
    echo "Think of them like parallel universes or save slots in a video game!"
    echo ""
    
    # ASCII art visual for branches
    echo "Here's a visual of what branches look like:"
    echo ""
    echo "                            feature-login"
    echo "                                 ↓"
    echo "                      o---------o---o"
    echo "                     /             ↑ You are here"
    echo "    o---o---o---o---o---o---o  ← main branch"
    echo "    ↑"
    echo "First commit"
    echo ""
    
    echo "What's happening here:"
    echo "1️⃣ You start with the main branch (bottom line)"
    echo "2️⃣ You create a feature-login branch (top line) to build new login screen"
    echo "3️⃣ Now you can make commits on feature-login without affecting main"
    echo "4️⃣ When your feature is done, you can merge it back to main"
    echo ""
    
    echo "Why branches are awesome:"
    echo "• You can work on multiple features/bugs at the same time"
    echo "• You can experiment without risking your stable code"
    echo "• Teams can work in parallel without stepping on each other's toes"
    echo "• You can try crazy ideas safely and abandon them if needed"
    echo ""
    
    echo "Here's how to use branches with Git Monkey:"
    echo "  gitmonkey branch new feature-name    # Create new branch"
    echo "  gitmonkey branch switch feature-name # Switch to that branch"
    echo "  gitmonkey push                       # Push your branch when ready"
    echo ""
    
    echo "Want to be super efficient? Try worktrees:"
    echo "  gitmonkey learn worktrees  # Learn about multiple workspaces"
    echo ""
    
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate explanation - more direct but still informative
    echo ""
    rainbow_box "Git Branches: Parallel Development Paths"
    echo ""
    
    echo "$learn_emoji Branches create isolated development environments:"
    echo ""
    
    # ASCII art visual for branches
    echo "                      feature-login"
    echo "                           ↓"
    echo "                o---------o---o"
    echo "               /             "
    echo "o---o---o---o---o---o---o  ← main"
    echo ""
    
    echo "Key concepts:"
    echo "• Branches point to specific commits in your repository"
    echo "• New branches fork from your current HEAD position"
    echo "• Each branch maintains its own commit history"
    echo "• Changes in one branch don't affect others until merged"
    echo ""
    
    echo "Common branching strategies:"
    echo "• feature branches - for new features (feature/login)"
    echo "• bug branches - for fixes (fix/header-alignment)"
    echo "• release branches - for upcoming releases (release/v1.2.0)"
    echo ""
    
    echo "Git Monkey commands for branches:"
    echo "  gitmonkey branch new <name>     # Create branch"
    echo "  gitmonkey branch switch <name>  # Switch branch"
    echo "  gitmonkey branch merge <src> <dest> # Merge branches"
    echo ""
    
  else
    # Advanced explanation - concise and technical
    echo ""
    echo "GIT BRANCH CONCEPT"
    echo ""
    
    # ASCII art visual for branches
    echo "                    feature"
    echo "                       ↓"
    echo "              o-------o---o"
    echo "             /            "
    echo "o---o---o---o---o---o  ← main"
    echo ""
    
    echo "• Branches are lightweight pointers to commits"
    echo "• Branch operations are O(1) - don't copy code"
    echo "• Reference format: refs/heads/<branch-name>"
    echo "• HEAD points to current branch (or specific commit in detached state)"
    echo ""
    
    echo "Branch management:"
    echo "• Create: gitmonkey branch new <name> [start-point]"
    echo "• Switch: gitmonkey branch switch <name>"
    echo "• Delete: gitmonkey branch delete <name>"
    echo "• Merge: gitmonkey branch merge <src> [dest]"
    echo ""
    
    echo "Advanced techniques:"
    echo "• Utilize worktrees for parallel development"
    echo "• Consider rebase for cleaner history"
    echo "• Use remote tracking branches for collaboration"
    echo ""
  fi
  
  # End timing and record
  local duration=$(end_timing "$start_time")
  record_command_time "learn_branch" "$duration"
  
  # Show terminal efficiency occasionally
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo ""
    echo "⚡ Learning through the terminal is fast! This visual guide loaded in just $(printf "%.1f" "$duration") seconds."
  fi
}

# Function to show branching strategies
show_branching_strategies() {
  # Start timing to record learning session
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "Branching Strategies: Organizing Your Git Workflow"
  else
    echo "BRANCHING STRATEGIES"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hey $IDENTITY! Let's explore different ways to organize branches in a project."
    echo ""
    echo "$learn_emoji Different teams use different branching strategies to keep their work organized."
    echo "There's no single 'right way' - each has pros and cons!"
    echo ""
  else
    echo "$learn_emoji Common Git branching workflows and their characteristics:"
    echo ""
  fi
  
  # ASCII art for Git Flow
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "1. Git Flow (Traditional)"
    echo ""
    echo "  master    o-----------------------o-----------o"
    echo "              \\                     /           ^"
    echo "  release     \\                o---o           |"
    echo "                \\              /               |"
    echo "  develop      o-o-o-o-o-o-o-o-o-o-o-o-o-o-o--o"
    echo "                 \\       /     \\       /"
    echo "  feature        o-o-o-o       o-o-o-o"
    echo ""
    
    echo "• Good for planned releases and larger teams"
    echo "• main/master branch is always production-ready"
    echo "• develop branch is integration branch"
    echo "• feature branches for new functionality"
    echo "• release branches for preparing releases"
    echo "• Complex but structured"
    echo ""
  else
    echo "1. Git Flow: master, develop, feature, release, hotfix branches"
    echo "   Structured but complex. Good for scheduled releases."
    echo ""
  fi
  
  # ASCII art for GitHub Flow
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "2. GitHub Flow (Simplified)"
    echo ""
    echo "  main      o---------o---------o---------o"
    echo "              \\         \\         \\"
    echo "  feature 1    o-o-o-----o"
    echo "                          \\"
    echo "  feature 2                o-o-o-o"
    echo "                                  \\"
    echo "  feature 3                        o-o-o"
    echo ""
    
    echo "• Simpler approach with fewer branches"
    echo "• main branch is always deployable"
    echo "• feature branches for all changes"
    echo "• Pull requests for code reviews"
    echo "• Great for continuous delivery"
    echo "• Much simpler than Git Flow"
    echo ""
  else
    echo "2. GitHub Flow: main + feature branches only"
    echo "   Simplicity focused. Continuous deployment via PRs."
    echo ""
  fi
  
  # Trunk-based development 
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "3. Trunk-Based Development"
    echo ""
    echo "  main/trunk  o---o---o---o---o---o---o---o"
    echo "                \\         /  \\     /"
    echo "  short-lived    o-o-o---o    o-o-o"
    echo ""
    
    echo "• Focus on main/trunk branch"
    echo "• Very short-lived feature branches (1-2 days)"
    echo "• Continuous integration emphasis"
    echo "• Feature flags for incomplete features"
    echo "• Requires strong testing culture"
    echo "• Used by many high-velocity teams"
    echo ""
  else
    echo "3. Trunk-Based: Short-lived branches, focus on trunk"
    echo "   High-velocity with strong CI/CD requirements."
    echo ""
  fi
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Which one should you use, $IDENTITY?"
    echo ""
    echo "For personal or small team projects:"
    echo "• GitHub Flow is simple and effective"
    echo "• Create a branch for each feature/fix"
    echo "• Merge back to main when complete"
    echo "• Keep branches short-lived if possible"
    echo ""
    
    echo "Git Monkey helps with any of these approaches!"
    echo "  gitmonkey branch new feature/login  # Create feature branch"
    echo "  gitmonkey worktree:add hotfix/bug   # Add hotfix worktree"
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    echo "How to choose a strategy:"
    echo "• Project size and complexity"
    echo "• Team size and distribution"
    echo "• Release cadence requirements"
    echo "• Testing and CI/CD capabilities"
    echo ""
  else
    echo "Selection factors: Team size, release cadence, project complexity, CI maturity"
    echo ""
  fi
  
  # End timing and record
  local duration=$(end_timing "$start_time")
  record_command_time "learn_branching_strategies" "$duration"
}

# Function to show git mental model explanation
show_mental_model_explanation() {
  # Start timing to record learning session
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "The Git Mental Model: Understanding How Git Thinks"
  else
    echo "GIT MENTAL MODEL"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hi $IDENTITY! Let's build a mental model of how Git actually works."
    echo "Understanding this will make Git feel much less mysterious!"
    echo ""
  fi
  
  # ASCII art for the three areas in Git
  echo "$learn_emoji Git has THREE main areas:"
  echo ""
  echo "╔════════════════╗  ╔════════════════╗  ╔════════════════╗"
  echo "║                ║  ║                ║  ║                ║"
  echo "║   WORKSPACE    ║  ║     STAGING    ║  ║     HISTORY    ║"
  echo "║                ║  ║                ║  ║                ║"
  echo "╚════════════════╝  ╚════════════════╝  ╚════════════════╝"
  echo "  Your files on       Pending changes     Saved commits"
  echo "   the disk            ready to go        (your timeline)"
  echo ""
  
  # Only show detailed explanations for beginners and intermediate users
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "Commands move files between these areas:"
    echo ""
    echo "                   git add               git commit"
    echo "  WORKSPACE ───────────────► STAGING ─────────────► HISTORY"
    echo "      ▲                                       │"
    echo "      │                                       │"
    echo "      └───────────────────────────────────────┘"
    echo "                    git checkout"
    echo ""
    
    echo "Common Git task flows:"
    echo ""
    
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "1️⃣ Saving your work:"
      echo "   • Edit files in your workspace"
      echo "   • git add sends changes to staging"
      echo "   • git commit saves staging to history"
      echo ""
      echo "2️⃣ Sharing your work:"
      echo "   • git push sends commits to the remote repository"
      echo "   • git pull gets commits from the remote repository"
      echo ""
      echo "3️⃣ Switching contexts:"
      echo "   • git branch new creates a new timeline"
      echo "   • git checkout switches your workspace to that timeline"
      echo ""
    else
      echo "1. Save cycle: edit → git add → git commit"
      echo "2. Share cycle: git pull → git push"
      echo "3. Branch cycle: git branch → git checkout → git merge"
      echo ""
    fi
  fi
  
  # Git objects explanation for higher tone stages
  if [ "$TONE_STAGE" -ge 2 ] && [ "$TONE_STAGE" -le 4 ]; then
    echo "Git's core object types:"
    echo ""
    echo "1. Blobs - File contents (no filenames!)"
    echo "2. Trees - Directories and filenames"
    echo "3. Commits - Snapshots with parent pointer(s)"
    echo "4. References - Pointers to commits (branches, tags)"
    echo ""
  fi
  
  # Only for advanced users
  if [ "$TONE_STAGE" -ge 4 ]; then
    echo "Advanced mental model:"
    echo "• Git is a content-addressable filesystem"
    echo "• Objects are named by SHA-1 hash of their content"
    echo "• Directed acyclic graph (DAG) of commits"
    echo "• Branches are just mutable pointers to commits"
    echo "• HEAD is a symbolic reference to current branch"
    echo ""
  fi
  
  # Add Git Monkey commands as examples only for beginners
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Git Monkey makes this even easier!"
    echo "  gitmonkey push                # Smart push with upstream tracking"
    echo "  gitmonkey branch new feature  # Create and switch to new branch"
    echo "  gitmonkey undo last-commit    # Oops! Fix a recent commit"
    echo ""
  fi
  
  # End timing and record
  local duration=$(end_timing "$start_time")
  record_command_time "learn_mental_model" "$duration"
  
  # Show terminal efficiency occasionally
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo ""
    echo "⚡ This guide loaded instantly in your terminal! ($(printf "%.2f" "$duration")s)"
    echo "   Visual learning in the terminal is fast and efficient."
  fi
}

# Function to show merge vs rebase explanation
show_merge_vs_rebase() {
  # Start timing to record learning session
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "Merge vs Rebase: Two Ways to Combine Changes"
  else
    echo "MERGE vs REBASE"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hey $IDENTITY! Let's explore two powerful ways to combine work in Git."
    echo "Both merge and rebase help you integrate changes, but they work differently!"
    echo ""
  fi
  
  echo "$learn_emoji Git provides TWO main ways to combine branches:"
  echo ""
  
  # Merge explanation
  echo "1️⃣ MERGE: Creating a new commit that combines branches"
  echo ""
  
  # ASCII art for merge
  echo "Before merge:"
  echo "             feature"
  echo "               ↓"
  echo "      A---B---C"
  echo "     /"
  echo "D---E---F---G    ← main"
  echo ""
  
  echo "After merge (main ← feature):"
  echo "              feature"
  echo "                ↓"
  echo "      A---B---C"
  echo "     /         \\"
  echo "D---E---F---G---H    ← main (merge commit)"
  echo ""
  
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "Merge characteristics:"
    echo "• Creates a new 'merge commit' (H) that combines both histories"
    echo "• Preserves complete history of both branches"
    echo "• Shows exactly when/how branches were combined"
    echo "• Feature branch remains unchanged"
    echo "• No rewriting of history"
    echo "• Good for public/shared branches"
    echo ""
  else
    echo "Merge: Preserves history, non-destructive, new merge commit"
    echo ""
  fi
  
  # Rebase explanation
  echo "2️⃣ REBASE: Replaying commits on a different base"
  echo ""
  
  # ASCII art for rebase
  echo "Before rebase:"
  echo "             feature"
  echo "               ↓"
  echo "      A---B---C"
  echo "     /"
  echo "D---E---F---G    ← main"
  echo ""
  
  echo "After rebase (feature onto main):"
  echo "                       feature"
  echo "                         ↓"
  echo "                A'--B'--C'"
  echo "               /"
  echo "D---E---F---G    ← main"
  echo ""
  
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "Rebase characteristics:"
    echo "• Rewrites commit history by creating new commits (A', B', C')"
    echo "• Creates linear, cleaner history"
    echo "• Makes it look like you worked from the latest main all along"
    echo "• Changes commit hashes (potentially destructive)"
    echo "• Not recommended for public/shared branches"
    echo ""
  else
    echo "Rebase: Rewrites history, linear result, destructive operation"
    echo ""
  fi
  
  # Practical advice
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "When to use which one, $IDENTITY?"
    echo ""
    echo "Use MERGE when:"
    echo "• Working on a public branch that others use"
    echo "• You want to preserve the exact history"
    echo "• You need to show exactly when a feature was integrated"
    echo "• You're a beginner and want the safer option"
    echo ""
    echo "Use REBASE when:"
    echo "• Working on a private feature branch"
    echo "• You want a cleaner, more linear history"
    echo "• You want to incorporate the latest changes from main"
    echo "• You're comfortable with Git and understand the risks"
    echo ""
    
    echo "Git Monkey commands:"
    echo "  gitmonkey branch merge feature main    # Merge feature into main"
    echo "  gitmonkey rebase feature main          # Rebase feature onto main (coming soon!)"
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    echo "Practical workflow:"
    echo "• For public branches: merge"
    echo "• For private branches: rebase then merge"
    echo "• For latest changes from main: git rebase main"
    echo "• For branch integration: git merge --no-ff feature"
    echo ""
  else
    echo "Advanced strategies:"
    echo "• Interactive rebase: clean history before merging/sharing"
    echo "• Squash merges: collapse feature work into single commit"
    echo "• Rebase workflow: rebase → force push → merge request"
    echo ""
  fi
  
  # End timing and record
  local duration=$(end_timing "$start_time")
  record_command_time "learn_merge_rebase" "$duration"
  
  # Show terminal efficiency occasionally
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo ""
    echo "⚡ This illustrated guide displayed in $(printf "%.1f" "$duration") seconds."
    echo "   The terminal makes learning git concepts fast and efficient!"
  fi
}

# Function to show common Git operations
show_common_operations() {
  # Start timing to record learning session
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "Common Git Operations: Your Daily Workflow"
  else
    echo "COMMON GIT OPERATIONS"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hey $IDENTITY! Let's explore the Git commands you'll use every day."
    echo "These form the core of your Git workflow!"
    echo ""
  fi
  
  # Basic workflow diagram
  echo "$learn_emoji The basic Git workflow:"
  echo ""
  echo "┌────────────────┐   ┌────────────────┐   ┌────────────────┐   ┌────────────────┐"
  echo "│                │   │                │   │                │   │                │"
  echo "│   Edit Files   │──▶│   git add .    │──▶│   git commit   │──▶│    git push    │"
  echo "│                │   │                │   │                │   │                │"
  echo "└────────────────┘   └────────────────┘   └────────────────┘   └────────────────┘"
  echo "                                                                         │"
  echo "┌────────────────┐   ┌────────────────┐                                  │"
  echo "│                │   │                │                                  │"
  echo "│    git pull    │◀──│  Remote Repo   │◀─────────────────────────────────┘"
  echo "│                │   │                │"
  echo "└────────────────┘   └────────────────┘"
  echo ""
  
  # Common operations explanations based on tone stage
  if [ "$TONE_STAGE" -le 2 ]; then
    # Beginner-friendly with more context
    echo "🔍 Daily operations and what they do:"
    echo ""
    echo "1️⃣ Creating or switching context:"
    echo "  git clone <url>         # Download a repository to your computer"
    echo "  git branch new <name>   # Create a new branch for a feature/fix"
    echo "  git branch switch <n>   # Switch to a different branch"
    echo ""
    echo "2️⃣ Making changes:"
    echo "  git status              # Check which files are modified"
    echo "  git add <files>         # Stage files for commit (or use 'git add .')"
    echo "  git commit -m \"message\" # Save your changes with a descriptive message"
    echo ""
    echo "3️⃣ Sharing and updating:"
    echo "  git push                # Send your commits to the remote repository"
    echo "  git pull                # Get latest changes from the remote repository"
    echo "  git fetch               # Download changes without applying them"
    echo ""
    echo "4️⃣ Reviewing changes:"
    echo "  git log                 # See commit history"
    echo "  git diff                # See what's changed in your files"
    echo "  git blame <file>        # See who changed each line and when"
    echo ""
    
    echo "Want less typing? Git Monkey makes these even easier!"
    echo "  gitmonkey branch new feature     # Create & switch to feature branch"
    echo "  gitmonkey push                   # Push with automatic upstream tracking"
    echo "  gitmonkey undo last-commit       # Easily fix a recent mistake"
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate with more efficient presentation
    echo "Common operations by workflow stage:"
    echo ""
    echo "Setup & Context:"
    echo "  git clone <url>         # Clone repository"
    echo "  git checkout -b <name>  # Create & switch to new branch"
    echo "  git checkout <name>     # Switch branches"
    echo ""
    echo "Development Cycle:"
    echo "  git status              # Check working tree status"
    echo "  git add [files]         # Stage changes for commit"
    echo "  git commit -m \"msg\"     # Commit staged changes"
    echo "  git push [-u origin <b>] # Push to remote"
    echo ""
    echo "Synchronization:"
    echo "  git fetch               # Retrieve remote changes"
    echo "  git pull                # Fetch & integrate changes"
    echo "  git merge <branch>      # Combine branch histories"
    echo "  git rebase <branch>     # Reapply commits on branch tip"
    echo ""
    echo "Review & Analysis:"
    echo "  git log                 # View commit history"
    echo "  git diff [commit] [file]# Show changes between points"
    echo "  git bisect              # Binary search for regression"
    echo ""
  else
    # Expert - concise reference only
    echo "Core operations:"
    echo "  clone, init, config, checkout (-b), branch, status"
    echo "  add, restore, reset, commit (-a, --amend), push, pull"
    echo "  fetch, merge, rebase, cherry-pick, bisect, revert"
    echo "  log, diff, show, reflog, blame, tag"
    echo ""
    echo "Advanced operations:"
    echo "  worktree, submodule, filter-branch, archive, stash"
    echo "  sparse-checkout, rev-parse, rev-list, gc, fsck"
    echo "  merge-base, show-ref, ls-files, ls-remote, describe"
    echo ""
  fi
  
  # End timing and record
  local duration=$(end_timing "$start_time")
  record_command_time "learn_common_operations" "$duration"
  
  # Show terminal efficiency occasionally
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo ""
    echo "⚡ Terminal efficiency: Loaded in $(printf "%.1f" "$duration") seconds!"
    echo "   Learning Git in the terminal helps you build muscle memory."
  fi
}

# Function to show Git's distributed nature
show_distributed_git() {
  # Start timing to record learning session
  local start_time=$(start_timing)
  
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    rainbow_box "Git's Distributed Nature: Working with Remotes"
  else
    echo "DISTRIBUTED GIT & REMOTES"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Hey $IDENTITY! Let's explore how Git works across multiple computers."
    echo "Git is a distributed version control system - everyone has a complete copy!"
    echo ""
  fi
  
  # ASCII art for distributed nature
  echo "$learn_emoji Git repositories can exist in multiple places simultaneously:"
  echo ""
  echo "┌─────────────────────────┐      ┌─────────────────────────┐"
  echo "│                         │      │                         │"
  echo "│     LOCAL REPOSITORY    │      │    REMOTE REPOSITORY    │"
  echo "│     (Your Computer)     │      │      (GitHub, etc)      │"
  echo "│                         │      │                         │"
  echo "│  ┌─────────────────┐    │      │  ┌─────────────────┐    │"
  echo "│  │  Working Files  │    │      │  │ Complete History│    │"
  echo "│  └─────────────────┘    │      │  └─────────────────┘    │"
  echo "│  ┌─────────────────┐    │      │                         │"
  echo "│  │ Complete History│    │◄────►│     Shared via HTTP     │"
  echo "│  └─────────────────┘    │      │     or SSH protocols    │"
  echo "│                         │      │                         │"
  echo "└─────────────────────────┘      └─────────────────────────┘"
  echo "                                           ▲"
  echo "                                           │"
  echo "                                           ▼"
  echo "┌─────────────────────────┐      ┌─────────────────────────┐"
  echo "│                         │      │                         │"
  echo "│  OTHER REPOSITORY #1    │      │  OTHER REPOSITORY #2    │"
  echo "│  (Collaborator's PC)    │      │  (Collaborator's PC)    │"
  echo "│                         │      │                         │"
  echo "└─────────────────────────┘      └─────────────────────────┘"
  echo ""
  
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "Key concepts of distributed Git:"
    echo "• Every clone is a complete repository with full history"
    echo "• You work locally, independent of network connection"
    echo "• Changes are synchronized via push and pull"
    echo "• The remote is just a shared reference point"
    echo "• Multiple collaborators can work simultaneously"
    echo ""
    
    echo "Common remote operations:"
    echo "  git remote -v                 # List remote repositories"
    echo "  git remote add origin <url>   # Add a remote"
    echo "  git push -u origin <branch>   # Push and set upstream tracking"
    echo "  git pull                      # Get and merge remote changes"
    echo "  git fetch                     # Get remote changes without merging"
    echo "  git clone <url>               # Create a new local copy from remote"
    echo ""
  fi
  
  # Show more detailed explanations for beginners
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "The remote workflow, $IDENTITY:"
    echo ""
    echo "1️⃣ Setting up connections:"
    echo "   When you 'git clone' a repository, Git automatically:"
    echo "   • Creates a local copy of all files and history"
    echo "   • Sets up a remote called 'origin' pointing to the source"
    echo "   • Creates tracking between local and remote branches"
    echo ""
    echo "2️⃣ Daily workflow with remotes:"
    echo "   • Start your day with 'git pull' to get latest changes"
    echo "   • Work locally making commits as needed"
    echo "   • Use 'git push' to share your changes with others"
    echo ""
    echo "3️⃣ Common scenarios:"
    echo "   • Collaborating: Multiple people push to the same remote"
    echo "   • Forks: You have your own remote copy of someone else's project"
    echo "   • Multiple remotes: You can pull from one remote and push to another"
    echo ""
    
    echo "Git Monkey makes working with remotes simpler:"
    echo "  gitmonkey clone <url>         # Clone with interactive guidance"
    echo "  gitmonkey push                # Smart push with auto-upstream setup"
    echo "  gitmonkey branch new feature  # Create branch with remote tracking"
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    echo "Advanced remote patterns:"
    echo "• Triangular workflow: Pull from upstream, push to origin"
    echo "• Fork-based collaboration: Multiple remotes with different permissions"
    echo "• Pull request workflow: Push to branch, merge via UI"
    echo "• Hook-based automation: Push triggers CI/CD pipelines"
    echo ""
  else
    echo "Reference:"
    echo "• git remote show, add, rename, remove, update, set-branches, set-head"
    echo "• git push --force-with-lease (safer than --force)"
    echo "• git branch --set-upstream-to=origin/<branch>"
    echo "• git config --add remote.origin.fetch +refs/pull/*/head:refs/remotes/origin/pr/*"
    echo ""
  fi
  
  # End timing and record
  local duration=$(end_timing "$start_time")
  record_command_time "learn_distributed_git" "$duration"
  
  # Show terminal efficiency occasionally
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo ""
    echo "⚡ Terminal efficiency: Loaded this diagram in $(printf "%.1f" "$duration") seconds!"
    echo "   Learning Git concepts with ASCII art visualizations in your terminal is fast and effective."
  fi
}

# Function to show a tone-appropriate help
show_help() {
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    box "$learn_emoji Git Monkey Learning Center"
    
    echo ""
    echo "Hi $IDENTITY! What would you like to learn about today?"
  else
    box "Git Monkey Learn"
  fi
  echo ""
  
  if [ "$TONE_STAGE" -le 3 ]; then
    echo "Available topics:"
    
    echo "  branch        - Understanding Git branches with visual examples"
    echo "  branching     - Learn about branching strategies and workflows"
    echo "  distributed   - Git's distributed nature and working with remotes"
    echo "  mental-model  - The core mental model of how Git works"
    echo "  merge-rebase  - Compare merge and rebase with visuals"
    echo "  operations    - Common Git operations and daily workflow"
    echo "  worktrees     - Learn about Git worktrees and their benefits"
    echo "  push          - Learn about Git Monkey's smart push functionality"
    
    if [ "$TONE_STAGE" -le 2 ]; then
      echo ""
      echo "Examples:"
      echo "  gitmonkey learn branch        # Learn about branches with visuals"
      echo "  gitmonkey learn mental-model  # Understand how Git thinks"
      echo "  gitmonkey learn merge-rebase  # See how to combine branches"
    fi
  else
    echo "Topics: branch, branching, distributed, mental-model, merge-rebase, operations, worktrees, push"
  fi
  echo ""
}

# Main function
main() {
  # Record learning session start
  local start_time=$(start_timing)
  
  # Check if a topic is provided
  if [ -z "$1" ]; then
    show_help
    
    # Record usage
    local duration=$(end_timing "$start_time")
    record_command_time "learn_help" "$duration"
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
    "branch")
      show_branch_explanation
      ;;
    "branching"|"strategies")
      show_branching_strategies
      ;;
    "mental-model"|"model")
      show_mental_model_explanation
      ;;
    "merge-rebase"|"merge"|"rebase")
      show_merge_vs_rebase
      ;;
    "operations"|"commands"|"workflow")
      show_common_operations
      ;;
    "distributed"|"remotes"|"remote")
      show_distributed_git
      ;;
    "help"|"--help"|"-h")
      show_help
      ;;
    *)
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "$error_emoji I don't know about that topic yet, $IDENTITY. Here's what I can teach you:"
      else
        echo "$error_emoji Unknown topic: $1"
      fi
      show_help
      
      # Record usage
      local duration=$(end_timing "$start_time")
      record_command_time "learn_unknown" "$duration"
      exit 1
      ;;
  esac
  
  # Record overall learning session
  local total_duration=$(end_timing "$start_time")
  record_command_time "learn_total" "$total_duration"
  
  # Occasionally suggest next steps for learning path (only for beginners)
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo ""
    echo "$info_emoji Learning path suggestion for $IDENTITY:"
    case "$1" in
      "branch")
        echo "  Try 'gitmonkey learn branching' next to see different workflow strategies!"
        ;;
      "branching")
        echo "  Try 'gitmonkey learn merge-rebase' next to learn how to combine branches!"
        ;;
      "distributed")
        echo "  Try 'gitmonkey learn push' next to see how to share your work with remotes!"
        ;;
      "mental-model")
        echo "  Try 'gitmonkey learn operations' next to see common Git commands!"
        ;;
      "merge-rebase")
        echo "  Try 'gitmonkey learn branch' next to understand branch concepts better!"
        ;;
      "operations")
        echo "  Try 'gitmonkey learn distributed' to see how Git works across computers!"
        ;;
      "push")
        echo "  Try 'gitmonkey learn distributed' to understand Git's remote architecture!"
        ;;
      "worktrees")
        echo "  Try 'gitmonkey learn branch' next to understand branch concepts better!"
        ;;
      *)
        echo "  Try 'gitmonkey learn mental-model' to understand the core Git concepts!"
        ;;
    esac
  fi
}

# Execute main function with all args
main "$@"
