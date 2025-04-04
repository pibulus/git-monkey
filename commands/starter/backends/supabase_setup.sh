#!/bin/bash

# Set directory paths for consistent imports
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"

# ========= SUPABASE SETUP MODULE =========
# Sets up Supabase in a project

setup_supabase() {
  local project_path="$1"
  local framework_type="$2"  # svelte, node, or static
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up Supabase." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Friendly intro
  typewriter "🔌 Setting up Supabase - open source Firebase alternative" 0.02
# Get current theme
THEME=$(get_selected_theme)
  typewriter "💡 This will add authentication, database, and storage capabilities" 0.02
  echo ""
  
  # Install Supabase client library
  typewriter "Installing Supabase client library..." 0.02
  
  # Different installation based on framework
  case "$framework_type" in
    svelte)
      # Install for SvelteKit
      npm install @supabase/supabase-js > /dev/null 2>&1
      
      # Create a lib/supabase.js file
      mkdir -p src/lib
      
      cat > src/lib/supabase.js << 'EOF'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
EOF
      
      # Create .env file with placeholders
      cat > .env << 'EOF'
# Supabase configuration
# Get these values from your Supabase project settings
VITE_SUPABASE_URL=https://your-project-url.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
EOF

      # Add .env to .gitignore if it's not already there
      if [ -f ".gitignore" ]; then
        if ! grep -q "^.env" ".gitignore"; then
          echo ".env" >> ".gitignore"
        fi
      else
        echo ".env" > ".gitignore"
      fi
      
      # Create an example auth component
      mkdir -p src/lib/components
      
      cat > src/lib/components/Auth.svelte << 'EOF'
<script>
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  
  let loading = false;
  let email = '';
  let password = '';
  let user = null;
  
  onMount(() => {
    // Get user from session
    user = supabase.auth.getSession().then(({ data }) => {
      user = data?.session?.user || null;
    });
    
    // Listen for auth changes
    const { data } = supabase.auth.onAuthStateChange((event, session) => {
      user = session?.user || null;
    });
  });
  
  async function handleSignUp() {
    try {
      loading = true;
      const { error } = await supabase.auth.signUp({ email, password });
      if (error) throw error;
      alert('Check your email for the login link!');
    } catch (error) {
      alert(error.message);
    } finally {
      loading = false;
    }
  }
  
  async function handleSignIn() {
    try {
      loading = true;
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;
    } catch (error) {
      alert(error.message);
    } finally {
      loading = false;
    }
  }
  
  async function handleSignOut() {
    try {
      loading = true;
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      user = null;
    } catch (error) {
      alert(error.message);
    } finally {
      loading = false;
    }
  }
</script>

<div class="auth-container">
  {#if user}
    <div class="user-info">
      <h2>Welcome, {user.email}</h2>
      <button on:click={handleSignOut} disabled={loading} class="btn btn-primary">
        {loading ? 'Loading...' : 'Sign Out'}
      </button>
    </div>
  {:else}
    <form class="auth-form">
      <h2>Login or Sign Up</h2>
      <div class="form-group">
        <label for="email">Email</label>
        <input
          id="email"
          type="email"
          placeholder="Your email"
          bind:value={email}
        />
      </div>
      <div class="form-group">
        <label for="password">Password</label>
        <input
          id="password"
          type="password"
          placeholder="Your password"
          bind:value={password}
        />
      </div>
      <div class="auth-buttons">
        <button
          on:click={handleSignIn}
          disabled={loading}
          class="btn btn-primary"
        >
          {loading ? 'Loading...' : 'Sign In'}
        </button>
        <button
          on:click={handleSignUp}
          disabled={loading}
          class="btn btn-outline"
        >
          {loading ? 'Loading...' : 'Sign Up'}
        </button>
      </div>
    </form>
  {/if}
</div>

<style>
  .auth-container {
    max-width: 400px;
    margin: 0 auto;
    padding: 2rem;
  }
  
  .auth-form, .user-info {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  
  .form-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .auth-buttons {
    display: flex;
    gap: 1rem;
    margin-top: 1rem;
  }
</style>
EOF
      
      # Create a README section with instructions
      if [ -f "README.md" ]; then
        cat >> README.md << 'EOF'

## Supabase Setup

This project uses Supabase for backend services. To set it up:

1. Create a Supabase project at https://supabase.com
2. Copy your project URL and anon key from the Supabase dashboard
3. Update the `.env` file with your values
4. Use the `supabase` client from `$lib/supabase.js` in your components

Examples:
```js
// Query data
const { data, error } = await supabase
  .from('table_name')
  .select('*')

// Insert data
const { data, error } = await supabase
  .from('table_name')
  .insert([{ column: 'value' }])
```

See the Auth component in `src/lib/components/Auth.svelte` for authentication examples.
EOF
      fi
      ;;
      
    node)
      # Install for Node.js
      npm install @supabase/supabase-js dotenv > /dev/null 2>&1
      
      # Create a utils directory if it doesn't exist
      mkdir -p utils
      
      # Create a supabase client file
      cat > utils/supabase.js << 'EOF'
require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseServiceKey);

module.exports = { supabase };
EOF
      
      # Create .env file with placeholders
      cat > .env << 'EOF'
# Supabase configuration
# Get these values from your Supabase project settings
SUPABASE_URL=https://your-project-url.supabase.co
SUPABASE_SERVICE_KEY=your-service-key
EOF
      
      # Add .env to .gitignore
      if [ -f ".gitignore" ]; then
        if ! grep -q "^.env" ".gitignore"; then
          echo ".env" >> ".gitignore"
        fi
      else
        echo ".env" > ".gitignore"
      fi
      
      # Create an example users route
      mkdir -p routes
      
      cat > routes/users.js << 'EOF'
const express = require('express');
const router = express.Router();
const { supabase } = require('../utils/supabase');

// Get all users
router.get('/', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('*');
      
    if (error) throw error;
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get a user by ID
router.get('/:id', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', req.params.id)
      .single();
      
    if (error) throw error;
    
    if (!data) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create a new user
router.post('/', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('users')
      .insert([req.body])
      .select();
      
    if (error) throw error;
    
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update a user
router.put('/:id', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('users')
      .update(req.body)
      .eq('id', req.params.id)
      .select();
      
    if (error) throw error;
    
    if (!data.length) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(data[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete a user
router.delete('/:id', async (req, res) => {
  try {
    const { error } = await supabase
      .from('users')
      .delete()
      .eq('id', req.params.id);
      
    if (error) throw error;
    
    res.status(204).end();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
EOF
      
      # Update the main app file to use the route
      if [ -f "index.js" ]; then
        # Check if express is imported
        if grep -q "express" "index.js"; then
          # Add the users route
          temp_file=$(mktemp)
          awk '{
            if ($0 ~ /const express = require/) {
              print $0
              print "const dotenv = require(\"dotenv\");"
              print "const usersRouter = require(\"./routes/users\");"
            } else if ($0 ~ /app.use\(express.json/) {
              print $0
              print "\n// Load environment variables"
              print "dotenv.config();"
              print "\n// Routes"
              print "app.use(\"/api/users\", usersRouter);"
            } else {
              print $0
            }
          }' "index.js" > "$temp_file"
          
          # Replace the file
          mv "$temp_file" "index.js"
        fi
      fi
      
      # Create a README section with instructions
      if [ -f "README.md" ]; then
        cat >> README.md << 'EOF'

## Supabase Setup

This project uses Supabase for backend services. To set it up:

1. Create a Supabase project at https://supabase.com
2. Copy your project URL and service key from the Supabase dashboard
3. Update the `.env` file with your values
4. Use the `supabase` client from `utils/supabase.js` in your routes

Examples:
```js
// Query data
const { data, error } = await supabase
  .from('table_name')
  .select('*')

// Insert data
const { data, error } = await supabase
  .from('table_name')
  .insert([{ column: 'value' }])
```

See the users router in `routes/users.js` for CRUD operation examples.
EOF
      fi
      ;;
      
    static)
      # Install for static sites
      # We'll use a direct CDN approach for simplicity
      
      # Create a js folder if it doesn't exist
      mkdir -p js
      
      # Create a supabase.js file for client-side use
      cat > js/supabase.js << 'EOF'
// Initialize the Supabase client
const supabaseUrl = 'https://your-project-url.supabase.co';
const supabaseAnonKey = 'your-anon-key';
const supabase = supabase.createClient(supabaseUrl, supabaseAnonKey);

// Authentication functions
async function signUp(email, password) {
  try {
    const { user, error } = await supabase.auth.signUp({ email, password });
    if (error) throw error;
    return { user };
  } catch (error) {
    return { error };
  }
}

async function signIn(email, password) {
  try {
    const { user, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return { user };
  } catch (error) {
    return { error };
  }
}

async function signOut() {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    return { success: true };
  } catch (error) {
    return { error };
  }
}

// Database functions
async function getItems() {
  try {
    const { data, error } = await supabase
      .from('items')
      .select('*');
    if (error) throw error;
    return { data };
  } catch (error) {
    return { error };
  }
}

async function addItem(item) {
  try {
    const { data, error } = await supabase
      .from('items')
      .insert([item])
      .select();
    if (error) throw error;
    return { data: data[0] };
  } catch (error) {
    return { error };
  }
}
EOF
      
      # Create a simple auth page
      cat > auth.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Authentication - My Site</title>
  <link rel="stylesheet" href="css/styles.css">
  <!-- Supabase JS from CDN -->
  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
</head>
<body>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-8">Authentication</h1>
    
    <div id="authContainer" class="max-w-md mx-auto">
      <!-- Auth UI will be rendered here -->
      <div id="loading">Loading...</div>
      
      <div id="signedOut" style="display: none;">
        <div class="mb-4">
          <label for="email" class="block mb-2">Email</label>
          <input type="email" id="email" class="w-full p-2 border rounded" placeholder="your@email.com">
        </div>
        <div class="mb-4">
          <label for="password" class="block mb-2">Password</label>
          <input type="password" id="password" class="w-full p-2 border rounded" placeholder="••••••••">
        </div>
        <div class="flex gap-2">
          <button id="signInButton" class="px-4 py-2 bg-blue-500 text-white rounded">Sign In</button>
          <button id="signUpButton" class="px-4 py-2 border rounded">Sign Up</button>
        </div>
      </div>
      
      <div id="signedIn" style="display: none;">
        <p>You are signed in as <span id="userEmail"></span></p>
        <button id="signOutButton" class="px-4 py-2 bg-red-500 text-white rounded mt-4">Sign Out</button>
      </div>
    </div>
  </div>
  
  <script>
    // Initialize Supabase client
    const supabaseUrl = 'https://your-project-url.supabase.co';
    const supabaseAnonKey = 'your-anon-key';
    const supabase = supabase.createClient(supabaseUrl, supabaseAnonKey);
    
    // DOM elements
    const loading = document.getElementById('loading');
    const signedOut = document.getElementById('signedOut');
    const signedIn = document.getElementById('signedIn');
    const userEmail = document.getElementById('userEmail');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const signInButton = document.getElementById('signInButton');
    const signUpButton = document.getElementById('signUpButton');
    const signOutButton = document.getElementById('signOutButton');
    
    // Check if user is signed in
    async function checkUser() {
      const { data } = await supabase.auth.getSession();
      const user = data?.session?.user;
      
      if (user) {
        // User is signed in
        signedOut.style.display = 'none';
        signedIn.style.display = 'block';
        userEmail.textContent = user.email;
      } else {
        // User is signed out
        signedOut.style.display = 'block';
        signedIn.style.display = 'none';
      }
      
      loading.style.display = 'none';
    }
    
    // Sign in
    signInButton.addEventListener('click', async () => {
      const email = emailInput.value;
      const password = passwordInput.value;
      
      loading.style.display = 'block';
      signedOut.style.display = 'none';
      
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      
      if (error) {
        alert(error.message);
        loading.style.display = 'none';
        signedOut.style.display = 'block';
      } else {
        checkUser();
      }
    });
    
    // Sign up
    signUpButton.addEventListener('click', async () => {
      const email = emailInput.value;
      const password = passwordInput.value;
      
      loading.style.display = 'block';
      signedOut.style.display = 'none';
      
      const { error } = await supabase.auth.signUp({ email, password });
      
      if (error) {
        alert(error.message);
        loading.style.display = 'none';
        signedOut.style.display = 'block';
      } else {
        alert('Check your email for a confirmation link!');
        loading.style.display = 'none';
        signedOut.style.display = 'block';
      }
    });
    
    // Sign out
    signOutButton.addEventListener('click', async () => {
      loading.style.display = 'block';
      signedIn.style.display = 'none';
      
      await supabase.auth.signOut();
      checkUser();
    });
    
    // Listen for auth changes
    supabase.auth.onAuthStateChange((event, session) => {
      checkUser();
    });
    
    // Initial check
    checkUser();
  </script>
</body>
</html>
EOF
      
      # Add a link to the auth page in the index.html
      if [ -f "index.html" ]; then
        temp_file=$(mktemp)
        
        # Update the navigation
        awk '{
          if ($0 ~ /<li><a href="#">Contact<\/a><\/li>/) {
            print $0
            print "        <li><a href=\"auth.html\">Sign In</a></li>"
          } else {
            print $0
          }
        }' "index.html" > "$temp_file"
        
        # Replace the file
        mv "$temp_file" "index.html"
      fi
      
      # Create a README section with instructions
      if [ -f "README.md" ]; then
        cat >> README.md << 'EOF'

## Supabase Setup

This project uses Supabase for backend services. To set it up:

1. Create a Supabase project at https://supabase.com
2. Copy your project URL and anon key from the Supabase dashboard
3. Update the Supabase initialization in `js/supabase.js` and `auth.html`
4. Use the auth.html page to test authentication

For static sites, you'll need to create your Supabase tables through the Supabase dashboard
and then use the JavaScript client to interact with them.

See the auth.html file for a complete authentication example.
EOF
      fi
      ;;
      
    *)
      typewriter "❌ Unknown framework type for Supabase setup: $framework_type" 0.02
      return 1
      ;;
  esac
  
  # Check if installation was successful
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Something went wrong installing Supabase." 0.02
    return 1
  fi
  
  # Success message
  rainbow_box "✅ Supabase set up successfully!"
  typewriter "🔐 NOTE: Don't forget to create a Supabase account and update the environment variables!" 0.02
  echo "$(display_success "$THEME")"
  
  return 0
}