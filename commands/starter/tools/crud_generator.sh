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

# Node (Express) CRUD generator
generate_node_crud() {
  local project_path="$1"
  local backend_type="$2"
  local table_name="$3"
  local schema="$4"
  
  echo ""
  typewriter "🚀 Generating CRUD for Node.js/Express with $backend_type..." 0.01
  
  # Create necessary directories for a well-structured Express app
  local routes_dir="$project_path/routes"
  local controllers_dir="$project_path/controllers"
  local views_dir="$project_path/views"
  
  mkdir -p "$routes_dir" "$controllers_dir" "$views_dir"
  
  # Create files based on backend type
  if [ "$backend_type" = "xata" ]; then
    generate_node_xata_crud "$project_path" "$routes_dir" "$controllers_dir" "$views_dir" "$table_name" "$schema"
  elif [ "$backend_type" = "supabase" ]; then
    generate_node_supabase_crud "$project_path" "$routes_dir" "$controllers_dir" "$views_dir" "$table_name" "$schema"
  fi
  
  # Update app.js to include the new routes
  update_express_app "$project_path" "$table_name"
  
  echo "✅ Express CRUD routes and controllers created successfully"
  return 0
}

# Function to generate Express CRUD with Xata
generate_node_xata_crud() {
  local project_path="$1"
  local routes_dir="$2"
  local controllers_dir="$3"
  local views_dir="$4"
  local table_name="$5"
  local schema="$6"
  
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
  
  # 1. Create controller file
  cat > "$controllers_dir/${table_name}Controller.js" << EOF
/**
 * ${display_name} Controller
 * Handles CRUD operations for ${table_name}
 */

const { XataClient } = require('../src/lib/xata');

// Initialize Xata client
const xata = new XataClient();

// Monkey Tip: You can customize these controller functions to add validation, 
// filtering or pagination

/**
 * Get all ${table_name}
 */
exports.getAll = async (req, res) => {
  try {
    const items = await xata.db.${table_name}.getAll();
    res.render('${table_name}/index', { 
      title: '${display_name} Management',
      items
    });
  } catch (error) {
    console.error('Error fetching ${table_name}:', error);
    res.status(500).render('error', { 
      message: 'Failed to load ${table_name}',
      error
    });
  }
};

/**
 * Show the form to create a new ${item_name}
 */
exports.createForm = async (req, res) => {
  res.render('${table_name}/form', { 
    title: 'Create New ${item_name}',
    item: {},
    action: '/api/${table_name}',
    method: 'POST'
  });
};

/**
 * Create a new ${item_name}
 */
exports.create = async (req, res) => {
  try {
    // Parse form data
    const data = req.body;
    
    // Convert checkbox values to boolean
    Object.keys(data).forEach(key => {
      if (data[key] === 'on') {
        data[key] = true;
      }
    });
    
    // Create new record
    const newItem = await xata.db.${table_name}.create(data);
    
    // Redirect to the list page with success message
    req.flash('success', '${item_name} created successfully');
    res.redirect('/api/${table_name}');
  } catch (error) {
    console.error('Error creating ${item_name}:', error);
    req.flash('error', 'Failed to create ${item_name}');
    res.redirect('/api/${table_name}/create');
  }
};

/**
 * Show the form to edit an existing ${item_name}
 */
exports.editForm = async (req, res) => {
  try {
    const id = req.params.id;
    const item = await xata.db.${table_name}.read(id);
    
    if (!item) {
      req.flash('error', '${item_name} not found');
      return res.redirect('/api/${table_name}');
    }
    
    res.render('${table_name}/form', { 
      title: 'Edit ${item_name}',
      item,
      action: \`/api/${table_name}/\${id}?_method=PUT\`,
      method: 'POST'
    });
  } catch (error) {
    console.error('Error fetching ${item_name} for edit:', error);
    req.flash('error', 'Failed to load ${item_name} for editing');
    res.redirect('/api/${table_name}');
  }
};

/**
 * Update an existing ${item_name}
 */
exports.update = async (req, res) => {
  try {
    const id = req.params.id;
    
    // Parse form data
    const data = req.body;
    
    // Convert checkbox values to boolean and handle unchecked boxes
    const booleanFields = ['is_active', 'enabled', 'active']; // Add your boolean field names
    booleanFields.forEach(field => {
      if (field in data && data[field] === 'on') {
        data[field] = true;
      } else {
        data[field] = false;
      }
    });
    
    // Update the record
    await xata.db.${table_name}.update(id, data);
    
    // Redirect to the list page with success message
    req.flash('success', '${item_name} updated successfully');
    res.redirect('/api/${table_name}');
  } catch (error) {
    console.error('Error updating ${item_name}:', error);
    req.flash('error', 'Failed to update ${item_name}');
    res.redirect(\`/api/${table_name}/\${req.params.id}/edit\`);
  }
};

/**
 * Delete an ${item_name}
 */
exports.delete = async (req, res) => {
  try {
    const id = req.params.id;
    
    // Delete the record
    await xata.db.${table_name}.delete(id);
    
    // Redirect to the list page with success message
    req.flash('success', '${item_name} deleted successfully');
    res.redirect('/api/${table_name}');
  } catch (error) {
    console.error('Error deleting ${item_name}:', error);
    req.flash('error', 'Failed to delete ${item_name}');
    res.redirect('/api/${table_name}');
  }
};
EOF

  # 2. Create routes file
  cat > "$routes_dir/${table_name}.js" << EOF
/**
 * ${display_name} Routes
 * Handles all routes for ${table_name} CRUD operations
 */

const express = require('express');
const router = express.Router();
const ${table_name}Controller = require('../controllers/${table_name}Controller');

// Monkey Tip: You can add middleware such as authentication checks here
// Example: const auth = require('../middleware/auth');
// Then apply it like: router.get('/', auth.required, ${table_name}Controller.getAll);

// Create a new ${item_name} - GET form and POST submission
router.get('/create', ${table_name}Controller.createForm);
router.post('/', ${table_name}Controller.create);

// Read all ${table_name}
router.get('/', ${table_name}Controller.getAll);

// Update an existing ${item_name} - GET form and PUT submission
router.get('/:id/edit', ${table_name}Controller.editForm);
router.put('/:id', ${table_name}Controller.update);

// Delete an ${item_name}
router.delete('/:id', ${table_name}Controller.delete);

module.exports = router;
EOF

  # 3. Create view directory
  mkdir -p "$views_dir/$table_name"
  
  # 4. Create index view (list of items)
  cat > "$views_dir/$table_name/index.ejs" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= title %></title>
  <link rel="stylesheet" href="/css/styles.css">
  <style>
    .container { max-width: 1200px; margin: 0 auto; padding: 1rem; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(600px, 1fr)); gap: 1rem; }
    .card { border: 1px solid #eaeaea; border-radius: 0.5rem; padding: 1rem; margin-bottom: 1rem; }
    .alert { padding: 0.75rem 1.25rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: 0.25rem; }
    .alert-success { color: #155724; background-color: #d4edda; border-color: #c3e6cb; }
    .alert-danger { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; }
    .flex { display: flex; }
    .justify-between { justify-content: space-between; }
    .btn {
      display: inline-block;
      font-weight: 400;
      text-align: center;
      vertical-align: middle;
      cursor: pointer;
      padding: 0.375rem 0.75rem;
      font-size: 1rem;
      line-height: 1.5;
      border-radius: 0.25rem;
      transition: color 0.15s ease-in-out, background-color 0.15s ease-in-out;
      text-decoration: none;
    }
    .btn-primary { color: #fff; background-color: #4299e1; }
    .btn-info { color: #fff; background-color: #38b2ac; }
    .btn-danger { color: #fff; background-color: #e53e3e; }
    .btn-sm { padding: 0.25rem 0.5rem; font-size: 0.875rem; }
    table { border-collapse: collapse; width: 100%; }
    th, td { padding: 0.5rem; text-align: left; border-bottom: 1px solid #eaeaea; }
    th { background-color: #f9fafb; }
  </style>
</head>
<body>
  <div class="container">
    <h1><%= title %></h1>
    
    <% if (messages && messages.success) { %>
      <div class="alert alert-success">
        <%= messages.success %>
      </div>
    <% } %>
    
    <% if (messages && messages.error) { %>
      <div class="alert alert-danger">
        <%= messages.error %>
      </div>
    <% } %>
    
    <div class="flex justify-between mb-4">
      <p><%= items.length %> items found</p>
      <a href="/api/${table_name}/create" class="btn btn-primary">Create New ${item_name}</a>
    </div>
    
    <% if (items.length > 0) { %>
      <div class="card">
        <table>
          <thead>
            <tr>
EOF

  # Generate table headers
  IFS=$'\n'
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Convert snake_case to Title Case for headers
      header=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      cat >> "$views_dir/$table_name/index.ejs" << EOF
              <th>${header}</th>
EOF
    fi
  done

  # Add actions column and continue with the table
  cat >> "$views_dir/$table_name/index.ejs" << EOF
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <% items.forEach(item => { %>
              <tr>
EOF

  # Generate table cells
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Handle different field types
      if [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$views_dir/$table_name/index.ejs" << EOF
                <td><%= item.${field} ? new Date(item.${field}).toLocaleString() : '-' %></td>
EOF
      elif [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$views_dir/$table_name/index.ejs" << EOF
                <td><%= item.${field} ? '✅' : '❌' %></td>
EOF
      else
        cat >> "$views_dir/$table_name/index.ejs" << EOF
                <td><%= item.${field} %></td>
EOF
      fi
    fi
  done

  # Add action buttons and finish the template
  cat >> "$views_dir/$table_name/index.ejs" << EOF
                <td>
                  <div class="flex">
                    <a href="/api/${table_name}/<%= item.id %>/edit" class="btn btn-info btn-sm mr-2">Edit</a>
                    
                    <form action="/api/${table_name}/<%= item.id %>?_method=DELETE" method="POST" onsubmit="return confirm('Are you sure you want to delete this item?');">
                      <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                    </form>
                  </div>
                </td>
              </tr>
            <% }); %>
          </tbody>
        </table>
      </div>
    <% } else { %>
      <div class="card">
        <p>No ${table_name} found. Create one using the button above.</p>
      </div>
    <% } %>
    
    <div class="mt-4">
      <a href="/" class="btn">Back to Home</a>
    </div>
  </div>
  
  <script>
    // Monkey Tip: Add your custom scripts here
    // Example: Auto-hide alerts after 5 seconds
    setTimeout(() => {
      const alerts = document.querySelectorAll('.alert');
      alerts.forEach(alert => {
        alert.style.display = 'none';
      });
    }, 5000);
  </script>
</body>
</html>
EOF

  # 5. Create form view (create/edit items)
  cat > "$views_dir/$table_name/form.ejs" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= title %></title>
  <link rel="stylesheet" href="/css/styles.css">
  <style>
    .container { max-width: 800px; margin: 0 auto; padding: 1rem; }
    .card { border: 1px solid #eaeaea; border-radius: 0.5rem; padding: 1.5rem; margin-bottom: 1rem; }
    .form-group { margin-bottom: 1rem; }
    .form-group label { display: block; margin-bottom: 0.5rem; font-weight: 500; }
    .form-control {
      display: block;
      width: 100%;
      padding: 0.375rem 0.75rem;
      font-size: 1rem;
      line-height: 1.5;
      color: #495057;
      background-color: #fff;
      background-clip: padding-box;
      border: 1px solid #ced4da;
      border-radius: 0.25rem;
      transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
    }
    .btn {
      display: inline-block;
      font-weight: 400;
      text-align: center;
      vertical-align: middle;
      cursor: pointer;
      padding: 0.375rem 0.75rem;
      font-size: 1rem;
      line-height: 1.5;
      border-radius: 0.25rem;
      transition: color 0.15s ease-in-out, background-color 0.15s ease-in-out;
      text-decoration: none;
    }
    .btn-primary { color: #fff; background-color: #4299e1; border: none; }
    .btn-secondary { color: #fff; background-color: #718096; border: none; }
    .flex { display: flex; }
    .justify-between { justify-content: space-between; }
    .mb-4 { margin-bottom: 1rem; }
  </style>
</head>
<body>
  <div class="container">
    <h1><%= title %></h1>
    
    <% if (messages && messages.error) { %>
      <div class="alert alert-danger">
        <%= messages.error %>
      </div>
    <% } %>
    
    <div class="card">
      <form action="<%= action %>" method="<%= method %>">
EOF

  # Generate form fields
  for field in $fields; do
    # Skip id field in the form inputs
    if [ "$field" != "id" ] && [ "$field" != "created_at" ] && [ "$field" != "updated_at" ]; then
      # Convert snake_case to Title Case for labels
      label=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      # Determine field type
      if [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$views_dir/$table_name/form.ejs" << EOF
        <div class="form-group">
          <label for="${field}">${label}</label>
          <input 
            type="datetime-local" 
            id="${field}" 
            name="${field}" 
            value="<%= item.${field} ? new Date(item.${field}).toISOString().slice(0, 16) : '' %>"
            class="form-control"
          />
        </div>
EOF
      elif [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$views_dir/$table_name/form.ejs" << EOF
        <div class="form-group">
          <label>
            <input 
              type="checkbox" 
              id="${field}" 
              name="${field}" 
              <%= item.${field} ? 'checked' : '' %> 
            />
            ${label}
          </label>
        </div>
EOF
      elif [[ "$field" =~ priority ]] || [[ "$field" =~ count ]] || [[ "$field" =~ amount ]]; then
        cat >> "$views_dir/$table_name/form.ejs" << EOF
        <div class="form-group">
          <label for="${field}">${label}</label>
          <input 
            type="number" 
            id="${field}" 
            name="${field}" 
            value="<%= item.${field} || '' %>" 
            class="form-control"
          />
        </div>
EOF
      elif [[ "$field" =~ description ]] || [[ "$field" =~ content ]]; then
        cat >> "$views_dir/$table_name/form.ejs" << EOF
        <div class="form-group">
          <label for="${field}">${label}</label>
          <textarea 
            id="${field}" 
            name="${field}" 
            rows="4"
            class="form-control"
          ><%= item.${field} || '' %></textarea>
        </div>
EOF
      else
        cat >> "$views_dir/$table_name/form.ejs" << EOF
        <div class="form-group">
          <label for="${field}">${label}</label>
          <input 
            type="text" 
            id="${field}" 
            name="${field}" 
            value="<%= item.${field} || '' %>" 
            class="form-control"
          />
        </div>
EOF
      fi
    fi
  done

  # Finish the form view
  cat >> "$views_dir/$table_name/form.ejs" << EOF
        
        <div class="flex justify-between mt-4">
          <button type="submit" class="btn btn-primary">Save</button>
          <a href="/api/${table_name}" class="btn btn-secondary">Cancel</a>
        </div>
      </form>
    </div>
  </div>
</body>
</html>
EOF

  # 6. Create error view if it doesn't exist
  if [ ! -f "$views_dir/error.ejs" ]; then
    cat > "$views_dir/error.ejs" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Error</title>
  <style>
    .container { max-width: 800px; margin: 0 auto; padding: 2rem; }
    .error-title { color: #e53e3e; }
    pre { background-color: #f7fafc; padding: 1rem; border-radius: 0.25rem; overflow-x: auto; }
    .btn {
      display: inline-block;
      padding: 0.5rem 1rem;
      background-color: #4299e1;
      color: white;
      text-decoration: none;
      border-radius: 0.25rem;
      margin-top: 1rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1 class="error-title">Error</h1>
    <h2><%= message %></h2>
    <% if (error && error.stack) { %>
      <pre><%= error.stack %></pre>
    <% } %>
    <a href="javascript:history.back()" class="btn">Go Back</a>
  </div>
</body>
</html>
EOF
  fi
}

# Function to generate Express CRUD with Supabase
generate_node_supabase_crud() {
  local project_path="$1"
  local routes_dir="$2"
  local controllers_dir="$3"
  local views_dir="$4"
  local table_name="$5"
  local schema="$6"
  
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
  
  # 1. Create controller file
  cat > "$controllers_dir/${table_name}Controller.js" << EOF
/**
 * ${display_name} Controller
 * Handles CRUD operations for ${table_name}
 */

const { createClient } = require('@supabase/supabase-js');

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL || 'http://localhost:54321';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
const supabase = createClient(supabaseUrl, supabaseKey);

// Monkey Tip: You can customize these controller functions to add validation, 
// filtering or pagination

/**
 * Get all ${table_name}
 */
exports.getAll = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('${table_name}')
      .select('*')
      .order('created_at', { ascending: false });
      
    if (error) throw error;
    
    res.render('${table_name}/index', { 
      title: '${display_name} Management',
      items: data || []
    });
  } catch (error) {
    console.error('Error fetching ${table_name}:', error);
    res.status(500).render('error', { 
      message: 'Failed to load ${table_name}',
      error
    });
  }
};

/**
 * Show the form to create a new ${item_name}
 */
exports.createForm = async (req, res) => {
  res.render('${table_name}/form', { 
    title: 'Create New ${item_name}',
    item: {},
    action: '/api/${table_name}',
    method: 'POST'
  });
};

/**
 * Create a new ${item_name}
 */
exports.create = async (req, res) => {
  try {
    // Parse form data
    const data = req.body;
    
    // Convert checkbox values to boolean
    Object.keys(data).forEach(key => {
      if (data[key] === 'on') {
        data[key] = true;
      }
    });
    
    // Create new record
    const { data: newItem, error } = await supabase
      .from('${table_name}')
      .insert(data)
      .select()
      .single();
      
    if (error) throw error;
    
    // Redirect to the list page with success message
    req.flash('success', '${item_name} created successfully');
    res.redirect('/api/${table_name}');
  } catch (error) {
    console.error('Error creating ${item_name}:', error);
    req.flash('error', 'Failed to create ${item_name}');
    res.redirect('/api/${table_name}/create');
  }
};

/**
 * Show the form to edit an existing ${item_name}
 */
exports.editForm = async (req, res) => {
  try {
    const id = req.params.id;
    
    const { data: item, error } = await supabase
      .from('${table_name}')
      .select('*')
      .eq('id', id)
      .single();
      
    if (error) throw error;
    
    if (!item) {
      req.flash('error', '${item_name} not found');
      return res.redirect('/api/${table_name}');
    }
    
    res.render('${table_name}/form', { 
      title: 'Edit ${item_name}',
      item,
      action: \`/api/${table_name}/\${id}?_method=PUT\`,
      method: 'POST'
    });
  } catch (error) {
    console.error('Error fetching ${item_name} for edit:', error);
    req.flash('error', 'Failed to load ${item_name} for editing');
    res.redirect('/api/${table_name}');
  }
};

/**
 * Update an existing ${item_name}
 */
exports.update = async (req, res) => {
  try {
    const id = req.params.id;
    
    // Parse form data
    const data = req.body;
    
    // Convert checkbox values to boolean and handle unchecked boxes
    const booleanFields = ['is_active', 'enabled', 'active']; // Add your boolean field names
    booleanFields.forEach(field => {
      if (field in data && data[field] === 'on') {
        data[field] = true;
      } else {
        data[field] = false;
      }
    });
    
    // Update the record
    const { error } = await supabase
      .from('${table_name}')
      .update(data)
      .eq('id', id);
      
    if (error) throw error;
    
    // Redirect to the list page with success message
    req.flash('success', '${item_name} updated successfully');
    res.redirect('/api/${table_name}');
  } catch (error) {
    console.error('Error updating ${item_name}:', error);
    req.flash('error', 'Failed to update ${item_name}');
    res.redirect(\`/api/${table_name}/\${req.params.id}/edit\`);
  }
};

/**
 * Delete an ${item_name}
 */
exports.delete = async (req, res) => {
  try {
    const id = req.params.id;
    
    // Delete the record
    const { error } = await supabase
      .from('${table_name}')
      .delete()
      .eq('id', id);
      
    if (error) throw error;
    
    // Redirect to the list page with success message
    req.flash('success', '${item_name} deleted successfully');
    res.redirect('/api/${table_name}');
  } catch (error) {
    console.error('Error deleting ${item_name}:', error);
    req.flash('error', 'Failed to delete ${item_name}');
    res.redirect('/api/${table_name}');
  }
};
EOF

  # 2. Create routes file - same as Xata
  cat > "$routes_dir/${table_name}.js" << EOF
/**
 * ${display_name} Routes
 * Handles all routes for ${table_name} CRUD operations
 */

const express = require('express');
const router = express.Router();
const ${table_name}Controller = require('../controllers/${table_name}Controller');

// Monkey Tip: You can add middleware such as authentication checks here
// Example: const auth = require('../middleware/auth');
// Then apply it like: router.get('/', auth.required, ${table_name}Controller.getAll);

// Create a new ${item_name} - GET form and POST submission
router.get('/create', ${table_name}Controller.createForm);
router.post('/', ${table_name}Controller.create);

// Read all ${table_name}
router.get('/', ${table_name}Controller.getAll);

// Update an existing ${item_name} - GET form and PUT submission
router.get('/:id/edit', ${table_name}Controller.editForm);
router.put('/:id', ${table_name}Controller.update);

// Delete an ${item_name}
router.delete('/:id', ${table_name}Controller.delete);

module.exports = router;
EOF

  # 3. Create view directory
  mkdir -p "$views_dir/$table_name"
  
  # 4/5. Create views - reuse the same views as for Xata, they're identical
  # Index view
  generate_node_xata_crud "$project_path" "$routes_dir" "$controllers_dir" "$views_dir" "$table_name" "$schema"
}

# Function to update Express app.js to include the new routes
update_express_app() {
  local project_path="$1"
  local table_name="$2"
  
  # Look for app.js or index.js
  local app_file=""
  if [ -f "$project_path/app.js" ]; then
    app_file="$project_path/app.js"
  elif [ -f "$project_path/index.js" ]; then
    app_file="$project_path/index.js"
  else
    echo "⚠️ Could not find app.js or index.js. You will need to manually add the routes."
    return 1
  fi
  
  # Create temporary file
  local temp_file=$(mktemp -t "express_app_XXXXXX")
  trap "rm -f '$temp_file'" EXIT
  
  # Look for a good spot to add our routes
  if grep -q "app\.use.*api" "$app_file"; then
    # Add route after another API route
    awk -v table="$table_name" '{
      print $0
      if ($0 ~ /app\.use.*\/api/ && !added) {
        print "app.use(\"/api/" table "\", require(\"./routes/" table "\"));"
        added = 1
      }
    }' "$app_file" > "$temp_file"
  elif grep -q "app\.use" "$app_file"; then
    # Add route after any app.use
    awk -v table="$table_name" '{
      print $0
      if ($0 ~ /app\.use/ && !added) {
        print "\n// " table " API routes"
        print "app.use(\"/api/" table "\", require(\"./routes/" table "\"));"
        added = 1
      }
    }' "$app_file" > "$temp_file"
  else
    # Add at the end of the file
    cat "$app_file" > "$temp_file"
    echo -e "\n// $table_name API routes" >> "$temp_file"
    echo "app.use(\"/api/$table_name\", require(\"./routes/$table_name\"));" >> "$temp_file"
  fi
  
  # Replace the file
  mv "$temp_file" "$app_file"
  
  # Check if method-override is installed
  if ! grep -q "method-override" "$app_file"; then
    echo "⚠️ This CRUD implementation uses method-override for PUT/DELETE requests."
    echo "Add these to your Express app:"
    echo "   const methodOverride = require('method-override');"
    echo "   app.use(methodOverride('_method'));"
    echo ""
    echo "And install with: npm install method-override"
  fi
  
  # Check if express-flash is installed
  if ! grep -q "express-flash" "$app_file"; then
    echo "⚠️ This CRUD implementation uses express-flash for flash messages."
    echo "Add these to your Express app:"
    echo "   const flash = require('express-flash');"
    echo "   app.use(flash());"
    echo ""
    echo "And install with: npm install express-flash"
  fi
  
  # Clean up trap
  trap - EXIT
  return 0
}

# Static site CRUD generator
generate_static_crud() {
  local project_path="$1"
  local backend_type="$2"
  local table_name="$3"
  local schema="$4"
  
  echo ""
  typewriter "🚀 Generating CRUD for static site with $backend_type..." 0.01
  
  # Create necessary directories
  local js_dir="$project_path/js"
  local css_dir="$project_path/css"
  mkdir -p "$js_dir" "$css_dir"
  
  # Generate HTML, JS, and CSS files
  if [ "$backend_type" = "xata" ]; then
    generate_static_xata_crud "$project_path" "$js_dir" "$css_dir" "$table_name" "$schema"
  elif [ "$backend_type" = "supabase" ]; then
    generate_static_supabase_crud "$project_path" "$js_dir" "$css_dir" "$table_name" "$schema"
  fi
  
  echo "✅ Static site CRUD files created successfully"
  return 0
}

# Function to generate static site CRUD with Xata
generate_static_xata_crud() {
  local project_path="$1"
  local js_dir="$2"
  local css_dir="$3"
  local table_name="$4"
  local schema="$5"
  
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
  
  # 1. Create JS file for Xata operations
  cat > "$js_dir/${table_name}.js" << EOF
/**
 * ${display_name} CRUD Module
 * Static site implementation using Xata client
 */

// Import the Xata client
import { XataClient } from '../lib/xata.js';

// Initialize global state
let items = [];
let currentItem = null;
let isEditing = false;

// DOM Elements (will be set on page load)
let itemList;
let itemForm;
let messageContainer;

// Initialize the Xata client
const xata = new XataClient();

// Monkey Tip: You can customize these functions to add validation,
// filtering, or pagination

/**
 * Load all ${table_name} from the database
 */
async function loadItems() {
  try {
    showLoading(true);
    
    // Clear any previous messages
    showMessage('');
    
    // Get items from database
    items = await xata.db.${table_name}.getAll();
    
    // Render the list
    renderItems();
    
    showLoading(false);
  } catch (error) {
    console.error('Error loading ${table_name}:', error);
    showMessage('Failed to load ${table_name}', 'error');
    showLoading(false);
  }
}

/**
 * Create a new ${item_name}
 */
async function createItem(data) {
  try {
    showLoading(true);
    
    // Create the item in the database
    const newItem = await xata.db.${table_name}.create(data);
    
    // Add to our local items array
    items.push(newItem);
    
    // Update the UI
    renderItems();
    resetForm();
    showMessage('${item_name} created successfully', 'success');
    
    showLoading(false);
  } catch (error) {
    console.error('Error creating ${item_name}:', error);
    showMessage('Failed to create ${item_name}', 'error');
    showLoading(false);
  }
}

/**
 * Update an existing ${item_name}
 */
async function updateItem(id, data) {
  try {
    showLoading(true);
    
    // Update the item in the database
    const updated = await xata.db.${table_name}.update(id, data);
    
    // Update our local items array
    const index = items.findIndex(item => item.id === id);
    if (index !== -1) {
      items[index] = { ...items[index], ...data };
    }
    
    // Update the UI
    renderItems();
    resetForm();
    showMessage('${item_name} updated successfully', 'success');
    
    showLoading(false);
  } catch (error) {
    console.error('Error updating ${item_name}:', error);
    showMessage('Failed to update ${item_name}', 'error');
    showLoading(false);
  }
}

/**
 * Delete an ${item_name}
 */
async function deleteItem(id) {
  if (!confirm('Are you sure you want to delete this ${item_name}?')) {
    return;
  }
  
  try {
    showLoading(true);
    
    // Delete the item from the database
    await xata.db.${table_name}.delete(id);
    
    // Remove from our local items array
    items = items.filter(item => item.id !== id);
    
    // Update the UI
    renderItems();
    showMessage('${item_name} deleted successfully', 'success');
    
    showLoading(false);
  } catch (error) {
    console.error('Error deleting ${item_name}:', error);
    showMessage('Failed to delete ${item_name}', 'error');
    showLoading(false);
  }
}

/**
 * Format a date for display
 */
function formatDate(dateString) {
  if (!dateString) return '';
  return new Date(dateString).toLocaleString();
}

/**
 * Render the items list
 */
function renderItems() {
  if (!itemList) return;
  
  // Clear the list
  itemList.innerHTML = '';
  
  if (items.length === 0) {
    itemList.innerHTML = '<div class="empty-message">No ${table_name} found. Create one using the form.</div>';
    return;
  }
  
  // Create table structure
  const table = document.createElement('table');
  table.className = 'items-table';
  
  // Add table header
  const thead = document.createElement('thead');
  const headerRow = document.createElement('tr');
  
  // Add headers based on fields
  [
EOF

  # Add table headers as an array
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Convert snake_case to Title Case for headers
      header=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      cat >> "$js_dir/${table_name}.js" << EOF
    '${header}',
EOF
    fi
  done

  cat >> "$js_dir/${table_name}.js" << EOF
    'Actions'
  ].forEach(headerText => {
    const th = document.createElement('th');
    th.textContent = headerText;
    headerRow.appendChild(th);
  });
  
  thead.appendChild(headerRow);
  table.appendChild(thead);
  
  // Add table body
  const tbody = document.createElement('tbody');
  
  // Add rows for each item
  items.forEach(item => {
    const row = document.createElement('tr');
    
    // Add cells for each field
EOF

  # Generate table cells for each field
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Handle different field types
      if [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$js_dir/${table_name}.js" << EOF
    // ${field} cell
    (() => {
      const cell = document.createElement('td');
      cell.textContent = formatDate(item.${field});
      row.appendChild(cell);
    })();
EOF
      elif [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$js_dir/${table_name}.js" << EOF
    // ${field} cell
    (() => {
      const cell = document.createElement('td');
      cell.textContent = item.${field} ? '✅' : '❌';
      row.appendChild(cell);
    })();
EOF
      else
        cat >> "$js_dir/${table_name}.js" << EOF
    // ${field} cell
    (() => {
      const cell = document.createElement('td');
      cell.textContent = item.${field} || '';
      row.appendChild(cell);
    })();
EOF
      fi
    fi
  done

  # Add actions cell and finish rendering function
  cat >> "$js_dir/${table_name}.js" << EOF
    
    // Actions cell
    (() => {
      const cell = document.createElement('td');
      cell.className = 'actions';
      
      // Edit button
      const editButton = document.createElement('button');
      editButton.textContent = 'Edit';
      editButton.className = 'btn-edit';
      editButton.addEventListener('click', () => startEdit(item));
      cell.appendChild(editButton);
      
      // Delete button
      const deleteButton = document.createElement('button');
      deleteButton.textContent = 'Delete';
      deleteButton.className = 'btn-delete';
      deleteButton.addEventListener('click', () => deleteItem(item.id));
      cell.appendChild(deleteButton);
      
      row.appendChild(cell);
    })();
    
    tbody.appendChild(row);
  });
  
  table.appendChild(tbody);
  itemList.appendChild(table);
}

/**
 * Start editing an item
 */
function startEdit(item) {
  currentItem = item;
  isEditing = true;
  
  // Update form title
  const formTitle = document.querySelector('#form-title');
  if (formTitle) {
    formTitle.textContent = 'Edit ${item_name}';
  }
  
  // Fill the form with the item data
EOF

  # Set form field values
  for field in $fields; do
    # Skip id field and un-editable fields
    if [ "$field" != "id" ] && [ "$field" != "created_at" ] && [ "$field" != "updated_at" ]; then
      # Handle different field types
      if [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$js_dir/${table_name}.js" << EOF
  document.getElementById('${field}').checked = Boolean(item.${field});
EOF
      elif [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$js_dir/${table_name}.js" << EOF
  if (item.${field}) {
    const date = new Date(item.${field});
    document.getElementById('${field}').value = date.toISOString().slice(0, 16);
  } else {
    document.getElementById('${field}').value = '';
  }
EOF
      else
        cat >> "$js_dir/${table_name}.js" << EOF
  document.getElementById('${field}').value = item.${field} || '';
EOF
      fi
    fi
  done

  # Finish startEdit and add remaining functions
  cat >> "$js_dir/${table_name}.js" << EOF
  
  // Show cancel button
  const cancelButton = document.getElementById('btn-cancel');
  if (cancelButton) {
    cancelButton.style.display = 'inline-block';
  }
}

/**
 * Reset the form to create mode
 */
function resetForm() {
  currentItem = null;
  isEditing = false;
  
  // Reset form title
  const formTitle = document.querySelector('#form-title');
  if (formTitle) {
    formTitle.textContent = 'Create New ${item_name}';
  }
  
  // Clear all form fields
  if (itemForm) {
    itemForm.reset();
  }
  
  // Hide cancel button
  const cancelButton = document.getElementById('btn-cancel');
  if (cancelButton) {
    cancelButton.style.display = 'none';
  }
}

/**
 * Show or hide the loading indicator
 */
function showLoading(show) {
  const loader = document.getElementById('loader');
  if (loader) {
    loader.style.display = show ? 'block' : 'none';
  }
}

/**
 * Show a message to the user
 */
function showMessage(message, type = '') {
  if (!messageContainer) return;
  
  messageContainer.textContent = message;
  messageContainer.className = 'message';
  
  if (type) {
    messageContainer.classList.add(\`message-\${type}\`);
  }
  
  if (message) {
    messageContainer.style.display = 'block';
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
      messageContainer.style.display = 'none';
    }, 5000);
  } else {
    messageContainer.style.display = 'none';
  }
}

/**
 * Handle form submission
 */
function handleSubmit(event) {
  event.preventDefault();
  
  // Collect form data
  const formData = {};
  
  // Process each field
EOF

  # Add code to collect form data for each field
  for field in $fields; do
    # Skip id and timestamps
    if [ "$field" != "id" ] && [ "$field" != "created_at" ] && [ "$field" != "updated_at" ]; then
      # Handle different field types
      if [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$js_dir/${table_name}.js" << EOF
  formData.${field} = document.getElementById('${field}').checked;
EOF
      else
        cat >> "$js_dir/${table_name}.js" << EOF
  formData.${field} = document.getElementById('${field}').value;
EOF
      fi
    fi
  done

  # Finish the form handling and initialize function
  cat >> "$js_dir/${table_name}.js" << EOF
  
  // Call the appropriate function based on mode
  if (isEditing && currentItem) {
    updateItem(currentItem.id, formData);
  } else {
    createItem(formData);
  }
}

/**
 * Initialize the module when the page loads
 */
function init() {
  // Get DOM elements
  itemList = document.getElementById('item-list');
  itemForm = document.getElementById('item-form');
  messageContainer = document.getElementById('message');
  
  // Add event listeners
  if (itemForm) {
    itemForm.addEventListener('submit', handleSubmit);
  }
  
  const cancelButton = document.getElementById('btn-cancel');
  if (cancelButton) {
    cancelButton.addEventListener('click', (e) => {
      e.preventDefault();
      resetForm();
    });
  }
  
  // Load items from the database
  loadItems();
}

// Export public API
export default {
  init,
  loadItems,
  createItem,
  updateItem,
  deleteItem
};
EOF

  # 2. Create CSS file
  cat > "$css_dir/${table_name}.css" << EOF
/* ${display_name} CRUD Styles */

/* Container */
.crud-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
}

/* Grid layout */
.crud-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
}

@media (min-width: 768px) {
  .crud-grid {
    grid-template-columns: minmax(300px, 1fr) 2fr;
  }
}

/* Card styling */
.card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
}

/* Form styling */
.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.form-control {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

textarea.form-control {
  min-height: 100px;
}

/* Button styling */
.btn {
  display: inline-block;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  text-decoration: none;
}

.btn-primary {
  background-color: #4299e1;
  color: white;
}

.btn-secondary {
  background-color: #a0aec0;
  color: white;
}

.btn-edit {
  background-color: #38b2ac;
  color: white;
  margin-right: 0.5rem;
}

.btn-delete {
  background-color: #e53e3e;
  color: white;
}

.btn-cancel {
  margin-left: 0.5rem;
  display: none;
}

/* Table styling */
.items-table {
  width: 100%;
  border-collapse: collapse;
}

.items-table th,
.items-table td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid #eaeaea;
}

.items-table th {
  font-weight: 600;
  background-color: #f8fafc;
}

.items-table tr:hover {
  background-color: #f1f5f9;
}

.actions {
  white-space: nowrap;
}

/* Message styling */
.message {
  padding: 0.75rem 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
  display: none;
}

.message-success {
  background-color: #c6f6d5;
  color: #276749;
}

.message-error {
  background-color: #fed7d7;
  color: #9b2c2c;
}

/* Loading indicator */
.loader {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(255, 255, 255, 0.8);
  z-index: 1000;
  display: flex;
  justify-content: center;
  align-items: center;
}

.spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  width: 30px;
  height: 30px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Empty state */
.empty-message {
  padding: 2rem;
  text-align: center;
  color: #718096;
  font-style: italic;
}
EOF

  # 3. Create HTML file
  cat > "$project_path/${table_name}.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${display_name} Management</title>
  <link rel="stylesheet" href="css/${table_name}.css">
</head>
<body>
  <!-- Loading indicator -->
  <div id="loader" class="loader">
    <div class="spinner"></div>
  </div>
  
  <div class="crud-container">
    <h1>${display_name} Management</h1>
    
    <!-- Message container for notifications -->
    <div id="message" class="message"></div>
    
    <div class="crud-grid">
      <!-- Form section -->
      <div class="card">
        <h2 id="form-title">Create New ${item_name}</h2>
        
        <form id="item-form">
EOF

  # Generate form fields
  for field in $fields; do
    # Skip id field and timestamps in the form
    if [ "$field" != "id" ] && [ "$field" != "created_at" ] && [ "$field" != "updated_at" ]; then
      # Convert snake_case to Title Case for labels
      label=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      # Determine field type
      if [[ "$field" =~ _at$ ]] || [[ "$field" =~ date ]]; then
        cat >> "$project_path/${table_name}.html" << EOF
          <div class="form-group">
            <label for="${field}">${label}</label>
            <input type="datetime-local" id="${field}" name="${field}" class="form-control">
          </div>
EOF
      elif [[ "$field" =~ is_ ]] || [[ "$field" =~ active ]] || [[ "$field" =~ enabled ]]; then
        cat >> "$project_path/${table_name}.html" << EOF
          <div class="form-group">
            <label>
              <input type="checkbox" id="${field}" name="${field}">
              ${label}
            </label>
          </div>
EOF
      elif [[ "$field" =~ priority ]] || [[ "$field" =~ count ]] || [[ "$field" =~ amount ]]; then
        cat >> "$project_path/${table_name}.html" << EOF
          <div class="form-group">
            <label for="${field}">${label}</label>
            <input type="number" id="${field}" name="${field}" class="form-control">
          </div>
EOF
      elif [[ "$field" =~ description ]] || [[ "$field" =~ content ]]; then
        cat >> "$project_path/${table_name}.html" << EOF
          <div class="form-group">
            <label for="${field}">${label}</label>
            <textarea id="${field}" name="${field}" class="form-control"></textarea>
          </div>
EOF
      else
        cat >> "$project_path/${table_name}.html" << EOF
          <div class="form-group">
            <label for="${field}">${label}</label>
            <input type="text" id="${field}" name="${field}" class="form-control">
          </div>
EOF
      fi
    fi
  done

  # Finish the HTML file
  cat >> "$project_path/${table_name}.html" << EOF
          
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">Save</button>
            <button id="btn-cancel" class="btn btn-secondary btn-cancel">Cancel</button>
          </div>
        </form>
      </div>
      
      <!-- List section -->
      <div class="card">
        <h2>${display_name} List</h2>
        <div id="item-list">
          <!-- Items will be rendered here by JavaScript -->
        </div>
      </div>
    </div>
    
    <div class="footer">
      <p><a href="index.html">Back to Home</a></p>
    </div>
  </div>
  
  <!-- Load module using ES modules -->
  <script type="module">
    import ${table_name}Module from './js/${table_name}.js';
    
    // Initialize when the page loads
    document.addEventListener('DOMContentLoaded', () => {
      ${table_name}Module.init();
    });
  </script>
</body>
</html>
EOF

  # 4. Add link to index.html if it exists
  if [ -f "$project_path/index.html" ]; then
    # Create temporary file
    local temp_file=$(mktemp -t "static_index_XXXXXX")
    trap "rm -f '$temp_file'" EXIT
    
    # Attempt to find navigation section
    if grep -q "<nav" "$project_path/index.html"; then
      awk -v table="$table_name" -v name="$display_name" '{
        print $0
        if ($0 ~ /<\/nav>/ || $0 ~ /<\/ul>/) {
          gsub("</nav>|</ul>", "  <li><a href=\"" table ".html\">" name " Management</a></li>\\n&")
        }
      }' "$project_path/index.html" > "$temp_file"
      
      mv "$temp_file" "$project_path/index.html"
      echo "✅ Added link to index.html"
    else
      echo "⚠️ Could not find navigation in index.html. Manual navigation update needed."
    fi
    
    # Clean up trap
    trap - EXIT
  fi
}

# Function to generate static site CRUD with Supabase
generate_static_supabase_crud() {
  local project_path="$1"
  local js_dir="$2"
  local css_dir="$3"
  local table_name="$4"
  local schema="$5"
  
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
  
  # 1. Create JS file for Supabase operations
  cat > "$js_dir/${table_name}.js" << EOF
/**
 * ${display_name} CRUD Module
 * Static site implementation using Supabase client
 */

// Import the Supabase client
import { createClient } from 'https://cdn.skypack.dev/@supabase/supabase-js';

// Initialize Supabase
const supabaseUrl = 'YOUR_SUPABASE_URL'; // Replace with your Supabase URL
const supabaseKey = 'YOUR_SUPABASE_KEY'; // Replace with your Supabase anon key
const supabase = createClient(supabaseUrl, supabaseKey);

// Monkey Tip: For production, store these values in environment variables
// and use a proper bundler like Webpack or Rollup instead of CDN imports

// Initialize global state
let items = [];
let currentItem = null;
let isEditing = false;

// DOM Elements (will be set on page load)
let itemList;
let itemForm;
let messageContainer;

// Monkey Tip: You can customize these functions to add validation,
// filtering, or pagination

/**
 * Load all ${table_name} from the database
 */
async function loadItems() {
  try {
    showLoading(true);
    
    // Clear any previous messages
    showMessage('');
    
    // Get items from database
    const { data, error } = await supabase
      .from('${table_name}')
      .select('*')
      .order('created_at', { ascending: false });
      
    if (error) throw error;
    
    items = data || [];
    
    // Render the list
    renderItems();
    
    showLoading(false);
  } catch (error) {
    console.error('Error loading ${table_name}:', error);
    showMessage('Failed to load ${table_name}', 'error');
    showLoading(false);
  }
}

/**
 * Create a new ${item_name}
 */
async function createItem(data) {
  try {
    showLoading(true);
    
    // Create the item in the database
    const { data: newItem, error } = await supabase
      .from('${table_name}')
      .insert(data)
      .select()
      .single();
      
    if (error) throw error;
    
    // Add to our local items array
    items.unshift(newItem);
    
    // Update the UI
    renderItems();
    resetForm();
    showMessage('${item_name} created successfully', 'success');
    
    showLoading(false);
  } catch (error) {
    console.error('Error creating ${item_name}:', error);
    showMessage('Failed to create ${item_name}', 'error');
    showLoading(false);
  }
}

/**
 * Update an existing ${item_name}
 */
async function updateItem(id, data) {
  try {
    showLoading(true);
    
    // Update the item in the database
    const { data: updated, error } = await supabase
      .from('${table_name}')
      .update(data)
      .eq('id', id)
      .select()
      .single();
      
    if (error) throw error;
    
    // Update our local items array
    const index = items.findIndex(item => item.id === id);
    if (index !== -1) {
      items[index] = { ...items[index], ...data };
    }
    
    // Update the UI
    renderItems();
    resetForm();
    showMessage('${item_name} updated successfully', 'success');
    
    showLoading(false);
  } catch (error) {
    console.error('Error updating ${item_name}:', error);
    showMessage('Failed to update ${item_name}', 'error');
    showLoading(false);
  }
}

/**
 * Delete an ${item_name}
 */
async function deleteItem(id) {
  if (!confirm('Are you sure you want to delete this ${item_name}?')) {
    return;
  }
  
  try {
    showLoading(true);
    
    // Delete the item from the database
    const { error } = await supabase
      .from('${table_name}')
      .delete()
      .eq('id', id);
      
    if (error) throw error;
    
    // Remove from our local items array
    items = items.filter(item => item.id !== id);
    
    // Update the UI
    renderItems();
    showMessage('${item_name} deleted successfully', 'success');
    
    showLoading(false);
  } catch (error) {
    console.error('Error deleting ${item_name}:', error);
    showMessage('Failed to delete ${item_name}', 'error');
    showLoading(false);
  }
}

/**
 * Format a date for display
 */
function formatDate(dateString) {
  if (!dateString) return '';
  return new Date(dateString).toLocaleString();
}

/**
 * Render the items list
 */
function renderItems() {
  if (!itemList) return;
  
  // Clear the list
  itemList.innerHTML = '';
  
  if (items.length === 0) {
    itemList.innerHTML = '<div class="empty-message">No ${table_name} found. Create one using the form.</div>';
    return;
  }
  
  // Create table structure
  const table = document.createElement('table');
  table.className = 'items-table';
  
  // Add table header
  const thead = document.createElement('thead');
  const headerRow = document.createElement('tr');
  
  // Add headers based on fields
  [
EOF

  # Add table headers as an array
  for field in $fields; do
    # Skip some fields in the table display to save space
    if [ "$field" != "description" ] && [ "$field" != "content" ]; then
      # Convert snake_case to Title Case for headers
      header=$(echo "$field" | sed -r 's/(_|-| )([a-z])/\u\2/g; s/^([a-z])/\u\1/g')
      
      cat >> "$js_dir/${table_name}.js" << EOF
    '${header}',
EOF
    fi
  done

  # The rest of the implementation is identical to Xata, so reuse that function
  # CSS and HTML files are also identical
  
  # Just handle the JS ending here and then call the Xata function to generate the rest
  cat >> "$js_dir/${table_name}.js" << EOF
    'Actions'
  ].forEach(headerText => {
    const th = document.createElement('th');
    th.textContent = headerText;
    headerRow.appendChild(th);
  });
  
  thead.appendChild(headerRow);
  table.appendChild(thead);
  
  // Add table body with same structure as Xata implementation
  // ... rest of the code is identical
EOF

  # Remove the generated file (incomplete) and generate the full implementation 
  # by reusing the Xata function but replacing the client imports
  rm "$js_dir/${table_name}.js"
  
  # Create the rest of the files using the Xata function
  generate_static_xata_crud "$project_path" "$js_dir" "$css_dir" "$table_name" "$schema"
  
  # Now replace the Xata client references with Supabase
  local temp_file=$(mktemp -t "supabase_js_XXXXXX")
  trap "rm -f '$temp_file'" EXIT
  
  # Replace Xata with Supabase in JS file
  sed 's/import { XataClient } from/import { createClient } from/g; 
       s/const xata = new XataClient()/const supabaseUrl = "YOUR_SUPABASE_URL";\nconst supabaseKey = "YOUR_SUPABASE_KEY";\nconst supabase = createClient(supabaseUrl, supabaseKey)/g;
       s/xata\.db\.${table_name}\.getAll()/supabase.from("'"${table_name}"'").select("*").order("created_at", { ascending: false })/g;
       s/xata\.db\.${table_name}\.create/supabase.from("'"${table_name}"'").insert/g;
       s/xata\.db\.${table_name}\.update/supabase.from("'"${table_name}"'").update/g;
       s/xata\.db\.${table_name}\.delete/supabase.from("'"${table_name}"'").delete().eq("id", /g;' \
       "$js_dir/${table_name}.js" > "$temp_file"
  
  mv "$temp_file" "$js_dir/${table_name}.js"
  
  # Add Supabase initialization note to the html file
  temp_file=$(mktemp -t "supabase_html_XXXXXX")
  trap "rm -f '$temp_file'" EXIT
  
  sed 's/<script type="module">/<script type="module">\n    \/\/ Monkey Tip: Replace YOUR_SUPABASE_URL and YOUR_SUPABASE_KEY in the JS file/g' \
      "$project_path/${table_name}.html" > "$temp_file"
  
  mv "$temp_file" "$project_path/${table_name}.html"
  
  # Clean up trap
  trap - EXIT
}

# Static site CRUD generator
generate_static_crud() {
  local project_path="$1"
  local backend_type="$2"
  local table_name="$3"
  local schema="$4"
  
  echo ""
  typewriter "🚀 Generating CRUD for static site with $backend_type..." 0.01
  
  # Create necessary directories
  local js_dir="$project_path/js"
  local css_dir="$project_path/css"
  mkdir -p "$js_dir" "$css_dir"
  
  # Generate HTML, JS, and CSS files
  if [ "$backend_type" = "xata" ]; then
    generate_static_xata_crud "$project_path" "$js_dir" "$css_dir" "$table_name" "$schema"
  elif [ "$backend_type" = "supabase" ]; then
    generate_static_supabase_crud "$project_path" "$js_dir" "$css_dir" "$table_name" "$schema"
  fi
  
  echo "✅ Static site CRUD files created successfully"
  return 0
}