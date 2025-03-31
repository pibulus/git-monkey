# 🐒 Git Monkey: Tone Stage & Title Engine System

## Overview

Git Monkey features a unique Tone Stage System that tracks user experience levels over time, and a Title Engine that assigns playful, themed titles based on user progression. This creates an ambient sense of growth and identity without explicit gamification.

## 🌀 Tone Stage System

### What It Does
The Tone Stage System tracks how far along you are in your Git Monkey journey, from absolute beginner to confident Git wizard. This progression affects:

- The tone and verbosity of explanations
- The detail level of help content
- The titles you can earn

### How It Works
- Stages range from 0 (newbie) to 5 (mastery)
- Your stage advances automatically based on your usage patterns:
  - Number of commands used
  - Diversity of commands
  - Tutorial completion
  - Advanced feature usage

### Tone Stage Progression

| Stage | Description | How to Reach This Stage |
|-------|-------------|-------------------------|
| 0 | Total beginner | Default for new users |
| 1 | Curious monkey | Use 3+ different commands successfully |
| 2 | Active user | Use branches, stashing, or undo features |
| 3 | Confident explorer | Use worktrees, pivot, or other advanced features |
| 4 | Chillmaster | Use 10+ commands including generate or custom setups |
| 5 | Ascended ape | Complete the tutorial or use 15+ different commands |

## 🍌 Title Engine

### What It Does
The Title Engine assigns you fun, themed titles based on your tone stage and selected theme. These titles are used in greetings, summaries, and UI elements.

### Available Themes
- **Jungle**: Nature and monkey-themed titles (default)
- **Hacker**: Tech and coding-themed titles
- **Wizard**: Magical and mystical titles
- **Cosmic**: Space and sci-fi themed titles

### Example Titles by Stage

#### Jungle Theme
- Stage 0: Banana Sprout, Tiny Ape, Monkeyling
- Stage 1: Commit Cub, Branch Hopper, Jungle Scout
- Stage 2: Patch Prince, Merge Monkey, Tree Swinger
- Stage 3: Git Whisperer, Vibeonaut, Branch Baron
- Stage 4: Chill Dog, Diff Druid, Repo Royalty
- Stage 5: The Final Commit, Cosmic Ape, Git Guardian

#### Hacker Theme
- Stage 0: Script Newbie, Byte Baby, Code Cadet
- Stage 1: CLI Climber, Hack Hobbyist, Data Dabbler
- Stage 2: Debug Detective, Code Conjurer, Binary Bandit
- Stage 3: Git Guru, Console Cowboy, Branch Breaker
- Stage 4: Deep Diver, Kernel Killer, Version Virtuoso
- Stage 5: Ghost in the Git, Code Commander, Bash Boss

And more for the Wizard and Cosmic themes!

## 🛠️ Using the Title System

### View Your Title
```bash
gitmonkey whoami      # Shows your title along with Git context
gitmonkey title       # Shows detailed title and tone stage info
```

### Manage Your Title
```bash
gitmonkey title list      # List available titles for your stage
gitmonkey title random    # Get a new random title for your stage
gitmonkey title set "Custom Title"    # Set a specific title
gitmonkey title theme wizard    # Change to the wizard theme
```

## Technical Details

- Tone stage and title information is stored in `~/.gitmonkey/profile.json`
- Command usage is tracked automatically to progress tone stages
- Tutorial completion can boost your tone stage
- Each new tone stage unlocks a new set of titles
- Your active title persists until your tone stage changes

## Philosophy

The Tone Stage & Title system embodies Git Monkey's design philosophy:
- **Meet users where they are**: Adapt to different experience levels
- **Progressive disclosure**: Reveal complexity gradually
- **Delight through surprise**: Create moments of unexpectedly pleasant interactions
- **Identity through journey**: Build connections through shared understanding

Enjoy your journey through Git Monkey's ranks, from Monkeyling to Cosmic Ape!