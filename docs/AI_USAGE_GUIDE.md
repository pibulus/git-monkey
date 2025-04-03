# 🧠 Git Monkey AI Usage Guide

This guide explains how to set up and use Git Monkey's AI-powered features, which enhance your Git workflow with intelligent assistance.

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Available AI Features](#available-ai-features)
3. [Configuration Options](#configuration-options)
4. [AI Providers](#ai-providers)
5. [Usage Tracking & Limits](#usage-tracking--limits)
6. [Troubleshooting](#troubleshooting)

## 🚀 Getting Started

Git Monkey's AI features require an API key from one of the supported AI providers. Here's how to set up:

1. **During first-time onboarding**: When you first run Git Monkey, you'll be offered AI integration as part of the setup process.

2. **Using the settings menu**:
   ```bash
   gitmonkey settings ai
   ```

3. **Choose a provider**: Select from OpenAI, Claude (Anthropic), Gemini (Google), or DeepSeek.

4. **Enter your API key**: You can obtain an API key from your chosen provider's website.

## 💡 Available AI Features

### 1. AI-Generated Commit Messages
Generate meaningful commit messages based on your changes.

```bash
gitmonkey commit --suggest
```

This will analyze your staged changes and suggest a well-formatted commit message following best practices.

### 2. Smart Branch Naming
Get AI-powered suggestions for branch names based on your recent work.

```bash
gitmonkey branch new --suggest
```

This creates branch name suggestions following conventional naming patterns like feature/, fix/, chore/, etc.

### 3. Merge Risk Analysis
Assess the potential risks before merging branches.

```bash
gitmonkey merge source_branch target_branch --analyze
```

This analyzes both branches and provides:
- A risk assessment score
- Explanation of potential conflicts
- Recommendations to reduce merge risks

### 4. Interactive Git Help
Ask questions about Git in plain language.

```bash
gitmonkey ask "how do I undo my last commit?"
```

This provides contextual Git help with commands you can execute directly.

## ⚙️ Configuration Options

Manage your AI settings with:

```bash
gitmonkey settings ai
```

Options include:
- Adding/updating API keys
- Setting a default AI provider
- Setting usage limits
- Viewing usage statistics
- Testing AI connections

## 🤖 AI Providers

Git Monkey supports multiple AI providers:

| Provider | Strengths | API Key URL |
|----------|-----------|-------------|
| OpenAI (GPT-4o) | Excellent code understanding, widely used | [OpenAI API Keys](https://platform.openai.com/api-keys) |
| Claude (Anthropic) | Strong reasoning, clear explanations | [Claude API Keys](https://console.anthropic.com/settings/keys) |
| Gemini (Google) | Good performance, competitive pricing | [Gemini API Keys](https://makersuite.google.com/app/apikey) |
| DeepSeek | Open-source foundation, specialized for code | [DeepSeek API Keys](https://platform.deepseek.com/api_keys) |

## 📊 Usage Tracking & Limits

Git Monkey tracks your AI usage to help manage costs:

- **View usage**: See your current month's usage with `gitmonkey settings ai` (option 5)
- **Set limits**: Set a monthly spending limit in cents (option 4)
- **Notifications**: Git Monkey will notify you when approaching your limit

Usage data is stored locally in `~/.gitmonkey/` and never shared externally.

## 🔧 Troubleshooting

### Common Issues

1. **API Key Errors**
   ```
   Error: No API key found for [Provider]
   ```
   Solution: Run `gitmonkey settings ai` and add or update your API key.

2. **Connection Failures**
   ```
   Error: Failed to get response from [Provider]
   ```
   Solutions:
   - Check your internet connection
   - Verify your API key is valid
   - Try a different AI provider

3. **Usage Limit Reached**
   ```
   Error: Monthly usage limit has been reached.
   ```
   Solution: Increase your usage limit in `gitmonkey settings ai` if desired.

### Performance Tips

- **Use caching**: Git Monkey automatically caches responses for 24 hours
- **Be specific**: More specific prompts produce better results
- **Try different providers**: Each provider has different strengths

---

For more information, feature requests, or to report issues with AI features, please visit the Git Monkey repository or run `gitmonkey help ai`.