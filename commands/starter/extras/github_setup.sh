#!/bin/bash

# ========= GITHUB SETUP MODULE =========
# Sets up a GitHub repository for a project

setup_github() {
  local project_name="$1"
  local project_path="$2"
  local is_private="${3:-false}"
  
  # Check if git is installed
  if ! check_command "git"; then
    typewriter "❌ Git is required to set up a GitHub repository." 0.02
    typewriter "Please install Git from https://git-scm.com" 0.02
    return 1
  }
  
  # Check if GitHub CLI is installed
  if ! check_command "gh"; then
    typewriter "❌ GitHub CLI is required for this setup." 0.02
    typewriter "Please install gh from https://cli.github.com" 0.02
    typewriter "💡 You can also manually create a repo on GitHub and push to it." 0.02
    return 1
  }
  
  # Check if already authenticated with GitHub
  if ! gh auth status &> /dev/null; then
    typewriter "You need to authenticate with GitHub CLI first." 0.02
    typewriter "Let's log you in..." 0.02
    gh auth login
    
    if [ $? -ne 0 ]; then
      typewriter "$(display_error "$THEME") GitHub authentication failed." 0.02
      return 1
    fi
  fi
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Friendly intro
  typewriter "🐙 Setting up a GitHub repository for your project" 0.02
  typewriter "💡 This will create a remote repo and push your code" 0.02
  echo ""
  
  # Initialize git if not already done
  if [ ! -d ".git" ]; then
    typewriter "Initializing git repository..." 0.02
    git init > /dev/null
  else
    typewriter "Git repository already initialized." 0.02
  fi
  
  # Check if there's a remote repository already
  if git remote get-url origin &> /dev/null; then
    typewriter "⚠️ This repo already has a remote origin configured." 0.02
    typewriter "Remote URL: $(git remote get-url origin)" 0.02
    
    read -p "Do you want to create a new GitHub repo anyway? (y/n): " create_new
    if [[ ! "$create_new" =~ ^[Yy]$ ]]; then
      typewriter "Skipping GitHub repository creation." 0.02
      return 0
    fi
  fi
  
  # Create .gitignore if it doesn't exist
  if [ ! -f ".gitignore" ]; then
    typewriter "Creating a basic .gitignore file..." 0.02
    
    cat > .gitignore << 'EOF'
# Dependency directories
node_modules/
vendor/

# Build outputs
dist/
build/

# Environment variables
.env
.env.local
.env.*

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db
EOF
  fi
  
  # Create GitHub repository
  typewriter "Creating GitHub repository: $project_name..." 0.02
  
  if [ "$is_private" = true ]; then
    gh repo create "$project_name" --private --source=. --remote=origin
  else
    gh repo create "$project_name" --public --source=. --remote=origin
  fi
  
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Failed to create GitHub repository." 0.02
    return 1
  fi
  
  # Stage all files
  typewriter "Staging all files..." 0.02
  git add . > /dev/null
  
  # Create initial commit if there isn't one
  if ! git rev-parse --verify HEAD &> /dev/null; then
    typewriter "Creating initial commit..." 0.02
    git commit -m "Initial commit" > /dev/null
  else
    typewriter "Repository already has commits." 0.02
  fi
  
  # Push to GitHub
  typewriter "Pushing to GitHub..." 0.02
  git push -u origin main > /dev/null 2>&1 || git push -u origin master > /dev/null 2>&1
  
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Failed to push to GitHub." 0.02
    typewriter "You might need to manually push with 'git push -u origin main'" 0.02
    return 1
  fi
  
  # Create a good readme if it doesn't exist or is minimal
  if [ ! -f "README.md" ] || [ $(wc -l < README.md) -lt 5 ]; then
    typewriter "Creating a detailed README.md..." 0.02
    
    cat > README.md << EOF
# $project_name

## Description

A project created with Git Monkey.

## Features

- [Add your features here]

## Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$(gh api user | jq -r .login)/$project_name.git

# Navigate to the project directory
cd $project_name

# Install dependencies
npm install
\`\`\`

## Usage

[Add usage instructions here]

## Contributing

1. Fork the Project
2. Create your Feature Branch (\`git checkout -b feature/AmazingFeature\`)
3. Commit your Changes (\`git commit -m 'Add some AmazingFeature'\`)
4. Push to the Branch (\`git push origin feature/AmazingFeature\`)
5. Open a Pull Request

## License

[Add license information here]

## Acknowledgments

- Created with [Git Monkey](https://github.com/yourname/git-monkey)
EOF
    
    # Commit and push the README
    git add README.md > /dev/null
    git commit -m "Add detailed README" > /dev/null
    git push > /dev/null
  fi
  
  # Get the repo URL
  REPO_URL=$(gh repo view --json url -q .url)
  
  # Success message
  rainbow_box "✅ GitHub repository created successfully!"
  echo "🔗 Repository URL: $REPO_URL"
  echo "$(display_success "$THEME")"
  
  return 0
}