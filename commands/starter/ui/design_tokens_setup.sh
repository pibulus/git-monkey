#!/bin/bash

# ========= DESIGN TOKENS SETUP MODULE =========
# Sets up a design tokens system for customizable UI themes
# Works with multiple UI libraries (Skeleton, Bits UI, etc.)

source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/performance.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/style.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/profile.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/identity.sh"

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"  # Can be "info", "success", "error", "warning"
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        "design") echo "🎨" ;;
        "color") echo "🌈" ;;
        "token") echo "🏷️" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "design") echo "[DESIGN]" ;;
        "color") echo "[COLOR]" ;;
        "token") echo "[TOKEN]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "design") echo "🔮" ;;
        "color") echo "✨" ;;
        "token") echo "🧪" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "design") echo "🌈" ;;
        "color") echo "🎨" ;;
        "token") echo "🪐" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "ℹ️" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "design") echo "🎨" ;;
        "color") echo "🌈" ;;
        "token") echo "🏷️" ;;
        *) echo "ℹ️" ;;
      esac
      ;;
  esac
}

setup_design_tokens() {
  local project_path="$1"
  local framework_type="$2"  # should be svelte or svelte-modern
  
  # Start timing for performance metrics
  local start_time=$(start_timing)
  
  # Get current tone stage and identity for context-aware help
  TONE_STAGE=$(get_tone_stage)
  THEME=$(get_selected_theme)
  IDENTITY=$(get_full_identity)
  
  # Get theme-specific emojis
  info_emoji=$(get_theme_emoji "info")
  success_emoji=$(get_theme_emoji "success")
  error_emoji=$(get_theme_emoji "error")
  warning_emoji=$(get_theme_emoji "warning")
  design_emoji=$(get_theme_emoji "design")
  color_emoji=$(get_theme_emoji "color")
  token_emoji=$(get_theme_emoji "token")
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "$error_emoji npm is required to set up Design Tokens." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # This module only works with SvelteKit
  if [[ "$framework_type" != "svelte" && "$framework_type" != "svelte-modern" ]]; then
    typewriter "$error_emoji Design Tokens system is designed specifically for SvelteKit projects." 0.02
    typewriter "Please choose a different feature for $framework_type projects." 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Tone-aware AND theme-aware introduction based on user's experience level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners - very friendly, detailed explanation
    case "$THEME" in
      "jungle")
        typewriter "$design_emoji Hey $IDENTITY! Let's add some colorful magic to your jungle project!" 0.02
        echo ""
        typewriter "Design Tokens are like a special color palette for your jungle treehouse." 0.02
        typewriter "We're setting up a system that will let you:" 0.02
        echo "  • $color_emoji Change all your jungle colors in one place"
        echo "  • $token_emoji Create beautiful themes for your visitors"
        echo "  • 🌓 Support dark mode and light mode for day and night"
        echo "  • 🐒 Make your UI consistent throughout your jungle"
        ;;
      "hacker")
        typewriter "$design_emoji INITIALIZING DESIGN TOKEN SYSTEM FOR USER: $IDENTITY" 0.02
        echo ""
        typewriter "DESIGN TOKENS: CENTRALIZED VISUAL CONFIGURATION PROTOCOL" 0.02
        typewriter "INSTALLING SYSTEM MODULES:" 0.02
        echo "  • $color_emoji COLOR VARIABLES: HSL-BASED COLOR MATRICES"
        echo "  • $token_emoji TOKEN MANAGEMENT: CENTRALIZED DESIGN VARIABLE SYSTEM"
        echo "  • [THEME] LIGHT/DARK MODE: DUAL ENVIRONMENT CONFIGURATION"
        echo "  • [UI] CONSISTENT COMPONENT VISUALIZATION PARAMETERS"
        ;;
      "wizard")
        typewriter "$design_emoji Greetings, $IDENTITY! Let us enchant your project with magical design tokens!" 0.02
        echo ""
        typewriter "Design Tokens are like magical incantations that control your interface appearance." 0.02
        typewriter "We're conjuring these mystical powers for you:" 0.02
        echo "  • $color_emoji Color spells to change your entire interface at once"
        echo "  • $token_emoji Magical tokens to create consistent visual enchantments"
        echo "  • 🌓 Light and dark realm switching capabilities"
        echo "  • ✨ Visual consistency across all your magical interfaces"
        ;;
      "cosmic")
        typewriter "$design_emoji Greetings, $IDENTITY! Initializing design token system for your space station!" 0.02
        echo ""
        typewriter "Design Tokens are like the central control panel for your interface's appearance." 0.02
        typewriter "We're installing these advanced systems into your spaceship:" 0.02
        echo "  • $color_emoji Color spectrum controls for visual customization"
        echo "  • $token_emoji Token management system for consistent interface design"
        echo "  • 🌓 Light/dark space mode for different environments"
        echo "  • 🛸 Visual consistency across all your control panels"
        ;;
      *)
        typewriter "$design_emoji Hey $IDENTITY! Let's add design tokens to your project!" 0.02
        echo ""
        typewriter "Design tokens are variables that store your design decisions in one place." 0.02
        typewriter "We're setting up a system that will let you:" 0.02
        echo "  • $color_emoji Define colors, spacing, and typography in one place"
        echo "  • $token_emoji Create consistent themes across your entire app"
        echo "  • 🌓 Support dark mode and light mode easily"
        echo "  • 🎨 Change your entire look and feel by updating one file"
        ;;
    esac
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users - moderate explanation, somewhat technical
    case "$THEME" in
      "jungle")
        typewriter "$design_emoji Setting up design tokens system for your jungle project" 0.02
        echo ""
        echo "Creating a centralized design system with:"
        echo "• $color_emoji CSS custom properties for colors, sizing, and spacing"
        echo "• $token_emoji Theme management with light and dark modes"
        echo "• CSS variable organization for consistent styling"
        echo "• Component-agnostic design patterns"
        ;;
      "hacker")
        typewriter "$design_emoji INITIALIZING DESIGN TOKEN MANAGEMENT SYSTEM" 0.02
        echo ""
        echo "INSTALLING MODULES:"
        echo "• $color_emoji CSS CUSTOM PROPERTY FRAMEWORK"
        echo "• $token_emoji THEME MANAGEMENT WITH DUAL MODES"
        echo "• CENTRALIZED DESIGN VARIABLE SYSTEM"
        echo "• COMPONENT-AGNOSTIC INTERFACE PROTOCOLS"
        ;;
      "wizard")
        typewriter "$design_emoji Preparing design token spellbook for your magical interface" 0.02
        echo ""
        echo "Adding these arcane elements to your grimoire:"
        echo "• $color_emoji CSS variable enchantments for colors and spacing"
        echo "• $token_emoji Theme management spells with light and dark modes"
        echo "• Centralized design variable magic"
        echo "• Component-agnostic enchantment patterns"
        ;;
      "cosmic")
        typewriter "$design_emoji Installing design token system to your space station" 0.02
        echo ""
        echo "Adding advanced interface controls:"
        echo "• $color_emoji CSS custom properties for visual configuration"
        echo "• $token_emoji Theme management with light/dark modes"
        echo "• Centralized design variable system"
        echo "• Component-agnostic design patterns"
        ;;
      *)
        typewriter "$design_emoji Setting up design tokens system for your project" 0.02
        echo ""
        echo "Installing a centralized design system with:"
        echo "• CSS custom properties for colors, spacing, and typography"
        echo "• Theme management with light and dark modes"
        echo "• Centralized design variable architecture"
        echo "• Component-agnostic patterns for UI consistency"
        ;;
    esac
    echo ""
  else
    # Advanced users - minimal, technical explanation
    case "$THEME" in
      "jungle")
        echo "$design_emoji Installing design tokens system with theme support."
        ;;
      "hacker")
        echo "$design_emoji DESIGN TOKENS SETUP: CSS VARIABLES + THEME MANAGEMENT"
        ;;
      "wizard")
        echo "$design_emoji Conjuring design tokens system with theme capabilities."
        ;;
      "cosmic")
        echo "$design_emoji Deploying design tokens system with theme management."
        ;;
      *)
        echo "$design_emoji Installing design tokens system with theme support."
        ;;
    esac
    echo ""
  fi
  
  # Show ASCII diagram for design tokens if tone stage is low
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Design Tokens System Architecture:"
    echo ""
    echo "┌──────────────────────────────────────────────────────────┐"
    echo "│                  DESIGN TOKENS SYSTEM                     │"
    echo "│                                                          │"
    echo "│  ┌───────────────────────────────────────────────────┐   │"
    echo "│  │                design-tokens.css                   │   │"
    echo "│  │                                                    │   │"
    echo "│  │  :root {                    .dark {                │   │"
    echo "│  │    --color-primary: #...      --color-primary: #...│   │"
    echo "│  │    --color-text: #...         --color-text: #...   │   │"
    echo "│  │    --spacing-1: 0.25rem       --color-bg: #...     │   │"
    echo "│  │    --radius-sm: 0.125rem    }                      │   │"
    echo "│  │  }                                                 │   │"
    echo "│  └───────────────────────────────────────────────────┘   │"
    echo "│                           │                               │"
    echo "│               ┌───────────┼───────────┐                   │"
    echo "│               │           │           │                   │"
    echo "│  ┌────────────▼────┐ ┌────▼─────┐ ┌───▼──────────┐        │"
    echo "│  │  theme-store.ts │ │ colors.ts│ │ theme-switch │        │"
    echo "│  └─────────────────┘ └──────────┘ └──────────────┘        │"
    echo "│               │                       │                   │"
    echo "│               └───────────┬───────────┘                   │"
    echo "│                           │                               │"
    echo "│  ┌───────────────────────▼───────────────────────────┐   │"
    echo "│  │                   COMPONENTS                       │   │"
    echo "│  │                                                    │   │"
    echo "│  │  Button   Card   Form   Input   Modal   ...        │   │"
    echo "│  │                                                    │   │"
    echo "│  └────────────────────────────────────────────────────┘  │"
    echo "│                                                          │"
    echo "└──────────────────────────────────────────────────────────┘"
    echo ""
  fi
  
  # Create lib directories for design tokens
  mkdir -p src/lib/styles
  mkdir -p src/lib/components/theme
  mkdir -p src/lib/stores
  
  # Create the design tokens CSS file
  typewriter "$token_emoji Creating design tokens style file..." 0.02
  
  cat > src/lib/styles/design-tokens.css << 'EOF'
/* ==========================================================================
   DESIGN TOKENS
   Central repository for all design variables across the application.
   Using HSL color format for better readability and adjustability.
   ========================================================================== */

/* Light Theme (Default) */
:root {
  /* Base colors */
  --color-white-hsl: 0, 0%, 100%;
  --color-black-hsl: 0, 0%, 0%;
  
  /* Primary colors */
  --color-primary-50-hsl: 217, 100%, 97%;
  --color-primary-100-hsl: 217, 100%, 95%;
  --color-primary-200-hsl: 217, 100%, 90%;
  --color-primary-300-hsl: 217, 100%, 80%;
  --color-primary-400-hsl: 217, 100%, 70%;
  --color-primary-500-hsl: 217, 91%, 60%;
  --color-primary-600-hsl: 217, 91%, 50%;
  --color-primary-700-hsl: 217, 91%, 40%;
  --color-primary-800-hsl: 217, 91%, 30%;
  --color-primary-900-hsl: 217, 91%, 20%;
  --color-primary-950-hsl: 217, 91%, 10%;
  
  /* Neutral colors */
  --color-neutral-50-hsl: 210, 20%, 98%;
  --color-neutral-100-hsl: 210, 20%, 96%;
  --color-neutral-200-hsl: 210, 16%, 93%;
  --color-neutral-300-hsl: 210, 16%, 85%;
  --color-neutral-400-hsl: 210, 12%, 65%;
  --color-neutral-500-hsl: 210, 8%, 45%;
  --color-neutral-600-hsl: 210, 12%, 35%;
  --color-neutral-700-hsl: 210, 16%, 25%;
  --color-neutral-800-hsl: 210, 20%, 15%;
  --color-neutral-900-hsl: 210, 24%, 10%;
  --color-neutral-950-hsl: 210, 24%, 5%;
  
  /* Success colors */
  --color-success-50-hsl: 142, 76%, 97%;
  --color-success-100-hsl: 142, 76%, 95%;
  --color-success-200-hsl: 142, 76%, 90%;
  --color-success-300-hsl: 142, 76%, 80%;
  --color-success-400-hsl: 142, 76%, 60%;
  --color-success-500-hsl: 142, 76%, 48%;
  --color-success-600-hsl: 142, 76%, 38%;
  --color-success-700-hsl: 142, 76%, 30%;
  --color-success-800-hsl: 142, 76%, 22%;
  --color-success-900-hsl: 142, 76%, 15%;
  --color-success-950-hsl: 142, 76%, 8%;
  
  /* Warning colors */
  --color-warning-50-hsl: 45, 100%, 96%;
  --color-warning-100-hsl: 45, 100%, 92%;
  --color-warning-200-hsl: 45, 100%, 85%;
  --color-warning-300-hsl: 45, 100%, 75%;
  --color-warning-400-hsl: 45, 100%, 65%;
  --color-warning-500-hsl: 45, 93%, 47%;
  --color-warning-600-hsl: 35, 93%, 42%;
  --color-warning-700-hsl: 30, 93%, 37%;
  --color-warning-800-hsl: 25, 93%, 32%;
  --color-warning-900-hsl: 20, 93%, 25%;
  --color-warning-950-hsl: 15, 93%, 15%;
  
  /* Error colors */
  --color-error-50-hsl: 0, 100%, 97%;
  --color-error-100-hsl: 0, 100%, 95%;
  --color-error-200-hsl: 0, 100%, 90%;
  --color-error-300-hsl: 0, 100%, 80%;
  --color-error-400-hsl: 0, 95%, 70%;
  --color-error-500-hsl: 0, 90%, 60%;
  --color-error-600-hsl: 0, 90%, 50%;
  --color-error-700-hsl: 0, 90%, 40%;
  --color-error-800-hsl: 0, 90%, 30%;
  --color-error-900-hsl: 0, 90%, 25%;
  --color-error-950-hsl: 0, 90%, 15%;
  
  /* Semantic color assignments */
  --color-background-hsl: var(--color-white-hsl);
  --color-foreground-hsl: var(--color-neutral-900-hsl);
  --color-muted-hsl: var(--color-neutral-200-hsl);
  --color-muted-foreground-hsl: var(--color-neutral-700-hsl);
  --color-card-hsl: var(--color-white-hsl);
  --color-card-foreground-hsl: var(--color-neutral-900-hsl);
  --color-border-hsl: var(--color-neutral-200-hsl);
  --color-input-hsl: var(--color-neutral-100-hsl);
  --color-ring-hsl: var(--color-primary-500-hsl);
  
  /* Component-specific colors */
  --color-primary-button-hsl: var(--color-primary-600-hsl);
  --color-primary-button-foreground-hsl: var(--color-white-hsl);
  --color-secondary-button-hsl: var(--color-neutral-200-hsl);
  --color-secondary-button-foreground-hsl: var(--color-neutral-900-hsl);
  
  /* Typography */
  --font-sans: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
  --font-serif: ui-serif, Georgia, Cambria, "Times New Roman", Times, serif;
  --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  
  --font-weight-light: 300;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
  
  --line-height-none: 1;
  --line-height-tight: 1.25;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;
  
  /* Spacing */
  --spacing-px: 1px;
  --spacing-0: 0;
  --spacing-0-5: 0.125rem;
  --spacing-1: 0.25rem;
  --spacing-1-5: 0.375rem;
  --spacing-2: 0.5rem;
  --spacing-3: 0.75rem;
  --spacing-4: 1rem;
  --spacing-5: 1.25rem;
  --spacing-6: 1.5rem;
  --spacing-8: 2rem;
  --spacing-10: 2.5rem;
  --spacing-12: 3rem;
  --spacing-16: 4rem;
  --spacing-20: 5rem;
  --spacing-24: 6rem;
  --spacing-32: 8rem;
  
  /* Borders */
  --border-radius-none: 0;
  --border-radius-sm: 0.125rem;
  --border-radius-md: 0.25rem;
  --border-radius-lg: 0.5rem;
  --border-radius-xl: 0.75rem;
  --border-radius-2xl: 1rem;
  --border-radius-3xl: 1.5rem;
  --border-radius-full: 9999px;
  
  --border-width-0: 0px;
  --border-width-1: 1px;
  --border-width-2: 2px;
  --border-width-4: 4px;
  --border-width-8: 8px;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  --shadow-inner: inset 0 2px 4px 0 rgb(0 0 0 / 0.05);
  --shadow-none: 0 0 #0000;
  
  /* Transitions */
  --transition-all: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-colors: background-color 0.15s cubic-bezier(0.4, 0, 0.2, 1), border-color 0.15s cubic-bezier(0.4, 0, 0.2, 1), color 0.15s cubic-bezier(0.4, 0, 0.2, 1), fill 0.15s cubic-bezier(0.4, 0, 0.2, 1), stroke 0.15s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-opacity: opacity 0.15s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-shadow: box-shadow 0.15s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-transform: transform 0.15s cubic-bezier(0.4, 0, 0.2, 1);
  
  /* Focus ring */
  --focus-ring: 0 0 0 2px hsl(var(--color-ring-hsl));
  
  /* z-index */
  --z-index-0: 0;
  --z-index-10: 10;
  --z-index-20: 20;
  --z-index-30: 30;
  --z-index-40: 40;
  --z-index-50: 50;
  --z-index-100: 100;
  --z-index-auto: auto;
}

/* Dark Theme */
.dark {
  --color-background-hsl: var(--color-neutral-900-hsl);
  --color-foreground-hsl: var(--color-neutral-100-hsl);
  --color-muted-hsl: var(--color-neutral-800-hsl);
  --color-muted-foreground-hsl: var(--color-neutral-400-hsl);
  --color-card-hsl: var(--color-neutral-800-hsl);
  --color-card-foreground-hsl: var(--color-neutral-100-hsl);
  --color-border-hsl: var(--color-neutral-700-hsl);
  --color-input-hsl: var(--color-neutral-700-hsl);
  
  /* Component-specific colors */
  --color-primary-button-hsl: var(--color-primary-500-hsl);
  --color-primary-button-foreground-hsl: var(--color-white-hsl);
  --color-secondary-button-hsl: var(--color-neutral-700-hsl);
  --color-secondary-button-foreground-hsl: var(--color-neutral-100-hsl);
}

/* CSS helpers for easier HSL usage */
:root {
  --color-white: hsl(var(--color-white-hsl));
  --color-black: hsl(var(--color-black-hsl));
  
  /* Primary colors - converted from HSL to regular CSS var */
  --color-primary-50: hsl(var(--color-primary-50-hsl));
  --color-primary-100: hsl(var(--color-primary-100-hsl));
  --color-primary-200: hsl(var(--color-primary-200-hsl));
  --color-primary-300: hsl(var(--color-primary-300-hsl));
  --color-primary-400: hsl(var(--color-primary-400-hsl));
  --color-primary-500: hsl(var(--color-primary-500-hsl));
  --color-primary-600: hsl(var(--color-primary-600-hsl));
  --color-primary-700: hsl(var(--color-primary-700-hsl));
  --color-primary-800: hsl(var(--color-primary-800-hsl));
  --color-primary-900: hsl(var(--color-primary-900-hsl));
  --color-primary-950: hsl(var(--color-primary-950-hsl));
  
  /* Semantic colors */
  --color-background: hsl(var(--color-background-hsl));
  --color-foreground: hsl(var(--color-foreground-hsl));
  --color-muted: hsl(var(--color-muted-hsl));
  --color-muted-foreground: hsl(var(--color-muted-foreground-hsl));
  --color-card: hsl(var(--color-card-hsl));
  --color-card-foreground: hsl(var(--color-card-foreground-hsl));
  --color-border: hsl(var(--color-border-hsl));
  --color-input: hsl(var(--color-input-hsl));
  
  /* Component colors */
  --color-primary-button: hsl(var(--color-primary-button-hsl));
  --color-primary-button-foreground: hsl(var(--color-primary-button-foreground-hsl));
  --color-secondary-button: hsl(var(--color-secondary-button-hsl));
  --color-secondary-button-foreground: hsl(var(--color-secondary-button-foreground-hsl));
}
EOF
  
  # Create a color utility file to generate variations
  cat > src/lib/styles/color-utils.ts << 'EOF'
/**
 * Convert a hex color to HSL string format for CSS variables
 * @param hex The hex color code (e.g., "#3b82f6")
 * @returns HSL string in format "222, 47%, 11%"
 */
export function hexToHSL(hex: string): string {
  // Remove the # if present
  hex = hex.replace(/^#/, '');
  
  // Parse the hex values
  let r = parseInt(hex.substring(0, 2), 16) / 255;
  let g = parseInt(hex.substring(2, 4), 16) / 255;
  let b = parseInt(hex.substring(4, 6), 16) / 255;
  
  // Find the min and max values to compute the lightness
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h = 0;
  let s = 0;
  let l = (max + min) / 2;
  
  // Only calculate saturation and hue if not grayscale
  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    
    switch (max) {
      case r:
        h = ((g - b) / d + (g < b ? 6 : 0)) * 60;
        break;
      case g:
        h = ((b - r) / d + 2) * 60;
        break;
      case b:
        h = ((r - g) / d + 4) * 60;
        break;
    }
  }
  
  // Round to nearest integers
  h = Math.round(h);
  s = Math.round(s * 100);
  l = Math.round(l * 100);
  
  return `${h}, ${s}%, ${l}%`;
}

/**
 * Generate a set of color shades from a base color
 * @param baseHex The base hex color
 * @returns An object with color shades from 50-950
 */
export function generateColorPalette(baseHex: string): Record<string, string> {
  // Parse the base color
  let baseHSL = hexToHSL(baseHex);
  const [h, s, l] = baseHSL.split(',').map(part => 
    parseFloat(part.replace('%', '').trim())
  );
  
  // Define the lightness values for each shade
  const lightnessMap = {
    '50': 97,
    '100': 94,
    '200': 88,
    '300': 80,
    '400': 65,
    '500': 50,  // Base
    '600': 40,
    '700': 32,
    '800': 25,
    '900': 18,
    '950': 10
  };
  
  // Generate the palette
  const palette: Record<string, string> = {};
  
  Object.entries(lightnessMap).forEach(([shade, lightness]) => {
    // Adjust saturation for extreme light/dark values
    let adjustedS = s;
    if (lightness > 90) adjustedS = Math.max(s * 0.8, 5);
    if (lightness < 20) adjustedS = Math.min(s * 1.2, 100);
    
    palette[shade] = `${h}, ${Math.round(adjustedS)}%, ${lightness}%`;
  });
  
  return palette;
}

/**
 * Create CSS custom properties for a color palette
 * @param name The color name (e.g., "primary")
 * @param palette The color palette object
 * @returns CSS strings for the color variables
 */
export function createCSSColorVariables(name: string, palette: Record<string, string>): string {
  let css = '';
  
  Object.entries(palette).forEach(([shade, value]) => {
    css += `  --color-${name}-${shade}-hsl: ${value};\n`;
  });
  
  return css;
}
EOF
  
  # Create the theme store
  typewriter "$color_emoji Creating theme management store..." 0.02
  
  cat > src/lib/stores/theme.ts << 'EOF'
import { writable } from 'svelte/store';
import { browser } from '$app/environment';

// Define theme types
export type ColorTheme = 'default' | 'blue' | 'purple' | 'green' | 'amber' | 'red' | 'pink';
export type ModeTheme = 'light' | 'dark' | 'system';

interface ThemeState {
  colorTheme: ColorTheme;
  modeTheme: ModeTheme;
}

// Get system color scheme preference
const getSystemPreference = (): 'light' | 'dark' => {
  if (!browser) return 'light';
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
};

// Load theme from localStorage or use default
const loadTheme = (): ThemeState => {
  if (!browser) return { colorTheme: 'default', modeTheme: 'system' };
  
  try {
    const saved = localStorage.getItem('theme-preferences');
    if (saved) {
      return JSON.parse(saved);
    }
  } catch (e) {
    console.error('Failed to load theme preferences:', e);
  }
  
  return { colorTheme: 'default', modeTheme: 'system' };
};

// Create theme store
export const theme = writable<ThemeState>(loadTheme());

// Apply theme to document
export function applyTheme(preferences: ThemeState): void {
  if (!browser) return;
  
  // Save to localStorage
  localStorage.setItem('theme-preferences', JSON.stringify(preferences));
  
  // Apply color theme
  document.documentElement.setAttribute('data-theme', preferences.colorTheme);
  
  // Apply mode theme
  const isDark = preferences.modeTheme === 'dark' || 
    (preferences.modeTheme === 'system' && getSystemPreference() === 'dark');
  
  if (isDark) {
    document.documentElement.classList.add('dark');
  } else {
    document.documentElement.classList.remove('dark');
  }
}

// Update theme function
export function updateTheme(updates: Partial<ThemeState>): void {
  theme.update(current => {
    const newTheme = { ...current, ...updates };
    applyTheme(newTheme);
    return newTheme;
  });
}

// Initialize theme
export function initializeTheme(): void {
  if (!browser) return;
  
  let currentTheme: ThemeState;
  const unsubscribe = theme.subscribe(value => {
    currentTheme = value;
  });
  
  applyTheme(currentTheme);
  unsubscribe();
  
  // Listen for system preference changes
  const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
  mediaQuery.addEventListener('change', () => {
    theme.update(current => {
      if (current.modeTheme === 'system') {
        applyTheme(current);
      }
      return current;
    });
  });
}

// Predefined color themes
export const colorThemes = {
  default: { name: 'Default', primary: '#3b82f6', secondary: '#6366f1' },
  blue: { name: 'Blue', primary: '#0ea5e9', secondary: '#2563eb' },
  purple: { name: 'Purple', primary: '#8b5cf6', secondary: '#6366f1' },
  green: { name: 'Green', primary: '#10b981', secondary: '#059669' },
  amber: { name: 'Amber', primary: '#f59e0b', secondary: '#d97706' },
  red: { name: 'Red', primary: '#ef4444', secondary: '#dc2626' },
  pink: { name: 'Pink', primary: '#ec4899', secondary: '#db2777' },
};
EOF
  
  # Create theme switcher component
  typewriter "$design_emoji Creating theme switcher component..." 0.02
  
  # Create the component folder
  mkdir -p src/lib/components/theme-switcher
  
  cat > src/lib/components/theme-switcher/ThemeSwitcher.svelte << 'EOF'
<script lang="ts">
  import { onMount } from 'svelte';
  import { theme, updateTheme, initializeTheme, colorThemes, type ColorTheme, type ModeTheme } from '$lib/stores/theme';
  
  // Initialize theme on mount
  onMount(() => {
    initializeTheme();
  });
  
  // Toggle between modes
  function toggleMode() {
    updateTheme({
      modeTheme: $theme.modeTheme === 'light' 
        ? 'dark' 
        : $theme.modeTheme === 'dark' 
        ? 'system' 
        : 'light'
    });
  }
  
  // Set color theme
  function setColorTheme(color: ColorTheme) {
    updateTheme({ colorTheme: color });
    isOpen = false;
  }
  
  // Popup state
  let isOpen = false;
  
  // Current mode icon
  $: modeIcon = $theme.modeTheme === 'light' 
    ? 'fa-sun' 
    : $theme.modeTheme === 'dark' 
    ? 'fa-moon' 
    : 'fa-circle-half-stroke';
</script>

<div class="theme-switcher relative z-50">
  <div class="flex items-center space-x-2">
    <!-- Mode switcher -->
    <button 
      class="mode-toggle p-2 rounded-full bg-muted text-foreground hover:bg-muted/80 transition-colors"
      on:click={toggleMode}
      aria-label="Toggle color mode"
    >
      <i class="fa-solid {modeIcon}"></i>
    </button>
    
    <!-- Theme picker -->
    <div class="relative">
      <button 
        class="theme-toggle p-2 rounded-full flex items-center gap-2 hover:bg-muted/80 transition-colors"
        class:bg-muted={isOpen}
        on:click={() => isOpen = !isOpen}
        aria-haspopup="true"
        aria-expanded={isOpen}
      >
        <span class="color-indicator w-4 h-4 rounded-full" style="background-color: {colorThemes[$theme.colorTheme].primary};"></span>
        <span class="sr-only">Select theme color</span>
      </button>
      
      {#if isOpen}
        <div
          class="theme-dropdown absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-card border border-border overflow-hidden"
          transition:fade={{ duration: 150 }}
        >
          <div class="p-2 grid grid-cols-2 gap-1">
            {#each Object.entries(colorThemes) as [key, colorTheme]}
              <button
                class="flex items-center p-2 rounded hover:bg-muted/50 transition-colors text-left"
                class:bg-muted={$theme.colorTheme === key}
                on:click={() => setColorTheme(key as ColorTheme)}
              >
                <span class="color-indicator w-4 h-4 rounded-full mr-2" style="background-color: {colorTheme.primary};"></span>
                <span class="text-sm">{colorTheme.name}</span>
              </button>
            {/each}
          </div>
          
          <div class="border-t border-border p-2">
            <div class="text-xs text-muted-foreground p-1">Current mode: {$theme.modeTheme}</div>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>

<style>
  /* Styles will be provided by design tokens */
</style>
EOF
  
  # Create a utility to generate theme colors
  cat > src/lib/components/theme-switcher/ThemeGenerator.svelte << 'EOF'
<script lang="ts">
  import { onMount } from 'svelte';
  import { hexToHSL, generateColorPalette, createCSSColorVariables } from '$lib/styles/color-utils';
  
  export let primaryColor = '#3b82f6';
  export let secondaryColor = '#6366f1';
  
  // Generated CSS
  let css = '';
  let isReady = false;
  
  onMount(() => {
    generateCss();
  });
  
  function generateCss() {
    try {
      // Generate primary color palette
      const primaryPalette = generateColorPalette(primaryColor);
      const secondaryPalette = generateColorPalette(secondaryColor);
      
      // Create CSS variables
      css = `:root {\n`;
      css += createCSSColorVariables('primary', primaryPalette);
      css += createCSSColorVariables('secondary', secondaryPalette);
      css += `}\n`;
      
      isReady = true;
    } catch (error) {
      console.error('Failed to generate CSS:', error);
    }
  }
  
  // Update when colors change
  $: {
    if (primaryColor || secondaryColor) {
      generateCss();
    }
  }
  
  // Apply CSS to the document
  export function applyCss() {
    if (!isReady) return false;
    
    try {
      // Create style element if it doesn't exist
      let styleEl = document.getElementById('dynamic-theme');
      if (!styleEl) {
        styleEl = document.createElement('style');
        styleEl.id = 'dynamic-theme';
        document.head.appendChild(styleEl);
      }
      
      // Update the CSS
      styleEl.textContent = css;
      return true;
    } catch (error) {
      console.error('Failed to apply CSS:', error);
      return false;
    }
  }
</script>

{#if isReady}
  <div class="theme-generator">
    <div class="form-fields grid grid-cols-1 md:grid-cols-2 gap-4">
      <div class="form-field">
        <label for="primaryColor" class="block text-sm font-medium mb-1">Primary Color</label>
        <div class="flex items-center gap-2">
          <input
            type="color"
            id="primaryColor"
            bind:value={primaryColor}
            class="w-10 h-10 rounded cursor-pointer"
          />
          <input
            type="text"
            bind:value={primaryColor}
            class="flex-1 px-3 py-2 border border-border rounded-md bg-input focus:outline-none focus:ring-1 focus:ring-primary-500"
          />
        </div>
      </div>
      
      <div class="form-field">
        <label for="secondaryColor" class="block text-sm font-medium mb-1">Secondary Color</label>
        <div class="flex items-center gap-2">
          <input
            type="color"
            id="secondaryColor"
            bind:value={secondaryColor}
            class="w-10 h-10 rounded cursor-pointer"
          />
          <input
            type="text"
            bind:value={secondaryColor}
            class="flex-1 px-3 py-2 border border-border rounded-md bg-input focus:outline-none focus:ring-1 focus:ring-primary-500"
          />
        </div>
      </div>
    </div>
    
    <div class="mt-4">
      <button
        on:click={applyCss}
        class="px-4 py-2 rounded-md bg-primary-button text-primary-button-foreground hover:opacity-90 transition-opacity"
      >
        Apply Theme
      </button>
    </div>
    
    <div class="mt-6">
      <h3 class="text-lg font-medium mb-2">Generated CSS Variables</h3>
      <pre class="p-3 border border-border rounded-md bg-muted overflow-x-auto text-sm">
        {css}
      </pre>
    </div>
  </div>
{:else}
  <div class="text-center p-4">
    Generating theme...
  </div>
{/if}
EOF
  
  # Create a theme showcase component
  cat > src/lib/components/theme-switcher/ThemeShowcase.svelte << 'EOF'
<script lang="ts">
  import { onMount } from 'svelte';
  import { theme } from '$lib/stores/theme';
  
  interface ColorSwatch {
    name: string;
    variable: string;
  }
  
  // Define color swatches to display
  const primarySwatches: ColorSwatch[] = [
    { name: '50', variable: 'var(--color-primary-50)' },
    { name: '100', variable: 'var(--color-primary-100)' },
    { name: '200', variable: 'var(--color-primary-200)' },
    { name: '300', variable: 'var(--color-primary-300)' },
    { name: '400', variable: 'var(--color-primary-400)' },
    { name: '500', variable: 'var(--color-primary-500)' },
    { name: '600', variable: 'var(--color-primary-600)' },
    { name: '700', variable: 'var(--color-primary-700)' },
    { name: '800', variable: 'var(--color-primary-800)' },
    { name: '900', variable: 'var(--color-primary-900)' },
    { name: '950', variable: 'var(--color-primary-950)' },
  ];
  
  const semanticSwatches: ColorSwatch[] = [
    { name: 'Background', variable: 'var(--color-background)' },
    { name: 'Foreground', variable: 'var(--color-foreground)' },
    { name: 'Muted', variable: 'var(--color-muted)' },
    { name: 'Muted Foreground', variable: 'var(--color-muted-foreground)' },
    { name: 'Card', variable: 'var(--color-card)' },
    { name: 'Card Foreground', variable: 'var(--color-card-foreground)' },
    { name: 'Border', variable: 'var(--color-border)' },
    { name: 'Input', variable: 'var(--color-input)' },
  ];
  
  // Component examples
  const spacing = [
    { name: '1', value: 'var(--spacing-1)' },
    { name: '2', value: 'var(--spacing-2)' },
    { name: '4', value: 'var(--spacing-4)' },
    { name: '8', value: 'var(--spacing-8)' },
  ];
  
  const radii = [
    { name: 'sm', value: 'var(--border-radius-sm)' },
    { name: 'md', value: 'var(--border-radius-md)' },
    { name: 'lg', value: 'var(--border-radius-lg)' },
    { name: 'full', value: 'var(--border-radius-full)' },
  ];
  
  // Helper to get computed color
  function getComputedColor(variable: string): string {
    if (typeof window === 'undefined') return '';
    return getComputedStyle(document.documentElement).getPropertyValue(variable);
  }
</script>

<div class="theme-showcase space-y-8">
  <div class="space-y-4">
    <h3 class="text-lg font-medium">Primary Colors</h3>
    <div class="grid grid-cols-5 sm:grid-cols-11 gap-2">
      {#each primarySwatches as swatch}
        <div class="color-swatch flex flex-col items-center">
          <div 
            class="w-12 h-12 rounded-md mb-1 border border-border"
            style="background-color: {swatch.variable};"
          ></div>
          <span class="text-xs">{swatch.name}</span>
        </div>
      {/each}
    </div>
  </div>
  
  <div class="space-y-4">
    <h3 class="text-lg font-medium">Semantic Colors</h3>
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
      {#each semanticSwatches as swatch}
        <div class="color-swatch">
          <div 
            class="w-full h-12 rounded-md mb-1 border border-border"
            style="background-color: {swatch.variable};"
          ></div>
          <span class="text-sm">{swatch.name}</span>
        </div>
      {/each}
    </div>
  </div>
  
  <div class="space-y-4">
    <h3 class="text-lg font-medium">Component Examples</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div class="space-y-4">
        <h4 class="text-base font-medium">Buttons</h4>
        <div class="flex flex-wrap gap-2">
          <button class="px-4 py-2 bg-primary-button text-primary-button-foreground rounded-md">
            Primary
          </button>
          <button class="px-4 py-2 bg-secondary-button text-secondary-button-foreground rounded-md">
            Secondary
          </button>
          <button class="px-4 py-2 border border-border rounded-md">
            Outline
          </button>
          <button class="px-4 py-2 text-primary-500">
            Link
          </button>
        </div>
      </div>
      
      <div class="space-y-4">
        <h4 class="text-base font-medium">Spacing</h4>
        <div class="flex items-end gap-2">
          {#each spacing as space}
            <div class="flex flex-col items-center">
              <div 
                class="bg-primary-400 w-8"
                style="height: {space.value};"
              ></div>
              <span class="text-xs mt-1">{space.name}</span>
            </div>
          {/each}
        </div>
      </div>
      
      <div class="space-y-4">
        <h4 class="text-base font-medium">Border Radius</h4>
        <div class="flex gap-4">
          {#each radii as radius}
            <div class="flex flex-col items-center">
              <div 
                class="bg-primary-400 w-12 h-12"
                style="border-radius: {radius.value};"
              ></div>
              <span class="text-xs mt-1">{radius.name}</span>
            </div>
          {/each}
        </div>
      </div>
      
      <div class="space-y-4">
        <h4 class="text-base font-medium">Current Theme</h4>
        <div class="text-sm space-y-1">
          <p><strong>Color Theme:</strong> {$theme.colorTheme}</p>
          <p><strong>Mode:</strong> {$theme.modeTheme}</p>
        </div>
      </div>
    </div>
  </div>
</div>
EOF
  
  # Create example page for design tokens
  typewriter "$info_emoji Creating examples page..." 0.02
  
  # Create the examples directory
  mkdir -p src/routes/examples/design-tokens
  
  cat > src/routes/examples/design-tokens/+page.svelte << 'EOF'
<script lang="ts">
  import { onMount } from 'svelte';
  import ThemeSwitcher from '$lib/components/theme-switcher/ThemeSwitcher.svelte';
  import ThemeGenerator from '$lib/components/theme-switcher/ThemeGenerator.svelte';
  import ThemeShowcase from '$lib/components/theme-switcher/ThemeShowcase.svelte';
  import { initializeTheme } from '$lib/stores/theme';
  
  let themeGenerator: ThemeGenerator;
  
  onMount(() => {
    // Initialize theme
    initializeTheme();
  });
  
  // Apply custom theme
  function applyCustomTheme() {
    if (themeGenerator) {
      themeGenerator.applyCss();
    }
  }
</script>

<svelte:head>
  <title>Design Tokens System</title>
</svelte:head>

<div class="container mx-auto px-4 py-8 max-w-6xl">
  <header class="flex justify-between items-center mb-8">
    <div>
      <h1 class="text-3xl font-bold">Design Tokens System</h1>
      <p class="text-muted-foreground">A showcase of design tokens and theme customization</p>
    </div>
    
    <ThemeSwitcher />
  </header>
  
  <div class="grid grid-cols-1 lg:grid-cols-6 gap-8">
    <div class="lg:col-span-6">
      <div class="border border-border rounded-lg p-6 bg-card shadow-sm">
        <h2 class="text-2xl font-bold mb-4">Current Theme</h2>
        <ThemeShowcase />
      </div>
    </div>
    
    <div class="lg:col-span-3">
      <div class="border border-border rounded-lg p-6 bg-card shadow-sm">
        <h2 class="text-2xl font-bold mb-4">Custom Theme Generator</h2>
        <ThemeGenerator bind:this={themeGenerator} />
      </div>
    </div>
    
    <div class="lg:col-span-3">
      <div class="border border-border rounded-lg p-6 bg-card shadow-sm">
        <h2 class="text-2xl font-bold mb-4">Typography & Spacing</h2>
        
        <div class="space-y-6">
          <div>
            <h3 class="text-xl font-bold mb-3">Typography</h3>
            <div class="space-y-4">
              <div>
                <h1 class="font-sans text-4xl">Heading 1</h1>
                <p class="text-sm text-muted-foreground">font-sans, 4xl</p>
              </div>
              <div>
                <h2 class="font-sans text-3xl">Heading 2</h2>
                <p class="text-sm text-muted-foreground">font-sans, 3xl</p>
              </div>
              <div>
                <h3 class="font-sans text-2xl">Heading 3</h3>
                <p class="text-sm text-muted-foreground">font-sans, 2xl</p>
              </div>
              <div>
                <h4 class="font-sans text-xl">Heading 4</h4>
                <p class="text-sm text-muted-foreground">font-sans, xl</p>
              </div>
              <div>
                <p class="font-sans text-base">Body text in sans-serif</p>
                <p class="text-sm text-muted-foreground">font-sans, base</p>
              </div>
              <div>
                <p class="font-mono text-base">Monospace text for code</p>
                <p class="text-sm text-muted-foreground">font-mono, base</p>
              </div>
            </div>
          </div>
          
          <div>
            <h3 class="text-xl font-bold mb-3">Shadows</h3>
            <div class="grid grid-cols-2 gap-4">
              <div class="p-4 bg-card border border-border rounded-md shadow-sm">shadow-sm</div>
              <div class="p-4 bg-card border border-border rounded-md shadow-md">shadow-md</div>
              <div class="p-4 bg-card border border-border rounded-md shadow-lg">shadow-lg</div>
              <div class="p-4 bg-card border border-border rounded-md shadow-xl">shadow-xl</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <div class="mt-8 border border-border rounded-lg p-6 bg-card shadow-sm">
    <h2 class="text-2xl font-bold mb-4">How to Use Design Tokens</h2>
    
    <div class="prose max-w-none">
      <p>Design tokens are centralized design variables that ensure consistency across your application. Here's how to use them:</p>
      
      <h3>CSS Variables</h3>
      <pre class="p-4 bg-muted rounded-md overflow-x-auto"><code>.my-component {
  background-color: var(--color-primary-500);
  color: var(--color-primary-foreground);
  padding: var(--spacing-4);
  border-radius: var(--border-radius-md);
  box-shadow: var(--shadow-md);
}</code></pre>
      
      <h3>Theming Support</h3>
      <p>Design tokens automatically support light and dark modes through the <code>.dark</code> class. No additional work needed!</p>
      
      <h3>Design System Integration</h3>
      <p>These tokens work seamlessly with Skeleton UI, Bits UI (shadcn-svelte), and other component libraries.</p>
    </div>
  </div>
</div>
EOF
  
  # Update the global style import in app.css or app.postcss
  typewriter "$info_emoji Updating global styles to include design tokens..." 0.02
  
  # Check which CSS file exists
  if [ -f "src/app.css" ]; then
    CSS_FILE="src/app.css"
  elif [ -f "src/app.postcss" ]; then
    CSS_FILE="src/app.postcss"
  else
    # Create a new one if neither exists
    mkdir -p src
    CSS_FILE="src/app.css"
    
    cat > "$CSS_FILE" << 'EOF'
@import './lib/styles/design-tokens.css';

/* Reset and base styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html,
body {
  height: 100%;
  width: 100%;
}

body {
  font-family: var(--font-sans);
  background-color: var(--color-background);
  color: var(--color-foreground);
  line-height: var(--line-height-normal);
}

h1, h2, h3, h4, h5, h6 {
  font-weight: var(--font-weight-bold);
  line-height: var(--line-height-tight);
}

/* Tailwind directives */
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
  fi
  
  # Check if the file already imports design tokens
  if ! grep -q "design-tokens.css" "$CSS_FILE"; then
    # Create a temporary file with the import at the top
    temp_file=$(mktemp)
    echo '@import "./lib/styles/design-tokens.css";' > "$temp_file"
    cat "$CSS_FILE" >> "$temp_file"
    mv "$temp_file" "$CSS_FILE"
  fi
  
  # Update layout to initialize theme if it exists
  if [ -f "src/routes/+layout.svelte" ]; then
    # Check if we already import theme store
    if ! grep -q "initializeTheme" "src/routes/+layout.svelte"; then
      # Check if we need to add onMount import
      if ! grep -q "import { onMount } from 'svelte';" "src/routes/+layout.svelte"; then
        sed -i '1s/^/<script>\n  import { onMount } from "svelte";\n  import { initializeTheme } from "$lib\/stores\/theme";\n  \n  onMount(() => {\n    initializeTheme();\n  });\n<\/script>\n\n/' "src/routes/+layout.svelte"
      else
        # Just add the import and initialization
        sed -i '/import { onMount } from/a import { initializeTheme } from "$lib/stores/theme";' "src/routes/+layout.svelte"
        sed -i '/onMount/a    initializeTheme();' "src/routes/+layout.svelte"
      fi
    fi
  else
    # Create a new layout file
    mkdir -p src/routes
    cat > src/routes/+layout.svelte << 'EOF'
<script>
  import "../app.css";
  import { onMount } from "svelte";
  import { initializeTheme } from "$lib/stores/theme";
  
  onMount(() => {
    initializeTheme();
  });
</script>

<div class="app min-h-screen">
  <slot />
</div>
EOF
  fi
  
  # Update tailwind.config.js to use our color system if it exists
  if [ -f "tailwind.config.js" ] || [ -f "tailwind.config.cjs" ]; then
    # Determine which file to use
    if [ -f "tailwind.config.js" ]; then
      TAILWIND_CONFIG="tailwind.config.js"
    else
      TAILWIND_CONFIG="tailwind.config.cjs"
    fi
    
    # Create a temporary file
    temp_config=$(mktemp)
    
    # Update the config to use our CSS variables
    cat > "$temp_config" << 'EOF'
/** @type {import('tailwindcss').Config} */
const config = {
  darkMode: 'class',
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
      colors: {
        // Primary colors based on design tokens
        primary: {
          50: 'var(--color-primary-50)',
          100: 'var(--color-primary-100)',
          200: 'var(--color-primary-200)',
          300: 'var(--color-primary-300)',
          400: 'var(--color-primary-400)',
          500: 'var(--color-primary-500)',
          600: 'var(--color-primary-600)',
          700: 'var(--color-primary-700)',
          800: 'var(--color-primary-800)',
          900: 'var(--color-primary-900)',
          950: 'var(--color-primary-950)',
        },
        // Semantic colors
        background: 'var(--color-background)',
        foreground: 'var(--color-foreground)',
        muted: 'var(--color-muted)',
        'muted-foreground': 'var(--color-muted-foreground)',
        card: 'var(--color-card)',
        'card-foreground': 'var(--color-card-foreground)',
        border: 'var(--color-border)',
        input: 'var(--color-input)',
        ring: 'var(--color-primary-500)',
      },
      borderRadius: {
        none: 'var(--border-radius-none)',
        sm: 'var(--border-radius-sm)',
        DEFAULT: 'var(--border-radius-md)',
        md: 'var(--border-radius-md)',
        lg: 'var(--border-radius-lg)',
        xl: 'var(--border-radius-xl)',
        '2xl': 'var(--border-radius-2xl)',
        '3xl': 'var(--border-radius-3xl)',
        full: 'var(--border-radius-full)',
      },
      fontFamily: {
        sans: ['var(--font-sans)'],
        serif: ['var(--font-serif)'],
        mono: ['var(--font-mono)'],
      },
      boxShadow: {
        sm: 'var(--shadow-sm)',
        DEFAULT: 'var(--shadow-md)',
        md: 'var(--shadow-md)',
        lg: 'var(--shadow-lg)',
        xl: 'var(--shadow-xl)',
        none: 'var(--shadow-none)',
      },
    },
  },
  plugins: [],
};

export default config;
EOF
    
    # Replace the existing config file
    mv "$temp_config" "$TAILWIND_CONFIG"
  fi
  
  # Measure duration for performance comparison
  local duration=$(end_timing "$start_time")
  local time_saved=$(echo "180.0 - $duration" | bc -l)  # Estimate GUI setup at 3 minutes
  record_operation_time "design_tokens_setup" "$duration"
  
  # Show theme and tone-appropriate completion message
  if [ "$TONE_STAGE" -le 1 ]; then
    # Beginners get a colorful, enthusiastic message
    case "$THEME" in
      "jungle")
        rainbow_box "🍌 Design Tokens now coloring your jungle project!"
        echo "🐒 Your design system was planted in $(printf "%.1f" "$duration") jungle seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than climbing the GUI trees!"
        echo ""
        echo "Your jungle now has these amazing color powers:"
        echo "  • $color_emoji Magic color system that changes your whole jungle at once"
        echo "  • 🌓 Light and dark jungle modes for day and night"
        echo "  • $token_emoji Theme customization so every monkey can pick their colors"
        echo "  • 🦍 Consistent designs across all your jungle interface"
        echo "  • 🌴 Easy theming for all your UI components"
        ;;
      "hacker")
        rainbow_box "[SYS] DESIGN TOKEN SYSTEM DEPLOYED SUCCESSFULLY"
        echo "[PERF] EXECUTION TIME: $(printf "%.1f" "$duration")s | EFFICIENCY GAIN: $(printf "%.1f" "$time_saved")s"
        echo "[INFO] GUI ALTERNATIVE ESTIMATED AT 180.0s ($(printf "%.1f" "$(echo "($time_saved / 180.0) * 100" | bc -l)")% FASTER)"
        echo ""
        echo "SYSTEM COMPONENTS ACTIVATED:"
        echo "  • $color_emoji COLOR VARIABLE SYSTEM: CENTRALIZED COLOR MANAGEMENT"
        echo "  • [THEME] LIGHT/DARK MODE PROTOCOLS: ENVIRONMENT-SENSITIVE DISPLAYS"
        echo "  • $token_emoji DESIGN TOKEN ARCHITECTURE: COMPONENT-AGNOSTIC VARIABLES"
        echo "  • [UI] CONSISTENT COMPONENT PARAMETERS: UNIFIED VISUAL LANGUAGE"
        echo "  • [GEN] THEME GENERATOR: CUSTOM COLOR SCHEME CREATOR"
        ;;
      "wizard")
        rainbow_box "✨ Your Design Token Spellbook is Ready, $IDENTITY!"
        echo "🧙 Your design system was conjured in $(printf "%.1f" "$duration") arcane seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than manual enchantments!"
        echo ""
        echo "Your spellbook contains these magical design powers:"
        echo "  • $color_emoji Color enchantments to change your entire magical interface"
        echo "  • 🌓 Light and dark realm switching for different magical environments"
        echo "  • $token_emoji Theme customization spells for personalized magical aesthetics"
        echo "  • 🔮 Visual consistency across all your scrolls and potions"
        echo "  • ✨ Design token magic to maintain harmony in your kingdom"
        ;;
      "cosmic")
        rainbow_box "🚀 Design Tokens Space Station Modules Installed!"
        echo "💫 Your design system was constructed in $(printf "%.1f" "$duration") cosmic seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than manual construction!"
        echo ""
        echo "Your space station now has these advanced design systems:"
        echo "  • $color_emoji Color control system for universal interface coordination"
        echo "  • 🌓 Light and dark space mode for different cosmic environments"
        echo "  • $token_emoji Theme customization for unique spacecraft identification"
        echo "  • 👽 Visual consistency across all your control panels"
        echo "  • 🛸 Design tokens to maintain order across the galaxy"
        ;;
      *)
        rainbow_box "✅ Design Tokens system added to your project!"
        echo "🚀 System was set up in $(printf "%.1f" "$duration") seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than setting up manually!"
        echo ""
        echo "📋 Your Design Tokens system includes:"
        echo "  • Centralized design variables for colors, spacing, and typography"
        echo "  • Dark/light mode theming with system preference detection"
        echo "  • Theme customization with multiple color schemes"
        echo "  • Component-agnostic design patterns"
        echo "  • Design showcase and theme generator"
        ;;
    esac
    
    # Show time efficiency visualization for beginners
    echo ""
    echo "Time efficiency comparison:"
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Terminal: $(printf "%3.1f" "$duration")s  $(progress_bar "$duration" 30 180)                    │"
    echo "│ GUI:      180.0s  $(progress_bar 180 30 180)  │"
    echo "└────────────────────────────────────────────────────────────┘"
    
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get a moderate message
    rainbow_box "$success_emoji Design Tokens system installed successfully!"
    echo "$info_emoji Setup completed in $(printf "%.1f" "$duration") seconds (estimated $(printf "%.1f" "$time_saved")s faster than manual setup)"
    echo ""
    echo "System features:"
    echo "• Centralized design variables with CSS custom properties"
    echo "• Theme management with light/dark modes"
    echo "• Multiple color schemes with theme switcher"
    echo "• Tailwind integration with design token variables"
    echo "• Example page at /examples/design-tokens"
  else
    # Advanced users get minimal output
    echo "$success_emoji Design Tokens system setup complete. ($(printf "%.1f" "$duration")s)"
    echo "Added: centralized design variables, theme management, color schemes."
    echo "Example at: /examples/design-tokens"
  fi
  
  # Random success message (fun for all tone levels)
  echo ""
  echo "$(display_success "$THEME")"
  
  # Next steps - tone appropriate
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "🚀 Next steps, $IDENTITY:"
    echo "  1. Start your development server:  npm run dev -- --open"
    echo "  2. Check out the examples:         http://localhost:5173/examples/design-tokens"
    echo "  3. Use design tokens in your CSS:  background-color: var(--color-primary-500);"
    echo ""
    echo "Happy coding! Git Monkey is here to help if you need anything else!"
  fi
  echo ""
  
  return 0
}

# Helper function to create a progress bar
progress_bar() {
  local value=$1
  local max_length=$2
  local full_value=$3
  local filled_length=$(echo "($value / $full_value) * $max_length" | bc -l | cut -d. -f1)
  
  local bar=""
  for ((i=0; i<filled_length; i++)); do
    bar="${bar}█"
  done
  
  for ((i=filled_length; i<max_length; i++)); do
    bar="${bar}░"
  done
  
  echo "$bar"
}