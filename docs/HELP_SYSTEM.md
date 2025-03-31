# 🐒 Git Monkey: Tone-Modulated Help System

## Overview

Git Monkey features a dynamic help system that adapts content based on the user's experience level (tone stage) and theme preferences. This provides just the right amount of information at each stage of the user's journey, avoiding both overwhelm for beginners and unnecessary verbosity for experts.

## 🧠 Key Concepts

### Tone Stages
Help content varies depending on the user's tone stage (0-5):

- **Stage 0-1**: Detailed explanations with analogies and step-by-step guidance
- **Stage 2-3**: More technical information with intermediate concepts
- **Stage 4-5**: Concise command references with advanced options

### Themed Styling
Help content styling adapts to match the user's selected theme:

- **Jungle**: 🐒 🍌 🌴 Monkey-themed emojis and terminology
- **Hacker**: > ! $ Terminal-style formatting and tech references
- **Wizard**: ✨ 📜 ⚠️ Magical theming with spell references
- **Cosmic**: 🚀 🌌 ☄️ Space-themed iconography and metaphors

## 🛠️ Using the Help System

### Basic Help Usage
```bash
gitmonkey help                   # List all available help topics
gitmonkey help commit            # Show help for 'commit' at your tone stage
gitmonkey help branch            # Show help for 'branch' at your tone stage
```

### Advanced Options
```bash
gitmonkey help push --deep 3     # Force intermediate level explanation
gitmonkey help worktree --theme wizard # Show help with wizard theme
gitmonkey help commit --all      # Show all tone levels (for development)
```

### Command Help Integration
All commands also support the `--help` flag, which routes to the tone-modulated help system:
```bash
gitmonkey branch --help          # Same as 'gitmonkey help branch'
gitmonkey worktree:add --help    # Same as 'gitmonkey help worktree'
```

## 🧩 Technical Implementation

### Directory Structure
```
help_data/
├── commit/
│   ├── help_stage_0.txt
│   ├── help_stage_3.txt
│   └── help_stage_5.txt
├── branch/
│   ├── help_stage_0.txt
│   └── help_stage_4.txt
└── ...
```

### Content Fallback
If help content for the exact tone stage isn't available, the system automatically falls back to the closest lower stage. This ensures users always get appropriate content without requiring help files for every possible stage.

### Styling and Formatting
The help system applies theme-specific styling to generic markers in the help content:
- `TIP:` becomes themed tip markers (🍌, >, ✨, 🚀)
- `NOTE:` becomes themed note markers (🐒, >, 📜, 🌌)
- `WARNING:` becomes themed warning markers (🙈, !, ⚠️, ☄️)

## 🎭 Design Principles

1. **Progressive Disclosure**
   - Beginners get focused on the essentials
   - Advanced users get dense, information-rich content
   - Each tone stage builds on knowledge from previous stages

2. **Consistent Formatting**
   - All help content follows the same structural pattern
   - Command syntax is always highlighted consistently
   - Examples are always provided for key operations

3. **Theme Integration**
   - Themed elements enhance rather than obscure content
   - Theming follows the user's preference settings
   - Default styling remains clean and readable

4. **Educational Growth**
   - Early stage help focuses on conceptual understanding
   - Mid-stage help introduces best practices and workflows
   - Advanced help covers edge cases and power-user techniques

## 📝 Creating New Help Content

To add help for a new command:

1. Create a directory in `help_data/` with the command name
2. Add help files for different tone stages (at minimum 0, 3, and 5)
3. Follow the formatting pattern with SECTION HEADERS and concise content
4. Include USAGE, EXAMPLES, and TIPS sections
5. Mark key phrases with TIP:, NOTE:, and WARNING: for themed styling
6. Test with `gitmonkey help command --all` to see all stages

By creating help content that grows with the user, Git Monkey becomes more valuable throughout the user's journey from beginner to expert.