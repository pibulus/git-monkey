#!/bin/bash

# ========= BITS UI SETUP MODULE =========
# Sets up Bits UI (shadcn-svelte) with Tailwind CSS for SvelteKit
# Bits UI is a collection of accessible, customizable components 
# based on the shadcn design system

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
        "component") echo "🦍" ;;
        "ui") echo "🌴" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "component") echo "[COMP]" ;;
        "ui") echo "[UI]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "component") echo "🔮" ;;
        "ui") echo "🧪" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "component") echo "👽" ;;
        "ui") echo "🛸" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "ℹ️" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "component") echo "🧩" ;;
        "ui") echo "🎨" ;;
        *) echo "ℹ️" ;;
      esac
      ;;
  esac
}

setup_bits_ui() {
  local project_path="$1"
  local framework_type="$2"  # should be svelte or svelte-modern for Bits UI
  
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
  component_emoji=$(get_theme_emoji "component")
  ui_emoji=$(get_theme_emoji "ui")
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "$error_emoji npm is required to set up Bits UI." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Bits UI only works with SvelteKit
  if [[ "$framework_type" != "svelte" && "$framework_type" != "svelte-modern" ]]; then
    typewriter "$error_emoji Bits UI is designed specifically for SvelteKit projects." 0.02
    typewriter "Please choose a different UI library for $framework_type projects." 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(random_fail)"
    return 1
  }
  
  # Tone-aware AND theme-aware introduction based on user's experience level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners - very friendly, detailed explanation
    case "$THEME" in
      "jungle")
        typewriter "$ui_emoji Hey $IDENTITY! Let's add some beautiful components to your jungle treehouse!" 0.02
        echo ""
        typewriter "Bits UI is like having pre-made treehouse furniture that you can customize!" 0.02
        typewriter "We're adding colorful, accessible components that work great for all monkeys:" 0.02
        echo "  • $component_emoji Buttons, form inputs, cards, and more - ready to use!"
        echo "  • 🐒 All components are accessible for every monkey in the jungle"
        echo "  • 🍌 Easy to customize and theme to match your jungle style"
        ;;
      "hacker")
        typewriter "$ui_emoji INITIALIZING BITS UI COMPONENT LIBRARY FOR USER: $IDENTITY" 0.02
        echo ""
        typewriter "BITS UI: ADVANCED MODULAR COMPONENT ARCHITECTURE SYSTEM" 0.02
        typewriter "INSTALLING COMPONENT MODULES:" 0.02
        echo "  • $component_emoji INTERFACE COMPONENTS: BUTTONS, FORMS, DIALOGS"
        echo "  • [A11Y] ACCESSIBILITY PROTOCOLS: ARIA COMPLIANT"
        echo "  • [THEME] CUSTOMIZATION SYSTEM: VARIABLE-BASED"
        ;;
      "wizard")
        typewriter "$ui_emoji Greetings, $IDENTITY! Let us enchant your project with magical components!" 0.02
        echo ""
        typewriter "Bits UI is a spellbook of pre-crafted magical interface elements." 0.02
        typewriter "We're adding these mystical components to your arcane collection:" 0.02
        echo "  • $component_emoji Component enchantments for buttons, forms, and scrolls"
        echo "  • ✨ Accessibility spells to make your interface usable by all wizards"
        echo "  • 🧙 Customization magic to match your personal aesthetic"
        ;;
      "cosmic")
        typewriter "$ui_emoji Greetings, $IDENTITY! Adding advanced UI technology to your space station!" 0.02
        echo ""
        typewriter "Bits UI is a collection of pre-fabricated interface modules for your cosmic dashboard." 0.02
        typewriter "We're installing these advanced components into your system:" 0.02
        echo "  • $component_emoji Interface modules for controls, forms, and displays"
        echo "  • 🚀 Accessibility protocols for universal alien interaction"
        echo "  • 🌠 Customization systems for matching your galactic aesthetic"
        ;;
      *)
        typewriter "$ui_emoji Hey $IDENTITY! Let's add beautiful components to your project!" 0.02
        echo ""
        typewriter "Bits UI gives you a collection of pre-made, customizable components." 0.02
        typewriter "We're adding these awesome features to your project:" 0.02
        echo "  • $component_emoji Ready-to-use buttons, forms, cards, and more"
        echo "  • ✨ All components are accessible and follow best practices"
        echo "  • 🎨 Easy to customize and theme to match your style"
        ;;
    esac
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users - moderate explanation, somewhat technical
    case "$THEME" in
      "jungle")
        typewriter "$ui_emoji Setting up Bits UI component library in your jungle" 0.02
        echo ""
        echo "Adding customizable component system to your treehouse:"
        echo "• $component_emoji Accessible, composable components"
        echo "• CSS variable-based theming system"
        echo "• Fully responsive and customizable"
        ;;
      "hacker")
        typewriter "$ui_emoji CONFIGURING COMPONENT ARCHITECTURE: BITS UI" 0.02
        echo ""
        echo "INSTALLING MODULES:"
        echo "• $component_emoji INTERFACE COMPONENT SYSTEM"
        echo "• ACCESSIBILITY-FIRST ARCHITECTURE"
        echo "• CSS VARIABLE CUSTOMIZATION PROTOCOLS"
        ;;
      "wizard")
        typewriter "$ui_emoji Preparing component spellbook for your magical interface" 0.02
        echo ""
        echo "Adding these arcane elements to your grimoire:"
        echo "• $component_emoji Enchanted interface components"
        echo "• Accessibility magic for universal usability"
        echo "• Theme customization spells for visual consistency"
        ;;
      "cosmic")
        typewriter "$ui_emoji Installing UI component systems to your space station" 0.02
        echo ""
        echo "Adding advanced interface modules:"
        echo "• $component_emoji Modular interface components"
        echo "• Universal accessibility standards"
        echo "• Theme customization system with CSS variables"
        ;;
      *)
        typewriter "$ui_emoji Setting up Bits UI component library for your project" 0.02
        echo ""
        echo "Installing a customizable component system with:"
        echo "• Accessible, composable UI components"
        echo "• CSS variable-based theming"
        echo "• Responsive and customizable design system"
        ;;
    esac
    echo ""
  else
    # Advanced users - minimal, technical explanation
    case "$THEME" in
      "jungle")
        echo "$ui_emoji Installing Bits UI components and configuration."
        ;;
      "hacker")
        echo "$ui_emoji BITS UI SETUP: COMPONENT LIBRARY + THEMING"
        ;;
      "wizard")
        echo "$ui_emoji Conjuring Bits UI component library with theme variables."
        ;;
      "cosmic")
        echo "$ui_emoji Deploying Bits UI component system with theme customization."
        ;;
      *)
        echo "$ui_emoji Installing Bits UI component library and configuration."
        ;;
    esac
    echo ""
  fi
  
  # Check if Tailwind is set up
  if [ ! -f "tailwind.config.js" ] && [ ! -f "tailwind.config.cjs" ]; then
    typewriter "$warning_emoji Tailwind CSS needs to be set up first. Let's do that..." 0.02
    setup_tailwind "$project_path" "$framework_type"
  fi
  
  # Show ASCII diagram for component architecture if tone stage is low
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Component Architecture Overview:"
    echo ""
    echo "┌────────────────────────────────────────────────────────┐"
    echo "│                     YOUR APP                           │"
    echo "│                                                        │"
    echo "│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │"
    echo "│  │    Pages     │  │    Layouts   │  │   Features    │  │"
    echo "│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │"
    echo "│         │                 │                 │          │"
    echo "│         └─────────────────┼─────────────────┘          │"
    echo "│                           │                            │"
    echo "│                           ▼                            │"
    echo "│  ┌────────────────────────────────────────────────┐    │"
    echo "│  │               BITS UI COMPONENTS               │    │"
    echo "│  │                                                │    │"
    echo "│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────┐  │    │"
    echo "│  │  │ Buttons │ │  Forms  │ │ Dialogs │ │ ...  │  │    │"
    echo "│  │  └─────────┘ └─────────┘ └─────────┘ └──────┘  │    │"
    echo "│  │                                                │    │"
    echo "│  └────────────────────────────────────────────────┘    │"
    echo "│                           │                            │"
    echo "│                           ▼                            │"
    echo "│  ┌────────────────────────────────────────────────┐    │"
    echo "│  │                CSS VARIABLES                    │    │"
    echo "│  │     (colors, spacing, radius, animations)       │    │"
    echo "│  └────────────────────────────────────────────────┘    │"
    echo "│                                                        │"
    echo "└────────────────────────────────────────────────────────┘"
    echo ""
  fi
  
  # Install Bits UI dependencies
  typewriter "$info_emoji Installing Bits UI dependencies..." 0.02
  
  # Show loading animation for npm install
  echo -n "Installing packages: "
  
  # Install Bits UI CLI
  echo -n "bits-ui "
  npm install -D bits-ui > /dev/null 2>&1
  
  # Add component styling utilities
  echo -n "class-variance-authority "
  npm install class-variance-authority > /dev/null 2>&1
  
  # Add utilities for class merging
  echo -n "clsx tailwind-merge "
  npm install clsx tailwind-merge > /dev/null 2>&1
  
  # Add Lucide icons
  echo -n "lucide-svelte "
  npm install lucide-svelte > /dev/null 2>&1
  
  # Add Tailwind plugins
  echo -n "tailwind-plugins "
  npm install -D tailwindcss-animate > /dev/null 2>&1
  
  # Add radix-svelte for more complex components
  echo -n "radix-svelte"
  npm install radix-svelte > /dev/null 2>&1
  
  echo " ✓"
  echo ""
  
  # Check if installation was successful
  if [ $? -ne 0 ]; then
    typewriter "$error_emoji $(random_fail) Something went wrong installing Bits UI dependencies." 0.02
    return 1
  fi
  
  # Create lib directories for components if they don't exist
  mkdir -p src/lib/components/ui
  mkdir -p src/lib/utils
  
  # Create utilities file if it doesn't exist
  if [ ! -f "src/lib/utils.ts" ] && [ ! -f "src/lib/utils/index.ts" ]; then
    mkdir -p src/lib/utils
    
    cat > src/lib/utils/index.ts << 'EOF'
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Combines class names with Tailwind CSS support
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Format a date to a locale-friendly string
 */
export function formatDate(date: Date | string): string {
  if (!date) return '';
  
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
}

/**
 * Safely parse JSON with a fallback
 */
export function parseJson<T>(json: string, fallback: T): T {
  try {
    return JSON.parse(json) as T;
  } catch (error) {
    return fallback;
  }
}

/**
 * Delay execution (useful for animations and loading states)
 */
export function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}
EOF
  fi
  
  # Update Tailwind config file
  typewriter "$info_emoji Configuring Tailwind for Bits UI components..." 0.02
  
  # Determine the Tailwind config file name
  TAILWIND_CONFIG="tailwind.config.js"
  if [ -f "tailwind.config.cjs" ]; then
    TAILWIND_CONFIG="tailwind.config.cjs"
  fi
  
  # Create a temporary file
  temp_config=$(mktemp)
  
  # Read the existing config and update it with Bits UI configuration
  cat > "$temp_config" << 'EOF'
/** @type {import('tailwindcss').Config} */
const config = {
  darkMode: ["class"],
  content: ["./src/**/*.{html,js,svelte,ts}"],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: 0 },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: 0 },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};

export default config;
EOF
  
  # Replace the existing config file
  mv "$temp_config" "$TAILWIND_CONFIG"
  
  # Create CSS variables file for theming
  typewriter "$info_emoji Creating theme configuration..." 0.02
  
  # Check if app.css exists and update it
  if [ -f "src/app.css" ]; then
    cat > src/app.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 240 10% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 240 10% 3.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 240 10% 3.9%;
    --primary: 240 5.9% 10%;
    --primary-foreground: 0 0% 98%;
    --secondary: 240 4.8% 95.9%;
    --secondary-foreground: 240 5.9% 10%;
    --muted: 240 4.8% 95.9%;
    --muted-foreground: 240 3.8% 46.1%;
    --accent: 240 4.8% 95.9%;
    --accent-foreground: 240 5.9% 10%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 5.9% 90%;
    --input: 240 5.9% 90%;
    --ring: 240 5.9% 10%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 240 10% 3.9%;
    --foreground: 0 0% 98%;
    --card: 240 10% 3.9%;
    --card-foreground: 0 0% 98%;
    --popover: 240 10% 3.9%;
    --popover-foreground: 0 0% 98%;
    --primary: 0 0% 98%;
    --primary-foreground: 240 5.9% 10%;
    --secondary: 240 3.7% 15.9%;
    --secondary-foreground: 0 0% 98%;
    --muted: 240 3.7% 15.9%;
    --muted-foreground: 240 5% 64.9%;
    --accent: 240 3.7% 15.9%;
    --accent-foreground: 0 0% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 3.7% 15.9%;
    --input: 240 3.7% 15.9%;
    --ring: 240 4.9% 83.9%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOF
  elif [ -f "src/app.postcss" ]; then
    # For postcss file
    cat > src/app.postcss << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 240 10% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 240 10% 3.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 240 10% 3.9%;
    --primary: 240 5.9% 10%;
    --primary-foreground: 0 0% 98%;
    --secondary: 240 4.8% 95.9%;
    --secondary-foreground: 240 5.9% 10%;
    --muted: 240 4.8% 95.9%;
    --muted-foreground: 240 3.8% 46.1%;
    --accent: 240 4.8% 95.9%;
    --accent-foreground: 240 5.9% 10%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 5.9% 90%;
    --input: 240 5.9% 90%;
    --ring: 240 5.9% 10%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 240 10% 3.9%;
    --foreground: 0 0% 98%;
    --card: 240 10% 3.9%;
    --card-foreground: 0 0% 98%;
    --popover: 240 10% 3.9%;
    --popover-foreground: 0 0% 98%;
    --primary: 0 0% 98%;
    --primary-foreground: 240 5.9% 10%;
    --secondary: 240 3.7% 15.9%;
    --secondary-foreground: 0 0% 98%;
    --muted: 240 3.7% 15.9%;
    --muted-foreground: 240 5% 64.9%;
    --accent: 240 3.7% 15.9%;
    --accent-foreground: 0 0% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 3.7% 15.9%;
    --input: 240 3.7% 15.9%;
    --ring: 240 4.9% 83.9%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOF
  else
    # Create a new file
    mkdir -p src
    cat > src/app.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 240 10% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 240 10% 3.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 240 10% 3.9%;
    --primary: 240 5.9% 10%;
    --primary-foreground: 0 0% 98%;
    --secondary: 240 4.8% 95.9%;
    --secondary-foreground: 240 5.9% 10%;
    --muted: 240 4.8% 95.9%;
    --muted-foreground: 240 3.8% 46.1%;
    --accent: 240 4.8% 95.9%;
    --accent-foreground: 240 5.9% 10%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 5.9% 90%;
    --input: 240 5.9% 90%;
    --ring: 240 5.9% 10%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 240 10% 3.9%;
    --foreground: 0 0% 98%;
    --card: 240 10% 3.9%;
    --card-foreground: 0 0% 98%;
    --popover: 240 10% 3.9%;
    --popover-foreground: 0 0% 98%;
    --primary: 0 0% 98%;
    --primary-foreground: 240 5.9% 10%;
    --secondary: 240 3.7% 15.9%;
    --secondary-foreground: 0 0% 98%;
    --muted: 240 3.7% 15.9%;
    --muted-foreground: 240 5% 64.9%;
    --accent: 240 3.7% 15.9%;
    --accent-foreground: 0 0% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 3.7% 15.9%;
    --input: 240 3.7% 15.9%;
    --ring: 240 4.9% 83.9%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOF
  fi
  
  # Create theme switcher component
  typewriter "$info_emoji Creating theme switcher component..." 0.02
  
  # Create the theme switcher directory
  mkdir -p src/lib/components/ui/theme-switcher
  
  # Create theme store
  cat > src/lib/components/ui/theme-switcher/theme-store.ts << 'EOF'
import { browser } from '$app/environment';
import { writable } from 'svelte/store';

type Theme = 'light' | 'dark' | 'system';

// Initialize from localStorage or default to system
const userTheme = browser 
  ? window.localStorage.getItem('theme') as Theme || 'system'
  : 'system';

// Create writable store with initial value
export const theme = writable<Theme>(userTheme);

// Get system preference
function getSystemTheme(): 'light' | 'dark' {
  if (!browser) return 'light';
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

// Update function
export function updateTheme(newTheme: Theme) {
  theme.set(newTheme);
  
  if (browser) {
    // Save to localStorage
    window.localStorage.setItem('theme', newTheme);
    
    // Update document classes
    const isDark = newTheme === 'dark' || (newTheme === 'system' && getSystemTheme() === 'dark');
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }
}

// Initialize theme
export function initializeTheme() {
  if (browser) {
    // Get the current theme
    let currentTheme: Theme;
    theme.subscribe(value => {
      currentTheme = value;
    })();
    
    // Apply theme
    updateTheme(currentTheme);
    
    // Listen for system preference changes
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    mediaQuery.addEventListener('change', () => {
      if (currentTheme === 'system') {
        updateTheme('system');
      }
    });
  }
}
EOF
  
  # Create theme switcher component
  cat > src/lib/components/ui/theme-switcher/theme-switcher.svelte << 'EOF'
<script lang="ts">
  import { onMount } from 'svelte';
  import { theme, updateTheme, initializeTheme } from './theme-store';
  import { Sun, Moon, Laptop } from 'lucide-svelte';
  
  // Initialize theme on mount
  onMount(() => {
    initializeTheme();
  });
  
  // Toggle between themes
  function toggleTheme() {
    $theme = $theme === 'light' ? 'dark' : $theme === 'dark' ? 'system' : 'light';
    updateTheme($theme);
  }
</script>

<button 
  on:click={toggleTheme}
  class="inline-flex items-center justify-center rounded-md text-sm font-medium
  transition-colors hover:bg-muted hover:text-foreground
  h-9 w-9 p-0 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring
  disabled:pointer-events-none disabled:opacity-50"
  title="Toggle theme"
>
  <span class="sr-only">Toggle theme</span>
  {#if $theme === 'light'}
    <Sun size={18} />
  {:else if $theme === 'dark'}
    <Moon size={18} />
  {:else}
    <Laptop size={18} />
  {/if}
</button>
EOF
  
  # Create some basic components
  typewriter "$info_emoji Creating example components..." 0.02
  
  # Create button component
  mkdir -p src/lib/components/ui/button
  cat > src/lib/components/ui/button/button.svelte << 'EOF'
<script lang="ts">
  import { cva, type VariantProps } from 'class-variance-authority';
  import { cn } from '$lib/utils';
  import { createEventDispatcher } from 'svelte';
  
  const dispatch = createEventDispatcher();
  
  const buttonVariants = cva(
    'inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
    {
      variants: {
        variant: {
          default: 'bg-primary text-primary-foreground hover:bg-primary/90',
          destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
          outline: 'border border-input hover:bg-accent hover:text-accent-foreground',
          secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
          ghost: 'hover:bg-accent hover:text-accent-foreground',
          link: 'text-primary underline-offset-4 hover:underline'
        },
        size: {
          default: 'h-10 px-4 py-2',
          sm: 'h-9 rounded-md px-3',
          lg: 'h-11 rounded-md px-8',
          icon: 'h-10 w-10'
        }
      },
      defaultVariants: {
        variant: 'default',
        size: 'default'
      }
    }
  );
  
  type ButtonVariants = VariantProps<typeof buttonVariants>;
  
  export let variant: ButtonVariants['variant'] = 'default';
  export let size: ButtonVariants['size'] = 'default';
  export let disabled = false;
  export let type: 'button' | 'submit' | 'reset' = 'button';
  export let class: string = '';
  
  function handleClick(e: MouseEvent) {
    if (disabled) {
      e.preventDefault();
      return;
    }
    
    dispatch('click', e);
  }
</script>

<button
  type={type}
  class={cn(buttonVariants({ variant, size }), class)}
  {disabled}
  on:click={handleClick}
  {...$$restProps}
>
  <slot />
</button>
EOF
  
  # Create card component
  mkdir -p src/lib/components/ui/card
  cat > src/lib/components/ui/card/card.svelte << 'EOF'
<script lang="ts">
  import { cn } from '$lib/utils';
  
  export let class: string = '';
</script>

<div class={cn('rounded-lg border bg-card text-card-foreground shadow-sm', class)} {...$$restProps}>
  <slot />
</div>
EOF
  
  cat > src/lib/components/ui/card/card-header.svelte << 'EOF'
<script lang="ts">
  import { cn } from '$lib/utils';
  
  export let class: string = '';
</script>

<div class={cn('flex flex-col space-y-1.5 p-6', class)} {...$$restProps}>
  <slot />
</div>
EOF
  
  cat > src/lib/components/ui/card/card-title.svelte << 'EOF'
<script lang="ts">
  import { cn } from '$lib/utils';
  
  export let class: string = '';
  export let tag: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6' = 'h3';
</script>

<svelte:element
  this={tag}
  class={cn('text-2xl font-semibold leading-none tracking-tight', class)}
  {...$$restProps}
>
  <slot />
</svelte:element>
EOF
  
  cat > src/lib/components/ui/card/card-description.svelte << 'EOF'
<script lang="ts">
  import { cn } from '$lib/utils';
  
  export let class: string = '';
</script>

<p class={cn('text-sm text-muted-foreground', class)} {...$$restProps}>
  <slot />
</p>
EOF
  
  cat > src/lib/components/ui/card/card-content.svelte << 'EOF'
<script lang="ts">
  import { cn } from '$lib/utils';
  
  export let class: string = '';
</script>

<div class={cn('p-6 pt-0', class)} {...$$restProps}>
  <slot />
</div>
EOF
  
  cat > src/lib/components/ui/card/card-footer.svelte << 'EOF'
<script lang="ts">
  import { cn } from '$lib/utils';
  
  export let class: string = '';
</script>

<div class={cn('flex items-center p-6 pt-0', class)} {...$$restProps}>
  <slot />
</div>
EOF
  
  cat > src/lib/components/ui/card/index.ts << 'EOF'
export { default as Card } from './card.svelte';
export { default as CardHeader } from './card-header.svelte';
export { default as CardTitle } from './card-title.svelte';
export { default as CardDescription } from './card-description.svelte';
export { default as CardContent } from './card-content.svelte';
export { default as CardFooter } from './card-footer.svelte';
EOF
  
  # Set up a sample page with components
  typewriter "$info_emoji Creating example page with components..." 0.02
  
  # Create examples directory if it doesn't exist
  mkdir -p src/routes/examples/bits-ui
  
  # Create the page
  cat > src/routes/examples/bits-ui/+page.svelte << 'EOF'
<script lang="ts">
  import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '$lib/components/ui/card';
  import { Button } from '$lib/components/ui/button';
  import ThemeSwitcher from '$lib/components/ui/theme-switcher/theme-switcher.svelte';
</script>

<svelte:head>
  <title>Bits UI Example</title>
</svelte:head>

<div class="container mx-auto py-8">
  <div class="flex justify-between items-center mb-8">
    <h1 class="text-3xl font-bold">Bits UI Components</h1>
    <ThemeSwitcher />
  </div>
  
  <p class="mb-8">This page demonstrates the basic Bits UI components with theme support.</p>
  
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
    <Card>
      <CardHeader>
        <CardTitle>Card Component</CardTitle>
        <CardDescription>A versatile container for content</CardDescription>
      </CardHeader>
      <CardContent>
        <p>Cards are containers for content that group related information. They can contain any combination of text, links, buttons, and other UI elements.</p>
      </CardContent>
      <CardFooter>
        <Button>Primary Action</Button>
        <Button variant="outline" class="ml-2">Secondary Action</Button>
      </CardFooter>
    </Card>
    
    <Card>
      <CardHeader>
        <CardTitle>Button Variants</CardTitle>
        <CardDescription>Different styles for different purposes</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="flex flex-wrap gap-2">
          <Button>Default</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="outline">Outline</Button>
          <Button variant="ghost">Ghost</Button>
          <Button variant="destructive">Destructive</Button>
          <Button variant="link">Link</Button>
        </div>
      </CardContent>
      <CardFooter>
        <p class="text-sm text-muted-foreground">Use different button variants to indicate importance and function.</p>
      </CardFooter>
    </Card>
  </div>
  
  <Card class="mb-10">
    <CardHeader>
      <CardTitle>Theme Support</CardTitle>
      <CardDescription>Dark and light mode with system preference detection</CardDescription>
    </CardHeader>
    <CardContent>
      <p class="mb-4">Bits UI comes with built-in theme support using CSS variables. Use the theme switcher in the top right to toggle between themes.</p>
      
      <div class="grid grid-cols-2 gap-4 mt-6">
        <div class="p-4 rounded-md bg-primary text-primary-foreground">Primary</div>
        <div class="p-4 rounded-md bg-secondary text-secondary-foreground">Secondary</div>
        <div class="p-4 rounded-md bg-accent text-accent-foreground">Accent</div>
        <div class="p-4 rounded-md bg-muted text-muted-foreground">Muted</div>
        <div class="p-4 rounded-md bg-card border border-border">Card</div>
        <div class="p-4 rounded-md bg-destructive text-destructive-foreground">Destructive</div>
      </div>
    </CardContent>
  </Card>
  
  <Card>
    <CardHeader>
      <CardTitle>Getting Started</CardTitle>
      <CardDescription>How to use these components in your project</CardDescription>
    </CardHeader>
    <CardContent>
      <p class="mb-4">Import components from <code class="text-sm font-mono bg-muted px-1 py-0.5 rounded">$lib/components/ui</code> to use them in your project.</p>
      
      <pre class="bg-muted p-4 rounded-md overflow-x-auto text-sm"><code>&lt;script&gt;
  import { Button } from '$lib/components/ui/button';
  import { Card, CardHeader, CardTitle } from '$lib/components/ui/card';
&lt;/script&gt;

&lt;Card&gt;
  &lt;CardHeader&gt;
    &lt;CardTitle&gt;Hello World&lt;/CardTitle&gt;
  &lt;/CardHeader&gt;
  &lt;Button&gt;Click Me&lt;/Button&gt;
&lt;/Card&gt;</code></pre>
    </CardContent>
    <CardFooter>
      <Button variant="outline" on:click={() => window.history.back()}>Go Back</Button>
    </CardFooter>
  </Card>
</div>
EOF
  
  # Update the layout file to include theme initialization if it exists
  if [ -f "src/routes/+layout.svelte" ]; then
    # Check if we need to add onMount import
    if ! grep -q "import { onMount } from 'svelte';" "src/routes/+layout.svelte"; then
      sed -i '1s/^/<script>\n  import { onMount } from "svelte";\n  import { initializeTheme } from "$lib\/components\/ui\/theme-switcher\/theme-store";\n  \n  onMount(() => {\n    initializeTheme();\n  });\n<\/script>\n\n/' "src/routes/+layout.svelte"
    elif ! grep -q "import { initializeTheme } from" "src/routes/+layout.svelte"; then
      # Just add the import and initialization
      sed -i '/import { onMount } from/a import { initializeTheme } from "$lib/components/ui/theme-switcher/theme-store";' "src/routes/+layout.svelte"
      sed -i '/onMount/a    initializeTheme();' "src/routes/+layout.svelte"
    fi
  else
    # Create a new layout file
    mkdir -p src/routes
    cat > src/routes/+layout.svelte << 'EOF'
<script>
  import "../app.css";
  import { onMount } from "svelte";
  import { initializeTheme } from "$lib/components/ui/theme-switcher/theme-store";
  
  onMount(() => {
    initializeTheme();
  });
</script>

<div class="min-h-screen bg-background">
  <slot />
</div>
EOF
  fi
  
  # Measure duration for performance comparison
  local duration=$(end_timing "$start_time")
  local time_saved=$(echo "210.0 - $duration" | bc -l)  # Estimate GUI setup at 3.5 minutes
  record_operation_time "bits_ui_setup" "$duration"
  
  # Show theme and tone-appropriate completion message
  if [ "$TONE_STAGE" -le 1 ]; then
    # Beginners get a colorful, enthusiastic message
    case "$THEME" in
      "jungle")
        rainbow_box "🍌 Bits UI components added to your jungle project!"
        echo "🐒 Your components were planted in $(printf "%.1f" "$duration") jungle seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than climbing the GUI trees!"
        echo ""
        echo "Your jungle now has these cool features:"
        echo "  • $component_emoji Beautiful UI components for your treehouse"
        echo "  • 🌙 Dark and light jungle mode with theme switching"
        echo "  • 🐵 Fully accessible for all jungle visitors"
        echo "  • 🌴 Customizable colors for your perfect aesthetic"
        echo "  • 🦍 Responsive design for all device sizes"
        ;;
      "hacker")
        rainbow_box "[SYS] BITS UI COMPONENT SYSTEM DEPLOYED"
        echo "[PERF] EXECUTION TIME: $(printf "%.1f" "$duration")s | EFFICIENCY GAIN: $(printf "%.1f" "$time_saved")s"
        echo "[INFO] GUI ALTERNATIVE ESTIMATED AT 210.0s ($(printf "%.1f" "$(echo "($time_saved / 210.0) * 100" | bc -l)")% FASTER)"
        echo ""
        echo "COMPONENT SYSTEM MODULES:"
        echo "  • $component_emoji INTERFACE COMPONENTS: BUTTON, CARD, FORM ELEMENTS"
        echo "  • [THEME] THEME SYSTEM: DARK/LIGHT/SYSTEM MODES"
        echo "  • [A11Y] ACCESSIBILITY: SEMANTIC MARKUP AND ARIA SUPPORT"
        echo "  • [DESIGN] CSS VARIABLE SYSTEM FOR CUSTOMIZATION"
        echo "  • [RESP] RESPONSIVE LAYOUT SYSTEM"
        ;;
      "wizard")
        rainbow_box "✨ Your Component Spellbook is Ready, $IDENTITY!"
        echo "🧙 Your components were conjured in $(printf "%.1f" "$duration") arcane seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than manual enchantments!"
        echo ""
        echo "Your spellbook contains these magical components:"
        echo "  • $component_emoji Arcane interface elements ready to use"
        echo "  • 🌙 Light and shadow realm switching"
        echo "  • ✨ Accessibility enchantments for all wizards"
        echo "  • 🧪 Magical color potions for customization"
        echo "  • 📜 Responsive scrolls for all crystal balls"
        ;;
      "cosmic")
        rainbow_box "🚀 Bits UI Space Station Modules Installed for $IDENTITY!"
        echo "💫 Your modules were constructed in $(printf "%.1f" "$duration") cosmic seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than manual construction!"
        echo ""
        echo "Your space station now has these advanced modules:"
        echo "  • $component_emoji Interface control panels ready to use"
        echo "  • 🌙 Dark space and light space mode switching"
        echo "  • 👽 Universal accessibility for all life forms"
        echo "  • 🛸 Customizable design variables for your fleet"
        echo "  • 🌌 Responsive layouts for all viewscreen sizes"
        ;;
      *)
        rainbow_box "✅ Bits UI components added to your project!"
        echo "🚀 Components were set up in $(printf "%.1f" "$duration") seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than setting up manually!"
        echo ""
        echo "📋 Your Bits UI integration includes:"
        echo "  • Ready-to-use UI components (Button, Card, etc.)"
        echo "  • Dark/light theme switching with system preference"
        echo "  • Accessibility features built-in"
        echo "  • CSS variable system for customization"
        echo "  • Responsive design for all screen sizes"
        ;;
    esac
    
    # Show time efficiency visualization for beginners
    echo ""
    echo "Time efficiency comparison:"
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Terminal: $(printf "%3.1f" "$duration")s  $(progress_bar "$duration" 30 210)                    │"
    echo "│ GUI:      210.0s  $(progress_bar 210 30 210)  │"
    echo "└────────────────────────────────────────────────────────────┘"
    
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get a moderate message
    rainbow_box "$success_emoji Bits UI components installed successfully!"
    echo "$info_emoji Setup completed in $(printf "%.1f" "$duration") seconds (estimated $(printf "%.1f" "$time_saved")s faster than manual setup)"
    echo ""
    echo "Integration features:"
    echo "• Modern UI component system with theme support"
    echo "• Dark/light mode with system preference detection"
    echo "• CSS variable-based design system"
    echo "• Accessible components with ARIA support"
    echo "• Example page at /examples/bits-ui"
  else
    # Advanced users get minimal output
    echo "$success_emoji Bits UI setup complete. ($(printf "%.1f" "$duration")s)"
    echo "Components: Button, Card. Theme system with dark/light toggle."
    echo "Example: /examples/bits-ui"
  fi
  
  # Random success message (fun for all tone levels)
  echo ""
  echo "$(random_success)"
  
  # Next steps - tone appropriate
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "🚀 Next steps, $IDENTITY:"
    echo "  1. Start your development server:  npm run dev -- --open"
    echo "  2. Check out the example page:     http://localhost:5173/examples/bits-ui"
    echo "  3. Use components in your app:     import { Button } from '\$lib/components/ui/button';"
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