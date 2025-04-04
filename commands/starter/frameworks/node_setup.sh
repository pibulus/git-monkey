#!/bin/bash

# Set directory paths for consistent imports
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
# Get current theme
THEME=$(get_selected_theme)
#!/bin/bash

# ========= NODE.JS SETUP MODULE =========
# Sets up a new Node.js project with Express

setup_node() {
  local project_name="$1"
  local project_path="$2"
  local with_express="${3:-true}"
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up a Node.js project." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Friendly intro
  typewriter "🚀 Setting up a Node.js project" 0.02
  [ "$with_express" = true ] && typewriter "💡 Including Express.js for building web backends" 0.02
  echo ""
  
  # Navigate to parent directory
  cd "$(dirname "$project_path")" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Initialize package.json
  typewriter "Initializing package.json..." 0.02
  
  if [ "$HEADLESS_MODE" = true ]; then
    # Non-interactive initialization
    npm init -y > /dev/null
  else
    # Interactive mode with guidance
    echo "✨ Let's set up your package.json file."
    echo "You'll need to answer a few questions (press Enter for defaults)."
    echo ""
    echo "Recommended:"
    echo "- Give it a clear name and description"
    echo "- Set the entry point (default: index.js)"
    echo "- Add your name as the author"
    echo ""
    read -p "Press Enter to continue..." 
    echo ""
    
    npm init
  fi
  
  # Check if initialization was successful
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Something went wrong initializing package.json." 0.02
    return 1
  fi
  
  # Add Express if requested
  if [ "$with_express" = true ]; then
    typewriter "Installing Express.js..." 0.02
    npm install express > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
      typewriter "$(display_error "$THEME") Something went wrong installing Express." 0.02
      return 1
    fi
    
    # Create a basic Express app template
    cat > index.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.send('Hello from Express! 🚀');
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

    # Add start script to package.json
    npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "start": "node index.js", "dev": "nodemon index.js" }' > /dev/null 2>&1
    
    # Add development dependency: nodemon
    npm install -D nodemon > /dev/null 2>&1
  else
    # Create a minimal Node.js starter
    cat > index.js << 'EOF'
// Node.js starter script
console.log('Hello, Node.js! 🚀');

// Your code starts here
function main() {
  console.log('Program started');
  // TODO: Add your application logic here
}

main();
EOF
    
    # Add start script to package.json
    npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "start": "node index.js" }' > /dev/null 2>&1
  fi
  
  # Create .gitignore
  cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Editor directories and files
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# OS files
.DS_Store
Thumbs.db
EOF
  
  # Success message
  if [ "$with_express" = true ]; then
    rainbow_box "✅ Node.js + Express project created successfully!"
  else
    rainbow_box "✅ Node.js project created successfully!"
  fi
  echo "$(display_success "$THEME")"
  
  return 0
}