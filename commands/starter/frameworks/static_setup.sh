#!/bin/bash

# Set directory paths for consistent imports
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
# Get current theme
THEME=$(get_selected_theme)
#!/bin/bash

# ========= STATIC SITE SETUP MODULE =========
# Sets up a new static HTML/CSS/JS project

setup_static() {
  local project_name="$1"
  local project_path="$2"
  
  # Friendly intro
  typewriter "🚀 Setting up a static site project" 0.02
  typewriter "💡 Pure HTML, CSS, and JavaScript goodness" 0.02
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
  
  # Create basic structure
  mkdir -p css js images
  
  # Create index.html with a modern template
  cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>My Awesome Site</title>
  <link rel="stylesheet" href="css/styles.css">
  <meta name="description" content="A beautiful static site created with Git Monkey">
</head>
<body>
  <header>
    <nav>
      <a href="/" class="logo">My Site</a>
      <ul>
        <li><a href="#">Home</a></li>
        <li><a href="#">About</a></li>
        <li><a href="#">Contact</a></li>
      </ul>
    </nav>
  </header>

  <main>
    <section class="hero">
      <h1>Welcome to My Site</h1>
      <p>A beautiful start to something amazing.</p>
    </section>
    
    <section class="content">
      <h2>About This Project</h2>
      <p>This is a static site created with Git Monkey's project starter.</p>
      <p>Edit the HTML, CSS, and JavaScript files to make it your own!</p>
    </section>
  </main>

  <footer>
    <p>&copy; 2025 My Awesome Site. Created with ❤️ using Git Monkey.</p>
  </footer>

  <script src="js/main.js"></script>
</body>
</html>
EOF
  
  # Create a basic CSS file
  cat > css/styles.css << 'EOF'
/* Base styles */
:root {
  --primary-color: #6366f1;
  --text-color: #1f2937;
  --background-color: #ffffff;
  --accent-color: #8b5cf6;
  --muted-color: #9ca3af;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  line-height: 1.6;
  color: var(--text-color);
  background-color: var(--background-color);
}

/* Layout */
header, main, footer {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

/* Navigation */
nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

nav ul {
  display: flex;
  list-style: none;
}

nav ul li {
  margin-left: 2rem;
}

nav a {
  text-decoration: none;
  color: var(--text-color);
  font-weight: 500;
}

nav a:hover {
  color: var(--primary-color);
}

.logo {
  font-size: 1.5rem;
  font-weight: bold;
  color: var(--primary-color);
}

/* Hero section */
.hero {
  padding: 4rem 0;
  text-align: center;
}

.hero h1 {
  font-size: 3rem;
  margin-bottom: 1rem;
  color: var(--primary-color);
}

/* Content section */
.content {
  padding: 2rem 0;
}

.content h2 {
  margin-bottom: 1rem;
  color: var(--text-color);
}

.content p {
  margin-bottom: 1rem;
}

/* Footer */
footer {
  text-align: center;
  color: var(--muted-color);
  padding: 2rem;
  margin-top: 2rem;
  border-top: 1px solid #f3f4f6;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  nav {
    flex-direction: column;
  }
  
  nav ul {
    margin-top: 1rem;
  }
  
  nav ul li {
    margin-left: 1rem;
    margin-right: 1rem;
  }
  
  .hero h1 {
    font-size: 2rem;
  }
}
EOF
  
  # Create a simple JS file
  cat > js/main.js << 'EOF'
// Main JavaScript file

// Wait for the DOM to be fully loaded
document.addEventListener('DOMContentLoaded', () => {
  console.log('Static site loaded! 🚀');
  
  // Add a simple animation to the h1
  const h1 = document.querySelector('h1');
  if (h1) {
    h1.style.opacity = '0';
    h1.style.transition = 'opacity 1s ease-in-out';
    
    setTimeout(() => {
      h1.style.opacity = '1';
    }, 300);
  }
  
  // Add your JavaScript code here
});
EOF
  
  # Create a README.md
  cat > README.md << EOF
# $project_name

A static website project created with Git Monkey.

## Getting Started

Just open \`index.html\` in your browser to view the site.

## Structure

- \`index.html\` - Main HTML file
- \`css/styles.css\` - Stylesheet
- \`js/main.js\` - JavaScript file
- \`images/\` - Directory for images

## Development

Edit the HTML, CSS, and JavaScript files to build your site.

You can use a local server for better development experience:
- Using Python: \`python -m http.server\`
- Using Node.js: \`npx serve\`
EOF
  
  # Create .gitignore
  cat > .gitignore << 'EOF'
# System Files
.DS_Store
Thumbs.db

# Editor directories and files
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# Logs
*.log
EOF
  
  # Success message
  rainbow_box "✅ Static site project created successfully!"
  echo "$(display_success "$THEME")"
  
  return 0
}