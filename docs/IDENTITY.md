# 🐒 Git Monkey: Personalized Identity System

## Overview

Git Monkey features a personalized identity system that creates a consistent, expressive identity for each user across the CLI. The system combines real names, anonymous alternatives, and earned titles to create a playful, adaptive experience that grows with the user.

## 🎭 Identity Components

### Real Name (Optional)
- Users can provide their real name for personalization
- If no name is provided, fun anonymous alternatives are used
- Examples: "Pablo", "Mysterious Banana", "Anon-Ape"

### Title
- Titles are earned through progression in the tone stage system
- Themed based on user preference (jungle, hacker, wizard, cosmic)
- Examples: "Git Guardian", "Code Commander", "Merge Monkey"

### Identity Modes
1. **Name Only**: Uses just the user's name (or anonymous alternative)
   - Example: "Pablo" or "Mysterious Banana"
2. **Title Only**: Uses just the user's earned title
   - Example: "Git Guardian" or "Merge Monkey"
3. **Combo (Default)**: Combines name and title
   - Example: "Pablo the Git Guardian" or "Mysterious Banana the Merge Monkey"

## 🛠️ Using the Identity System

### Setting Up Your Identity
```bash
gitmonkey identity setup         # Interactive identity setup
gitmonkey identity name "Pablo"  # Set your name directly
gitmonkey identity mode 3        # Set identity mode (1=name, 2=title, 3=combo)
```

### Managing Your Identity
```bash
gitmonkey identity               # View your current identity
gitmonkey identity random        # Get a new random title
gitmonkey identity preview 2     # Preview how title-only mode would look
gitmonkey identity lock on       # Lock your current title
gitmonkey identity lock off      # Allow title to change with progression
```

### Viewing Your Identity
```bash
gitmonkey whoami                 # Shows identity along with Git context
```

## 🧠 Technical Details

### Storage
- All identity information is stored in `~/.gitmonkey/profile.json`
- Identity information is contained in the `identity` object:
  ```json
  "identity": {
    "name": "Pablo",
    "display_name": "Pablo",
    "custom_name": true,
    "identity_mode": 3,
    "title_locked": false
  }
  ```

### Anonymous Names
If no name is provided, the system uses fun anonymous alternatives:
- Mysterious Banana
- Anon-Ape
- Secret Simian
- Unknown Primate
- Shadow Coder
- Nameless Monkey
- And more...

The anonymous name is consistently generated based on system username.

### Identity Modes
- 1: Name only format - "Pablo"
- 2: Title only format - "Git Guardian"
- 3: Combo format - "Pablo the Git Guardian"

### Title Locking
Users can lock their current title to prevent it from changing as they progress through tone stages. This is useful when they find a title they particularly like.

## 🎨 Integration Points

The identity system is integrated throughout Git Monkey:
- Welcome messages in the CLI
- Greetings at the start of commands
- Whoami command output
- Menu interface
- Tutorial completion messages

## 🌱 Philosophy

The identity system embodies several key principles:
1. **Personalization without Invasion**: Collects minimal personal information
2. **Playfulness with Respect**: Fun without being childish
3. **Growth-Oriented**: Evolves with the user's experience
4. **Opt-In Flexibility**: All aspects are optional and customizable
5. **Consistent Personality**: Creates a cohesive experience across the CLI

This creates an environment that feels alive and responsive without being intrusive or patronizing.