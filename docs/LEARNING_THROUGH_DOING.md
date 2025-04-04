# Learning Through Doing: The Git Monkey Educational Approach

This document outlines Git Monkey's approach to teaching Git concepts by embedding education within the normal workflow rather than through separate tutorials.

## Philosophy: Show Me, Don't Tell Me

We believe that:
1. People learn best through active experience
2. Concepts stick when they're immediately relevant
3. Learning should feel like a natural byproduct, not a chore
4. Tutorials are often skipped or forgotten

## Micro-Learning Components

### 1. Contextual Concept Flashes

```bash
# After creating their first branch
if is_first_branch && [ "$TONE_STAGE" -le 2 ]; then
  echo ""
  echo "🧠 CONCEPT FLASH: Git Branches"
  echo "Think of branches like parallel universes where you can safely"
  echo "experiment with code changes without affecting the main universe."
  echo "You can always travel between these universes later!"
  echo ""
}
```

### 2. Teachable Moment Detection

```bash
# When a merge conflict occurs
if git status | grep -q "You have unmerged paths"; then
  # This is a teachable moment!
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "📚 Learning Opportunity: Merge Conflicts"
    echo ""
    echo "What's happening: Two different changes to the same lines of code"
    echo "can't be automatically combined by Git."
    echo ""
    echo "Git marks these conflicts in your files with >>>>> and <<<<<"
    echo "markings. Edit the files to keep what you want, then save."
    echo ""
    echo "Next steps:"
    echo "1. Edit the conflicted files (listed above)"
    echo "2. Remove the conflict markers and save"
    echo "3. Run: git add <filename>"
    echo "4. Finish with: git commit"
    echo ""
  fi
}
```

### 3. Visual Learning Aids

```bash
# When explaining branch operations
show_branch_diagram() {
  local tone_stage="$1"
  
  if [ "$tone_stage" -le 3 ]; then
    echo "Your Git branch structure looks like this:"
    echo ""
    echo "main     o---o---o---o---o"
    echo "                 \\"
    echo "$branch_name    o---o"
    echo "                    ^"
    echo "                   You are here"
    echo ""
  fi
}
```

### 4. Action-Based Learning

```bash
# After a successful rebase
if [ "$TONE_STAGE" -le 3 ]; then
  echo "$success_emoji Rebase complete! Want to understand what just happened?"
  read -p "View a quick explanation? (y/n): " show_explanation
  
  if [[ "$show_explanation" =~ [Yy] ]]; then
    echo ""
    echo "🔄 WHAT JUST HAPPENED: Rebase"
    echo ""
    echo "Before:        After:"
    echo "main o---o     main o---o"
    echo "      \\          |"
    echo "feat  o---o     feat o'--o'"
    echo ""
    echo "Your changes from the feature branch were:"
    echo "1. Temporarily set aside"
    echo "2. The branch pointer was moved to the latest main"
    echo "3. Your changes were replayed on top, one by one"
    echo ""
    echo "This keeps history cleaner than a merge commit would."
  fi
}
```

### 5. Progressive Command Mastery

Track command usage and gradually introduce more advanced options:

```bash
# utils/command_mastery.sh
check_command_mastery() {
  local command="$1"
  local usage_count=$(get_command_usage_count "$command")
  
  # First introduce basic options
  if [ "$usage_count" -eq 3 ] && [ "$TONE_STAGE" -le 3 ]; then
    echo ""
    echo "🔧 COMMAND MASTERY: Level 1 $command"
    echo "You've used this command a few times now! Try these options:"
    
    case "$command" in
      "commit")
        echo "gitmonkey commit -a      # Auto-add changes to tracked files"
        ;;
      "branch")
        echo "gitmonkey branch -r      # See remote branches too"
        ;;
      # More commands...
    esac
  fi
  
  # Then introduce intermediate options
  if [ "$usage_count" -eq 10 ] && [ "$TONE_STAGE" -le 3 ]; then
    echo ""
    echo "🔧 COMMAND MASTERY: Level 2 $command"
    # Show more advanced options...
  fi
  
  # Finally introduce power user options
  if [ "$usage_count" -eq 25 ] && [ "$TONE_STAGE" -le 4 ]; then
    echo ""
    echo "🔧 COMMAND MASTERY: Level 3 $command"
    # Show advanced options...
  fi
}
```

## Concept Learning Modules

Small, focused explanations triggered by relevant actions:

### Git Mental Model

```bash
# concepts/mental_model.sh
explain_git_mental_model() {
  clear
  echo "🧠 THE GIT MENTAL MODEL"
  echo ""
  echo "Git has THREE main areas:"
  echo ""
  echo "╔════════════════╗  ╔════════════════╗  ╔════════════════╗"
  echo "║                ║  ║                ║  ║                ║"
  echo "║   WORKSPACE    ║  ║     STAGING    ║  ║     HISTORY    ║"
  echo "║                ║  ║                ║  ║                ║"
  echo "╚════════════════╝  ╚════════════════╝  ╚════════════════╝"
  echo "  Your files on       Pending changes     Saved commits"
  echo "   the disk            ready to go        (your timeline)"
  echo ""
  echo "Commands move files between these areas:"
  echo ""
  echo "                   git add               git commit"
  echo "  WORKSPACE ───────────────► STAGING ─────────────► HISTORY"
  echo "      ▲                                       │"
  echo "      │                                       │"
  echo "      └───────────────────────────────────────┘"
  echo "                    git checkout"
  echo ""
  read -p "Press Enter to continue..."
}
```

### Branching Concept

```bash
# concepts/branches.sh
explain_branches() {
  clear
  echo "🌿 UNDERSTANDING BRANCHES"
  echo ""
  echo "Branches are parallel timelines for your code."
  echo ""
  echo "                           feature"
  echo "                            ↓"
  echo "                  o---------o"
  echo "                 /"
  echo "    o---o---o---o---o---o"
  echo "                      ↑"
  echo "                     main"
  echo ""
  echo "• Each branch can evolve independently"
  echo "• You can switch between branches easily"
  echo "• Later, you can merge changes from one branch to another"
  echo ""
  read -p "Press Enter to continue..."
}
```

## Milestone-Based Learning Celebrations

Track progress and celebrate learning milestones:

```bash
# utils/milestone_tracker.sh
check_git_milestones() {
  # Get current usage stats
  local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
  local branch_count=$(git branch | wc -l)
  
  # Check for milestones
  if [ "$commit_count" -eq 10 ] && [ "$TONE_STAGE" -le 3 ]; then
    echo ""
    box "🎉 Git Milestone: 10 Commits!"
    echo ""
    echo "You're building a solid Git history. With each commit, you're:"
    echo "• Creating restore points you can return to"
    echo "• Documenting your progress"
    echo "• Building a detailed history of your project"
    echo ""
  fi
}
```

## Error → Learning Opportunities

Convert errors into learning moments:

```bash
# utils/error_learning.sh
handle_git_error() {
  local error_code="$1"
  local error_msg="$2"
  
  if [ "$TONE_STAGE" -le 3 ]; then
    case "$error_code" in
      128)
        if echo "$error_msg" | grep -q "reference is not a tree"; then
          echo ""
          echo "$warning_emoji Learning Moment: Reference Error"
          echo ""
          echo "Git couldn't find the branch or commit you referenced."
          echo "This usually happens when:"
          echo "• The branch name is mistyped"
          echo "• The branch only exists remotely (try 'git fetch' first)"
          echo "• The branch has been deleted"
          echo ""
          echo "Try checking available branches with: gitmonkey branch list"
        fi
        ;;
      # More error cases...
    esac
  fi
}
```

## Concept Visualization System

Use ASCII art to visualize Git concepts:

```bash
# Visualize rebase vs merge
visualize_rebase_vs_merge() {
  echo "MERGE (creates a merge commit):"
  echo ""
  echo "      A---B---C feature"
  echo "     /         \\"
  echo "D---E---F---G---H main"
  echo ""
  echo "REBASE (replays your commits on top):"
  echo ""
  echo "              A'--B'--C' feature"
  echo "             /"
  echo "D---E---F---G main"
  echo ""
}
```

## Real-time Feedback Learning

```bash
# After committing with a weak commit message
check_commit_message_quality() {
  local message="$1"
  
  # Check message length
  if [ "${#message}" -lt 10 ] && [ "$TONE_STAGE" -le 3 ]; then
    echo "$warning_emoji Learning opportunity: Commit messages"
    echo "Short commit messages make it harder to understand changes later."
    echo "Try using the format: 'type: what changed and why'"
    echo "Example: 'fix: resolve login button alignment issue'"
  fi
  
  # Check for best practices
  if ! echo "$message" | grep -q ":" && [ "$TONE_STAGE" -le 3 ] && (( RANDOM % 3 == 0 )); then
    echo "$info_emoji Commit message tip: Adding a type prefix helps organize changes"
    echo "Example: 'feat: add user profile page' or 'fix: resolve login issue'"
  fi
}
```

## Creating Mental Models

Techniques to help users build accurate mental models:

### State Visualization

```bash
# Visualize current Git state
show_git_state() {
  if [ "$TONE_STAGE" -le 3 ]; then
    echo ""
    echo "📊 CURRENT GIT STATE:"
    echo ""
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
      echo "💼 WORKSPACE: Has uncommitted changes"
    else
      echo "💼 WORKSPACE: Clean (matches last commit)"
    fi
    
    # Check for staged changes
    if git diff --cached --quiet; then
      echo "📋 STAGING: Empty (nothing ready to commit)"
    else
      echo "📋 STAGING: Has changes ready to commit"
    fi
    
    # Current branch status
    local branch=$(git branch --show-current)
    local ahead=$(git rev-list HEAD --not --remotes | wc -l | tr -d '[:space:]')
    
    echo "📜 CURRENT BRANCH: $branch"
    if [ "$ahead" -gt 0 ]; then
      echo "   • $ahead commits ahead of remote (unpushed)"
    else
      echo "   • In sync with remote (all changes pushed)"
    fi
    echo ""
  fi
}
```

## Documentation vs. Learning-by-Doing

While we have documentation, we prioritize embedded learning:

```bash
# When a user runs a rarely-used command
track_command_learning() {
  local command="$1"
  
  if ! has_used_command "$command"; then
    if [ "$TONE_STAGE" -le 3 ]; then
      echo "$info_emoji First time using $command? Try it out, then run:"
      echo "gitmonkey learn $command  # For a deeper explanation"
    fi
    
    mark_command_as_used "$command"
  fi
}
```

---

By embedding learning directly into daily Git workflows, Git Monkey helps users build accurate mental models of Git through progressive discovery, visualization, and contextual learning.