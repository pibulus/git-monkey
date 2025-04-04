#!/bin/bash

# Set directory paths for consistent imports
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"

# ========= SHOELACE SETUP MODULE =========
# Sets up Shoelace Web Components

setup_shoelace() {
  local project_path="$1"
  local framework_type="$2"  # svelte, node, or static
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up Shoelace." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Friendly intro
  typewriter "🧩 Setting up Shoelace - framework-agnostic web components" 0.02
  typewriter "💡 This will add high-quality, accessible web components to your project" 0.02
  echo ""
  
  # Install Shoelace
  typewriter "Installing Shoelace web components..." 0.02
  npm install @shoelace-style/shoelace > /dev/null 2>&1
  
  # Check if installation was successful
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Something went wrong installing Shoelace." 0.02
    return 1
  fi
  
  # Framework-specific setup
  case "$framework_type" in
    svelte)
      # For SvelteKit
      typewriter "Setting up Shoelace for SvelteKit..." 0.02
      
      # Create an imports file
      mkdir -p src/lib
      
      cat > src/lib/shoelace.js << 'EOF'
// Import the Shoelace theme and components you need
import '@shoelace-style/shoelace/dist/themes/light.css';

// Import specific components to reduce bundle size
// Change this list to match the components you need
import '@shoelace-style/shoelace/dist/components/button/button.js';
import '@shoelace-style/shoelace/dist/components/card/card.js';
import '@shoelace-style/shoelace/dist/components/dialog/dialog.js';
import '@shoelace-style/shoelace/dist/components/input/input.js';
import '@shoelace-style/shoelace/dist/components/select/select.js';
import '@shoelace-style/shoelace/dist/components/tab/tab.js';
import '@shoelace-style/shoelace/dist/components/tab-group/tab-group.js';
import '@shoelace-style/shoelace/dist/components/tab-panel/tab-panel.js';
import '@shoelace-style/shoelace/dist/components/tooltip/tooltip.js';

// To use all components (larger bundle size)
// import '@shoelace-style/shoelace/dist/shoelace.js';

// Set the base path to the folder where assets are copied
// If using SvelteKit, this should be '/node_modules/@shoelace-style/shoelace/dist/'
import { setBasePath } from '@shoelace-style/shoelace/dist/utilities/base-path.js';
setBasePath('/node_modules/@shoelace-style/shoelace/dist/');
EOF
      
      # Update the layout file
      if [ -f "src/routes/+layout.svelte" ]; then
        # Check if Shoelace is already imported
        if ! grep -q "@shoelace-style/shoelace" "src/routes/+layout.svelte"; then
          # Create a temporary file
          temp_layout=$(mktemp)
          
          # Add Shoelace import to the top of the script tag
          awk '{
            if ($0 ~ /<script>/) {
              print $0
              print "  import \"$lib/shoelace.js\";"
            } else if ($0 ~ /import .* from/) {
              print $0
            } else {
              print $0
            }
          }' "src/routes/+layout.svelte" > "$temp_layout"
          
          # Replace the layout file
          mv "$temp_layout" "src/routes/+layout.svelte"
        else
          typewriter "🔍 Shoelace already imported in layout file." 0.02
        fi
      else
        # Create a basic layout file
        mkdir -p src/routes
        
        cat > src/routes/+layout.svelte << 'EOF'
<script>
  import "$lib/shoelace.js";
</script>

<slot />
EOF
      fi
      
      # Create an example page
      if [ ! -f "src/routes/shoelace-demo.svelte" ]; then
        mkdir -p src/routes
        
        cat > src/routes/shoelace-demo.svelte << 'EOF'
<svelte:head>
  <title>Shoelace Demo</title>
</svelte:head>

<div class="container mx-auto p-8 space-y-8">
  <h1 class="text-3xl font-bold mb-6">Shoelace Web Components</h1>
  
  <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
    <div class="space-y-4">
      <h2 class="text-2xl font-semibold">Buttons</h2>
      <div class="flex flex-wrap gap-2">
        <sl-button>Default</sl-button>
        <sl-button variant="primary">Primary</sl-button>
        <sl-button variant="success">Success</sl-button>
        <sl-button variant="neutral">Neutral</sl-button>
        <sl-button variant="warning">Warning</sl-button>
        <sl-button variant="danger">Danger</sl-button>
      </div>
      
      <h2 class="text-2xl font-semibold mt-6">Input</h2>
      <sl-input label="Name" help-text="Enter your full name"></sl-input>
      <sl-input type="email" label="Email" help-text="Enter a valid email address"></sl-input>
      
      <h2 class="text-2xl font-semibold mt-6">Select</h2>
      <sl-select label="Select one">
        <sl-option value="option-1">Option 1</sl-option>
        <sl-option value="option-2">Option 2</sl-option>
        <sl-option value="option-3">Option 3</sl-option>
      </sl-select>
    </div>
    
    <div>
      <h2 class="text-2xl font-semibold">Card</h2>
      <sl-card class="card-overview">
        <img 
          slot="image" 
          src="https://images.unsplash.com/photo-1559209172-0ff8f6d49ff7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=80" 
          alt="A peaceful mountain landscape" 
        />
        <strong>Card Title</strong>
        <small>This is a description of the card.</small>
        <div slot="footer">
          <sl-button variant="primary" pill>Follow</sl-button>
          <sl-button variant="neutral" pill>View</sl-button>
        </div>
      </sl-card>
      
      <h2 class="text-2xl font-semibold mt-6">Tabs</h2>
      <sl-tab-group>
        <sl-tab slot="nav" panel="general">General</sl-tab>
        <sl-tab slot="nav" panel="custom">Custom</sl-tab>
        <sl-tab slot="nav" panel="advanced">Advanced</sl-tab>
        <sl-tab-panel name="general">This is the general tab panel.</sl-tab-panel>
        <sl-tab-panel name="custom">This is the custom tab panel.</sl-tab-panel>
        <sl-tab-panel name="advanced">This is the advanced tab panel.</sl-tab-panel>
      </sl-tab-group>
      
      <h2 class="text-2xl font-semibold mt-6">Dialog</h2>
      <sl-button id="open-dialog">Open Dialog</sl-button>
      <sl-dialog label="Dialog" class="dialog-overview">
        This is a dialog with a header and a footer.
        <div slot="footer">
          <sl-button variant="primary">Close</sl-button>
        </div>
      </sl-dialog>
    </div>
  </div>
</div>

<script>
  import { onMount } from 'svelte';
  
  onMount(() => {
    // Initialize dialog
    const dialog = document.querySelector('.dialog-overview');
    const openButton = document.querySelector('#open-dialog');
    const closeButton = dialog.querySelector('sl-button[variant="primary"]');
    
    openButton.addEventListener('click', () => dialog.show());
    closeButton.addEventListener('click', () => dialog.hide());
  });
</script>

<style>
  .card-overview {
    max-width: 400px;
  }
  
  sl-card::part(footer) {
    display: flex;
    justify-content: space-between;
  }
</style>
EOF
      fi
      ;;
      
    node)
      # For Node/Express projects
      typewriter "Setting up Shoelace for Express app..." 0.02
      
      # Create a public directory for assets if it doesn't exist
      mkdir -p public/shoelace
      
      # Create a script to copy Shoelace assets
      cat > scripts/copy-shoelace-assets.js << 'EOF'
const fs = require('fs');
const path = require('path');

// Source and destination paths
const sourcePath = path.join(__dirname, '../node_modules/@shoelace-style/shoelace/dist/assets');
const destPath = path.join(__dirname, '../public/shoelace/assets');

// Create destination directory if it doesn't exist
if (!fs.existsSync(destPath)) {
  fs.mkdirSync(destPath, { recursive: true });
}

// Copy assets recursively
function copyDir(src, dest) {
  const entries = fs.readdirSync(src, { withFileTypes: true });
  
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    
    if (entry.isDirectory()) {
      if (!fs.existsSync(destPath)) {
        fs.mkdirSync(destPath, { recursive: true });
      }
      copyDir(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

// Execute the copy
try {
  copyDir(sourcePath, destPath);
# Get current theme
THEME=$(get_selected_theme)
  console.log('✅ Shoelace assets copied successfully');
} catch (err) {
  console.error('❌ Error copying Shoelace assets:', err);
}
EOF
      
      # Add script to package.json
      if [ -f "package.json" ]; then
        npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "copy-shoelace": "node scripts/copy-shoelace-assets.js" }' > /dev/null 2>&1
      fi
      
      # Create a directory for scripts
      mkdir -p scripts
      
      # Add express route for Shoelace assets if the app exists
      if [ -f "index.js" ]; then
        # Check if express.static is already set for node_modules
        if ! grep -q "express.static.*node_modules" "index.js"; then
          # Add a route for Shoelace
          temp_file=$(mktemp)
          awk '{
            if ($0 ~ /app.use\(express.static/) {
              print $0
              print "app.use(\"/node_modules\", express.static(\"node_modules/@shoelace-style/shoelace/dist/\"));"
            } else {
              print $0
            }
          }' "index.js" > "$temp_file"
          mv "$temp_file" "index.js"
        fi
      fi
      
      # Create an example view with Shoelace
      mkdir -p views
      
      if [ ! -f "views/shoelace.ejs" ]; then
        cat > views/shoelace.ejs << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Shoelace Components</title>
  
  <!-- Shoelace theme -->
  <link rel="stylesheet" href="/node_modules/@shoelace-style/shoelace/dist/themes/light.css">
  
  <!-- Custom styles -->
  <style>
    body {
      font-family: var(--sl-font-sans);
      margin: 0;
      padding: 2rem;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
    }
    .grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 2rem;
    }
    @media (min-width: 768px) {
      .grid {
        grid-template-columns: 1fr 1fr;
      }
    }
    .card-overview {
      max-width: 400px;
    }
    .component-section {
      margin-bottom: 2rem;
    }
    .button-group {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Shoelace Web Components</h1>
    
    <div class="grid">
      <div>
        <div class="component-section">
          <h2>Buttons</h2>
          <div class="button-group">
            <sl-button>Default</sl-button>
            <sl-button variant="primary">Primary</sl-button>
            <sl-button variant="success">Success</sl-button>
            <sl-button variant="neutral">Neutral</sl-button>
            <sl-button variant="warning">Warning</sl-button>
            <sl-button variant="danger">Danger</sl-button>
          </div>
        </div>
        
        <div class="component-section">
          <h2>Input</h2>
          <sl-input label="Name" help-text="Enter your full name"></sl-input>
          <sl-input type="email" label="Email" help-text="Enter your email address"></sl-input>
        </div>
        
        <div class="component-section">
          <h2>Select</h2>
          <sl-select label="Select an option">
            <sl-option value="option-1">Option 1</sl-option>
            <sl-option value="option-2">Option 2</sl-option>
            <sl-option value="option-3">Option 3</sl-option>
          </sl-select>
        </div>
      </div>
      
      <div>
        <div class="component-section">
          <h2>Card</h2>
          <sl-card class="card-overview">
            <img 
              slot="image" 
              src="https://images.unsplash.com/photo-1547483238-2cbf881a559f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" 
              alt="A mountain landscape" 
            />
            <strong>Card Title</strong>
            <small>This is the card description that will be truncated if it gets too long.</small>
            <div slot="footer">
              <sl-button variant="primary">Primary</sl-button>
              <sl-button variant="neutral">Neutral</sl-button>
            </div>
          </sl-card>
        </div>
        
        <div class="component-section">
          <h2>Tabs</h2>
          <sl-tab-group>
            <sl-tab slot="nav" panel="general">General</sl-tab>
            <sl-tab slot="nav" panel="custom">Custom</sl-tab>
            <sl-tab slot="nav" panel="advanced">Advanced</sl-tab>
            <sl-tab-panel name="general">This is the general tab panel.</sl-tab-panel>
            <sl-tab-panel name="custom">This is the custom tab panel.</sl-tab-panel>
            <sl-tab-panel name="advanced">This is the advanced tab panel.</sl-tab-panel>
          </sl-tab-group>
        </div>
        
        <div class="component-section">
          <h2>Dialog</h2>
          <sl-button id="open-dialog">Open Dialog</sl-button>
          <sl-dialog label="Dialog" class="dialog-overview">
            This is a dialog with a header and a footer.
            <div slot="footer">
              <sl-button variant="primary" id="close-dialog">Close</sl-button>
            </div>
          </sl-dialog>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Load specific Shoelace components to reduce bundle size -->
  <script type="module">
    import '@shoelace-style/shoelace/dist/components/button/button.js';
    import '@shoelace-style/shoelace/dist/components/card/card.js';
    import '@shoelace-style/shoelace/dist/components/dialog/dialog.js';
    import '@shoelace-style/shoelace/dist/components/input/input.js';
    import '@shoelace-style/shoelace/dist/components/select/select.js';
    import '@shoelace-style/shoelace/dist/components/option/option.js';
    import '@shoelace-style/shoelace/dist/components/tab/tab.js';
    import '@shoelace-style/shoelace/dist/components/tab-group/tab-group.js';
    import '@shoelace-style/shoelace/dist/components/tab-panel/tab-panel.js';
    
    // Set base path for assets
    import { setBasePath } from '@shoelace-style/shoelace/dist/utilities/base-path.js';
    setBasePath('/node_modules/@shoelace-style/shoelace/dist/');
    
    // Initialize dialog
    const dialog = document.querySelector('.dialog-overview');
    const openButton = document.querySelector('#open-dialog');
    const closeButton = document.querySelector('#close-dialog');
    
    openButton.addEventListener('click', () => dialog.show());
    closeButton.addEventListener('click', () => dialog.hide());
  </script>
</body>
</html>
EOF
      fi
      
      # Add a route for the Shoelace demo
      if [ -f "index.js" ]; then
        # Check if the route already exists
        if ! grep -q "'/shoelace'" "index.js"; then
          # Add the route
          temp_file=$(mktemp)
          awk '{
            if ($0 ~ /app.use\(.*\);/) {
              print $0
              print ""
              print "// Shoelace demo route"
              print "app.get(\"/shoelace\", (req, res) => {"
              print "  res.render(\"shoelace\");"
              print "});"
            } else {
              print $0
            }
          }' "index.js" > "$temp_file"
          mv "$temp_file" "index.js"
        fi
      fi
      ;;
      
    static)
      # For static sites
      typewriter "Setting up Shoelace for static site..." 0.02
      
      # Create an example HTML file with Shoelace
      if [ ! -f "shoelace.html" ]; then
        cat > shoelace.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Shoelace Web Components</title>
  
  <!-- Shoelace theme -->
  <link rel="stylesheet" href="node_modules/@shoelace-style/shoelace/dist/themes/light.css">
  
  <style>
    :root {
      --max-width: 1200px;
      --font-family: system-ui, -apple-system, sans-serif;
    }
    
    body {
      font-family: var(--font-family);
      margin: 0;
      padding: 2rem;
      color: #333;
      line-height: 1.6;
    }
    
    .container {
      max-width: var(--max-width);
      margin: 0 auto;
    }
    
    header {
      margin-bottom: 2rem;
      border-bottom: 1px solid #eee;
      padding-bottom: 1rem;
    }
    
    h1 {
      font-size: 2.5rem;
      margin-bottom: 0.5rem;
    }
    
    h2 {
      font-size: 1.8rem;
      margin-top: 2rem;
      margin-bottom: 1rem;
    }
    
    .component-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 2rem;
    }
    
    @media (min-width: 768px) {
      .component-grid {
        grid-template-columns: 1fr 1fr;
      }
    }
    
    .component-section {
      margin-bottom: 2rem;
    }
    
    .button-group {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
      margin-bottom: 1rem;
    }
    
    .card-demo {
      max-width: 350px;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>Shoelace Web Components</h1>
      <p>A demonstration of Shoelace web components that work in any framework.</p>
    </header>
    
    <main>
      <div class="component-grid">
        <div>
          <section class="component-section">
            <h2>Buttons</h2>
            <div class="button-group">
              <sl-button>Default</sl-button>
              <sl-button variant="primary">Primary</sl-button>
              <sl-button variant="success">Success</sl-button>
              <sl-button variant="neutral">Neutral</sl-button>
              <sl-button variant="warning">Warning</sl-button>
              <sl-button variant="danger">Danger</sl-button>
            </div>
            
            <div class="button-group">
              <sl-button size="small">Small</sl-button>
              <sl-button size="medium">Medium</sl-button>
              <sl-button size="large">Large</sl-button>
            </div>
            
            <div class="button-group">
              <sl-button circle><sl-icon name="gear"></sl-icon></sl-button>
              <sl-button pill>Pill Button</sl-button>
              <sl-button loading>Loading</sl-button>
              <sl-button disabled>Disabled</sl-button>
            </div>
          </section>
          
          <section class="component-section">
            <h2>Form Controls</h2>
            <div style="display: flex; flex-direction: column; gap: 1rem; max-width: 400px;">
              <sl-input label="Name" help-text="Enter your full name" placeholder="John Doe"></sl-input>
              <sl-input type="email" label="Email" help-text="Enter a valid email address" placeholder="john@example.com"></sl-input>
              <sl-textarea label="Comment" help-text="Enter your comment here" placeholder="Type your comment..."></sl-textarea>
              <sl-select label="Select an option">
                <sl-option value="option-1">Option 1</sl-option>
                <sl-option value="option-2">Option 2</sl-option>
                <sl-option value="option-3">Option 3</sl-option>
              </sl-select>
              <sl-checkbox>I agree to the terms and conditions</sl-checkbox>
            </div>
          </section>
        </div>
        
        <div>
          <section class="component-section">
            <h2>Card</h2>
            <sl-card class="card-demo">
              <img 
                slot="image" 
                src="https://images.unsplash.com/photo-1559209172-0ff8f6d49ff7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" 
                alt="A peaceful mountain landscape" 
              />
              <strong>Card Title</strong>
              <small>This is a description of the card and demonstrates the basic card component from Shoelace.</small>
              <div slot="footer">
                <sl-button variant="primary">Learn More</sl-button>
                <sl-button variant="neutral">Cancel</sl-button>
              </div>
            </sl-card>
          </section>
          
          <section class="component-section">
            <h2>Tabs</h2>
            <sl-tab-group>
              <sl-tab slot="nav" panel="general">General</sl-tab>
              <sl-tab slot="nav" panel="custom">Custom</sl-tab>
              <sl-tab slot="nav" panel="advanced">Advanced</sl-tab>
              <sl-tab-panel name="general">This is the general tab panel. You can put any content here.</sl-tab-panel>
              <sl-tab-panel name="custom">This is the custom tab panel. You can customize the appearance of tabs.</sl-tab-panel>
              <sl-tab-panel name="advanced">This is the advanced tab panel. You can build complex interfaces with tabs.</sl-tab-panel>
            </sl-tab-group>
          </section>
          
          <section class="component-section">
            <h2>Dialog</h2>
            <sl-button id="open-dialog">Open Dialog</sl-button>
            <sl-dialog label="Dialog Example" class="dialog-example">
              <p>This is a dialog component that can be used for modals, alerts, and other interactive elements.</p>
              <p>Dialogs are displayed in the top layer and are stacked in order of creation.</p>
              <div slot="footer">
                <sl-button variant="primary" id="close-dialog">Close</sl-button>
              </div>
            </sl-dialog>
          </section>
          
          <section class="component-section">
            <h2>Alert</h2>
            <sl-alert variant="primary" open>
              <sl-icon slot="icon" name="info-circle"></sl-icon>
              <strong>This is a primary alert.</strong><br>
              It draws attention to important information.
            </sl-alert>
          </section>
        </div>
      </div>
    </main>
    
    <footer style="margin-top: 2rem; border-top: 1px solid #eee; padding-top: 1rem;">
      <p>
        Learn more about <a href="https://shoelace.style/" target="_blank">Shoelace web components</a>.
      </p>
    </footer>
  </div>
  
  <!-- Load Shoelace components -->
  <script type="module">
    import '@shoelace-style/shoelace/dist/components/button/button.js';
    import '@shoelace-style/shoelace/dist/components/card/card.js';
    import '@shoelace-style/shoelace/dist/components/dialog/dialog.js';
    import '@shoelace-style/shoelace/dist/components/input/input.js';
    import '@shoelace-style/shoelace/dist/components/textarea/textarea.js';
    import '@shoelace-style/shoelace/dist/components/select/select.js';
    import '@shoelace-style/shoelace/dist/components/option/option.js';
    import '@shoelace-style/shoelace/dist/components/checkbox/checkbox.js';
    import '@shoelace-style/shoelace/dist/components/tab/tab.js';
    import '@shoelace-style/shoelace/dist/components/tab-group/tab-group.js';
    import '@shoelace-style/shoelace/dist/components/tab-panel/tab-panel.js';
    import '@shoelace-style/shoelace/dist/components/alert/alert.js';
    import '@shoelace-style/shoelace/dist/components/icon/icon.js';
    
    // Set the base path to the folder where assets are copied
    import { setBasePath } from '@shoelace-style/shoelace/dist/utilities/base-path.js';
    setBasePath('./node_modules/@shoelace-style/shoelace/dist/');
    
    // Initialize the dialog
    const dialog = document.querySelector('.dialog-example');
    const openButton = document.querySelector('#open-dialog');
    const closeButton = document.querySelector('#close-dialog');
    
    openButton.addEventListener('click', () => dialog.show());
    closeButton.addEventListener('click', () => dialog.hide());
  </script>
</body>
</html>
EOF
      fi
      
      # Add a link to the Shoelace demo in index.html
      if [ -f "index.html" ]; then
        # Check if link already exists
        if ! grep -q "shoelace.html" "index.html"; then
          # Create a temporary file
          temp_file=$(mktemp)
          
          # Add the link to the navigation
          awk '{
            if ($0 ~ /<li><a href="[^"]*">Contact<\/a><\/li>/) {
              print $0
              print "        <li><a href=\"shoelace.html\">Shoelace Demo</a></li>"
            } else {
              print $0
            }
          }' "index.html" > "$temp_file"
          
          # Replace the file
          mv "$temp_file" "index.html"
        fi
      fi
      
      # Add shoelace to package.json scripts if it exists
      if [ -f "package.json" ]; then
        # Add a script to copy assets if needed
        npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "postinstall": "cp -r node_modules/@shoelace-style/shoelace/dist/assets public/assets" }' > /dev/null 2>&1
      fi
      ;;
      
    *)
      typewriter "❌ Unknown framework type for Shoelace setup: $framework_type" 0.02
      return 1
      ;;
  esac
  
  # Create a README section with instructions
  if [ -f "README.md" ]; then
    cat >> README.md << 'EOF'

## Shoelace Web Components

This project uses Shoelace, a collection of framework-agnostic web components.

### Usage Examples

```html
<!-- Button component -->
<sl-button variant="primary">Click me</sl-button>

<!-- Input component -->
<sl-input label="Name" help-text="Enter your name"></sl-input>

<!-- Card component -->
<sl-card>
  <strong>Card Title</strong>
  <div slot="footer">
    <sl-button variant="primary">Action</sl-button>
  </div>
</sl-card>
```

For more components and documentation, visit the [Shoelace website](https://shoelace.style/).
EOF
  fi
  
  # Success message
  rainbow_box "✅ Shoelace Web Components set up successfully!"
  echo "$(display_success "$THEME")"
  
  return 0
}