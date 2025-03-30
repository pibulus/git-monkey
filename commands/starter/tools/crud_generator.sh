#!/bin/bash

# ========= GIT MONKEY CRUD GENERATOR =========
# Generates ready-to-use, working CRUD templates based on framework and backend

# Source utilities
source ./utils/style.sh
source ./utils/config.sh
source ./commands/starter/starter_config.sh

# Default values
DEFAULT_TABLE_NAME="crudTable"
MINIMAL_MODE=false
FORMLESS_MODE=false
MOCK_DATA_MODE=false

# Function to parse command-line arguments
parse_crud_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --minimal)
        MINIMAL_MODE=true
        shift
        ;;
      --formless)
        FORMLESS_MODE=true
        shift
        ;;
      --mock)
        MOCK_DATA_MODE=true
        shift
        ;;
      --table)
        TABLE_NAME="$2"
        shift
        shift
        ;;
      *)
        # Assume positional arguments: project_path backend_type framework_type table_name
        if [ -z "$PROJECT_PATH" ]; then
          PROJECT_PATH="$1"
        elif [ -z "$BACKEND_TYPE" ]; then
          BACKEND_TYPE="$1"
        elif [ -z "$FRAMEWORK_TYPE" ]; then
          FRAMEWORK_TYPE="$1"
        elif [ -z "$TABLE_NAME" ]; then
          TABLE_NAME="$1"
        fi
        shift
        ;;
    esac
  done

  # Set defaults if values aren't provided
  TABLE_NAME="${TABLE_NAME:-$DEFAULT_TABLE_NAME}"
}

# Function to validate inputs
validate_inputs() {
  # Validate project path
  if [ -z "$PROJECT_PATH" ]; then
    handle_error "Project path is required."
    return 1
  fi

  if [ ! -d "$PROJECT_PATH" ]; then
    handle_error "Project directory does not exist: $PROJECT_PATH"
    return 1
  fi

  # Validate backend type
  if [ -z "$BACKEND_TYPE" ]; then
    handle_error "Backend type is required (xata or supabase)."
    return 1
  fi

  if [ "$BACKEND_TYPE" != "xata" ] && [ "$BACKEND_TYPE" != "supabase" ]; then
    handle_error "Backend type must be 'xata' or 'supabase'."
    return 1
  fi

  # Validate framework type
  if [ -z "$FRAMEWORK_TYPE" ]; then
    handle_error "Framework type is required (svelte, node, or static)."
    return 1
  fi

  if [ "$FRAMEWORK_TYPE" != "svelte" ] && [ "$FRAMEWORK_TYPE" != "node" ] && [ "$FRAMEWORK_TYPE" != "static" ]; then
    handle_error "Framework type must be 'svelte', 'node', or 'static'."
    return 1
  }

  # Validate table name (simple validation)
  if [[ ! "$TABLE_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
    handle_error "Table name must contain only letters, numbers, and underscores."
    return 1
  fi

  return 0
}

# Function to handle errors
handle_error() {
  local error_message="$1"
  echo "❌ Error: $error_message"
  
  # Suggest fixes based on error type
  if [[ "$error_message" == *"Backend type"* ]]; then
    echo "ℹ️ Available backend types: xata, supabase"
  elif [[ "$error_message" == *"Framework type"* ]]; then
    echo "ℹ️ Available framework types: svelte, node, static"
  elif [[ "$error_message" == *"Project directory"* ]]; then
    echo "ℹ️ Make sure to run this command from your project's root directory"
  fi
  
  return 1
}

# Function to detect UI libraries
detect_ui_library() {
  local project_path="$1"
  local framework_type="$2"

  # Default to basic
  UI_LIBRARY="basic"

  if [ "$framework_type" = "svelte" ]; then
    # Check package.json for UI libraries
    if grep -q "daisyui" "$project_path/package.json" 2>/dev/null; then
      UI_LIBRARY="daisyui"
    elif grep -q "@skeletonlabs/skeleton" "$project_path/package.json" 2>/dev/null; then
      UI_LIBRARY="skeleton"
    elif grep -q "flowbite-svelte" "$project_path/package.json" 2>/dev/null; then
      UI_LIBRARY="flowbite"
    elif grep -q "shoelace" "$project_path/package.json" 2>/dev/null; then
      UI_LIBRARY="shoelace"
    elif grep -q "tailwindcss" "$project_path/package.json" 2>/dev/null; then
      UI_LIBRARY="tailwind"
    fi
  elif [ "$framework_type" = "node" ]; then
    # Check for Node UI libraries
    if grep -q "tailwindcss" "$project_path/package.json" 2>/dev/null; then
      UI_LIBRARY="tailwind"
    fi
  elif [ "$framework_type" = "static" ]; then
    # Check for static site UI libraries
    if grep -q "tailwindcss" "$project_path/package.json" 2>/dev/null || [ -f "$project_path/tailwind.config.js" ]; then
      UI_LIBRARY="tailwind"
    fi
  fi

  echo "🎨 Detected UI library: $UI_LIBRARY"
  return 0
}

# Function to check if backend setup exists
check_backend_setup() {
  local project_path="$1"
  local backend_type="$2"
  local framework_type="$3"

  if [ "$backend_type" = "xata" ]; then
    # Check for Xata setup
    if [ "$framework_type" = "svelte" ]; then
      if [ ! -f "$project_path/src/lib/xata.js" ]; then
        handle_error "Couldn't find Xata SDK. Did you run backend setup?"
        echo "ℹ️ Try running 'gitmonkey start' and selecting Xata as your backend."
        return 1
      fi
    elif [ "$framework_type" = "node" ]; then
      if [ ! -f "$project_path/src/lib/xata.js" ] && [ ! -f "$project_path/lib/xata.js" ]; then
        handle_error "Couldn't find Xata SDK. Did you run backend setup?"
        echo "ℹ️ Try running 'gitmonkey start' and selecting Xata as your backend."
        return 1
      fi
    elif [ "$framework_type" = "static" ]; then
      if [ ! -f "$project_path/js/lib/xata.js" ] && [ ! -f "$project_path/js/api/xata-client.js" ]; then
        handle_error "Couldn't find Xata client. Did you run backend setup?"
        echo "ℹ️ Try running 'gitmonkey start' and selecting Xata as your backend."
        return 1
      fi
    fi
  elif [ "$backend_type" = "supabase" ]; then
    # Check for Supabase setup
    if ! grep -q "supabase" "$project_path/package.json" 2>/dev/null; then
      handle_error "Couldn't find Supabase SDK. Did you run backend setup?"
      echo "ℹ️ Try running 'gitmonkey start' and selecting Supabase as your backend."
      return 1
    fi
  fi

  return 0
}

# Function to get or create schema
get_or_create_schema() {
  local backend_type="$1"
  local table_name="$2"

  # Default schema for the CRUD table
  local schema

  # Ask if user wants to use default schema
  if [ "$MOCK_DATA_MODE" != true ]; then
    read -p "🧩 Use default schema for $table_name? (y/n): " use_default
    if [[ ! "$use_default" =~ ^[Yy]$ ]]; then
      echo "📋 Define your schema below (JSON format):"
      echo "Example: { \"id\": \"string\", \"name\": \"string\", \"email\": \"string\", \"active\": \"boolean\" }"
      read -p "> " custom_schema
      if [ -n "$custom_schema" ]; then
        schema="$custom_schema"
      else
        echo "⚠️ No schema provided, using default."
        use_default="y"
      fi
    fi
  else
    use_default="y"
  fi

  # Use default schema if requested
  if [[ "$use_default" =~ ^[Yy]$ ]]; then
    if [ "$backend_type" = "xata" ]; then
      schema='{
        "id": "string",
        "name": "string",
        "description": "text",
        "created_at": "datetime",
        "updated_at": "datetime",
        "is_active": "boolean",
        "priority": "int"
      }'
    elif [ "$backend_type" = "supabase" ]; then
      schema='{
        "id": "uuid",
        "name": "text",
        "description": "text",
        "created_at": "timestamp",
        "updated_at": "timestamp",
        "is_active": "boolean",
        "priority": "integer"
      }'
    fi
  fi

  echo "$schema"
}

# Main generator function
generate_crud() {
  local project_path="$1"
  local backend_type="$2"     # xata or supabase
  local framework_type="$3"   # svelte, node, static
  local table_name="$4"       # default: crudTable

  # Detect UI library being used
  detect_ui_library "$project_path" "$framework_type"

  # Check if backend is set up
  check_backend_setup "$project_path" "$backend_type" "$framework_type" || return 1

  # Get or create schema
  SCHEMA=$(get_or_create_schema "$backend_type" "$table_name")

  # Show summary
  echo ""
  box "CRUD Generator Summary"
  echo "📂 Project: $project_path"
  echo "🔌 Backend: $backend_type"
  echo "🖥️ Framework: $framework_type"
  echo "📋 Table: $table_name"
  echo "🎨 UI Library: $UI_LIBRARY"
  
  if [ "$MINIMAL_MODE" = true ]; then echo "⚙️ Mode: Minimal"; fi
  if [ "$FORMLESS_MODE" = true ]; then echo "⚙️ Mode: API Only (No Forms)"; fi
  if [ "$MOCK_DATA_MODE" = true ]; then echo "⚙️ Mode: With Mock Data"; fi
  
  echo ""
  read -p "🚀 Ready to generate CRUD? (y/n): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    return 0
  fi

  # Generate CRUD based on framework
  case "$framework_type" in
    svelte)
      generate_svelte_crud "$project_path" "$backend_type" "$table_name" "$SCHEMA"
      ;;
    node)
      generate_node_crud "$project_path" "$backend_type" "$table_name" "$SCHEMA"
      ;;
    static)
      generate_static_crud "$project_path" "$backend_type" "$table_name" "$SCHEMA"
      ;;
    *)
      handle_error "Unsupported framework type: $framework_type"
      return 1
      ;;
  esac

  # Create metadata
  save_crud_metadata "$project_path" "$backend_type" "$framework_type" "$table_name"

  # Success message
  rainbow_box "✅ CRUD template complete!"
  echo "🐒 Monkey tip: Check your new CRUD pages and adapt them to your needs!"
  
  return 0
}

# Function to save metadata about generated CRUD
save_crud_metadata() {
  local project_path="$1"
  local backend_type="$2"
  local framework_type="$3"
  local table_name="$4"

  # Create .monkey directory if it doesn't exist
  mkdir -p "$project_path/.monkey"

  # Create or update crud-history.json
  local history_file="$project_path/.monkey/crud-history.json"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  if [ -f "$history_file" ]; then
    # Update existing file
    local temp_file=$(mktemp)
    jq --arg table "$table_name" --arg backend "$backend_type" --arg framework "$framework_type" --arg time "$timestamp" \
      '.generated += [{"table": $table, "backend": $backend, "framework": $framework, "timestamp": $time}]' \
      "$history_file" > "$temp_file" 2>/dev/null
    
    if [ $? -eq 0 ]; then
      mv "$temp_file" "$history_file"
    else
      # If jq failed, create a new file
      rm "$temp_file"
      echo "{\"generated\": [{\"table\": \"$table_name\", \"backend\": \"$backend_type\", \"framework\": \"$framework_type\", \"timestamp\": \"$timestamp\"}]}" > "$history_file"
    fi
  else
    # Create new file
    echo "{\"generated\": [{\"table\": \"$table_name\", \"backend\": \"$backend_type\", \"framework\": \"$framework_type\", \"timestamp\": \"$timestamp\"}]}" > "$history_file"
  fi
}

# Main function that's called when script is executed directly
main() {
  # Process command-line arguments
  parse_crud_args "$@"
  
  # Validate inputs
  validate_inputs || return 1
  
  # Generate CRUD
  generate_crud "$PROJECT_PATH" "$BACKEND_TYPE" "$FRAMEWORK_TYPE" "$TABLE_NAME"
  
  return $?
}

# Call main function passing all arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

# Function to generate CRUD for SvelteKit
generate_svelte_crud() {
  local project_path="$1"
  local backend_type="$2" 
  local table_name="$3"
  local schema="$4"
  
  echo ""
  typewriter "🚀 Generating CRUD for SvelteKit with $backend_type..." 0.01
  
  # Create the CRUD route directory
  local crud_dir="$project_path/src/routes/$table_name"
  mkdir -p "$crud_dir"
  
  # Create files based on backend type
  if [ "$backend_type" = "xata" ]; then
    generate_svelte_xata_crud "$crud_dir" "$table_name" "$schema"
  elif [ "$backend_type" = "supabase" ]; then
    generate_svelte_supabase_crud "$crud_dir" "$table_name" "$schema"
  fi
  
  # Update navigation if possible
  update_svelte_navigation "$project_path" "$table_name"
  
  echo "✅ SvelteKit CRUD routes created at /src/routes/$table_name"
  return 0
}

# Function to generate Svelte CRUD with Xata
generate_svelte_xata_crud() {
  local crud_dir="$1"
  local table_name="$2"
  local schema="$3"
  
  local item_name=$(echo "$table_name" | sed -r 's/s$//; s/(.)/\u\1/g')
  if [ "$item_name" = "$table_name" ]; then
    # If no transformation happened, ensure it's singular
    item_name="${item_name}Item"
  fi
  
  # Create server file
  cat > "$crud_dir/+page.server.js" << EOF
import { XataClient } from '\$lib/xata';
import { fail } from '@sveltejs/kit';

// Initialize Xata client
const xata = new XataClient();

// Monkey Tip: You can customize query options (e.g., add sorting, filtering)
export async function load() {
  try {
    const items = await xata.db.${table_name}.getAll();
    return { items };
  } catch (error) {
    console.error('Error loading ${table_name}:', error);
    return { items: [], error: 'Failed to load data' };
  }
}

export const actions = {
  create: async ({ request }) => {
    const formData = await request.formData();
    const data = Object.fromEntries(formData);
    
    // Monkey Tip: Add validation here before creating records
    try {
      const newItem = await xata.db.${table_name}.create(data);
      return { success: true, item: newItem };
    } catch (error) {
      console.error('Error creating ${item_name}:', error);
      return fail(500, { error: 'Failed to create ${item_name}' });
    }
  },
  
  update: async ({ request }) => {
    const formData = await request.formData();
    const id = formData.get('id');
    
    if (!id) {
      return fail(400, { error: 'ID is required for updates' });
    }
    
    const data = Object.fromEntries(formData);
    delete data.id; // Remove ID from the data object
    
    try {
      const updated = await xata.db.${table_name}.update(id, data);
      return { success: true, item: updated };
    } catch (error) {
      console.error('Error updating ${item_name}:', error);
      return fail(500, { error: 'Failed to update ${item_name}' });
    }
  },
  
  delete: async ({ request }) => {
    const formData = await request.formData();
    const id = formData.get('id');
    
    if (!id) {
      return fail(400, { error: 'ID is required for deletion' });
    }
    
    try {
      await xata.db.${table_name}.delete(id);
      return { success: true };
    } catch (error) {
      console.error('Error deleting ${item_name}:', error);
      return fail(500, { error: 'Failed to delete ${item_name}' });
    }
  }
};
EOF

  # Create UI page based on the detected UI framework
  if [ "$UI_LIBRARY" = "daisyui" ]; then
    generate_svelte_daisyui_page "$crud_dir" "$table_name" "$schema"
  elif [ "$UI_LIBRARY" = "skeleton" ]; then
    generate_svelte_skeleton_page "$crud_dir" "$table_name" "$schema"
  elif [ "$UI_LIBRARY" = "flowbite" ]; then
    generate_svelte_flowbite_page "$crud_dir" "$table_name" "$schema"
  else
    # Default to tailwind
    generate_svelte_tailwind_page "$crud_dir" "$table_name" "$schema"
  fi
}

# Function to generate Svelte CRUD with Supabase
generate_svelte_supabase_crud() {
  local crud_dir="$1"
  local table_name="$2"
  local schema="$3"
  
  local item_name=$(echo "$table_name" | sed -r 's/s$//; s/(.)/\u\1/g')
  if [ "$item_name" = "$table_name" ]; then
    # If no transformation happened, ensure it's singular
    item_name="${item_name}Item"
  fi
  
  # Create server file
  cat > "$crud_dir/+page.server.js" << EOF
import { error, fail } from '@sveltejs/kit';
import { supabase } from '\$lib/supabaseClient';

export async function load() {
  try {
    const { data, error: err } = await supabase
      .from('${table_name}')
      .select('*');
      
    if (err) throw err;
    
    return { items: data || [] };
  } catch (err) {
    console.error('Error loading ${table_name}:', err);
    return { items: [], error: 'Failed to load data' };
  }
}

export const actions = {
  create: async ({ request }) => {
    const formData = await request.formData();
    const data = Object.fromEntries(formData);
    
    // Monkey Tip: Add validation here before creating records
    try {
      const { data: newItem, error: err } = await supabase
        .from('${table_name}')
        .insert(data)
        .select()
        .single();
        
      if (err) throw err;
      
      return { success: true, item: newItem };
    } catch (err) {
      console.error('Error creating ${item_name}:', err);
      return fail(500, { error: 'Failed to create ${item_name}' });
    }
  },
  
  update: async ({ request }) => {
    const formData = await request.formData();
    const id = formData.get('id');
    
    if (!id) {
      return fail(400, { error: 'ID is required for updates' });
    }
    
    const data = Object.fromEntries(formData);
    delete data.id; // Remove ID from the data object
    
    try {
      const { data: updated, error: err } = await supabase
        .from('${table_name}')
        .update(data)
        .eq('id', id)
        .select()
        .single();
        
      if (err) throw err;
      
      return { success: true, item: updated };
    } catch (err) {
      console.error('Error updating ${item_name}:', err);
      return fail(500, { error: 'Failed to update ${item_name}' });
    }
  },
  
  delete: async ({ request }) => {
    const formData = await request.formData();
    const id = formData.get('id');
    
    if (!id) {
      return fail(400, { error: 'ID is required for deletion' });
    }
    
    try {
      const { error: err } = await supabase
        .from('${table_name}')
        .delete()
        .eq('id', id);
        
      if (err) throw err;
      
      return { success: true };
    } catch (err) {
      console.error('Error deleting ${item_name}:', err);
      return fail(500, { error: 'Failed to delete ${item_name}' });
    }
  }
};
EOF

  # Create UI page based on the detected UI framework
  if [ "$UI_LIBRARY" = "daisyui" ]; then
    generate_svelte_daisyui_page "$crud_dir" "$table_name" "$schema"
  elif [ "$UI_LIBRARY" = "skeleton" ]; then
    generate_svelte_skeleton_page "$crud_dir" "$table_name" "$schema"
  elif [ "$UI_LIBRARY" = "flowbite" ]; then
    generate_svelte_flowbite_page "$crud_dir" "$table_name" "$schema"
  else
    # Default to tailwind
    generate_svelte_tailwind_page "$crud_dir" "$table_name" "$schema"
  fi
}

# Function to generate TailwindCSS UI for SvelteKit
generate_svelte_tailwind_page() {
  local crud_dir="$1"
  local table_name="$2"
  local schema="$3"
  
  local item_name=$(echo "$table_name" | sed -r 's/s$//; s/(.)/\u\1/g')
  if [ "$item_name" = "$table_name" ]; then
    # If no transformation happened, ensure it's singular
    item_name="${item_name}Item"
  fi
  
  # Create title case name for display
  local display_name=$(echo "$table_name" | sed -r 's/([A-Z])/ \1/g; s/^./\u&/; s/_/ /g')
  
  # Create fields from schema
  local fields=$(echo "$schema" | jq -r 'keys[] as $k | "\($k)"' 2>/dev/null)
  if [ -z "$fields" ]; then
    # Fallback if jq fails or schema is invalid
    fields="id name description created_at updated_at is_active priority"
  fi
  
  # Create the Svelte page with Tailwind styling
  cat > "$crud_dir/+page.svelte" << EOF
<script>
  import { enhance } from '\$app/forms';
  export let data;
  export let form;

  // Edit mode state
  let editMode = false;
  let currentItem = {};
  
  // Form state
  let formMode = 'create';
  
  // Helper to reset form
  function resetForm() {
    currentItem = {};
    formMode = 'create';
    editMode = false;
  }
  
  // Edit item function
  function editItem(item) {
    currentItem = { ...item };
    formMode = 'update';
    editMode = true;
  }
  
  // Format date helper
  function formatDate(dateString) {
    if (!dateString) return '';
    return new Date(dateString).toLocaleString();
  }
</script>

<svelte:head>
  <title>${display_name} Management</title>
</svelte:head>

<div class="container mx-auto p-4">
  <h1 class="text-3xl font-bold mb-6">${display_name} Management</h1>
  
  {#if form?.error}
    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4" role="alert">
      <span class="font-bold">Error:</span> {form.error}
    </div>
  {/if}
  
  {#if form?.success}
    <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4" role="alert">
      <span class="font-bold">Success!</span> Operation completed successfully.
    </div>
  {/if}
  
  <div class="grid md:grid-cols-2 gap-6">
    <!-- Form Section -->
    <div class="bg-white p-6 rounded-lg shadow-md">
      <h2 class="text-xl font-semibold mb-4">
        {formMode === 'create' ? 'Create' : 'Edit'} ${item_name}
      </h2>
      
      <form method="POST" action="?/${formMode}" use:enhance>
        {#if formMode === 'update'}
          <input type="hidden" name="id" value={currentItem.id} />
        {/if}
        
EOF

  # Generate form fields dynamically based on schema
  IFS=$'\n'
  for field in $fields; do
    # Skip id field in the form inputs
    if [ "$field" != "id" ] && [ "$field" != "created_at" ] && [ "$field" != "updated_at" ]; then
      # Convert snake_case to Title Case for labels
      label=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      # Determine field type
      if [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
        <div class="mb-4">
          <label for="${field}" class="block text-sm font-medium text-gray-700">${label}</label>
          <input 
            type="datetime-local" 
            id="${field}" 
            name="${field}" 
            bind:value={currentItem.${field}} 
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          />
        </div>
EOF
      elif [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
        <div class="mb-4">
          <label class="inline-flex items-center">
            <input 
              type="checkbox" 
              id="${field}" 
              name="${field}" 
              bind:checked={currentItem.${field}} 
              class="rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
            <span class="ml-2">${label}</span>
          </label>
        </div>
EOF
      elif [[ "$field" =~ priority ]] || [[ "$field" =~ count ]] || [[ "$field" =~ amount ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
        <div class="mb-4">
          <label for="${field}" class="block text-sm font-medium text-gray-700">${label}</label>
          <input 
            type="number" 
            id="${field}" 
            name="${field}" 
            bind:value={currentItem.${field}} 
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          />
        </div>
EOF
      elif [[ "$field" =~ description ]] || [[ "$field" =~ content ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
        <div class="mb-4">
          <label for="${field}" class="block text-sm font-medium text-gray-700">${label}</label>
          <textarea 
            id="${field}" 
            name="${field}" 
            bind:value={currentItem.${field}} 
            rows="3"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          ></textarea>
        </div>
EOF
      else
        cat >> "$crud_dir/+page.svelte" << EOF
        <div class="mb-4">
          <label for="${field}" class="block text-sm font-medium text-gray-700">${label}</label>
          <input 
            type="text" 
            id="${field}" 
            name="${field}" 
            bind:value={currentItem.${field}} 
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          />
        </div>
EOF
      fi
    fi
  done

  # Continue with the rest of the form and table
  cat >> "$crud_dir/+page.svelte" << EOF
        
        <div class="flex justify-between mt-6">
          <button
            type="submit"
            class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            {formMode === 'create' ? 'Create' : 'Update'} ${item_name}
          </button>
          
          {#if formMode === 'update'}
            <button
              type="button"
              on:click={resetForm}
              class="inline-flex justify-center py-2 px-4 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Cancel
            </button>
          {/if}
        </div>
      </form>
    </div>
    
    <!-- Table Section -->
    <div class="bg-white p-6 rounded-lg shadow-md">
      <h2 class="text-xl font-semibold mb-4">${display_name} List</h2>
      
      {#if !data.items || data.items.length === 0}
        <p class="text-gray-500">No ${display_name.toLowerCase()} found. Create one using the form.</p>
      {:else}
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
EOF

  # Generate table headers
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Convert snake_case to Title Case for headers
      header=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      cat >> "$crud_dir/+page.svelte" << EOF
                <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ${header}
                </th>
EOF
    fi
  done

  # Add actions column and continue with the table
  cat >> "$crud_dir/+page.svelte" << EOF
                <th class="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              {#each data.items as item (item.id)}
                <tr>
EOF

  # Generate table cells
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Handle different field types
      if [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
                  <td class="px-3 py-4 whitespace-nowrap text-sm text-gray-500">
                    {formatDate(item.${field})}
                  </td>
EOF
      elif [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
                  <td class="px-3 py-4 whitespace-nowrap text-sm text-gray-500">
                    {item.${field} ? '✅' : '❌'}
                  </td>
EOF
      else
        cat >> "$crud_dir/+page.svelte" << EOF
                  <td class="px-3 py-4 whitespace-nowrap text-sm text-gray-500">
                    {item.${field}}
                  </td>
EOF
      fi
    fi
  done

  # Add action buttons and finish the template
  cat >> "$crud_dir/+page.svelte" << EOF
                  <td class="px-3 py-4 whitespace-nowrap text-sm text-gray-500 space-x-2">
                    <button
                      on:click={() => editItem(item)}
                      class="text-indigo-600 hover:text-indigo-900"
                    >
                      Edit
                    </button>
                    
                    <form 
                      method="POST" 
                      action="?/delete" 
                      use:enhance 
                      class="inline"
                      onsubmit="return confirm('Are you sure you want to delete this item?');"
                    >
                      <input type="hidden" name="id" value={item.id} />
                      <button
                        type="submit"
                        class="text-red-600 hover:text-red-900"
                      >
                        Delete
                      </button>
                    </form>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {/if}
    </div>
  </div>
</div>

<style>
  /* Monkey Tip: Add your custom styles here if needed */
</style>
EOF
}

# Function to generate DaisyUI UI for SvelteKit
generate_svelte_daisyui_page() {
  local crud_dir="$1"
  local table_name="$2"
  local schema="$3"
  
  local item_name=$(echo "$table_name" | sed -r 's/s$//; s/(.)/\u\1/g')
  if [ "$item_name" = "$table_name" ]; then
    # If no transformation happened, ensure it's singular
    item_name="${item_name}Item"
  fi
  
  # Create title case name for display
  local display_name=$(echo "$table_name" | sed -r 's/([A-Z])/ \1/g; s/^./\u&/; s/_/ /g')
  
  # Create fields from schema
  local fields=$(echo "$schema" | jq -r 'keys[] as $k | "\($k)"' 2>/dev/null)
  if [ -z "$fields" ]; then
    # Fallback if jq fails or schema is invalid
    fields="id name description created_at updated_at is_active priority"
  fi
  
  # Create the Svelte page with DaisyUI styling
  cat > "$crud_dir/+page.svelte" << EOF
<script>
  import { enhance } from '\$app/forms';
  export let data;
  export let form;

  // Edit mode state
  let editMode = false;
  let currentItem = {};
  
  // Form state
  let formMode = 'create';
  
  // Helper to reset form
  function resetForm() {
    currentItem = {};
    formMode = 'create';
    editMode = false;
  }
  
  // Edit item function
  function editItem(item) {
    currentItem = { ...item };
    formMode = 'update';
    editMode = true;
  }
  
  // Format date helper
  function formatDate(dateString) {
    if (!dateString) return '';
    return new Date(dateString).toLocaleString();
  }
</script>

<svelte:head>
  <title>${display_name} Management</title>
</svelte:head>

<div class="container mx-auto p-4">
  <h1 class="text-3xl font-bold mb-6">${display_name} Management</h1>
  
  {#if form?.error}
    <div class="alert alert-error mb-4">
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
      <span>{form.error}</span>
    </div>
  {/if}
  
  {#if form?.success}
    <div class="alert alert-success mb-4">
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
      <span>Operation completed successfully.</span>
    </div>
  {/if}
  
  <div class="grid md:grid-cols-2 gap-6">
    <!-- Form Section -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">
          {formMode === 'create' ? 'Create' : 'Edit'} ${item_name}
        </h2>
        
        <form method="POST" action="?/${formMode}" use:enhance>
          {#if formMode === 'update'}
            <input type="hidden" name="id" value={currentItem.id} />
          {/if}
          
EOF

  # Generate form fields dynamically based on schema
  IFS=$'\n'
  for field in $fields; do
    # Skip id field in the form inputs
    if [ "$field" != "id" ] && [ "$field" != "created_at" ] && [ "$field" != "updated_at" ]; then
      # Convert snake_case to Title Case for labels
      label=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      # Determine field type
      if [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
          <div class="form-control w-full mb-4">
            <label for="${field}" class="label">
              <span class="label-text">${label}</span>
            </label>
            <input 
              type="datetime-local" 
              id="${field}" 
              name="${field}" 
              bind:value={currentItem.${field}} 
              class="input input-bordered w-full"
            />
          </div>
EOF
      elif [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
          <div class="form-control mb-4">
            <label class="label cursor-pointer">
              <span class="label-text">${label}</span>
              <input 
                type="checkbox" 
                id="${field}" 
                name="${field}" 
                bind:checked={currentItem.${field}} 
                class="checkbox checkbox-primary"
              />
            </label>
          </div>
EOF
      elif [[ "$field" =~ priority ]] || [[ "$field" =~ count ]] || [[ "$field" =~ amount ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
          <div class="form-control w-full mb-4">
            <label for="${field}" class="label">
              <span class="label-text">${label}</span>
            </label>
            <input 
              type="number" 
              id="${field}" 
              name="${field}" 
              bind:value={currentItem.${field}} 
              class="input input-bordered w-full"
            />
          </div>
EOF
      elif [[ "$field" =~ description ]] || [[ "$field" =~ content ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
          <div class="form-control w-full mb-4">
            <label for="${field}" class="label">
              <span class="label-text">${label}</span>
            </label>
            <textarea 
              id="${field}" 
              name="${field}" 
              bind:value={currentItem.${field}} 
              rows="3"
              class="textarea textarea-bordered w-full"
            ></textarea>
          </div>
EOF
      else
        cat >> "$crud_dir/+page.svelte" << EOF
          <div class="form-control w-full mb-4">
            <label for="${field}" class="label">
              <span class="label-text">${label}</span>
            </label>
            <input 
              type="text" 
              id="${field}" 
              name="${field}" 
              bind:value={currentItem.${field}} 
              class="input input-bordered w-full"
            />
          </div>
EOF
      fi
    fi
  done

  # Continue with the rest of the form and table
  cat >> "$crud_dir/+page.svelte" << EOF
        
          <div class="card-actions justify-between mt-6">
            <button
              type="submit"
              class="btn btn-primary"
            >
              {formMode === 'create' ? 'Create' : 'Update'} ${item_name}
            </button>
            
            {#if formMode === 'update'}
              <button
                type="button"
                on:click={resetForm}
                class="btn btn-ghost"
              >
                Cancel
              </button>
            {/if}
          </div>
        </form>
      </div>
    </div>
    
    <!-- Table Section -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">${display_name} List</h2>
        
        {#if !data.items || data.items.length === 0}
          <div class="alert alert-info">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <span>No ${display_name.toLowerCase()} found. Create one using the form.</span>
          </div>
        {:else}
          <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
              <thead>
                <tr>
EOF

  # Generate table headers
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Convert snake_case to Title Case for headers
      header=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      cat >> "$crud_dir/+page.svelte" << EOF
                  <th>${header}</th>
EOF
    fi
  done

  # Add actions column and continue with the table
  cat >> "$crud_dir/+page.svelte" << EOF
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {#each data.items as item (item.id)}
                  <tr>
EOF

  # Generate table cells
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Handle different field types
      if [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
                    <td>{formatDate(item.${field})}</td>
EOF
      elif [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$crud_dir/+page.svelte" << EOF
                    <td>
                      {#if item.${field}}
                        <span class="badge badge-success">Yes</span>
                      {:else}
                        <span class="badge badge-ghost">No</span>
                      {/if}
                    </td>
EOF
      else
        cat >> "$crud_dir/+page.svelte" << EOF
                    <td>{item.${field}}</td>
EOF
      fi
    fi
  done

  # Add action buttons and finish the template
  cat >> "$crud_dir/+page.svelte" << EOF
                    <td>
                      <div class="flex space-x-2">
                        <button
                          on:click={() => editItem(item)}
                          class="btn btn-sm btn-info"
                        >
                          Edit
                        </button>
                        
                        <form 
                          method="POST" 
                          action="?/delete" 
                          use:enhance 
                          class="inline"
                          onsubmit="return confirm('Are you sure you want to delete this item?');"
                        >
                          <input type="hidden" name="id" value={item.id} />
                          <button
                            type="submit"
                            class="btn btn-sm btn-error"
                          >
                            Delete
                          </button>
                        </form>
                      </div>
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>

<!-- Monkey Tip: You can customize this component by importing global styles or adding your own -->
EOF
}

# Function to update navigation in SvelteKit app
update_svelte_navigation() {
  local project_path="$1"
  local table_name="$2"
  
  # Create title case name for display
  local display_name=$(echo "$table_name" | sed -r 's/([A-Z])/ \1/g; s/^./\u&/; s/_/ /g')
  
  # Try to update navigation in layout if it exists
  if [ -f "$project_path/src/routes/+layout.svelte" ]; then
    echo "🔄 Updating navigation to include $table_name..."
    
    # Create temporary file
    local temp_file=$(mktemp -t "svelte_nav_XXXXXX") || {
      echo "❌ Failed to create temporary file."
      return 1
    }
    
    # Ensure cleanup
    trap "rm -f '$temp_file'" EXIT
    
    # Check if we can find a navigation section
    if grep -q "<nav" "$project_path/src/routes/+layout.svelte"; then
      # Try to add navigation link
      awk -v table="$table_name" -v name="$display_name" '{
        if ($0 ~ /<\/nav>/) {
          # This adds a link right before the closing nav tag
          print "        <a href=\"/" table "\" class=\"btn btn-ghost\">Manage " name "</a>"
          print $0
        } else {
          print $0
        }
      }' "$project_path/src/routes/+layout.svelte" > "$temp_file"
      
      # Replace the file
      mv "$temp_file" "$project_path/src/routes/+layout.svelte"
      echo "✅ Added navigation link to $display_name management page."
    else
      echo "⚠️ Could not find navigation in layout. Manual navigation update needed."
    fi
    
    # Clean up trap
    trap - EXIT
  fi
}

# Add function declarations for the other UI frameworks here
generate_svelte_skeleton_page() {
  local crud_dir="$1"
  local table_name="$2"
  local schema="$3"
  
  # Generate a Skeleton UI version - for simplicity we'll use the Tailwind version for now
  # This would be expanded in the full implementation
  generate_svelte_tailwind_page "$crud_dir" "$table_name" "$schema"
  
  echo "⚠️ Skeleton UI template is using Tailwind CSS as a base. Customize for full Skeleton UI features."
}

generate_svelte_flowbite_page() {
  local crud_dir="$1"
  local table_name="$2"
  local schema="$3"
  
  # Generate a Flowbite version - for simplicity we'll use the Tailwind version for now
  # This would be expanded in the full implementation
  generate_svelte_tailwind_page "$crud_dir" "$table_name" "$schema"
  
  echo "⚠️ Flowbite template is using Tailwind CSS as a base. Customize for full Flowbite features."
}

# Node (Express) CRUD generator to be implemented in part 2
generate_node_crud() {
  local project_path="$1"
  local backend_type="$2"
  local table_name="$3"
  local schema="$4"
  
  echo "Node.js CRUD generator coming in part 2!"
  return 0
}

# Static site CRUD generator to be implemented in part 2
generate_static_crud() {
  local project_path="$1"
  local backend_type="$2"
  local table_name="$3"
  local schema="$4"
  
  echo "Static site CRUD generator coming in part 2!"
  return 0
}