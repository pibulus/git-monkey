#!/bin/bash

# ========= ESLINT & PRETTIER SETUP MODULE =========
# Sets up ESLint and Prettier in a project

setup_eslint_prettier() {
  local project_path="$1"
  local framework_type="$2"  # svelte, node, or static
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up ESLint and Prettier." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(random_fail)"
    return 1
  }
  
  # Friendly intro
  typewriter "🧹 Setting up ESLint and Prettier - code quality tools" 0.02
  typewriter "💡 This will help you write cleaner, more consistent code" 0.02
  echo ""
  
  # Different setup based on framework
  case "$framework_type" in
    svelte)
      # For SvelteKit, ESLint might already be installed
      if [ ! -f ".eslintrc.cjs" ] && [ ! -f ".eslintrc.js" ] && [ ! -f ".eslintrc.json" ]; then
        typewriter "Installing ESLint with Svelte configuration..." 0.02
        npm install -D eslint eslint-plugin-svelte > /dev/null 2>&1
        
        # Create ESLint config
        cat > .eslintrc.cjs << 'EOF'
module.exports = {
  root: true,
  extends: [
    'eslint:recommended',
    'plugin:svelte/recommended'
  ],
  parserOptions: {
    sourceType: 'module',
    ecmaVersion: 2020,
    extraFileExtensions: ['.svelte']
  },
  env: {
    browser: true,
    es2017: true,
    node: true
  },
  rules: {
    // Your custom rules here
  }
};
EOF
      else
        typewriter "ESLint configuration already exists." 0.02
      fi
      
      # Set up Prettier if not already there
      if [ ! -f ".prettierrc" ] && [ ! -f ".prettierrc.js" ] && [ ! -f ".prettierrc.json" ]; then
        typewriter "Installing Prettier with Svelte configuration..." 0.02
        npm install -D prettier prettier-plugin-svelte > /dev/null 2>&1
        
        # Create Prettier config
        cat > .prettierrc << 'EOF'
{
  "singleQuote": true,
  "trailingComma": "none",
  "printWidth": 100,
  "plugins": ["prettier-plugin-svelte"],
  "pluginSearchDirs": ["."],
  "overrides": [{ "files": "*.svelte", "options": { "parser": "svelte" } }]
}
EOF
      else
        typewriter "Prettier configuration already exists." 0.02
      fi
      
      # Add format script if not already in package.json
      if [ -f "package.json" ]; then
        if ! grep -q "\"format\":" "package.json"; then
          npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "format": "prettier --write ." }' > /dev/null 2>&1
        fi
      fi
      ;;
      
    node)
      # For Node.js projects
      typewriter "Installing ESLint with Node.js configuration..." 0.02
      npm install -D eslint > /dev/null 2>&1
      
      # Create ESLint config
      cat > .eslintrc.json << 'EOF'
{
  "env": {
    "node": true,
    "commonjs": true,
    "es2021": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": "latest"
  },
  "rules": {
    "indent": ["error", 2],
    "linebreak-style": ["error", "unix"],
    "quotes": ["error", "single"],
    "semi": ["error", "always"],
    "no-unused-vars": ["warn"],
    "no-console": ["warn", { "allow": ["info", "warn", "error"] }]
  }
}
EOF
      
      # Set up Prettier
      typewriter "Installing Prettier..." 0.02
      npm install -D prettier > /dev/null 2>&1
      
      # Create Prettier config
      cat > .prettierrc << 'EOF'
{
  "singleQuote": true,
  "trailingComma": "none",
  "printWidth": 100
}
EOF
      
      # Add scripts to package.json
      if [ -f "package.json" ]; then
        npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "lint": "eslint .", "format": "prettier --write ." }' > /dev/null 2>&1
      fi
      
      # Create .eslintignore
      cat > .eslintignore << 'EOF'
node_modules/
dist/
build/
EOF
      
      # Create .prettierignore
      cat > .prettierignore << 'EOF'
node_modules/
dist/
build/
package-lock.json
EOF
      ;;
      
    static)
      # For static sites, set up for HTML/CSS/JS
      typewriter "Installing ESLint with HTML/CSS/JS configuration..." 0.02
      npm install -D eslint eslint-plugin-html > /dev/null 2>&1
      
      # Create ESLint config
      cat > .eslintrc.json << 'EOF'
{
  "env": {
    "browser": true,
    "es2021": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": "latest"
  },
  "plugins": ["html"],
  "rules": {
    "indent": ["error", 2],
    "linebreak-style": ["error", "unix"],
    "quotes": ["error", "single"],
    "semi": ["error", "always"]
  }
}
EOF
      
      # Set up Prettier
      typewriter "Installing Prettier..." 0.02
      npm install -D prettier > /dev/null 2>&1
      
      # Create Prettier config
      cat > .prettierrc << 'EOF'
{
  "singleQuote": true,
  "trailingComma": "none",
  "printWidth": 100,
  "tabWidth": 2,
  "semi": true
}
EOF
      
      # Add package.json if it doesn't exist
      if [ ! -f "package.json" ]; then
        npm init -y > /dev/null 2>&1
      fi
      
      # Add scripts to package.json
      npx json -I -f package.json -e 'this.scripts = { ...this.scripts, "lint": "eslint .", "format": "prettier --write ." }' > /dev/null 2>&1
      
      # Create .eslintignore
      cat > .eslintignore << 'EOF'
node_modules/
dist/
build/
EOF
      
      # Create .prettierignore
      cat > .prettierignore << 'EOF'
node_modules/
dist/
build/
EOF
      ;;
      
    *)
      typewriter "❌ Unknown framework type for ESLint & Prettier setup: $framework_type" 0.02
      return 1
      ;;
  esac
  
  # Check if installation was successful
  if [ $? -ne 0 ]; then
    typewriter "$(random_fail) Something went wrong installing ESLint and Prettier." 0.02
    return 1
  fi
  
  # Create VS Code settings to use ESLint and Prettier
  mkdir -p .vscode
  
  cat > .vscode/settings.json << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
EOF
  
  # Success message
  rainbow_box "✅ ESLint and Prettier set up successfully!"
  echo "$(random_success)"
  
  return 0
}