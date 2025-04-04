#!/bin/bash

# ========= GIT MONKEY TUTORIAL MODE =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"




display_splash "$THEME"
ascii_spell "Learning Git by doing, not watching"

box "Git School: Choose Your Lesson"
echo "Each lesson is hands-on. You'll try real commands in your terminal."
echo "Don't worry about making mistakes – that's how we learn! 🙈"
echo ""

PS3=$'\nWhich lesson would you like to try? '
options=(
  "Basic Git flow (add, commit, push)" 
  "Branching basics" 
  "Undoing with reset and revert" 
  "Using log & reflog" 
  "Pulling and pushing to remote"
  "Return to menu"
)

# Function to pause and let user try
try_it() {
  echo ""
  echo "💻 Go ahead and try it..." | lolcat
  read -p "Press Enter when you've given it a shot (or type 'skip' to continue): " skip_input
  echo ""
  
  if [ "$skip_input" != "skip" ]; then
    echo "🎯 Nice work!"
  fi
}

# Function to show example
show_example() {
  local cmd="$1"
  local description="$2"
  
  echo ""
  echo "Example:" 
  echo "  $ $cmd" | lolcat -a
  echo "  $description"
  echo ""
}

# Function to track tutorial completion
track_tutorial_progress() {
  local lesson="$1"
  local temp_file=$(mktemp)
  
  # Get current completed lessons array
  local completed_lessons=$(get_profile_field "stats.completed_lessons")
  
  if [ "$completed_lessons" = "null" ] || [ -z "$completed_lessons" ]; then
    # Initialize the array if it doesn't exist
    jq '.stats.completed_lessons = []' "$PROFILE_FILE" > "$temp_file"
    mv "$temp_file" "$PROFILE_FILE"
  fi
  
  # Add the lesson to completed_lessons if not already there
  jq --arg lesson "$lesson" \
    '.stats.completed_lessons = (if .stats.completed_lessons | index($lesson) then .stats.completed_lessons else .stats.completed_lessons + [$lesson] end)' \
    "$PROFILE_FILE" > "$temp_file"
  
  mv "$temp_file" "$PROFILE_FILE"
  
  # Check if all lessons are completed
  local all_lessons=("basic-git" "branching" "undo" "log" "remote")
  local completed_count=$(get_profile_field "stats.completed_lessons | length")
  
  if [ "$completed_count" -ge "${#all_lessons[@]}" ]; then
    # All lessons completed, mark tutorial as complete
    mark_tutorial_completed
    
    # Check for tone stage advancement
    local previous_stage=$(get_tone_stage)
    local current_stage=$(get_tone_stage)
    
    if [ "$current_stage" -gt "$previous_stage" ]; then
      local new_title=$(get_monkey_title "$current_stage")
      echo "🎉 You've advanced to a new tone stage! You are now a \"$new_title\"."
    fi
  fi
}

select opt in "${options[@]}"; do
    case $REPLY in
        1)
            # Basic Git flow
            typewriter "🌱 Basic Git Flow: Add, Commit, Push" 0.02
            echo ""
            echo "Git's basic workflow is like taking a photo of your code:"
            echo "1. Stage your changes (git add)"
            echo "2. Commit with a message (git commit)"
            echo "3. Push to share with others (git push)"
            
            # Example 1
            show_example "git status" "This shows what files have changed"
            try_it
            
            # Example 2
            echo "Now let's stage some changes:"
            show_example "git add file.txt" "This stages a specific file"
            show_example "git add ." "This stages all changes"
            try_it
            
            # Example 3
            echo "Next, commit your changes with a message:"
            show_example "git commit -m \"Add new feature\"" "This saves your changes with a description"
            try_it
            
            # Example 4
            echo "Finally, push your changes to share them:"
            show_example "git push origin main" "This pushes commits to the main branch on the remote"
            try_it
            
            rainbow_box "🎓 You've completed the basic Git flow lesson!"
            echo "$(display_success "$THEME")"
            
            # Track tutorial progress
            track_tutorial_progress "basic-git"
            
            break
            ;;
            
        2)
            # Branching basics
            typewriter "🌿 Branching Basics: Create, Switch, Merge" 0.02
            echo ""
            echo "Branches are like parallel timelines for your code:"
            echo "1. Create a branch (git branch or git checkout -b)"
            echo "2. Switch between branches (git checkout)"
            echo "3. Merge changes back (git merge)"
            
            # Example 1
            echo "Let's see what branches exist:"
            show_example "git branch" "This lists all local branches (* shows current)"
            try_it
            
            # Example 2
            echo "Now create a new branch for a feature:"
            show_example "git checkout -b feature-login" "This creates and switches to a new branch in one command"
            try_it
            
            # Example 3
            echo "Make some changes, add and commit them to the feature branch:"
            show_example "git add . && git commit -m \"Add login form\"" "This stages and commits all changes"
            try_it
            
            # Example 4
            echo "Now let's go back to the main branch:"
            show_example "git checkout main" "This switches to the main branch"
            try_it
            
            # Example 5
            echo "And merge our feature branch into main:"
            show_example "git merge feature-login" "This brings the commits from feature-login into main"
            try_it
            
            rainbow_box "🎓 You've completed the branching basics lesson!"
            echo "$(display_success "$THEME")"
            
            # Track tutorial progress
            track_tutorial_progress "branching"
            
            break
            ;;
            
        3)
            # Undoing with reset and revert
            typewriter "↩️ Undoing Changes: Reset and Revert" 0.02
            echo ""
            echo "Everyone makes mistakes. Git offers several ways to fix them:"
            echo "1. Unstage changes (git reset)"
            echo "2. Undo a commit (git reset HEAD~1)"
            echo "3. Revert a commit (git revert)"
            
            # Example 1
            echo "Let's see what's currently staged:"
            show_example "git status" "This shows what files are staged or changed"
            try_it
            
            # Example 2
            echo "To unstage a file that you've added:"
            show_example "git reset HEAD file.txt" "This unstages a specific file"
            try_it
            
            # Example 3
            echo "To undo your last commit (but keep the changes):"
            show_example "git reset --soft HEAD~1" "This moves HEAD back one commit but keeps changes staged"
            try_it
            
            # Example 4
            echo "To completely undo your last commit (deleting changes):"
            show_example "git reset --hard HEAD~1" "⚠️ This deletes the commit AND changes - be careful!"
            echo "⚠️ Only use --hard when you're sure you want to delete those changes!"
            try_it
            
            # Example 5
            echo "To create a new commit that undoes a previous commit:"
            show_example "git revert HEAD" "This creates a new commit that undoes the last commit"
            try_it
            
            rainbow_box "🎓 You've completed the undoing changes lesson!"
            echo "$(display_success "$THEME")"
            
            # Track tutorial progress
            track_tutorial_progress "undo"
            
            break
            ;;
            
        4)
            # Using log & reflog
            typewriter "📜 Git Time Travel: Log & Reflog" 0.02
            echo ""
            echo "Git keeps a detailed history of all your changes:"
            echo "1. View commit history (git log)"
            echo "2. See all Git actions with reflog (git reflog)"
            echo "3. Recover 'lost' commits"
            
            # Example 1
            echo "Let's look at your commit history:"
            show_example "git log" "This shows detailed commit history"
            show_example "git log --oneline" "This shows a compact version of history"
            try_it
            
            # Example 2
            echo "Let's see a graphical view of your commit history:"
            show_example "git log --oneline --graph --all" "This shows branches and merges visually"
            try_it
            
            # Example 3
            echo "Now let's look at your reflog - Git's detailed journal of all actions:"
            show_example "git reflog" "This shows ALL Git ref updates (commits, checkouts, resets, etc.)"
            try_it
            
            # Example 4
            echo "To recover a 'lost' commit after a reset:"
            show_example "git reflog" "First find the commit hash"
            show_example "git checkout -b recovery-branch <hash>" "Then checkout that commit to a new branch"
            try_it
            
            rainbow_box "🎓 You've completed the Git time travel lesson!"
            echo "$(display_success "$THEME")"
            
            # Track tutorial progress
            track_tutorial_progress "log"
            
            break
            ;;
            
        5)
            # Pulling and pushing to remote
            typewriter "🌐 Working with Remotes: Pull & Push" 0.02
            echo ""
            echo "Git connects your local repo with remote ones like GitHub:"
            echo "1. Add a remote (git remote add)"
            echo "2. Fetch changes (git fetch)"
            echo "3. Pull changes (git pull)"
            echo "4. Push changes (git push)"
            
            # Example 1
            echo "Let's see what remotes you have configured:"
            show_example "git remote -v" "This shows the remote repositories connected to your local repo"
            try_it
            
            # Example 2
            echo "To add a new remote repository:"
            show_example "git remote add origin https://github.com/username/repo.git" "This adds a remote named 'origin'"
            try_it
            
            # Example 3
            echo "To download changes without merging them:"
            show_example "git fetch origin" "This gets all changes from origin but doesn't merge them"
            try_it
            
            # Example 4
            echo "To download AND merge changes in one step:"
            show_example "git pull origin main" "This fetches and merges changes from main branch on origin"
            try_it
            
            # Example 5
            echo "To push your local commits to the remote:"
            show_example "git push origin main" "This pushes your commits to the main branch on origin"
            try_it
            
            # Example 6
            echo "To set up branch tracking for easier pulls and pushes:"
            show_example "git branch --set-upstream-to=origin/main main" "This links your local main to remote main"
            show_example "git push -u origin feature-branch" "This pushes and sets up tracking in one command"
            try_it
            
            rainbow_box "🎓 You've completed the working with remotes lesson!"
            echo "$(display_success "$THEME")"
            
            # Track tutorial progress
            track_tutorial_progress "remote"
            
            break
            ;;
            
        6)
            echo "Returning to menu..."
            break
            ;;
            
        *)
            echo "Please select a valid lesson number." ;;
    esac
done
