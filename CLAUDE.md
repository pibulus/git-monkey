# Git Monkey CLI - Development Guidelines

## Commands
- Run CLI: `bash gitmonkey.sh` or `gitmonkey` (if alias installed)
- Debug command: `bash -x commands/[command].sh` 
- Check syntax: `shellcheck commands/*.sh utils/*.sh`
- Test installation: `bash install.sh`

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