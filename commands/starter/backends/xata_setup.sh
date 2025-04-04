#!/bin/bash

# Set directory paths for consistent imports
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
# Get current theme
THEME=$(get_selected_theme)
#!/bin/bash

# ========= XATA SETUP MODULE =========
# Sets up Xata in a project

setup_xata() {
  local project_path="$1"
  local framework_type="$2"  # svelte, node, or static
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up Xata." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Friendly intro
  typewriter "🚀 Setting up Xata - serverless database for modern apps" 0.02
  typewriter "💡 This will add authentication, database, and storage capabilities" 0.02
  echo ""
  
  # Check for Xata CLI
  if ! command -v xata &> /dev/null; then
    typewriter "Installing Xata CLI globally..." 0.02
    npm install -g @xata.io/cli@latest > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
      typewriter "$(display_error "$THEME") Failed to install Xata CLI." 0.02
      typewriter "Try running: npm install -g @xata.io/cli@latest" 0.02
      return 1
    fi
  fi
  
  # Prompt for Xata API key with validation
  typewriter "To set up Xata, you'll need an API key and workspace slug from your Xata account." 0.02
  typewriter "You can find these at https://app.xata.io/settings" 0.02
  echo ""
  
  read -p "Enter your Xata API key: " xata_api_key
  if [ -z "$xata_api_key" ]; then
    typewriter "$(display_error "$THEME") Xata API key cannot be empty." 0.02
    return 1
  fi
  
  # Validate API key format (basic format check - should be alphanumeric + possible special chars)
  if ! [[ "$xata_api_key" =~ ^[a-zA-Z0-9_.-]{20,}$ ]]; then
    typewriter "⚠️ Warning: The API key format doesn't look valid. API keys are typically 20+ characters." 0.02
    read -p "Continue anyway? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      typewriter "$(display_error "$THEME") Setup aborted." 0.02
      return 1
    fi
  fi
  
  # Prompt for Xata workspace slug
  read -p "Enter your Xata workspace slug (found in Xata settings): " xata_workspace_slug
  if [ -z "$xata_workspace_slug" ]; then
    typewriter "$(display_error "$THEME") Xata workspace slug cannot be empty." 0.02
    return 1
  fi
  
  # Safely create Xata config directory if it doesn't exist
  if [ ! -d "$HOME/.config/xata" ]; then
    mkdir -p "$HOME/.config/xata" 2>/dev/null || {
      echo "Warning: Could not create ~/.config/xata directory."
      echo "Please create this directory manually and ensure it's writable."
      echo "Try: mkdir -p ~/.config/xata"
      read -p "Press Enter to continue after you've created the directory, or Ctrl+C to cancel..." 
    }
  fi
  
  # Ensure the directory is writable if it exists
  if [ -d "$HOME/.config/xata" ] && [ ! -w "$HOME/.config/xata" ]; then
    echo "Warning: The ~/.config/xata directory exists but is not writable."
    echo "Please make it writable by running: chmod u+w ~/.config/xata"
    read -p "Press Enter to continue after you've made the directory writable, or Ctrl+C to cancel..." 
  fi
  
  # Authenticate with Xata
  typewriter "Authenticating with Xata..." 0.02
  XATA_API_KEY=$xata_api_key xata auth login > /dev/null 2>&1
  
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Failed to authenticate with Xata." 0.02
    return 1
  fi
  
  # Create database
  local db_name=$(basename "$project_path")
  typewriter "Creating Xata database: $db_name..." 0.02
  
  xata dbs create "$db_name" --workspace "$xata_workspace_slug" > /dev/null 2>&1
  
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Failed to create Xata database." 0.02
    typewriter "The database name might already be taken or you don't have sufficient permissions." 0.02
    return 1
  fi
  
  # Ask if the user wants to create a sample schema
  read -p "Would you like to create a sample table schema? (y/n): " create_schema
  
  if [[ "$create_schema" =~ ^[Yy]$ ]]; then
    # Create temporary schema file with a more secure pattern and cleanup trap
    local schema_file=$(mktemp -t "xata_schema_XXXXXX") || { 
      echo "$(display_error "$THEME") Failed to create temporary file." 
      return 1
    }
    
    # Ensure the temporary file gets cleaned up even if the script exits unexpectedly
    trap "rm -f '$schema_file'" EXIT
    
    # Write sample schema
    cat > "$schema_file" << 'EOF'
{
  "tables": [
    {
      "name": "items",
      "columns": [
        {
          "name": "title",
          "type": "string"
        },
        {
          "name": "description",
          "type": "text"
        },
        {
          "name": "isComplete",
          "type": "bool"
        },
        {
          "name": "priority",
          "type": "int"
        },
        {
          "name": "dueDate",
          "type": "datetime"
        },
        {
          "name": "attachment",
          "type": "file"
        }
      ]
    }
  ]
}
EOF
    
    # Upload schema
    typewriter "Uploading sample schema to Xata..." 0.02
    xata schema upload "$schema_file" --db="https://${xata_workspace_slug}.xata.sh/db/${db_name}" > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
      typewriter "$(display_error "$THEME") Failed to upload schema." 0.02
      rm "$schema_file"
      return 1
    fi
    
    # Note: The trap will handle cleanup of schema_file
    
    # Insert sample data
    typewriter "Inserting sample data into the database..." 0.02
    xata random-data --table=items --records=10 --db="https://${xata_workspace_slug}.xata.sh/db/${db_name}" > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
      typewriter "$(display_error "$THEME") Failed to insert sample data." 0.02
    fi
  fi
  
  # Initialize Xata in the project
  typewriter "Initializing Xata in your project..." 0.02
  
  # Determine code generation path based on framework
  local codegen_path
  
  case "$framework_type" in
    svelte)
      codegen_path="src/lib/xata.js"
      ;;
    node)
      mkdir -p src/lib
      codegen_path="src/lib/xata.js"
      ;;
    static)
      mkdir -p js/lib
      codegen_path="js/lib/xata.js"
      ;;
    *)
      codegen_path="src/xata.js"
      ;;
  esac
  
  # Initialize Xata with the determined path
  xata init --db="https://${xata_workspace_slug}.xata.sh/db/${db_name}" --sdk --no-input --yes --codegen="$codegen_path" > /dev/null 2>&1
  
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Failed to initialize Xata in your project." 0.02
    return 1
  fi
  
  # Generate code from schema
  typewriter "Generating code from your Xata schema..." 0.02
  xata codegen > /dev/null 2>&1
  
  if [ $? -ne 0 ]; then
    typewriter "$(display_error "$THEME") Failed to generate code from schema." 0.02
    return 1
  fi
  
  # Create framework-specific example files
  case "$framework_type" in
    svelte)
      # Create a demo route for SvelteKit
      mkdir -p src/routes/xata-demo
      
      # Create +page.svelte
      cat > src/routes/xata-demo/+page.svelte << 'EOF'
<script>
  export let data;

  // State for new item
  let newItem = {
    title: '',
    description: '',
    priority: 1,
    isComplete: false
  };

  // Function to handle form submission
  async function handleSubmit() {
    try {
      const response = await fetch('/xata-demo', {
        method: 'POST',
        body: JSON.stringify(newItem),
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.ok) {
        // Refresh the page to show new data
        window.location.reload();
      } else {
        alert('Failed to create item');
      }
    } catch (error) {
      console.error('Error creating item:', error);
      alert('Error creating item');
    }
  }

  // Function to handle item deletion
  async function deleteItem(id) {
    try {
      const response = await fetch(`/xata-demo?id=${id}`, {
        method: 'DELETE'
      });
      
      if (response.ok) {
        // Refresh the page to show updated data
        window.location.reload();
      } else {
        alert('Failed to delete item');
      }
    } catch (error) {
      console.error('Error deleting item:', error);
      alert('Error deleting item');
    }
  }

  // Function to toggle completion status
  async function toggleComplete(id, currentStatus) {
    try {
      const response = await fetch('/xata-demo', {
        method: 'PATCH',
        body: JSON.stringify({ id, isComplete: !currentStatus }),
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.ok) {
        // Refresh the page to show updated data
        window.location.reload();
      } else {
        alert('Failed to update item');
      }
    } catch (error) {
      console.error('Error updating item:', error);
      alert('Error updating item');
    }
  }
</script>

<div class="container mx-auto p-8">
  <h1 class="text-3xl font-bold mb-8">Xata Demo</h1>
  
  <div class="mb-8">
    <h2 class="text-2xl font-semibold mb-4">Create New Item</h2>
    <form on:submit|preventDefault={handleSubmit} class="space-y-4 max-w-md">
      <div>
        <label for="title" class="block text-sm font-medium mb-1">Title</label>
        <input 
          type="text" 
          id="title" 
          bind:value={newItem.title} 
          class="w-full p-2 border rounded"
          required
        />
      </div>
      
      <div>
        <label for="description" class="block text-sm font-medium mb-1">Description</label>
        <textarea 
          id="description" 
          bind:value={newItem.description} 
          class="w-full p-2 border rounded"
          rows="3"
        ></textarea>
      </div>
      
      <div>
        <label for="priority" class="block text-sm font-medium mb-1">Priority (1-5)</label>
        <input 
          type="number" 
          id="priority" 
          bind:value={newItem.priority} 
          min="1" 
          max="5" 
          class="w-full p-2 border rounded"
        />
      </div>
      
      <div class="flex items-center">
        <input 
          type="checkbox" 
          id="isComplete" 
          bind:checked={newItem.isComplete} 
          class="mr-2"
        />
        <label for="isComplete" class="text-sm">Completed</label>
      </div>
      
      <button 
        type="submit" 
        class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
      >
        Create Item
      </button>
    </form>
  </div>
  
  <div>
    <h2 class="text-2xl font-semibold mb-4">Items</h2>
    
    {#if data.items.length === 0}
      <p>No items found. Create some using the form above.</p>
    {:else}
      <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {#each data.items as item}
          <div class="border rounded-lg p-4 bg-white shadow-sm">
            <div class="flex justify-between">
              <h3 class="font-semibold {item.isComplete ? 'line-through text-gray-400' : ''}">
                {item.title}
              </h3>
              <span class="px-2 py-0.5 text-xs rounded-full bg-blue-100 text-blue-800">
                Priority: {item.priority}
              </span>
            </div>
            
            <p class="mt-2 text-gray-600 text-sm">
              {item.description || 'No description'}
            </p>
            
            {#if item.dueDate}
              <p class="mt-2 text-xs text-gray-500">
                Due: {new Date(item.dueDate).toLocaleString()}
              </p>
            {/if}
            
            <div class="mt-4 flex space-x-2">
              <button 
                class="px-3 py-1 text-xs rounded border border-blue-600 text-blue-600 hover:bg-blue-50"
                on:click={() => toggleComplete(item.id, item.isComplete)}
              >
                {item.isComplete ? 'Mark Incomplete' : 'Mark Complete'}
              </button>
              
              <button 
                class="px-3 py-1 text-xs rounded border border-red-600 text-red-600 hover:bg-red-50"
                on:click={() => deleteItem(item.id)}
              >
                Delete
              </button>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>
EOF
      
      # Create +page.server.js
      cat > src/routes/xata-demo/+page.server.js << 'EOF'
import { XataClient } from '$lib/xata';

// Initialize Xata client
const xata = new XataClient();

export async function load() {
  // Fetch all items from the Xata database
  try {
    const items = await xata.db.items.getAll();
    return { items };
  } catch (error) {
    console.error('Error loading items:', error);
    return { items: [] };
  }
}

export const actions = {
  default: async ({ request }) => {
    // Handle POST request to create a new item
    const data = await request.json();
    
    try {
      const newItem = await xata.db.items.create(data);
      return { success: true, item: newItem };
    } catch (error) {
      console.error('Error creating item:', error);
      return { success: false, error: error.message };
    }
  }
};

// For non-form submissions (DELETE and PATCH)
export async function DELETE({ url }) {
  const id = url.searchParams.get('id');
  
  if (!id) {
    return new Response('ID is required', { status: 400 });
  }
  
  try {
    await xata.db.items.delete(id);
    return new Response('Item deleted', { status: 200 });
  } catch (error) {
    console.error('Error deleting item:', error);
    return new Response('Error deleting item', { status: 500 });
  }
}

export async function PATCH({ request }) {
  const data = await request.json();
  
  if (!data.id) {
    return new Response('ID is required', { status: 400 });
  }
  
  try {
    await xata.db.items.update(data.id, {
      isComplete: data.isComplete
    });
    
    return new Response('Item updated', { status: 200 });
  } catch (error) {
    console.error('Error updating item:', error);
    return new Response('Error updating item', { status: 500 });
  }
}
EOF
      
      # Add link to demo in layout
      if [ -f "src/routes/+layout.svelte" ]; then
        # Use a more secure temporary file pattern
        local temp_file=$(mktemp -t "xata_layout_XXXXXX") || {
          echo "$(display_error "$THEME") Failed to create temporary file."
          return 1
        }
        
        # Ensure the temporary file gets cleaned up even if the script exits unexpectedly
        trap "rm -f '$temp_file'" EXIT
        
        awk '{
          if ($0 ~ /<nav/) {
            print $0
            found_nav = 1
          } else if (found_nav && $0 ~ /<\/nav>/) {
            print "          <a href=\"/xata-demo\" class=\"btn variant-ghost-surface\">Xata Demo</a>"
            print $0
            found_nav = 0
          } else {
            print $0
          }
        }' "src/routes/+layout.svelte" > "$temp_file"
        
        # Replace the file
        mv "$temp_file" "src/routes/+layout.svelte"
        
        # Clean up trap when we're done with this block
        trap - EXIT
      fi
      
      # Update README
      if [ -f "README.md" ]; then
        cat >> README.md << 'EOF'

## Xata Integration

This project uses [Xata](https://xata.io) as a serverless database. A demo CRUD application is available at `/xata-demo`.

To work with Xata:

1. The Xata client is initialized in `src/lib/xata.js`
2. Use the client to perform CRUD operations:

```js
// Import the client
import { XataClient } from '$lib/xata';
const xata = new XataClient();

// Create a record
const newItem = await xata.db.items.create({ 
  title: 'New item', 
  description: 'Description' 
});

// Read records
const items = await xata.db.items.getAll();
const item = await xata.db.items.read('record-id');

// Update a record
await xata.db.items.update('record-id', { title: 'Updated title' });

// Delete a record
await xata.db.items.delete('record-id');
```

See the Xata demo in `/src/routes/xata-demo` for a complete example.
EOF
      fi
      ;;
      
    node)
      # Create a demo route for Node/Express
      mkdir -p routes
      
      # Create a route file
      cat > routes/xata-demo.js << 'EOF'
const express = require('express');
const router = express.Router();
const { XataClient } = require('../src/lib/xata');

// Initialize Xata client
const xata = new XataClient();

// GET route to display all items
router.get('/', async (req, res) => {
  try {
    const items = await xata.db.items.getAll();
    res.render('xata-demo', { items });
  } catch (error) {
    console.error('Error fetching items:', error);
    res.status(500).render('error', { 
      message: 'Error fetching items', 
      error 
    });
  }
});

// POST route to create a new item
router.post('/', async (req, res) => {
  try {
    const { title, description, priority, isComplete } = req.body;
    
    // Basic validation
    if (!title) {
      return res.status(400).json({ error: 'Title is required' });
    }
    
    // Create the item
    const newItem = await xata.db.items.create({
      title,
      description,
      priority: Number(priority) || 1,
      isComplete: isComplete === 'on' || isComplete === true
    });
    
    // Redirect back to the main page
    res.redirect('/xata-demo');
  } catch (error) {
    console.error('Error creating item:', error);
    res.status(500).render('error', { 
      message: 'Error creating item', 
      error 
    });
  }
});

// GET route to show edit form
router.get('/edit/:id', async (req, res) => {
  try {
    const item = await xata.db.items.read(req.params.id);
    
    if (!item) {
      return res.status(404).render('error', { 
        message: 'Item not found' 
      });
    }
    
    res.render('xata-edit', { item });
  } catch (error) {
    console.error('Error fetching item:', error);
    res.status(500).render('error', { 
      message: 'Error fetching item', 
      error 
    });
  }
});

// POST route to update an item
router.post('/edit/:id', async (req, res) => {
  try {
    const { title, description, priority, isComplete } = req.body;
    
    // Update the item
    await xata.db.items.update(req.params.id, {
      title,
      description,
      priority: Number(priority) || 1,
      isComplete: isComplete === 'on' || isComplete === true
    });
    
    // Redirect back to the main page
    res.redirect('/xata-demo');
  } catch (error) {
    console.error('Error updating item:', error);
    res.status(500).render('error', { 
      message: 'Error updating item', 
      error 
    });
  }
});

// POST route to delete an item
router.post('/delete/:id', async (req, res) => {
  try {
    await xata.db.items.delete(req.params.id);
    res.redirect('/xata-demo');
  } catch (error) {
    console.error('Error deleting item:', error);
    res.status(500).render('error', { 
      message: 'Error deleting item', 
      error 
    });
  }
});

module.exports = router;
EOF
      
      # Create demo view
      mkdir -p views
      
      cat > views/xata-demo.ejs << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Xata Demo</title>
  <link rel="stylesheet" href="/css/styles.css">
  <style>
    .container { max-width: 1200px; margin: 0 auto; padding: 1rem; }
    .form-group { margin-bottom: 1rem; }
    .form-group label { display: block; margin-bottom: 0.5rem; }
    .form-control { width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 0.25rem; }
    .btn { display: inline-block; padding: 0.5rem 1rem; background: #4F46E5; color: white; border: none; border-radius: 0.25rem; cursor: pointer; }
    .btn-danger { background: #EF4444; }
    .card { border: 1px solid #ddd; border-radius: 0.5rem; padding: 1rem; margin-bottom: 1rem; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1rem; }
    .completed { text-decoration: line-through; color: #9CA3AF; }
    .priority { display: inline-block; padding: 0.25rem 0.5rem; background: #EFF6FF; color: #1E40AF; border-radius: 9999px; font-size: 0.75rem; }
    .flex { display: flex; }
    .flex-col { flex-direction: column; }
    .justify-between { justify-content: space-between; }
    .mt-4 { margin-top: 1rem; }
    .mb-4 { margin-bottom: 1rem; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Xata Demo</h1>
    
    <div class="mb-4">
      <h2>Create New Item</h2>
      <form action="/xata-demo" method="POST" class="flex flex-col max-w-md">
        <div class="form-group">
          <label for="title">Title</label>
          <input type="text" id="title" name="title" class="form-control" required>
        </div>
        
        <div class="form-group">
          <label for="description">Description</label>
          <textarea id="description" name="description" class="form-control" rows="3"></textarea>
        </div>
        
        <div class="form-group">
          <label for="priority">Priority (1-5)</label>
          <input type="number" id="priority" name="priority" min="1" max="5" value="1" class="form-control">
        </div>
        
        <div class="form-group">
          <label>
            <input type="checkbox" name="isComplete"> Completed
          </label>
        </div>
        
        <button type="submit" class="btn">Create Item</button>
      </form>
    </div>
    
    <div>
      <h2>Items</h2>
      
      <% if (items.length === 0) { %>
        <p>No items found. Create some using the form above.</p>
      <% } else { %>
        <div class="grid">
          <% items.forEach(item => { %>
            <div class="card">
              <div class="flex justify-between">
                <h3 class="<%= item.isComplete ? 'completed' : '' %>">
                  <%= item.title %>
                </h3>
                <span class="priority">
                  Priority: <%= item.priority %>
                </span>
              </div>
              
              <p><%= item.description || 'No description' %></p>
              
              <% if (item.dueDate) { %>
                <p>Due: <%= new Date(item.dueDate).toLocaleString() %></p>
              <% } %>
              
              <div class="mt-4 flex">
                <a href="/xata-demo/edit/<%= item.id %>" class="btn" style="margin-right: 0.5rem;">Edit</a>
                
                <form action="/xata-demo/delete/<%= item.id %>" method="POST">
                  <button type="submit" class="btn btn-danger">Delete</button>
                </form>
              </div>
            </div>
          <% }) %>
        </div>
      <% } %>
    </div>
  </div>
</body>
</html>
EOF
      
      # Create edit view
      cat > views/xata-edit.ejs << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Edit Item - Xata Demo</title>
  <link rel="stylesheet" href="/css/styles.css">
  <style>
    .container { max-width: 800px; margin: 0 auto; padding: 1rem; }
    .form-group { margin-bottom: 1rem; }
    .form-group label { display: block; margin-bottom: 0.5rem; }
    .form-control { width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 0.25rem; }
    .btn { display: inline-block; padding: 0.5rem 1rem; background: #4F46E5; color: white; border: none; border-radius: 0.25rem; cursor: pointer; text-decoration: none; }
    .btn-secondary { background: #9CA3AF; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Edit Item</h1>
    
    <form action="/xata-demo/edit/<%= item.id %>" method="POST">
      <div class="form-group">
        <label for="title">Title</label>
        <input type="text" id="title" name="title" class="form-control" value="<%= item.title %>" required>
      </div>
      
      <div class="form-group">
        <label for="description">Description</label>
        <textarea id="description" name="description" class="form-control" rows="3"><%= item.description || '' %></textarea>
      </div>
      
      <div class="form-group">
        <label for="priority">Priority (1-5)</label>
        <input type="number" id="priority" name="priority" min="1" max="5" value="<%= item.priority || 1 %>" class="form-control">
      </div>
      
      <div class="form-group">
        <label>
          <input type="checkbox" name="isComplete" <%= item.isComplete ? 'checked' : '' %>> Completed
        </label>
      </div>
      
      <div>
        <button type="submit" class="btn">Update Item</button>
        <a href="/xata-demo" class="btn btn-secondary" style="margin-left: 0.5rem;">Cancel</a>
      </div>
    </form>
  </div>
</body>
</html>
EOF
      
      # Create error view
      cat > views/error.ejs << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Error - Xata Demo</title>
  <link rel="stylesheet" href="/css/styles.css">
  <style>
    .container { max-width: 800px; margin: 0 auto; padding: 1rem; }
    .error { color: #B91C1C; }
    .btn { display: inline-block; padding: 0.5rem 1rem; background: #4F46E5; color: white; border: none; border-radius: 0.25rem; cursor: pointer; text-decoration: none; }
  </style>
</head>
<body>
  <div class="container">
    <h1 class="error">Error</h1>
    
    <p><%= message %></p>
    
    <% if (error && error.stack) { %>
      <pre><%= error.stack %></pre>
    <% } %>
    
    <div>
      <a href="/xata-demo" class="btn">Back to Xata Demo</a>
    </div>
  </div>
</body>
</html>
EOF
      
      # Update app.js or index.js to use the route
      if [ -f "index.js" ]; then
        # Use a more secure temporary file pattern
        local temp_file=$(mktemp -t "xata_index_XXXXXX") || {
          echo "$(display_error "$THEME") Failed to create temporary file."
          return 1
        }
        
        # Ensure the temporary file gets cleaned up even if the script exits unexpectedly
        trap "rm -f '$temp_file'" EXIT
        
        awk '{
          if ($0 ~ /const express = require/) {
            print $0
            found_express = 1
          } else if (found_express && $0 ~ /const app = express/) {
            print $0
            found_app = 1
          } else if (found_app && $0 ~ /app.use\(/) {
            print $0
            if (!found_routes) {
              print "// Xata demo route"
              print "const xataRoutes = require(\"./routes/xata-demo\");"
              print "app.use(\"/xata-demo\", xataRoutes);"
              print ""
              found_routes = 1
            }
          } else {
            print $0
          }
        }' "index.js" > "$temp_file"
        
        # Replace the file
        mv "$temp_file" "index.js"
      fi
      
      # Update README
      if [ -f "README.md" ]; then
        cat >> README.md << 'EOF'

## Xata Integration

This project uses [Xata](https://xata.io) as a serverless database. A demo CRUD application is available at `/xata-demo`.

To work with Xata:

1. The Xata client is initialized in `src/lib/xata.js`
2. Example routes are available in `routes/xata-demo.js`
3. Use the client to perform CRUD operations:

```js
// Import the client
const { XataClient } = require('../src/lib/xata');
const xata = new XataClient();

// Create a record
const newItem = await xata.db.items.create({ 
  title: 'New item', 
  description: 'Description' 
});

// Read records
const items = await xata.db.items.getAll();
const item = await xata.db.items.read('record-id');

// Update a record
await xata.db.items.update('record-id', { title: 'Updated title' });

// Delete a record
await xata.db.items.delete('record-id');
```

See the Xata demo in the `/xata-demo` route for a complete example.
EOF
      fi
      ;;
      
    static)
      # For static sites, create a simple frontend and API demo
      mkdir -p js/api
      
      # Create a Xata API client
      cat > js/api/xata-client.js << 'EOF'
// Xata API client for the browser
class XataClient {
  constructor(apiKey, databaseURL) {
    this.apiKey = apiKey;
    this.databaseURL = databaseURL;
    this.baseURL = 'https://api.xata.io';
  }

  // Helper method to handle API requests
  async _request(path, options) {
    const url = `${this.baseURL}${path}`;
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${this.apiKey}`
    };

    try {
      const response = await fetch(url, {
        ...options,
        headers
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'API request failed');
      }

      return await response.json();
    } catch (error) {
      console.error('Xata API error:', error);
      throw error;
    }
  }

  // Get all records from a table
  async getAll(table) {
    const path = `/api/v1/db${this.databaseURL}:main/tables/${table}/query`;
    return this._request(path, {
      method: 'POST',
      body: JSON.stringify({
        page: { size: 100 }
      })
    });
  }

  // Get a single record by ID
  async getRecord(table, id) {
    const path = `/api/v1/db${this.databaseURL}:main/tables/${table}/data/${id}`;
    return this._request(path, {
      method: 'GET'
    });
  }

  // Create a new record
  async createRecord(table, data) {
    const path = `/api/v1/db${this.databaseURL}:main/tables/${table}/data`;
    return this._request(path, {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }

  // Update a record
  async updateRecord(table, id, data) {
    const path = `/api/v1/db${this.databaseURL}:main/tables/${table}/data/${id}`;
    return this._request(path, {
      method: 'PATCH',
      body: JSON.stringify(data)
    });
  }

  // Delete a record
  async deleteRecord(table, id) {
    const path = `/api/v1/db${this.databaseURL}:main/tables/${table}/data/${id}`;
    return this._request(path, {
      method: 'DELETE'
    });
  }
}
EOF
      
      # Create Xata demo page
      cat > xata-demo.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Xata Demo</title>
  <link rel="stylesheet" href="css/styles.css">
  <style>
    .container { max-width: 1200px; margin: 0 auto; padding: 1rem; }
    .form-group { margin-bottom: 1rem; }
    .form-group label { display: block; margin-bottom: 0.5rem; }
    .form-control { width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 0.25rem; }
    .btn { display: inline-block; padding: 0.5rem 1rem; background: #4F46E5; color: white; border: none; border-radius: 0.25rem; cursor: pointer; }
    .btn-danger { background: #EF4444; }
    .card { border: 1px solid #ddd; border-radius: 0.5rem; padding: 1rem; margin-bottom: 1rem; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1rem; }
    .completed { text-decoration: line-through; color: #9CA3AF; }
    .priority { display: inline-block; padding: 0.25rem 0.5rem; background: #EFF6FF; color: #1E40AF; border-radius: 9999px; font-size: 0.75rem; }
    .flex { display: flex; }
    .justify-between { justify-content: space-between; }
    .mt-4 { margin-top: 1rem; }
    .mb-8 { margin-bottom: 2rem; }
    .setup-section { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 0.5rem; padding: 1rem; margin-bottom: 2rem; }
    .code { font-family: monospace; background: #f1f5f9; padding: 0.25rem; border-radius: 0.25rem; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Xata Static Demo</h1>
    
    <div class="setup-section">
      <h2>Setup</h2>
      <p>To use this demo, you need to provide your Xata API key and database URL:</p>
      
      <div class="form-group">
        <label for="apiKey">Xata API Key</label>
        <input type="password" id="apiKey" class="form-control" placeholder="Enter your Xata API key" />
      </div>
      
      <div class="form-group">
        <label for="databaseURL">Database URL</label>
        <input type="text" id="databaseURL" class="form-control" placeholder="e.g., /workspaces/workspace-slug/dbs/database-name" />
      </div>
      
      <button id="saveConfig" class="btn">Save Configuration</button>
      
      <div class="mt-4">
        <p>
          <strong>Note:</strong> For a real application, you would handle API keys securely on a server.
          This demo stores the API key in localStorage for demonstration purposes only.
        </p>
      </div>
    </div>
    
    <div id="app" style="display: none;">
      <div class="mb-8">
        <h2>Create New Item</h2>
        <form id="createForm" class="max-w-md">
          <div class="form-group">
            <label for="title">Title</label>
            <input type="text" id="title" name="title" class="form-control" required>
          </div>
          
          <div class="form-group">
            <label for="description">Description</label>
            <textarea id="description" name="description" class="form-control" rows="3"></textarea>
          </div>
          
          <div class="form-group">
            <label for="priority">Priority (1-5)</label>
            <input type="number" id="priority" name="priority" min="1" max="5" value="1" class="form-control">
          </div>
          
          <div class="form-group">
            <label>
              <input type="checkbox" id="isComplete" name="isComplete"> Completed
            </label>
          </div>
          
          <button type="submit" class="btn">Create Item</button>
        </form>
      </div>
      
      <div>
        <h2>Items</h2>
        <div id="loading">Loading items...</div>
        <div id="items" class="grid"></div>
      </div>
    </div>
  </div>
  
  <script src="js/api/xata-client.js"></script>
  <script>
    // Configuration management
    const CONFIG_KEY = 'xata_demo_config';
    let xataClient = null;
    
    // DOM elements
    const setupSection = document.querySelector('.setup-section');
    const appSection = document.getElementById('app');
    const saveConfigBtn = document.getElementById('saveConfig');
    const apiKeyInput = document.getElementById('apiKey');
    const databaseURLInput = document.getElementById('databaseURL');
    const createForm = document.getElementById('createForm');
    const loadingElement = document.getElementById('loading');
    const itemsContainer = document.getElementById('items');
    
    // Load configuration from localStorage
    function loadConfig() {
      const config = localStorage.getItem(CONFIG_KEY);
      if (config) {
        try {
          const { apiKey, databaseURL } = JSON.parse(config);
          apiKeyInput.value = apiKey;
          databaseURLInput.value = databaseURL;
          
          // Initialize client and load items
          xataClient = new XataClient(apiKey, databaseURL);
          setupSection.style.display = 'none';
          appSection.style.display = 'block';
          loadItems();
          
          return true;
        } catch (error) {
          console.error('Error loading config:', error);
        }
      }
      return false;
    }
    
    // Save configuration to localStorage
    saveConfigBtn.addEventListener('click', () => {
      const apiKey = apiKeyInput.value.trim();
      const databaseURL = databaseURLInput.value.trim();
      
      if (!apiKey || !databaseURL) {
        alert('Please enter both API key and database URL');
        return;
      }
      
      const config = { apiKey, databaseURL };
      localStorage.setItem(CONFIG_KEY, JSON.stringify(config));
      
      // Initialize client and load items
      xataClient = new XataClient(apiKey, databaseURL);
      setupSection.style.display = 'none';
      appSection.style.display = 'block';
      loadItems();
    });
    
    // Load items from Xata
    async function loadItems() {
      if (!xataClient) return;
      
      loadingElement.style.display = 'block';
      itemsContainer.innerHTML = '';
      
      try {
        const response = await xataClient.getAll('items');
        loadingElement.style.display = 'none';
        
        if (response.records && response.records.length > 0) {
          response.records.forEach(item => {
            itemsContainer.appendChild(createItemElement(item));
          });
        } else {
          itemsContainer.innerHTML = '<p>No items found. Create some using the form above.</p>';
        }
      } catch (error) {
        loadingElement.style.display = 'none';
        itemsContainer.innerHTML = `<p>Error loading items: ${error.message}</p>`;
      }
    }
    
    // Create an item element
    function createItemElement(item) {
      const card = document.createElement('div');
      card.className = 'card';
      
      const header = document.createElement('div');
      header.className = 'flex justify-between';
      
      const title = document.createElement('h3');
      title.className = item.isComplete ? 'completed' : '';
      title.textContent = item.title;
      
      const priority = document.createElement('span');
      priority.className = 'priority';
      priority.textContent = `Priority: ${item.priority || 1}`;
      
      header.appendChild(title);
      header.appendChild(priority);
      
      const description = document.createElement('p');
      description.textContent = item.description || 'No description';
      
      const actions = document.createElement('div');
      actions.className = 'mt-4';
      
      const toggleBtn = document.createElement('button');
      toggleBtn.className = 'btn';
      toggleBtn.style.marginRight = '0.5rem';
      toggleBtn.textContent = item.isComplete ? 'Mark Incomplete' : 'Mark Complete';
      toggleBtn.addEventListener('click', () => toggleComplete(item.id, item.isComplete));
      
      const deleteBtn = document.createElement('button');
      deleteBtn.className = 'btn btn-danger';
      deleteBtn.textContent = 'Delete';
      deleteBtn.addEventListener('click', () => deleteItem(item.id));
      
      actions.appendChild(toggleBtn);
      actions.appendChild(deleteBtn);
      
      card.appendChild(header);
      card.appendChild(description);
      
      if (item.dueDate) {
        const dueDate = document.createElement('p');
        dueDate.textContent = `Due: ${new Date(item.dueDate).toLocaleString()}`;
        card.appendChild(dueDate);
      }
      
      card.appendChild(actions);
      
      return card;
    }
    
    // Create a new item
    createForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const title = document.getElementById('title').value;
      const description = document.getElementById('description').value;
      const priority = parseInt(document.getElementById('priority').value);
      const isComplete = document.getElementById('isComplete').checked;
      
      try {
        await xataClient.createRecord('items', {
          title,
          description,
          priority,
          isComplete
        });
        
        // Reset form and reload items
        createForm.reset();
        loadItems();
      } catch (error) {
        alert(`Error creating item: ${error.message}`);
      }
    });
    
    // Toggle item completion status
    async function toggleComplete(id, currentStatus) {
      try {
        await xataClient.updateRecord('items', id, {
          isComplete: !currentStatus
        });
        loadItems();
      } catch (error) {
        alert(`Error updating item: ${error.message}`);
      }
    }
    
    // Delete an item
    async function deleteItem(id) {
      if (!confirm('Are you sure you want to delete this item?')) return;
      
      try {
        await xataClient.deleteRecord('items', id);
        loadItems();
      } catch (error) {
        alert(`Error deleting item: ${error.message}`);
      }
    }
    
    // Initialize the app
    if (!loadConfig()) {
      setupSection.style.display = 'block';
      appSection.style.display = 'none';
    }
  </script>
</body>
</html>
EOF
      
      # Add link to demo in index.html
      if [ -f "index.html" ]; then
        # Check if link already exists
        if ! grep -q "xata-demo.html" "index.html"; then
          # Create a temporary file with a more secure pattern
          local temp_file=$(mktemp -t "xata_html_XXXXXX") || {
            echo "$(display_error "$THEME") Failed to create temporary file."
            return 1
          }
          
          # Ensure the temporary file gets cleaned up even if the script exits unexpectedly
          trap "rm -f '$temp_file'" EXIT
          
          # Add the link to the navigation
          awk '{
            if ($0 ~ /<li><a href="[^"]*">Contact<\/a><\/li>/) {
              print $0
              print "        <li><a href=\"xata-demo.html\">Xata Demo</a></li>"
            } else {
              print $0
            }
          }' "index.html" > "$temp_file"
          
          # Replace the file
          mv "$temp_file" "index.html"
          
          # Clean up trap when we're done with this block
          trap - EXIT
        fi
      fi
      
      # Update README
      if [ -f "README.md" ]; then
        cat >> README.md << 'EOF'

## Xata Integration

This project includes a demo integration with [Xata](https://xata.io), a serverless database. 

To use the demo:
1. Open `xata-demo.html` in your browser
2. Enter your Xata API key and database URL
3. Use the demo app to create, read, update, and delete items

**Note:** This demo stores the API key in localStorage for demonstration purposes only. 
For a real application, you should handle API keys securely on a server.

The demo uses a simple JavaScript client in `js/api/xata-client.js` to interact with the Xata API.
For production use, consider using the official Xata SDK.
EOF
      fi
      ;;
      
    *)
      typewriter "⚠️ Unknown framework type: $framework_type. Basic setup only." 0.02
      ;;
  esac
  
  # Add Xata section to README if not already done
  if [ -f "README.md" ] && ! grep -q "## Xata Integration" "README.md"; then
    cat >> "README.md" << 'EOF'

## Xata Integration

This project uses [Xata](https://xata.io) as a serverless database.

To get started:
1. Create an account at [xata.io](https://xata.io)
2. Create an API key in the Xata dashboard
3. Use the Xata client to interact with your database
EOF
  fi
  
  # Success message
  rainbow_box "✅ Xata set up successfully!"
  typewriter "🔐 NOTE: Your Xata database is now set up and ready to use!" 0.02
  typewriter "Visit https://app.xata.io to view your database in the Xata dashboard." 0.02
  echo "$(display_success "$THEME")"
  
  return 0
}