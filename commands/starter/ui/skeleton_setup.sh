#!/bin/bash

# ========= SKELETON UI SETUP MODULE =========
# Sets up Skeleton UI with Tailwind CSS for SvelteKit

setup_skeleton() {
  local project_path="$1"
  local framework_type="$2"  # should be svelte for Skeleton
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up Skeleton UI." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Skeleton only works with SvelteKit
  if [ "$framework_type" != "svelte" ]; then
    typewriter "❌ Skeleton UI is designed specifically for SvelteKit projects." 0.02
    typewriter "Please choose a different UI library for $framework_type projects." 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Friendly intro
  typewriter "🔮 Setting up Skeleton UI - a comprehensive UI toolkit for SvelteKit" 0.02
  typewriter "💡 This will add components, themes, and utilities built specifically for Svelte" 0.02
  echo ""
  
  # Check if Tailwind is set up
  if [ ! -f "tailwind.config.js" ] && [ ! -f "tailwind.config.cjs" ]; then
    typewriter "❌ Tailwind CSS needs to be set up first. Let's do that..." 0.02
    setup_tailwind "$project_path" "$framework_type"
  fi
  
  typewriter "Installing Skeleton UI dependencies..." 0.02
  # Install Skeleton UI dependencies
  npm install -D @skeletonlabs/skeleton @floating-ui/dom postcss-load-config svelte-populations > /dev/null 2>&1
  
  # Check if installation was successful
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Something went wrong installing Skeleton UI." 0.02
    return 1
  fi
  
  # Update tailwind.config.js or tailwind.config.cjs
  typewriter "Configuring Skeleton in Tailwind..." 0.02
  
  # Determine the Tailwind config file name
  TAILWIND_CONFIG="tailwind.config.js"
  if [ -f "tailwind.config.cjs" ]; then
    TAILWIND_CONFIG="tailwind.config.cjs"
  fi
  
  # Create a temporary file
  temp_config=$(mktemp)
  
  # Read the existing config and update it
  if grep -q "plugins:" "$TAILWIND_CONFIG"; then
    awk '{
      if ($0 ~ /plugins: \[/) {
        print $0
        print "    require(\"@skeletonlabs/skeleton/tailwind/theme.cjs\"),"
        print "    require(\"@skeletonlabs/skeleton/tailwind/skeleton.cjs\"),"
      } else if ($0 ~ /content: \[/) {
        print "  content: ["
        print "    \"./src/**/*.{html,js,svelte,ts}\","
        print "    \"./node_modules/@skeletonlabs/skeleton/**/*.{html,js,svelte,ts}\","
      } else {
        print $0
      }
    }' "$TAILWIND_CONFIG" > "$temp_config"
    mv "$temp_config" "$TAILWIND_CONFIG"
  else
    # If we can't find the plugins section, create a new config
    cat > "$TAILWIND_CONFIG" << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
    './src/**/*.{html,js,svelte,ts}',
    './node_modules/@skeletonlabs/skeleton/**/*.{html,js,svelte,ts}'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@skeletonlabs/skeleton/tailwind/theme.cjs'),
    require('@skeletonlabs/skeleton/tailwind/skeleton.cjs'),
  ],
}
EOF
  fi
  
  # Update svelte.config.js
  typewriter "Configuring Svelte for Skeleton UI..." 0.02
  
  if [ -f "svelte.config.js" ]; then
    # Create a temporary file
    temp_svelte=$(mktemp)
    
    # Check if config already has preprocessor section
    if grep -q "preprocess:" "svelte.config.js"; then
      awk '{
        if ($0 ~ /preprocess:/) {
          print "  preprocess: vitePreprocess(),"
        } else if ($0 ~ /import \{/) {
          print "import { vitePreprocess } from \"@sveltejs/kit/vite\";"
        } else {
          print $0
        }
      }' "svelte.config.js" > "$temp_svelte"
      mv "$temp_svelte" "svelte.config.js"
    else
      # Add preprocessor if not found
      awk '{
        if ($0 ~ /kit: \{/) {
          print "  preprocess: vitePreprocess(),"
          print $0
        } else if ($0 ~ /import \{/) {
          print $0
          print "import { vitePreprocess } from \"@sveltejs/kit/vite\";"
        } else {
          print $0
        }
      }' "svelte.config.js" > "$temp_svelte"
      mv "$temp_svelte" "svelte.config.js"
    fi
  else
    typewriter "❌ svelte.config.js not found. Skeleton UI may not work correctly." 0.02
  fi
  
  # Set up app.html template
  typewriter "Setting up document template for Skeleton themes..." 0.02
  
  if [ -f "src/app.html" ]; then
    # Create a temporary file
    temp_html=$(mktemp)
    
    # Check if app.html already has data-theme attribute
    if ! grep -q "data-theme" "src/app.html"; then
      awk '{
        if ($0 ~ /<html/) {
          gsub(/<html/, "<html data-theme=\"skeleton\"")
          print $0
        } else {
          print $0
        }
      }' "src/app.html" > "$temp_html"
      mv "$temp_html" "src/app.html"
    else
      typewriter "🔍 data-theme attribute already present in app.html." 0.02
    }
  else
    typewriter "❌ src/app.html not found. Skeleton themes may not work correctly." 0.02
  fi
  
  # Create a basic Skeleton theme module
  typewriter "Creating Skeleton theme module..." 0.02
  
  mkdir -p src/lib
  
  # Check if theme file already exists
  if [ ! -f "src/lib/themes.ts" ]; then
    cat > src/lib/themes.ts << 'EOF'
// Skeleton theme module
import { join } from 'path';
import type { CustomThemeConfig } from '@skeletonlabs/tw-plugin';

// Skeleton theme config
export const myCustomTheme: CustomThemeConfig = {
	name: 'my-custom-theme',
	properties: {
		// =~= Theme Properties =~=
		"--theme-font-family-base": "system-ui",
		"--theme-font-family-heading": "system-ui",
		"--theme-font-color-base": "0 0 0",
		"--theme-font-color-dark": "255 255 255",
		"--theme-rounded-base": "9999px",
		"--theme-rounded-container": "8px",
		"--theme-border-base": "1px",
		// =~= Theme Colors  =~=
		// primary
		"--color-primary-50": "240 249 255", // #f0f9ff
		"--color-primary-100": "224 243 254", // #e0f3fe
		"--color-primary-200": "186 230 253", // #bae6fd
		"--color-primary-300": "125 211 252", // #7dd3fc
		"--color-primary-400": "56 189 248",  // #38bdf8
		"--color-primary-500": "14 165 233",  // #0ea5e9
		"--color-primary-600": "2 132 199",   // #0284c7
		"--color-primary-700": "3 105 161",   // #0369a1
		"--color-primary-800": "7 89 133",    // #075985
		"--color-primary-900": "12 74 110",   // #0c4a6e
		// secondary
		"--color-secondary-50": "240 253 250",  // #f0fdfa
		"--color-secondary-100": "204 251 241", // #ccfbf1
		"--color-secondary-200": "153 246 228", // #99f6e4
		"--color-secondary-300": "153 246 228", // #99f6e4
		"--color-secondary-400": "45 212 191",  // #2dd4bf
		"--color-secondary-500": "20 184 166",  // #14b8a6
		"--color-secondary-600": "13 148 136",  // #0d9488
		"--color-secondary-700": "15 118 110",  // #0f766e
		"--color-secondary-800": "17 94 89",    // #115e59
		"--color-secondary-900": "19 78 74",    // #134e4a
		// tertiary
		"--color-tertiary-50": "255 241 242",   // #fff1f2
		"--color-tertiary-100": "255 228 230",  // #ffe4e6
		"--color-tertiary-200": "254 205 211",  // #fecdd3
		"--color-tertiary-300": "253 164 175",  // #fda4af
		"--color-tertiary-400": "251 113 133",  // #fb7185
		"--color-tertiary-500": "244 63 94",    // #f43f5e
		"--color-tertiary-600": "225 29 72",    // #e11d48
		"--color-tertiary-700": "190 18 60",    // #be123c
		"--color-tertiary-800": "159 18 57",    // #9f1239
		"--color-tertiary-900": "136 19 55",    // #881337
		// success
		"--color-success-50": "240 253 244",    // #f0fdf4
		"--color-success-100": "220 252 231",   // #dcfce7
		"--color-success-200": "187 247 208",   // #bbf7d0
		"--color-success-300": "134 239 172",   // #86efac
		"--color-success-400": "74 222 128",    // #4ade80
		"--color-success-500": "34 197 94",     // #22c55e
		"--color-success-600": "22 163 74",     // #16a34a
		"--color-success-700": "21 128 61",     // #15803d
		"--color-success-800": "22 101 52",     // #166534
		"--color-success-900": "20 83 45",      // #14532d
		// warning
		"--color-warning-50": "254 252 232",    // #fefce8
		"--color-warning-100": "254 249 195",   // #fef9c3
		"--color-warning-200": "254 240 138",   // #fef08a
		"--color-warning-300": "253 224 71",    // #fde047
		"--color-warning-400": "250 204 21",    // #facc15
		"--color-warning-500": "234 179 8",     // #eab308
		"--color-warning-600": "202 138 4",     // #ca8a04
		"--color-warning-700": "161 98 7",      // #a16207
		"--color-warning-800": "133 77 14",     // #854d0e
		"--color-warning-900": "113 63 18",     // #713f12
		// error
		"--color-error-50": "254 242 242",      // #fef2f2
		"--color-error-100": "254 226 226",     // #fee2e2
		"--color-error-200": "254 202 202",     // #fecaca
		"--color-error-300": "252 165 165",     // #fca5a5
		"--color-error-400": "248 113 113",     // #f87171
		"--color-error-500": "239 68 68",       // #ef4444
		"--color-error-600": "220 38 38",       // #dc2626
		"--color-error-700": "185 28 28",       // #b91c1c
		"--color-error-800": "153 27 27",       // #991b1b
		"--color-error-900": "127 29 29",       // #7f1d1d
		// surface
		"--color-surface-50": "250 250 250",    // #fafafa
		"--color-surface-100": "244 244 245",   // #f4f4f5
		"--color-surface-200": "228 228 231",   // #e4e4e7
		"--color-surface-300": "212 212 216",   // #d4d4d8
		"--color-surface-400": "161 161 170",   // #a1a1aa
		"--color-surface-500": "113 113 122",   // #71717a
		"--color-surface-600": "82 82 91",      // #52525b
		"--color-surface-700": "63 63 70",      // #3f3f46
		"--color-surface-800": "39 39 42",      // #27272a
		"--color-surface-900": "24 24 27",      // #18181b
	}
};
EOF
  else
    typewriter "🔍 Theme file already exists at src/lib/themes.ts." 0.02
  fi
  
  # Create a layout with Skeleton UI
  typewriter "Creating Skeleton UI layout..." 0.02
  
  # Check if layout file exists
  if [ -f "src/routes/+layout.svelte" ]; then
    # Check if Skeleton is already imported
    if ! grep -q "@skeletonlabs/skeleton" "src/routes/+layout.svelte"; then
      # Create a temporary file
      temp_layout=$(mktemp)
      
      # Add Skeleton imports to the existing layout
      echo '<script>
  // Skeleton UI
  import "@skeletonlabs/skeleton/themes/theme-skeleton.css";
  import "@skeletonlabs/skeleton/styles/all.css";
  // App shell
  import { AppShell } from "@skeletonlabs/skeleton";
  // Local CSS
  import "../app.css";
</script>

<AppShell>
  <slot />
</AppShell>' > "$temp_layout"
      
      # Replace the layout file
      mv "$temp_layout" "src/routes/+layout.svelte"
    else
      typewriter "🔍 Skeleton UI already imported in layout file." 0.02
    fi
  else
    # Create a new layout file
    mkdir -p src/routes
    
    cat > src/routes/+layout.svelte << 'EOF'
<script>
  // Skeleton UI
  import "@skeletonlabs/skeleton/themes/theme-skeleton.css";
  import "@skeletonlabs/skeleton/styles/all.css";
  // App shell
  import { AppShell } from "@skeletonlabs/skeleton";
  // Local CSS
  import "../app.css";
</script>

<AppShell>
  <slot />
</AppShell>
EOF
  fi
  
  # Create an example page with Skeleton components
  typewriter "Creating an example page with Skeleton components..." 0.02
  
  # Check if page file exists
  if [ -f "src/routes/+page.svelte" ]; then
    # Back up the existing page
    cp "src/routes/+page.svelte" "src/routes/+page.svelte.bak"
    typewriter "📑 Backed up existing page to +page.svelte.bak" 0.02
  fi
  
  # Create a new example page
  cat > src/routes/+page.svelte << 'EOF'
<script>
  import { Avatar, Accordion, AccordionItem, Button, Card } from '@skeletonlabs/skeleton';
</script>

<div class="container mx-auto p-8 space-y-8">
  <h1 class="h1 mb-4">Welcome to Skeleton UI</h1>
  <p class="mb-8">This is an example page showing Skeleton UI components.</p>
  
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
    <Card>
      <header class="card-header">
        <h3 class="h3">Card Component</h3>
      </header>
      <section class="p-4">
        <p>This is a basic card component from Skeleton UI.</p>
      </section>
      <footer class="card-footer">
        <Button>Action</Button>
      </footer>
    </Card>
    
    <Card>
      <header class="card-header">
        <Avatar initials="SK" width="w-12" />
        <h3 class="h3 pl-4">Avatar Component</h3>
      </header>
      <section class="p-4">
        <p>Avatars are used to represent users.</p>
      </section>
      <footer class="card-footer">
        <Button variant="ghost">View Profile</Button>
      </footer>
    </Card>
    
    <Card>
      <header class="card-header">
        <h3 class="h3">Interactive Elements</h3>
      </header>
      <section class="p-4">
        <div class="flex gap-2 flex-wrap mb-4">
          <Button>Default</Button>
          <Button variant="filled">Filled</Button>
          <Button variant="ringed">Ringed</Button>
          <Button variant="ghost">Ghost</Button>
        </div>
        <Accordion>
          <AccordionItem open>
            <svelte:fragment slot="lead">🚀</svelte:fragment>
            <svelte:fragment slot="summary">Getting Started</svelte:fragment>
            <svelte:fragment slot="content">
              <p class="p-4">Skeleton is a UI toolkit for Svelte + Tailwind.</p>
            </svelte:fragment>
          </AccordionItem>
          <AccordionItem>
            <svelte:fragment slot="lead">🎨</svelte:fragment>
            <svelte:fragment slot="summary">Theming</svelte:fragment>
            <svelte:fragment slot="content">
              <p class="p-4">Skeleton supports custom theming and comes with several pre-built themes.</p>
            </svelte:fragment>
          </AccordionItem>
        </Accordion>
      </section>
    </Card>
  </div>
  
  <div class="alert variant-filled-primary">
    <div class="flex items-center gap-4">
      <div>⚡</div>
      <div class="flex-1">
        <h3 class="h3">Supercharge your SvelteKit apps!</h3>
        <p>Skeleton UI provides a complete design system for rapid development.</p>
      </div>
      <Button href="https://skeleton.dev" target="_blank">Learn More</Button>
    </div>
  </div>
</div>
EOF
  
  # Success message
  rainbow_box "✅ Skeleton UI set up successfully!"
  echo "$(display_success "$THEME")"
  
  return 0
}