#!/bin/bash

# ========= DAISYUI SETUP MODULE =========
# Sets up DaisyUI with Tailwind CSS

setup_daisyui() {
  local project_path="$1"
  local framework_type="$2"  # svelte, node, or static
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up DaisyUI." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Friendly intro
  typewriter "🌼 Setting up DaisyUI - component library for Tailwind CSS" 0.02
  typewriter "💡 This will add beautiful, customizable components to your project" 0.02
  echo ""
  
  # Check if Tailwind is set up
  if [ ! -f "tailwind.config.js" ]; then
    typewriter "❌ Tailwind CSS needs to be set up first. Let's do that..." 0.02
    setup_tailwind "$project_path" "$framework_type"
  fi
  
  # Install DaisyUI
  typewriter "Installing DaisyUI..." 0.02
  npm install -D daisyui@latest > /dev/null 2>&1
  
  # Check if installation was successful
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Something went wrong installing DaisyUI." 0.02
    return 1
  fi
  
  # Update tailwind.config.js
  typewriter "Configuring DaisyUI in Tailwind..." 0.02
  
  # Create a temporary file
  temp_config=$(mktemp)
  
  # Read the existing config
  if [ -f "tailwind.config.js" ]; then
    # Check if daisyui is already in plugins
    if grep -q "daisyui" "tailwind.config.js"; then
      typewriter "🔍 DaisyUI is already configured in tailwind.config.js." 0.02
    else
      # Add daisyui to plugins
      awk '{
        if ($0 ~ /plugins: \[\]/) {
          print "  plugins: [require(\"daisyui\")],"
        } else if ($0 ~ /plugins: \[/) {
          gsub(/plugins: \[/, "plugins: [require(\"daisyui\"),")
          print $0
        } else {
          print $0
        }
      }' "tailwind.config.js" > "$temp_config"
      
      # Add themes configuration if not present
      if ! grep -q "daisyui:" "$temp_config"; then
        awk '{
          if ($0 ~ /theme: \{/) {
            print $0
            print "    extend: {},"
            print "  },"
            print "  daisyui: {"
            print "    themes: [\"light\", \"dark\", \"cupcake\"],"
            print "  },"
          } else if ($0 ~ /extend: \{\},/) {
            print $0
            print "  },"
            print "  daisyui: {"
            print "    themes: [\"light\", \"dark\", \"cupcake\"],"
            print "  },"
          } else {
            print $0
          }
        }' "$temp_config" > "tailwind.config.js"
      else
        # Config already has daisyui section
        mv "$temp_config" "tailwind.config.js"
      fi
    fi
  else
    # If tailwind.config.js doesn't exist, create it
    cat > "tailwind.config.js" << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./**/*.{html,js,svelte,ts,jsx,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "dark", "cupcake"],
  },
}
EOF
  fi
  
  # Clean up temporary file if it exists
  [ -f "$temp_config" ] && rm "$temp_config"
  
  # Create demo component examples based on framework
  case "$framework_type" in
    svelte)
      # For SvelteKit, add a components directory with examples
      mkdir -p src/lib/components
      
      # Create a button component
      cat > src/lib/components/Button.svelte << 'EOF'
<script>
  export let variant = 'primary';
  export let size = 'md';
  export let type = 'button';
</script>

<button
  {type}
  class="btn btn-{variant} btn-{size}"
  on:click
>
  <slot>Button</slot>
</button>
EOF
      
      # Create a card component
      cat > src/lib/components/Card.svelte << 'EOF'
<script>
  export let title = 'Card Title';
  export let imageUrl = '';
</script>

<div class="card w-full bg-base-100 shadow-xl">
  {#if imageUrl}
    <figure><img src={imageUrl} alt={title} /></figure>
  {/if}
  <div class="card-body">
    <h2 class="card-title">{title}</h2>
    <div>
      <slot>Card content goes here</slot>
    </div>
    <div class="card-actions justify-end">
      <slot name="actions">
        <button class="btn btn-primary">Action</button>
      </slot>
    </div>
  </div>
</div>
EOF
      
      # Update a route to show examples if it exists
      if [ -f "src/routes/+page.svelte" ]; then
        # Create a temporary file
        temp_file=$(mktemp)
        
        # Create example page
        cat > "$temp_file" << 'EOF'
<script>
  import Button from '$lib/components/Button.svelte';
  import Card from '$lib/components/Card.svelte';
</script>

<div class="container mx-auto p-4">
  <h1 class="text-3xl font-bold mb-8">DaisyUI Components</h1>
  
  <div class="mb-8">
    <h2 class="text-2xl font-semibold mb-4">Buttons</h2>
    <div class="flex flex-wrap gap-2">
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="accent">Accent</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="link">Link</Button>
    </div>
  </div>
  
  <div class="mb-8">
    <h2 class="text-2xl font-semibold mb-4">Cards</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <Card title="Welcome to DaisyUI">
        <p>This is a simple card component using DaisyUI.</p>
        <svelte:fragment slot="actions">
          <button class="btn btn-primary">Get Started</button>
        </svelte:fragment>
      </Card>
      
      <Card 
        title="Card with Image" 
        imageUrl="https://daisyui.com/images/stock/photo-1606107557195-0e29a4b5b4aa.jpg"
      >
        <p>This card includes an image from DaisyUI's sample images.</p>
      </Card>
      
      <Card title="Customizable">
        <p>You can customize cards with different content and actions.</p>
        <svelte:fragment slot="actions">
          <button class="btn btn-outline">Cancel</button>
          <button class="btn btn-accent">Accept</button>
        </svelte:fragment>
      </Card>
    </div>
  </div>
  
  <div class="text-center mt-8">
    <a href="https://daisyui.com/components/" class="link link-primary" target="_blank">
      Explore more DaisyUI components
    </a>
  </div>
</div>
EOF
        
        # Replace the page
        mv "$temp_file" "src/routes/+page.svelte"
      fi
      ;;
      
    node)
      # For Node/Express, add a views directory with examples
      mkdir -p views
      
      # Create an example EJS template if not exists
      if [ ! -f "views/index.ejs" ]; then
        cat > views/index.ejs << 'EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DaisyUI with Express</title>
  <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
  <div class="container mx-auto p-4">
    <h1 class="text-3xl font-bold mb-8">DaisyUI Components</h1>
    
    <div class="mb-8">
      <h2 class="text-2xl font-semibold mb-4">Buttons</h2>
      <div class="flex flex-wrap gap-2">
        <button class="btn btn-primary">Primary</button>
        <button class="btn btn-secondary">Secondary</button>
        <button class="btn btn-accent">Accent</button>
        <button class="btn btn-ghost">Ghost</button>
        <button class="btn btn-link">Link</button>
      </div>
    </div>
    
    <div class="mb-8">
      <h2 class="text-2xl font-semibold mb-4">Cards</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div class="card w-full bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">Welcome to DaisyUI</h2>
            <p>This is a simple card component using DaisyUI.</p>
            <div class="card-actions justify-end">
              <button class="btn btn-primary">Get Started</button>
            </div>
          </div>
        </div>
        
        <div class="card w-full bg-base-100 shadow-xl">
          <figure><img src="https://daisyui.com/images/stock/photo-1606107557195-0e29a4b5b4aa.jpg" alt="Card with Image"></figure>
          <div class="card-body">
            <h2 class="card-title">Card with Image</h2>
            <p>This card includes an image from DaisyUI's sample images.</p>
          </div>
        </div>
        
        <div class="card w-full bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">Customizable</h2>
            <p>You can customize cards with different content and actions.</p>
            <div class="card-actions justify-end">
              <button class="btn btn-outline">Cancel</button>
              <button class="btn btn-accent">Accept</button>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="text-center mt-8">
      <a href="https://daisyui.com/components/" class="link link-primary" target="_blank">
        Explore more DaisyUI components
      </a>
    </div>
  </div>
</body>
</html>
EOF
      fi
      
      # Update Express app to use EJS if not already set up
      if [ -f "index.js" ]; then
        # Check if express is imported
        if grep -q "express" "index.js"; then
          # Check if view engine is set
          if ! grep -q "view engine" "index.js"; then
            # Add view engine setup
            temp_file=$(mktemp)
            awk '{
              if ($0 ~ /const app = express\(\);/) {
                print $0
                print "app.set(\"view engine\", \"ejs\");"
                print "app.set(\"views\", \"./views\");"
              } else {
                print $0
              }
            }' "index.js" > "$temp_file"
            
            # Replace the file
            mv "$temp_file" "index.js"
          fi
          
          # Check if route for index exists
          if ! grep -q "res.render(" "index.js"; then
            # Update or add the root route
            temp_file=$(mktemp)
            awk '{
              if ($0 ~ /app.get\("\/"/) {
                print "app.get(\"/\", (req, res) => {"
                print "  res.render(\"index\");"
                print "});"
              } else if ($0 ~ /app.listen/) {
                print "app.get(\"/\", (req, res) => {"
                print "  res.render(\"index\");"
                print "});"
                print ""
                print $0
              } else {
                print $0
              }
            }' "index.js" > "$temp_file"
            
            # Replace the file
            mv "$temp_file" "index.js"
          fi
          
          # Install EJS
          npm install ejs > /dev/null 2>&1
        fi
      fi
      ;;
      
    static)
      # For static sites, update the index.html
      if [ -f "index.html" ]; then
        temp_file=$(mktemp)
        
        cat > "$temp_file" << 'EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>My Awesome Site with DaisyUI</title>
  <link rel="stylesheet" href="css/styles.css">
  <meta name="description" content="A beautiful static site created with Git Monkey and DaisyUI">
</head>
<body>
  <div class="navbar bg-base-100 shadow-md">
    <div class="flex-1">
      <a href="/" class="btn btn-ghost normal-case text-xl">My Site</a>
    </div>
    <div class="flex-none">
      <ul class="menu menu-horizontal px-1">
        <li><a href="#">Home</a></li>
        <li><a href="#">About</a></li>
        <li><a href="#">Contact</a></li>
      </ul>
    </div>
  </div>

  <main class="container mx-auto px-4 py-8">
    <section class="hero min-h-[50vh] bg-base-200 rounded-box mb-8">
      <div class="hero-content text-center">
        <div class="max-w-md">
          <h1 class="text-5xl font-bold">Welcome to My Site</h1>
          <p class="py-6">A beautiful start to something amazing, powered by DaisyUI.</p>
          <button class="btn btn-primary">Get Started</button>
        </div>
      </div>
    </section>
    
    <section class="mb-8">
      <h2 class="text-3xl font-bold mb-4">About This Project</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h3 class="card-title">DaisyUI Components</h3>
            <p>This static site uses DaisyUI, a component library for Tailwind CSS. It provides beautiful, customizable components that work out of the box.</p>
          </div>
        </div>
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h3 class="card-title">Getting Started</h3>
            <p>Edit the HTML and CSS files to create your own beautiful website. DaisyUI makes it easy with pre-built components like cards, buttons, and more.</p>
          </div>
        </div>
      </div>
    </section>
    
    <section class="mb-8">
      <h2 class="text-3xl font-bold mb-4">UI Components</h2>
      <div class="flex flex-wrap gap-2 mb-6">
        <button class="btn">Default</button>
        <button class="btn btn-primary">Primary</button>
        <button class="btn btn-secondary">Secondary</button>
        <button class="btn btn-accent">Accent</button>
        <button class="btn btn-ghost">Ghost</button>
        <button class="btn btn-link">Link</button>
      </div>
      
      <div class="flex flex-wrap gap-2">
        <div class="badge">Default</div>
        <div class="badge badge-primary">Primary</div>
        <div class="badge badge-secondary">Secondary</div>
        <div class="badge badge-accent">Accent</div>
        <div class="badge badge-outline">Outline</div>
      </div>
    </section>
  </main>

  <footer class="footer p-10 bg-base-200 text-base-content">
    <div>
      <span class="footer-title">Services</span> 
      <a class="link link-hover">Branding</a> 
      <a class="link link-hover">Design</a> 
      <a class="link link-hover">Marketing</a> 
    </div> 
    <div>
      <span class="footer-title">Company</span> 
      <a class="link link-hover">About us</a> 
      <a class="link link-hover">Contact</a> 
      <a class="link link-hover">Jobs</a> 
    </div> 
    <div>
      <span class="footer-title">Legal</span> 
      <a class="link link-hover">Terms of use</a> 
      <a class="link link-hover">Privacy policy</a> 
    </div>
  </footer>
  <footer class="footer footer-center p-4 bg-base-300 text-base-content">
    <div>
      <p>&copy; 2025 My Awesome Site. Created with ❤️ using Git Monkey and DaisyUI.</p>
      <div class="mt-2">
        <div class="dropdown dropdown-top">
          <label tabindex="0" class="btn btn-xs btn-ghost m-1">Change Theme</label>
          <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
            <li><a onclick="document.documentElement.setAttribute('data-theme', 'light')">Light</a></li>
            <li><a onclick="document.documentElement.setAttribute('data-theme', 'dark')">Dark</a></li>
            <li><a onclick="document.documentElement.setAttribute('data-theme', 'cupcake')">Cupcake</a></li>
          </ul>
        </div>
      </div>
    </div>
  </footer>

  <script src="js/main.js"></script>
</body>
</html>
EOF
        
        # Replace the HTML file
        mv "$temp_file" "index.html"
      fi
      ;;
      
    *)
      typewriter "❌ Unknown framework type for DaisyUI setup: $framework_type" 0.02
      return 1
      ;;
  esac
  
  # Success message
  rainbow_box "✅ DaisyUI set up successfully!"
  echo "$(display_success "$THEME")"
  
  return 0
}