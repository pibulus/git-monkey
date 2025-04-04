# Git Monkey Implementation Consistency Guide

This document serves as a reference for maintaining consistency across Git Monkey enhancements, particularly focusing on Svelte integration and modern web development features.

## Core Design Principles

### 1. Tone Stage System

Git Monkey uses a 0-5 tone stage system to adapt content based on user experience level:

- **Stage 0-1**: Complete beginners
  - Provide detailed explanations with friendly language
  - Use analogies and metaphors to explain concepts
  - Include step-by-step guidance with examples
  - Address the user by identity (e.g., "Hey $IDENTITY!")

- **Stage 2-3**: Intermediate users
  - Provide moderate detail with some technical terminology
  - Focus on efficiency with fewer examples
  - Use more direct language while maintaining friendliness
  - Less personalization, more task-focused

- **Stage 4-5**: Advanced users
  - Provide minimal, technical explanations
  - Focus purely on the task with minimal guidance
  - Use technical terminology with no simplification
  - No personalization, just facts and commands

**Implementation Pattern:**
```bash
if [ "$TONE_STAGE" -le 2 ]; then
  echo "Hey $IDENTITY! Here's a friendly explanation of what we're doing..."
  # Detailed explanation
elif [ "$TONE_STAGE" -le 3 ]; then
  echo "Setting up X with Y configuration..."
  # Moderate explanation
else
  echo "Configuring X."
  # Minimal explanation
fi
```

### 2. Theme System

Git Monkey supports multiple themes to personalize the user experience:

- **Jungle**: Playful, nature-themed with monkey and banana emojis
- **Hacker**: Technical, matrix-style with code references
- **Wizard**: Magical, mystical with spell-casting metaphors
- **Cosmic**: Space-themed with celestial metaphors

**Implementation Pattern:**
```bash
# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"  # Can be "info", "success", "error", etc.
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        # etc.
      esac
      ;;
    # Other themes...
  esac
}

# Then use it
info_emoji=$(get_theme_emoji "info")
echo "$info_emoji Some information..."
```

### 3. Performance Tracking

Git Monkey tracks performance to demonstrate terminal efficiency:

- Measure operation timing for key actions
- Compare with estimated GUI equivalent times
- Show time saved occasionally to reinforce the terminal's speed
- Use visual indicators for long-running operations

**Implementation Pattern:**
```bash
# Start timing
local start_time=$(start_timing)

# Perform operations...

# End timing and record metrics
local duration=$(end_timing "$start_time")
record_operation_time "operation_name" "$duration"

# Show efficiency (occasionally)
if (( RANDOM % 3 == 0 )); then
  echo "⚡ Terminal efficiency: Completed in $(printf "%.2f" "$duration") seconds!"
  echo "   A comparable GUI operation would take several minutes."
fi
```

### 4. Visual Engagement

Git Monkey uses visual elements to enhance the terminal experience:

- ASCII art for complex concepts
- Boxes and banners for important information
- Progress indicators for long-running tasks
- Typewriter effect for important explanations

**Implementation Pattern:**
```bash
# For important setup steps
typewriter "🚀 Setting up advanced features..." 0.02

# For completion
rainbow_box "✅ Setup completed successfully!"

# For complex concepts (ASCII art)
echo "┌────────────────┐  ┌────────────────┐"
echo "│  Component A   │──│  Component B   │"
echo "└────────────────┘  └────────────────┘"
```

### 5. Progressive Disclosure

Git Monkey reveals features and options progressively:

- Show basic options first, then offer advanced capabilities
- Suggest next steps after completing an operation
- Provide context-aware help based on user actions
- Use a step-by-step approach for complex flows

**Implementation Pattern:**
```bash
# Basic setup first
set_up_basic_feature

# Then offer advanced options
echo "Would you like to configure advanced options? (y/n)"
read response
if [[ "$response" =~ ^[Yy]$ ]]; then
  set_up_advanced_features
fi

# Suggest next steps
echo "🔍 Next steps:"
echo "  • Run X to see your changes"
echo "  • Configure Y for additional features"
```

## Specific Component Guidelines

### 1. SvelteKit Implementation

When implementing SvelteKit features:

- **Project Structure**: 
  - Follow SvelteKit conventions (`routes`, `lib`, etc.)
  - Use `+page.svelte` and `+page.server.ts` pattern
  - Separate UI components in `lib/components`

- **TypeScript Integration**:
  - Use proper typing for all functions
  - Leverage SvelteKit's built-in types
  - Create type-safe interfaces between client and server

- **Server Actions**:
  - Implement with progressive enhancement
  - Include validation with appropriate error handling
  - Support both JavaScript and non-JavaScript environments

### 2. Component Libraries

When implementing component library integrations:

- Create minimal, working examples for each component
- Focus on composition patterns rather than individual components
- Include theme integration if the library supports it
- Provide clear documentation on component usage

### 3. Backend Connections

For backend integrations:

- Support both local development and production deployment
- Include environment variable setup
- Create type-safe interfaces between frontend and backend
- Implement proper error handling and loading states

### 4. CRUD Operations

When implementing CRUD patterns:

- Create a complete working example
- Follow RESTful conventions
- Include validation on both client and server
- Demonstrate optimistic UI updates for better UX

## Implementation Checklist

For each new feature, ensure:

- [ ] Tone-aware explanations for all user levels
- [ ] Theme integration with appropriate styling
- [ ] Performance tracking with efficiency metrics
- [ ] Visual feedback with ASCII diagrams where helpful
- [ ] Progressive disclosure of complex options
- [ ] Educational content or links to learn module
- [ ] Error handling with friendly messages
- [ ] Complete working examples
- [ ] Clear next steps after completion

## Troubleshooting Common Issues

When issues arise:

1. **Tone Stage Mismatch**: 
   - Check if `TONE_STAGE` is being properly sourced
   - Verify conditionals cover all tone stages (0-5)

2. **Theme System Problems**:
   - Ensure `THEME` variable is available
   - Check theme-specific functions are defined

3. **Performance Tracking Errors**:
   - Verify `utils/performance.sh` is sourced
   - Check function calls for proper parameter order

4. **Visual Elements Not Displaying**:
   - Ensure `utils/style.sh` is sourced
   - Check terminal capability for advanced styling

## Testing New Features

Before submitting:

1. Test with all tone stages (0-5)
2. Test with all themes
3. Test with various input combinations
4. Verify performance tracking works
5. Ensure error handling works properly
6. Check integration with existing functionality