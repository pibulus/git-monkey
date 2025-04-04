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
- Get AI-powered commit messages and branch names
- Analyze merge risks with AI before conflicts happen
- Ask Git questions in plain language and get help
- Manage multiple branches with worktrees
- Switch contexts rapidly with pivot/return
- Push with automatic upstream tracking
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

Git Monkey provides multiple types of commands: the core CLI tool, AI-powered features, and Git aliases it sets up for you.

### CLI Commands

| Command | What it does |
|---------|--------------|
| `gitmonkey` | Launches the interactive menu |
| `gitmonkey tutorial` | Interactive Git School lessons (learn by doing) |
| `gitmonkey start [name]` | Create a new project with your preferred stack |
| `gitmonkey stash` | Manage your stashed changes |
| `gitmonkey push` | Push with automatic upstream tracking |
| `gitmonkey worktree:add` | Create a worktree for a branch |
| `gitmonkey worktree:list` | Show all active worktrees |
| `gitmonkey worktree:switch` | Navigate between worktrees |
| `gitmonkey worktree:remove` | Remove a worktree safely |
| `gitmonkey pivot` | Quick context switching with auto-stashing |
| `gitmonkey return` | Return to previous context |
| `gitmonkey whoami` | Show your current Git context |
| `gitmonkey tips` | View Git tips and tricks |
| `gitmonkey settings` | Customize your Git Monkey experience |
| `gitmonkey wizard` | Access advanced Git features |
| `gitmonkey help` | Show all available commands |
| `gitmonkey version` | Display the current version |

### AI-Powered Features

| Command | What it does |
|---------|--------------|
| `gitmonkey commit --suggest` | AI-generated commit messages based on your changes |
| `gitmonkey branch new --suggest` | Smart branch naming suggestions for your work |
| `gitmonkey merge <src> <target> --analyze` | AI risk analysis before merging branches |
| `gitmonkey ask "your git question"` | Interactive Git help in plain language |
| `gitmonkey settings ai` | Configure AI providers and preferences |

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

## 🧠 AI-Powered Assistance

Git Monkey now includes intelligent AI features that help you work more efficiently:

- **Smart Commit Messages**: Get AI-generated commit suggestions based on your code changes
- **Branch Name Generator**: Create meaningful branch names based on your repository context
- **Merge Risk Analysis**: Get a clear explanation of potential merge conflicts before they happen
- **Interactive Git Help**: Ask questions about Git in plain language and get personalized answers

The AI system adapts to your chosen theme and can work with multiple providers:
- OpenAI (GPT-4o)
- Claude (Anthropic)
- Gemini (Google)
- DeepSeek

Each feature works with or without AI, so you're never dependent on network connectivity.

## 🧙‍♂️ Themes & Easter Eggs

Git Monkey is more than just commands — it's a vibe.

- ASCII art & typewriter effects
- Terminal confetti moments
- Rare fortune cookie messages
- Four unique themes: Jungle, Hacker, Wizard, and Cosmic

## 🙏 Credits

Made with bananas and brains by Pablo Alvarado  
ASCII powered by lolcat, figlet, boxes, cowsay, and love.

## 📜 Legal

### License

Git Monkey is © 2025 Pablo Alvarado. All rights reserved.

This software is released under a custom license that allows for personal and educational use.
Commercial use requires explicit written permission from the copyright holder.
See the [LICENSE](LICENSE) file for details.

### Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to get started.

### Code of Conduct

We're committed to providing a welcoming and inspiring community for all. Please read our [Code of Conduct](CODE_OF_CONDUCT.md).