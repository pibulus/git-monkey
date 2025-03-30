# Git Monkey CLI - Development Guidelines

## Commands
- Run CLI: `bash gitmonkey.sh` or `gitmonkey` (if alias installed)
- Run specific command: `gitmonkey [command]` (e.g., `gitmonkey tutorial`)
- Run project starter: `gitmonkey start [project_name] [--preset name] [--minimal]`
- Debug command: `bash -x commands/[command].sh` 
- Check syntax: `shellcheck commands/*.sh utils/*.sh`
- Test installation: `bash install.sh`

## Project Structure
- `/bin/git-monkey` - CLI router (legacy)
- `/gitmonkey.sh` - Main CLI dispatcher
- `/commands/` - Command scripts (e.g., `tutorial.sh`, `branch.sh`)
  - `/commands/start.sh` - Main project starter script
  - `/commands/starter/` - Project starter modules
    - `/commands/starter/starter_config.sh` - Shared config for starter
    - `/commands/starter/frameworks/` - Framework setup modules (SvelteKit, Node, Static)
    - `/commands/starter/ui/` - UI toolkit modules (Tailwind, DaisyUI)
    - `/commands/starter/backends/` - Backend service modules (Supabase)
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
- `random_greeting()` - Random welcome message
- `random_success()` - Random success message
- `random_fail()` - Random failure message

## Configuration
- User settings stored in `$HOME/.gitmonkey/config/settings.conf`
- Settings include animation, ASCII art, and color preferences
- Update settings with `update_setting [setting] [value]`
- Access settings via environment variables (e.g., `$ENABLE_ANIMATIONS`)