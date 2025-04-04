# Git Monkey Welcome & Onboarding

The Git Monkey welcome and onboarding experience is designed to create a delightful first impression and gently guide new users into the tool's capabilities.

## Key Features

### 1. Personalized Experience
- Asks for user's name to personalize all future interactions
- Stores preferences in `~/.gitmonkey/` configuration directory
- Uses the name throughout the tour with friendly, conversational language

### 2. Theme Selection
- Introduces Git Monkey's theme system during onboarding
- Offers visual previews of each theme (Jungle, Hacker, Wizard, Cosmic)
- Demonstrates theme-specific visuals immediately after selection

### 3. Guided Tour
- Provides a concise overview of Git Monkey's 5 core capabilities
- Tailors explanations to beginner level
- Uses visual animations and ASCII art to maintain engagement

### 4. First Command Guidance
- Suggests an appropriate first command based on selected theme
- Provides clear instructions on how to continue exploring
- Sets expectations for what comes next

## Technical Implementation

The welcome system:

1. **Detects First-Time Use**
   - Checks for `~/.gitmonkey/welcomed` marker file
   - Automatically launches welcome flow for new users

2. **Manages Animation Flow**
   - Uses staged typing animations with natural-feeling variable speeds
   - Includes dramatic pauses for better information absorption
   - Provides a `--skip-intro` flag for users who want to bypass animations

3. **Creates Configuration**
   - Stores identity in `~/.gitmonkey/identity`
   - Saves theme preference in `~/.gitmonkey/theme`
   - Can be reset with `gitmonkey welcome --reset`

4. **Integrates with Main CLI**
   - Adds welcome command to main command list
   - Intelligently handles the transition from welcome to selected command

## Tone-Awareness

The welcome experience introduces users to Git Monkey's tone system:

- All new users start at tone stage 0 (complete beginner)
- Welcome text uses simple language with clear explanations
- Personalization creates an immediate connection
- Visual elements make abstract concepts concrete

## Design Principles

The onboarding experience follows these principles:

1. **Delight First**: Create an emotional connection before explaining features
2. **Progressive Disclosure**: Start with basics, hint at advanced features
3. **Personalization**: Use the user's name throughout to build connection
4. **Visual Learning**: Show rather than just tell when introducing concepts
5. **Quick Wins**: Guide users to immediate success with their first command

## User Experience Flow

1. **Introduction**: Animated ASCII art introduction with theme-specific styling
2. **Identity**: Ask for user's name and store for future sessions
3. **Theme Selection**: Interactive theme selection with visual previews
4. **Quick Tour**: Concise overview of key features with visual examples
5. **First Command**: Guidance for first command with clear next steps