# Git Monkey CLI - Development Guidelines

## Commands
- Run CLI: `bash gitmonkey.sh` or `gitmonkey` (if alias installed)
- Run specific command: `gitmonkey [command]` (e.g., `gitmonkey tutorial`)
- Run project starter: `gitmonkey start [project_name] [--preset name] [--minimal]`
- Run worktree commands: `gitmonkey worktree:add <branch>`, `gitmonkey worktree:list`, etc.
- Run context switching: `gitmonkey pivot <branch>`, `gitmonkey return`
- Run smart push: `gitmonkey push [--force] [--no-config] [--yes]`
- Debug command: `bash -x commands/[command].sh` 
- Check syntax: `shellcheck commands/*.sh utils/*.sh`
- Verify permissions: `find . -name "*.sh" -not -executable`
- Test installation: `bash install.sh`

## Project Structure
- `/bin/git-monkey` - CLI router
- `/gitmonkey.sh` - Main CLI dispatcher
- `/commands/` - Command scripts (e.g., `tutorial.sh`, `branch.sh`)
  - `/commands/push.sh` - Smart push with automatic upstream
  - `/commands/worktree.sh` - Worktree command router
  - `/commands/worktree/` - Worktree subcommands
    - `/commands/worktree/add.sh` - Add new worktrees
    - `/commands/worktree/list.sh` - List existing worktrees
    - `/commands/worktree/switch.sh` - Navigate between worktrees
    - `/commands/worktree/remove.sh` - Delete worktrees
  - `/commands/pivot.sh` - Context switching with auto-stashing
  - `/commands/return.sh` - Return to previous context
  - `/commands/whoami.sh` - Show current Git context
  - `/commands/learn.sh` - Educational content
  - `/commands/start.sh` - Main project starter script
  - `/commands/starter/` - Project starter modules
    - `/commands/starter/starter_config.sh` - Shared config for starter
    - `/commands/starter/frameworks/` - Framework setup modules (SvelteKit, Node, Static)
    - `/commands/starter/ui/` - UI toolkit modules (Tailwind, DaisyUI, etc.)
    - `/commands/starter/backends/` - Backend service modules (Supabase, Xata)
    - `/commands/starter/extras/` - Additional setup modules (ESLint, GitHub)
- `/utils/` - Utility scripts
  - `/utils/style.sh` - UI and styling utilities
  - `/utils/config.sh` - Configuration management
- `/assets/` - ASCII art and other resources

## Code Style
- Use shebang `#!/bin/bash` for all scripts
- Source utilities: `source ./utils/style.sh` or `source ./utils/config.sh`
- Follow consistent indentation (2 spaces)
- Keep functions small and single-purpose
- Use descriptive variable names (SNAKE_CASE for constants)
- Add comments for non-obvious code
- Error handling: Use `|| { echo "Error message"; exit 1; }` pattern
- Function naming: Use lowercase_with_underscores
- Quote all variables: `"$variable"` not $variable
- Check commands exist before using: `if command -v figlet >/dev/null; then`
- Prefer local variables in functions: `local my_var="value"`

## Style Utilities
- `typewriter "Text" [speed]` - Animated text printing
- `ascii_banner "Text"` - Large ASCII art text
- `box "Text"` - Create a simple box around text
- `rainbow_box "Text"` - Colorful box for important messages
- `line()` - Horizontal line divider
- `random_greeting()` - Random welcome message
- `random_success()` - Random success message
- `random_fail()` - Random failure message
- `random_tip()` - Random troubleshooting tip

## Configuration
- User settings stored in `$HOME/.gitmonkey/config/settings.conf`
- Worktree state stored in `$HOME/.gitmonkey/worktrees.json`
- Pivot state stored in `$HOME/.gitmonkey/pivot.json`
- Settings include animation, ASCII art, and color preferences
- Update settings with `update_setting [setting] [value]`
- Access settings via environment variables (e.g., `$ENABLE_ANIMATIONS`)

## Worktree Helper Functions
- `record_worktree` - Save worktree info to state file
- `remove_worktree_record` - Delete worktree from state file
- `get_worktree_path` - Get path for a specific branch
- `has_uncommitted_changes` - Check for unsaved work

## Context Switching Helpers
- `save_pivot_state` - Store context before switching
- `get_pivot_state` - Retrieve stored context
- `clear_pivot_state` - Clean up after returning
- `find_stash_entry` - Locate stashed changes by name

## UX Principle: Smart Contextual Help & Autoresponse

When implementing Git Monkey features, apply this pattern for error handling and friction points:

```
[Step 1] Detect issue (e.g., missing upstream, detached HEAD, uncommitted changes)
[Step 2] Show friendly explanation:
    "🐒 Looks like you're in [problem]. Here's what's going on..."
[Step 3] Offer to fix it:
    "Want me to [solution]? (Y/n)"
[Step 4] On confirmation, run the fix.
[Optional] Support `--yes` or `--auto` flag to skip the prompt.
```

Apply this pattern to common Git friction points:
- Pushing with no upstream
- Switching branches with uncommitted changes
- Pushing to detached HEAD
- Rebasing without pulling latest
- Git pull with divergent branches
- Adding remotes
- Renaming branches
- Orphaned stashes
- Merging conflicts
- Cleaning ignored files

## Important Notes
- For directory navigation commands (pivot, return, worktree:switch), the output must be evaluated:
  - Use `eval "$(./commands/pivot.sh)"` in the main router
- All scripts should check for required commands before using them
- Remember to make all script files executable after creating them
- Ensure consistent styling with the rest of the codebase
- Add educational content to `learn.sh` for new features
- Add the `--yes` flag to all commands that require user confirmation