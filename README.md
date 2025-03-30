# 🐒 Git Monkey CLI

**The chillest, kindest way to learn Git.**  
Built for curious humans, not grumpy devs.  
Inspired by retro hacker energy and the joy of getting unstuck.

---

## ✨ What It Is

A local-friendly CLI script that helps you:
- Set up your git aliases with zero friction
- Clone repos with style and confidence
- Create and switch branches with helpful guidance
- Undo mistakes safely (without the panic)
- Start new projects with your preferred tech stack
- Learn Git interactively with "Git School"
- Explore advanced features with Wizard Mode

---

## 🧑‍🚀 Getting Started

```bash
git clone https://github.com/yourname/git-monkey
cd git-monkey
bash install.sh
```

Then restart your terminal.

You'll be able to run `gitmonkey` from anywhere!

## 🛠 Commands

Git Monkey provides two types of commands: the CLI tool itself and Git aliases it sets up for you.

### CLI Commands

| Command | What it does |
|---------|--------------|
| `gitmonkey` | Launches the interactive menu |
| `gitmonkey tutorial` | Interactive Git School lessons (learn by doing) |
| `gitmonkey start [name]` | Create a new project with your preferred stack |
| `gitmonkey stash` | Manage your stashed changes |
| `gitmonkey tips` | View Git tips and tricks |
| `gitmonkey settings` | Customize your Git Monkey experience |
| `gitmonkey wizard` | Access advanced Git features |
| `gitmonkey help` | Show all available commands |
| `gitmonkey version` | Display the current version |

### Git Aliases

These powerful shortcuts are installed when you run `gitmonkey alias`:

| Command | What it does |
|---------|--------------|
| `git s "message"` | Save your work (add + commit in one step) |
| `git lol` | View your git history with ASCII style |
| `git new branch-name` | Start a new branch with guidance |
| `git yikes` | Reset your code to match the last push |
| `git resurrect` | Recover lost commits via reflog |

## 🌈 Design Philosophy

Git Monkey is powered by the Soft Stack:

- **Emotional intelligence** - We know Git can be scary
- **Delightful UX** - Terminal joy should be standard
- **Slack for chaos** - Git mistakes happen to everyone
- **Hacker joy, human ease** - Power without the pain

We believe learning should feel fun, not fragile.

## 🚀 Project Starter

Git Monkey includes a powerful project starter that helps you scaffold new projects with your preferred tech stack:

```bash
gitmonkey start my-awesome-project
```

The starter wizard guides you through:

- **Frameworks**: SvelteKit, Node.js, or static sites
- **UI Libraries**: Tailwind CSS with DaisyUI
- **Backend Services**: Supabase integration
- **Developer Tools**: ESLint, Prettier, GitHub repo setup

You can save your favorite configurations as presets:

```bash
# Use a saved preset
gitmonkey start new-project --preset favorite

# Skip prompts and use defaults
gitmonkey start quick-project --minimal
```

## 🧙‍♂️ Themes & Easter Eggs

Git Monkey is more than just commands — it's a vibe.

- ASCII art & typewriter effects
- Terminal confetti moments
- Rare fortune cookie messages
- Secret themes coming soon...

## 🙏 Credits

Made with bananas and brains by [@pablosoftstack](https://github.com/pablosoftstack)  
ASCII powered by lolcat, figlet, boxes, cowsay, and love.