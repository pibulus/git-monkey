# 🚀 Git Monkey AI Integration Plan

This document outlines the comprehensive plan for integrating AI capabilities into Git Monkey, enhancing the user experience while maintaining the tool's core principles of being delightful, educational, and respectful of user preferences.

## 📋 Table of Contents

1. [Strategic Overview](#-strategic-overview)
2. [User Onboarding & Experience](#-user-onboarding--experience)
3. [Technical Implementation](#-technical-implementation)
4. [Feature Roadmap](#-feature-roadmap)
5. [Implementation Phases](#-implementation-phases)
6. [Security & Privacy](#-security--privacy)
7. [Directory Structure](#-directory-structure)
8. [API Reference](#-api-reference)

## 🧠 Strategic Overview

Git Monkey's AI integration will transform it from a helpful Git tool into an intelligent development assistant. The AI features should feel like a natural extension of Git Monkey's personality - not a separate bolt-on feature, but an organic enhancement of its ability to help users master Git.

### Core Principles

1. **Contextual Understanding**: AI features will understand Git operations in context
2. **Adaptive Assistance**: Provide personalized help based on user expertise level
3. **Workflow Enhancement**: Offer proactive suggestions that save time and prevent errors
4. **Graceful Degradation**: Remain fully functional even without AI access
5. **Provider Flexibility**: Support multiple AI providers for reliability and user choice

## 👤 User Onboarding & Experience

### First-Time Setup

During initial onboarding in `welcome.sh`, users will be offered AI integration as an optional enhancement:

1. After theme selection, present AI options with clear benefits
2. Offer multiple provider choices (OpenAI, Claude, Gemini, DeepSeek)
3. Guide users through API key setup with direct links
4. Make skipping easy with clear instructions to add later

### Progressive Disclosure

Features will be introduced gradually to avoid overwhelming users:

1. Start with commit message suggestions (highest value, familiar concept)
2. Introduce branch naming as users create branches
3. Present merge risk analysis when attempting complex merges
4. Make advanced help available on-demand through the ask command

### Theme Integration

All AI interactions will adapt to the user's chosen theme:

| Theme | Personality | Visual Style | Terminology |
|-------|-------------|--------------|-------------|
| Jungle | Playful, friendly | Vines, bananas, monkeys | "Swinging through code" |
| Hacker | Technical, precise | Matrix-style, terminals | "System analysis" |
| Wizard | Mystical, wise | Sparkles, scrolls, spells | "Arcane knowledge" |
| Cosmic | Expansive, visionary | Stars, planets, galaxies | "Cosmic intelligence" |

## 🔧 Technical Implementation

### API Key Management

Keys will be managed securely through `utils/ai_keys.sh`:

```bash
# Constants
AI_KEYS_FILE="$HOME/.gitmonkey/api_keys"
AI_CONFIG_FILE="$HOME/.gitmonkey/ai_config"

# Core functions
initialize_ai_keys_file()  # Create secure files with proper permissions
save_api_key()             # Add/update provider API key
get_api_key()              # Retrieve key for a provider
delete_api_key()           # Remove a provider
set_default_ai_provider()  # Set preferred provider
get_default_ai_provider()  # Get current default provider
```

Keys will be stored in JSON format with 600 permissions:
```json
{
  "OpenAI": "sk-...",
  "Claude": "sk-ant-...",
  "Gemini": "AIz...",
  "DeepSeek": "sk-dpk-..."
}
```

### Central Request Handler

All AI interactions will flow through `utils/ai_request.sh`:

```bash
# Main functions
ai_request()              # Primary function for making requests
process_git_context()     # Add Git-specific context to prompts
make_api_request()        # Provider-specific API handling
generate_cache_key()      # Create cache keys for responses
check_cache()             # Check for cached responses
update_cache()            # Store responses for reuse
```

Features include:
- Automatic retries for failed requests
- Response caching to improve performance
- Fallback to alternative providers
- Context enrichment for better responses
- Timeout handling

### Provider-Specific Integration

| Provider | API Endpoint | Model | Documentation |
|----------|--------------|-------|---------------|
| OpenAI | api.openai.com/v1/chat/completions | gpt-4o | [API Docs](https://platform.openai.com/docs/api-reference) |
| Claude | api.anthropic.com/v1/messages | claude-3-haiku | [API Docs](https://docs.anthropic.com/claude/reference/getting-started-with-the-api) |
| Gemini | generativelanguage.googleapis.com | gemini-pro | [API Docs](https://ai.google.dev/tutorials/rest_quickstart) |
| DeepSeek | api.deepseek.com/v1/chat/completions | deepseek-chat | [API Docs](https://platform.deepseek.com/docs) |

## ✨ Feature Roadmap

### 1. AI-Powered Commit Messages

- **Function**: `generate_ai_commit()` in `commit.sh`
- **Activation**: `gitmonkey commit --suggest` or `gitmonkey commit --ai`
- **Workflow**:
  1. Analyze staged changes with `git diff --cached`
  2. Send diff to AI with recent commit context
  3. Generate concise, conventional commit message
  4. Allow user to accept, edit, or discard suggestion

### 2. Smart Branch Naming

- **Function**: `suggest_branch_name()` in `branch.sh`
- **Activation**: `gitmonkey branch new --suggest`
- **Workflow**:
  1. Analyze current context (issue numbers, recent work)
  2. Generate multiple naming suggestions
  3. Follow conventional prefixes (feature/, fix/, etc.)
  4. Allow quick selection or custom entry

### 3. Merge Risk Analysis

- **Function**: `analyze_merge_risks()` in `merge.sh`
- **Activation**: `gitmonkey merge source target --analyze`
- **Workflow**:
  1. Compare branches to identify potential conflicts
  2. Assess risk level based on change patterns
  3. Provide specific recommendations to mitigate risks
  4. Allow user to proceed or cancel based on analysis

### 4. Interactive Git Help

- **Function**: `ask_git_question()` in `ask.sh`
- **Activation**: `gitmonkey ask "how do I undo my last commit?"`
- **Workflow**:
  1. Capture current Git context for relevance
  2. Generate personalized response based on tone stage
  3. Format response with command highlighting
  4. Offer to explain or execute suggested commands

## 📅 Implementation Phases

### Phase 1: Core Infrastructure (1-2 weeks)
- [ ] Implement `utils/ai_keys.sh` for secure key management
- [ ] Create AI provider integration in `utils/ai_request.sh`
- [ ] Add AI setup during onboarding in `welcome.sh`
- [ ] Build the AI settings menu in `settings_ai.sh`

### Phase 2: First Features (1-2 weeks)
- [ ] Implement AI-powered commit messages in `commit.sh`
- [ ] Add branch name suggestions in `branch.sh`
- [ ] Create comprehensive tests for the integration

### Phase 3: Advanced Features (2-3 weeks)
- [ ] Build merge risk analysis in `merge.sh`
- [ ] Implement interactive Git help with `ask.sh`
- [ ] Enhance all features with theme awareness

### Phase 4: Expansion & Refinement (ongoing)
- [ ] Add support for more AI providers
- [ ] Implement caching for performance and cost efficiency
- [ ] Create a system for tracking AI usage

## 🔒 Security & Privacy

### API Key Security

- Store keys in `~/.gitmonkey/api_keys` with 600 permissions
- Never log or display API keys in output
- Provide clear instructions for key rotation
- Implement a command for securely updating keys

### Data Privacy

- Only send necessary code context to AI services
- Avoid sending entire files or repositories
- Include clear documentation of data handling
- Give users control over what information is shared

### Error Handling

- Gracefully degrade when AI services are unavailable
- Provide meaningful error messages without exposing sensitive information
- Always have non-AI fallbacks for critical features

### Usage Control

- Implement usage tracking to prevent accidental excessive API usage
- Allow users to set monthly limits
- Provide clear warnings when approaching limits
- Support disabling specific features to manage costs

## 🗂️ Directory Structure

```
commands/
├── welcome.sh           # Onboarding with AI options 
├── commit.sh            # AI-enhanced commits
├── branch.sh            # AI branch naming suggestions
├── merge.sh             # AI merge risk analysis
├── ask.sh               # New: AI-powered Git help
├── settings_ai.sh       # New: AI settings management
utils/
├── ai_keys.sh           # API key management 
├── ai_request.sh        # Central AI request handler
```

## 🔌 API Reference

### Provider Sign-Up URLs

- OpenAI: https://platform.openai.com/api-keys
- Claude: https://console.anthropic.com/settings/keys
- Gemini: https://makersuite.google.com/app/apikey
- DeepSeek: https://platform.deepseek.com/api_keys

### Request Format Examples

**OpenAI (GPT-4)**:
```json
{
  "model": "gpt-4o",
  "messages": [
    {"role": "system", "content": "You are a helpful Git assistant."},
    {"role": "user", "content": "Here's my diff: ..."}
  ],
  "temperature": 0.3,
  "max_tokens": 500
}
```

**Claude**:
```json
{
  "model": "claude-3-haiku-20240307",
  "max_tokens": 500,
  "messages": [
    {"role": "user", "content": "Here's my diff: ..."}
  ]
}
```

**Gemini**:
```json
{
  "contents": [
    {"parts": [{"text": "Here's my diff: ..."}]}
  ],
  "generationConfig": {
    "temperature": 0.3,
    "maxOutputTokens": 500
  }
}
```

---

This plan will be continuously updated as the implementation progresses. For questions or suggestions about the AI integration, please create an issue or contact the Git Monkey development team.