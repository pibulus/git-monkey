#!/bin/bash

# ========= GIT MONKEY OPEN COMMAND =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# Opens Git projects in the user's preferred editor/IDE


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
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
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

# Detect operating system
detect_os() {
  case "$(uname -s)" in
    Darwin*)
      echo "macos"
      ;;
    Linux*)
      echo "linux"
      ;;
    CYGWIN*|MINGW*|MSYS*)
      echo "windows"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Get user's preferred editor from settings or environment
get_preferred_editor() {
  # First check if the user has set a preferred editor in git monkey
  local editor=$(get_setting "preferred_editor")
  
  # If not set in git monkey, check VISUAL and EDITOR environment variables
  if [ -z "$editor" ]; then
    editor="${VISUAL:-${EDITOR:-}}"
  fi
  
  # If still not set, return empty
  echo "$editor"
}

# Open in Visual Studio Code
open_in_vscode() {
  local path="$1"
  
  # Default to current directory if no path specified
  if [ -z "$path" ]; then
    path="."
  fi
  
  # Check if code command is available
  if command -v code &>/dev/null; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji Opening in Visual Studio Code..."
    fi
    
    code "$path"
    return $?
  else
    # Code command not found, provide instructions
    if [ "$TONE_STAGE" -le 3 ]; then
      echo "$warning_emoji 'code' command not found."
      echo "To install the VS Code command-line tool:"
      echo "  1. Open VS Code"
      echo "  2. Press Cmd+Shift+P (or Ctrl+Shift+P on Windows/Linux)"
      echo "  3. Type 'shell command' and select 'Install code command in PATH'"
    else
      echo "$warning_emoji 'code' command not found. Install VS Code CLI tools."
    fi
    return 1
  fi
}

# Open in Sublime Text
open_in_sublime() {
  local path="$1"
  
  # Default to current directory if no path specified
  if [ -z "$path" ]; then
    path="."
  fi
  
  # Check if subl command is available
  if command -v subl &>/dev/null; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji Opening in Sublime Text..."
    fi
    
    subl "$path"
    return $?
  else
    # Sublime command not found, provide instructions
    if [ "$TONE_STAGE" -le 3 ]; then
      echo "$warning_emoji 'subl' command not found."
      echo "To install the Sublime Text command-line tool, see:"
      echo "https://www.sublimetext.com/docs/command_line.html"
    else
      echo "$warning_emoji 'subl' command not found. Install Sublime CLI tools."
    fi
    return 1
  fi
}

# Open with system default
open_with_system_default() {
  local path="$1"
  local os=$(detect_os)
  
  # Default to current directory if no path specified
  if [ -z "$path" ]; then
    path="."
  fi
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$info_emoji Opening with system default..."
  fi
  
  case "$os" in
    "macos")
      open "$path"
      ;;
    "linux")
      xdg-open "$path" &>/dev/null
      ;;
    "windows")
      start "" "$path" &>/dev/null
      ;;
    *)
      echo "$error_emoji Unsupported operating system."
      return 1
      ;;
  esac
  
  return $?
}

# Open diff in editor
open_diff() {
  local os=$(detect_os)
  local diff_file="/tmp/gitmonkey_diff_$(date +%s).diff"
  
  # Generate diff file
  git diff > "$diff_file"
  
  # If diff is empty, check for staged changes
  if [ ! -s "$diff_file" ]; then
    git diff --staged > "$diff_file"
  fi
  
  # If still empty, inform user
  if [ ! -s "$diff_file" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji No changes to display, $IDENTITY!"
    else
      echo "$info_emoji No changes to display."
    fi
    rm "$diff_file"
    return 0
  fi
  
  # Open diff file with appropriate editor
  local editor="$1"
  
  case "$editor" in
    "code"|"vscode")
      open_in_vscode "$diff_file"
      ;;
    "subl"|"sublime")
      open_in_sublime "$diff_file"
      ;;
    *)
      # Try preferred editor first
      local preferred=$(get_preferred_editor)
      
      if [ -n "$preferred" ]; then
        $preferred "$diff_file"
      else
        # Fall back to OS default
        open_with_system_default "$diff_file"
      fi
      ;;
  esac
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "$info_emoji Opened diff in your editor. This is a temporary file and won't be saved to your repository."
  fi
}

# Open merge conflicts in editor
open_merge() {
  # Check if there are merge conflicts
  if ! git ls-files -u | grep -q .; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji There are no merge conflicts to resolve, $IDENTITY!"
    else
      echo "$info_emoji No merge conflicts to resolve."
    fi
    return 0
  fi
  
  # Get conflicted files
  local conflicted_files=($(git diff --name-only --diff-filter=U))
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$info_emoji Opening ${#conflicted_files[@]} files with merge conflicts..."
  else
    echo "$info_emoji Opening ${#conflicted_files[@]} conflicted files..."
  fi
  
  # Open with appropriate editor
  local editor="$1"
  
  case "$editor" in
    "code"|"vscode")
      open_in_vscode "${conflicted_files[@]}"
      ;;
    "subl"|"sublime")
      open_in_sublime "${conflicted_files[@]}"
      ;;
    *)
      # Try preferred editor first
      local preferred=$(get_preferred_editor)
      
      if [ -n "$preferred" ]; then
        $preferred "${conflicted_files[@]}"
      else
        # Fall back to system default for each file
        for file in "${conflicted_files[@]}"; do
          open_with_system_default "$file"
        done
      fi
      ;;
  esac
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "$info_emoji Look for the <<<<<<, =======, and >>>>>>> markers to find the conflicted areas."
    echo "After resolving conflicts, save the files, then run:"
    echo "  git add <filename>    # For each resolved file"
    echo "  git commit            # To complete the merge"
  elif [ "$TONE_STAGE" -le 3 ]; then
    echo ""
    echo "$info_emoji After resolving conflicts: git add <files>, then git commit"
  fi
}

# Open a specific branch
open_branch() {
  local branch="$1"
  local editor="$2"
  
  # If no branch specified, show error
  if [ -z "$branch" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$error_emoji Please specify a branch name, $IDENTITY!"
      echo "Usage: gitmonkey open branch <branch-name> [editor]"
    else
      echo "$error_emoji Missing branch name."
      echo "Usage: gitmonkey open branch <branch-name> [editor]"
    fi
    return 1
  fi
  
  # Check if branch exists
  if ! git show-ref --verify --quiet "refs/heads/$branch"; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$error_emoji Branch '$branch' doesn't exist, $IDENTITY!"
    else
      echo "$error_emoji Branch '$branch' doesn't exist."
    fi
    return 1
  fi
  
  # Switch to branch first
  if [ "$(git rev-parse --abbrev-ref HEAD)" != "$branch" ]; then
    if [ "$TONE_STAGE" -le 2 ]; then
      echo "$info_emoji Switching to branch '$branch' first..."
    fi
    
    git checkout "$branch"
    
    if [ $? -ne 0 ]; then
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "$error_emoji Failed to switch to branch '$branch'."
        echo "You might have uncommitted changes. Try committing or stashing them first."
      else
        echo "$error_emoji Failed to switch to branch '$branch'."
      fi
      return 1
    fi
  fi
  
  # Open in editor
  open_in_editor "$editor"
}

# Open in appropriate editor
open_in_editor() {
  local editor="$1"
  
  case "$editor" in
    "code"|"vscode")
      open_in_vscode
      ;;
    "subl"|"sublime")
      open_in_sublime
      ;;
    *)
      # Try preferred editor first
      local preferred=$(get_preferred_editor)
      
      if [ -n "$preferred" ]; then
        $preferred .
      else
        # Fall back to OS default
        open_with_system_default
      fi
      ;;
  esac
  
  # Display terminal+GUI workflow tip occasionally for beginners
  if [ "$TONE_STAGE" -le 2 ] && (( RANDOM % 3 == 0 )); then
    echo ""
    echo "$info_emoji Pro tip: You can now use a hybrid workflow!"
    echo "   • Use your editor for viewing and editing files"
    echo "   • Use Git Monkey in the terminal for quick Git operations"
    echo "   • Combine both for maximum efficiency"
  fi
}

# Set preferred editor
set_preferred_editor() {
  local editor="$1"
  
  # Validate editor
  case "$editor" in
    "code"|"vscode")
      if ! command -v code &>/dev/null; then
        if [ "$TONE_STAGE" -le 2 ]; then
          echo "$warning_emoji VS Code command 'code' not found, $IDENTITY."
          echo "VS Code is set as preferred, but you'll need to install the command-line tool:"
          echo "  1. Open VS Code"
          echo "  2. Press Cmd+Shift+P (or Ctrl+Shift+P on Windows/Linux)"
          echo "  3. Type 'shell command' and select 'Install code command in PATH'"
        else
          echo "$warning_emoji VS Code command 'code' not found. Install command-line tools."
        fi
      fi
      update_setting "preferred_editor" "code"
      ;;
    "subl"|"sublime")
      if ! command -v subl &>/dev/null; then
        if [ "$TONE_STAGE" -le 2 ]; then
          echo "$warning_emoji Sublime Text command 'subl' not found, $IDENTITY."
          echo "Sublime Text is set as preferred, but you'll need to install the command-line tool:"
          echo "See: https://www.sublimetext.com/docs/command_line.html"
        else
          echo "$warning_emoji Sublime Text command 'subl' not found. Install command-line tools."
        fi
      fi
      update_setting "preferred_editor" "subl"
      ;;
    "vim"|"nvim"|"nano"|"emacs"|"atom"|"webstorm")
      update_setting "preferred_editor" "$editor"
      ;;
    *)
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "$error_emoji Unknown editor: $editor"
        echo "Supported editors: code (VS Code), subl (Sublime Text), vim, nvim, nano, emacs, atom, webstorm"
      else
        echo "$error_emoji Unknown editor: $editor"
        echo "Supported: code, subl, vim, nvim, nano, emacs, atom, webstorm"
      fi
      return 1
      ;;
  esac
  
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "$success_emoji Preferred editor set to $editor!"
    echo "You can now use 'gitmonkey open' without specifying an editor."
  else
    echo "$success_emoji Preferred editor: $editor"
  fi
}

# Show usage information
show_usage() {
  echo "Usage: gitmonkey open [option] [editor]"
  echo ""
  echo "Options:"
  echo "  (default)       Open current directory in editor"
  echo "  diff            Open Git diff in editor"
  echo "  merge           Open merge conflicts in editor"
  echo "  branch <name>   Checkout and open branch in editor"
  echo "  set <editor>    Set preferred editor"
  echo ""
  echo "Editors:"
  echo "  code, vscode    Visual Studio Code"
  echo "  subl, sublime   Sublime Text"
  echo "  (system)        System default (if no editor specified)"
  echo ""
  echo "Examples:"
  echo "  gitmonkey open                 # Open current directory in preferred editor"
  echo "  gitmonkey open code            # Open current directory in VS Code"
  echo "  gitmonkey open diff sublime    # Open Git diff in Sublime Text"
  echo "  gitmonkey open merge           # Open merge conflicts in preferred editor"
  echo "  gitmonkey open branch feature  # Checkout and open feature branch"
  echo "  gitmonkey open set code        # Set VS Code as preferred editor"
}

# Main function
main() {
  # No arguments, open current directory
  if [ $# -eq 0 ]; then
    open_in_editor
    return $?
  fi
  
  # Parse arguments
  local option="$1"
  local editor="${2:-}"
  
  case "$option" in
    "diff")
      open_diff "$editor"
      ;;
    "merge")
      open_merge "$editor"
      ;;
    "branch")
      open_branch "$2" "$3"
      ;;
    "set")
      set_preferred_editor "$2"
      ;;
    "help"|"--help"|"-h")
      show_usage
      ;;
    "code"|"vscode"|"subl"|"sublime"|"vim"|"nvim"|"nano"|"emacs"|"atom"|"webstorm")
      # If the first argument is an editor, open current directory in that editor
      open_in_editor "$option"
      ;;
    *)
      if [ "$TONE_STAGE" -le 2 ]; then
        echo "$error_emoji Unknown option: $option"
        echo "Run 'gitmonkey open --help' for usage information."
      else
        echo "$error_emoji Unknown option: $option"
      fi
      return 1
      ;;
  esac
}

# Execute main function
main "$@"
