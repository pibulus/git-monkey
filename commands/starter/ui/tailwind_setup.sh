#!/bin/bash

# ========= TAILWIND CSS SETUP MODULE =========
# Sets up Tailwind CSS in a project

setup_tailwind() {
  local project_path="$1"
  local framework_type="$2"  # svelte, node, or static
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up Tailwind CSS." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Friendly intro
  typewriter "🎨 Setting up Tailwind CSS - utility-first CSS framework" 0.02
  typewriter "💡 This will add clean, minimal styling to your project" 0.02
  echo ""
  
  # Install Tailwind CSS
  typewriter "Installing Tailwind CSS and dependencies..." 0.02
  
  # Different setup based on framework
  case "$framework_type" in
    svelte)
      # Tailwind for SvelteKit
      npm install -D tailwindcss postcss autoprefixer > /dev/null 2>&1
      npx tailwindcss init -p > /dev/null 2>&1
      
      # Update tailwind.config.js
      cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF
      
      # Add global.css file if it doesn't exist
      if [ ! -f "./src/app.css" ] && [ -d "./src" ]; then
        # Create or update the global CSS file
        cat > ./src/app.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Your custom CSS here */
EOF
        
        # Ensure it's imported in layout
        if [ -f "./src/routes/+layout.svelte" ]; then
          # Check if import exists
          if ! grep -q "import '../app.css'" "./src/routes/+layout.svelte"; then
            # Create a temporary file
            temp_file=$(mktemp)
            echo '<script>
  import "../app.css";
</script>

<slot />' > "$temp_file"
            
            # If the file has content, try to preserve it
            if [ -s "./src/routes/+layout.svelte" ]; then
              if grep -q "<slot" "./src/routes/+layout.svelte"; then
                # File already has content, just add the import
                sed -i '1s/^/<script>\n  import "..\/app.css";\n<\/script>\n\n/' "./src/routes/+layout.svelte"
              else
                # Replace the file
                mv "$temp_file" "./src/routes/+layout.svelte"
              fi
            else
              # File is empty or doesn't exist
              mv "$temp_file" "./src/routes/+layout.svelte"
            fi
          fi
        elif [ -d "./src/routes" ]; then
          # Create the layout file
          mkdir -p "./src/routes"
          cat > "./src/routes/+layout.svelte" << 'EOF'
<script>
  import "../app.css";
</script>

<slot />
EOF
        fi
      fi
      ;;
      
    node)
      # For Node/Express projects we'll create a public folder with CSS
      npm install -D tailwindcss postcss autoprefixer > /dev/null 2>&1
      npx tailwindcss init -p > /dev/null 2>&1
      
      # Create src and public directories if they don't exist
      mkdir -p src/css public/css
      
      # Create input CSS file
      cat > src/css/styles.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Your custom styles below */
EOF
      
      # Update tailwind.config.js
      cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,js,ejs}', './public/**/*.{html,js}'],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF
      
      # Add build script to package.json
      npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "build:css": "tailwindcss -i ./src/css/styles.css -o ./public/css/styles.css", "watch:css": "tailwindcss -i ./src/css/styles.css -o ./public/css/styles.css --watch" }' > /dev/null 2>&1
      
      # Build the CSS file
      npx tailwindcss -i ./src/css/styles.css -o ./public/css/styles.css > /dev/null 2>&1
      
      # If there's an Express app, link to the CSS
      if [ -f "index.js" ]; then
        # Check if express.static is already set
        if ! grep -q "express.static" "index.js"; then
          # Add static middleware before the routes
          sed -i '/app.use/a app.use(express.static("public"));' "index.js"
        fi
      fi
      ;;
      
    static)
      # For static sites
      npm install -D tailwindcss postcss autoprefixer > /dev/null 2>&1
      npx tailwindcss init -p > /dev/null 2>&1
      
      # Create src directory if it doesn't exist
      mkdir -p src
      
      # Move the existing CSS to src if needed
      if [ -f "css/styles.css" ]; then
        mv css/styles.css src/styles.css
      fi
      
      # Create input CSS file
      cat > src/styles.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Your custom styles below */
EOF
      
      # Update tailwind.config.js
      cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./*.html'],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF
      
      # Add build scripts to package.json
      if [ ! -f "package.json" ]; then
        # Create a minimal package.json
        npm init -y > /dev/null 2>&1
      fi
      
      # Update package.json
      npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "build:css": "tailwindcss -i ./src/styles.css -o ./css/styles.css", "watch:css": "tailwindcss -i ./src/styles.css -o ./css/styles.css --watch" }' > /dev/null 2>&1
      
      # Build the CSS file
      npx tailwindcss -i ./src/styles.css -o ./css/styles.css > /dev/null 2>&1
      
      # Update index.html to point to the new CSS if needed
      if [ -f "index.html" ]; then
        # Make sure it links to the right CSS
        sed -i 's|href="styles.css"|href="css/styles.css"|g' index.html
        sed -i 's|href="./styles.css"|href="css/styles.css"|g' index.html
      fi
      ;;
      
    *)
      typewriter "❌ Unknown framework type for Tailwind setup: $framework_type" 0.02
      return 1
      ;;
  esac
  
  # Check if installation was successful
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Something went wrong installing Tailwind CSS." 0.02
    return 1
  fi
  
  # Success message
  rainbow_box "✅ Tailwind CSS set up successfully!"
  echo "$(display_success "$THEME")"
  
  return 0
}