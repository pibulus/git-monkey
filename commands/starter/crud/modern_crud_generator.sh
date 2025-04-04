#!/bin/bash

# ========= GIT MONKEY MODERN CRUD GENERATOR =========
# Phase 3 implementation - Enhanced CRUD generator with:
# - Server Actions
# - Zod Validation
# - Optimistic UI Updates
# - Real-time Features
# - Filtering and Pagination

# Source utilities and dependencies
source ./utils/style.sh
source ./utils/config.sh
source ./utils/performance.sh
source ./commands/starter/starter_config.sh

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"  # Can be "info", "success", "error", "warning", etc.
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        "server") echo "🌴" ;;
        "form") echo "📝" ;;
        "realtime") echo "⚡" ;;
        "filter") echo "🔍" ;;
        "optimistic") echo "✨" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "server") echo "[SRV]" ;;
        "form") echo "[FORM]" ;;
        "realtime") echo "[LIVE]" ;;
        "filter") echo "[FLTR]" ;;
        "optimistic") echo "[OPT]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "server") echo "🔮" ;;
        "form") echo "📚" ;;
        "realtime") echo "⚡" ;;
        "filter") echo "🔍" ;;
        "optimistic") echo "✨" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "server") echo "🛰️" ;;
        "form") echo "📡" ;;
        "realtime") echo "⚡" ;;
        "filter") echo "🔭" ;;
        "optimistic") echo "✨" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "ℹ️" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "server") echo "🖥️" ;;
        "form") echo "📝" ;;
        "realtime") echo "⚡" ;;
        "filter") echo "🔍" ;;
        "optimistic") echo "✨" ;;
        *) echo "ℹ️" ;;
      esac
      ;;
  esac
}

# Function to generate modern CRUD with SvelteKit + Supabase
generate_modern_crud_sveltekit() {
  local project_path="$1"
  local table_name="$2"
  local backend_type="$3"
  local options="$4"
  
  # Get current tone stage and theme for context-aware help
  TONE_STAGE=$(get_tone_stage)
  THEME=$(get_selected_theme)
  IDENTITY=$(get_full_identity)
  
  # Get theme-specific emojis
  info_emoji=$(get_theme_emoji "info")
  success_emoji=$(get_theme_emoji "success")
  error_emoji=$(get_theme_emoji "error")
  warning_emoji=$(get_theme_emoji "warning")
  server_emoji=$(get_theme_emoji "server")
  form_emoji=$(get_theme_emoji "form")
  realtime_emoji=$(get_theme_emoji "realtime")
  filter_emoji=$(get_theme_emoji "filter")
  optimistic_emoji=$(get_theme_emoji "optimistic")
  
  # Start timing for performance metrics
  local start_time=$(start_timing)
  
  # Navigate to project directory
  cd "$project_path" || {
    typewriter "$error_emoji Could not navigate to project directory: $project_path" 0.02
    return 1
  }
  
  # Verify if this is a SvelteKit project
  if [ ! -f "svelte.config.js" ]; then
    typewriter "$error_emoji Not a SvelteKit project. Please run this in a SvelteKit project directory." 0.02
    return 1
  }

  # Tone-aware introduction based on user's experience level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners - very friendly, detailed explanation
    case "$THEME" in
      "jungle")
        typewriter "$info_emoji Hi $IDENTITY! Let's create a modern jungle CRUD habitat for your $table_name!" 0.02
        echo ""
        typewriter "We're building a super-smart jungle app with:" 0.02
        echo "  • $server_emoji Server Actions - keeps your data safe in the tree canopy"
        echo "  • $form_emoji Zod Validation - makes sure only the right bananas get stored"
        echo "  • $optimistic_emoji Optimistic UI - feels fast like swinging from vine to vine"
        echo "  • $realtime_emoji Real-time Updates - see changes instantly like monkey telepathy"
        echo "  • $filter_emoji Smart Filtering - find the ripest bananas in your data jungle"
        ;;
      "hacker")
        typewriter "$info_emoji INITIALIZING ADVANCED CRUD SYSTEM FOR: $table_name" 0.02
        echo ""
        typewriter "DEPLOYING NEXT-GEN PROTOCOLS:" 0.02
        echo "  • $server_emoji SERVER ACTIONS: SECURE DATA TRANSACTION PROTOCOLS"
        echo "  • $form_emoji ZOD VALIDATION: TYPE-SAFE DATA SCHEMA ENFORCEMENT"
        echo "  • $optimistic_emoji OPTIMISTIC UI: PREDICTIVE INTERFACE LATENCY COMPENSATION"
        echo "  • $realtime_emoji REAL-TIME SYNC: LIVE DATA STREAM PROCESSING"
        echo "  • $filter_emoji ENHANCED QUERIES: CONFIGURABLE DATA FILTERING ALGORITHMS"
        ;;
      "wizard")
        typewriter "$info_emoji Greetings, $IDENTITY! Let us conjure a magical CRUD spell for $table_name!" 0.02
        echo ""
        typewriter "We shall weave these enchantments into your creation:" 0.02
        echo "  • $server_emoji Server Actions - spells that work from the ethereal server plane"
        echo "  • $form_emoji Zod Validation - magical wards to ensure data purity"
        echo "  • $optimistic_emoji Optimistic UI - illusions that make magic appear faster"
        echo "  • $realtime_emoji Real-time Updates - divination that reveals changes as they happen"
        echo "  • $filter_emoji Magical Filters - scrying tools to find exactly what you seek"
        ;;
      "cosmic")
        typewriter "$info_emoji Greetings, $IDENTITY! Launching advanced CRUD constellation for $table_name!" 0.02
        echo ""
        typewriter "Installing these celestial technologies:" 0.02
        echo "  • $server_emoji Server Actions - orbital command center for data operations"
        echo "  • $form_emoji Zod Validation - gravitational field to ensure data integrity"
        echo "  • $optimistic_emoji Optimistic UI - quantum prediction for instant feedback"
        echo "  • $realtime_emoji Real-time Updates - subspace communication channels"
        echo "  • $filter_emoji Stellar Filters - nebula mapping to chart your data cosmos"
        ;;
      *)
        typewriter "$info_emoji Hi $IDENTITY! Let's create a modern CRUD system for your $table_name!" 0.02
        echo ""
        typewriter "We're building an awesome app with these cool features:" 0.02
        echo "  • $server_emoji Server Actions - makes your forms work better and faster"
        echo "  • $form_emoji Zod Validation - keeps your data clean and error-free"
        echo "  • $optimistic_emoji Optimistic UI - makes your app feel super responsive"
        echo "  • $realtime_emoji Real-time Updates - see changes instantly as they happen"
        echo "  • $filter_emoji Smart Filtering - easily find what you're looking for"
        ;;
    esac
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users - moderate explanation, somewhat technical
    case "$THEME" in
      "jungle")
        typewriter "$info_emoji Setting up modern CRUD operations for $table_name" 0.02
        echo ""
        echo "Building with advanced patterns for a robust jungle ecosystem:"
        echo "• $server_emoji Server-side form actions with progressive enhancement"
        echo "• $form_emoji Type-safe schema validation with Zod"
        echo "• $optimistic_emoji Optimistic UI updates for improved UX"
        echo "• $realtime_emoji Real-time data synchronization"
        echo "• $filter_emoji Advanced filtering and pagination"
        ;;
      "hacker")
        typewriter "$info_emoji DEPLOYING ADVANCED CRUD MODULE FOR: $table_name" 0.02
        echo ""
        echo "INSTALLING COMPONENTS:"
        echo "• $server_emoji SERVER ACTIONS: FORM ACTION API WITH PROGRESSIVE ENHANCEMENT"
        echo "• $form_emoji ZOD SCHEMA VALIDATION: TYPE-SAFE DATA STRUCTURES"
        echo "• $optimistic_emoji OPTIMISTIC UI: REACTIVE STATE PREDICTION"
        echo "• $realtime_emoji REAL-TIME SYNC: SUPABASE SUBSCRIPTION STREAMS"
        echo "• $filter_emoji QUERY SYSTEM: DYNAMIC FILTERING AND PAGINATION"
        ;;
      "wizard")
        typewriter "$info_emoji Crafting modern CRUD enchantments for $table_name" 0.02
        echo ""
        echo "Weaving these powerful spells into your grimoire:"
        echo "• $server_emoji Server action runes for secure form submission"
        echo "• $form_emoji Zod validation sigils for data integrity"
        echo "• $optimistic_emoji Optimistic illusion charms for responsive interfaces"
        echo "• $realtime_emoji Ethereal connection enchantments for live updates"
        echo "• $filter_emoji Scrying filters to locate specific knowledge"
        ;;
      "cosmic")
        typewriter "$info_emoji Deploying modern CRUD constellation for $table_name" 0.02
        echo ""
        echo "Installing interstellar components:"
        echo "• $server_emoji Server-side action modules with progressive enhancement"
        echo "• $form_emoji Zod validation shields for type safety"
        echo "• $optimistic_emoji Optimistic UI quantum state prediction"
        echo "• $realtime_emoji Real-time data streams through subspace channels"
        echo "• $filter_emoji Advanced nebula mapping for data exploration"
        ;;
      *)
        typewriter "$info_emoji Setting up modern CRUD operations for $table_name" 0.02
        echo ""
        echo "This implementation includes server actions with progressive enhancement,"
        echo "Zod schema validation, optimistic UI updates, real-time data, and"
        echo "advanced filtering/pagination patterns."
        ;;
    esac
    echo ""
  else
    # Advanced users - minimal, technical explanation
    case "$THEME" in
      "jungle")
        echo "$info_emoji Implementing modern CRUD for $table_name with server actions, Zod, optimistic UI, real-time data, and filtering."
        ;;
      "hacker")
        echo "$info_emoji CRUD MODULE: SERVER ACTIONS + ZOD + OPTIMISTIC UI + REAL-TIME + FILTERING"
        ;;
      "wizard")
        echo "$info_emoji Conjuring CRUD spells with server actions, Zod validation, optimistic UI, real-time updates, and filtering."
        ;;
      "cosmic")
        echo "$info_emoji Deploying CRUD systems with server actions, Zod validation, optimistic UI, real-time data, and filtering."
        ;;
      *)
        echo "$info_emoji Setting up modern CRUD with server actions, Zod validation, optimistic UI, real-time updates, and filtering."
        ;;
    esac
    echo ""
  fi
  
  # Install required dependencies
  echo "Installing required dependencies..."
  
  # Show simple terminal progress indicator
  echo -n "["
  for i in {1..30}; do
    echo -n "▓"
    sleep 0.01
  done
  echo -n "]"
  echo ""
  
  # Install Zod for schema validation
  npm install zod > /dev/null 2>&1
  
  # Install SuperForms for enhanced form handling
  npm install sveltekit-superforms > /dev/null 2>&1
  
  if [ "$backend_type" = "supabase" ]; then
    # Install Supabase realtime
    npm install @supabase/supabase-js > /dev/null 2>&1
  fi
  
  # Create directories for CRUD operations
  mkdir -p "src/lib/schemas"
  mkdir -p "src/lib/components/ui"
  mkdir -p "src/lib/components/forms"
  mkdir -p "src/lib/components/tables"
  mkdir -p "src/routes/$table_name"
  mkdir -p "src/routes/api/$table_name"

  # Create schema file with Zod validation
  create_schema_file "$table_name"
  
  # Create routes and components
  create_routes "$table_name" "$backend_type"
  
  # Create form components
  create_form_components "$table_name"
  
  # Create table components with filtering and pagination
  create_table_components "$table_name"
  
  # Create optimistic UI utilities
  create_optimistic_ui_utils "$table_name"
  
  # Create real-time features if backend supports it
  if [ "$backend_type" = "supabase" ]; then
    create_realtime_features "$table_name"
  fi
  
  # Display ASCII diagram explaining the architecture
  if [ "$TONE_STAGE" -le 2 ]; then
    show_architecture_diagram
  fi
  
  # Calculate performance metrics
  local end_time=$(end_timing "$start_time")
  local formatted_time=$(format_timing "$end_time")
  
  # Success message with performance metrics
  rainbow_box "🚀 Modern CRUD Implementation Complete!"
  typewriter "$success_emoji Generated modern CRUD operations for $table_name in $formatted_time" 0.02
  
  # Show next steps based on tone stage
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "🎯 Next Steps:"
    echo "1. Run npm run dev to start your dev server"
    echo "2. Visit http://localhost:5173/$table_name to see your CRUD app"
    echo "3. Check out the generated files to understand the patterns"
  fi
  
  return 0
}

# Function to create schema file with Zod validation
create_schema_file() {
  local table_name="$1"
  local schema_file="src/lib/schemas/${table_name}.ts"
  
  echo "Creating schema file for $table_name..."
  
  # Create the schema file
  cat > "$schema_file" << EOF
import { z } from 'zod';

// Define the ${table_name} schema
export const ${table_name}Schema = z.object({
  id: z.string().uuid().optional(),
  name: z.string().min(2, { message: "Name must be at least 2 characters" }),
  description: z.string().min(5, { message: "Description must be at least 5 characters" }).max(500),
  createdAt: z.date().optional(),
  updatedAt: z.date().optional(),
  // Add more fields as needed for your ${table_name}
});

// Type inference from the schema
export type ${capitalize_first_letter "$table_name"} = z.infer<typeof ${table_name}Schema>;

// Schema for creating a new ${table_name} (ID and timestamps are handled by the server)
export const create${capitalize_first_letter "$table_name"}Schema = ${table_name}Schema.omit({ id: true, createdAt: true, updatedAt: true });

// Schema for updating an existing ${table_name}
export const update${capitalize_first_letter "$table_name"}Schema = create${capitalize_first_letter "$table_name"}Schema.partial();

// Type for filtering ${table_name}
export const ${table_name}FilterSchema = z.object({
  name: z.string().optional(),
  sortBy: z.enum(['name', 'createdAt', 'updatedAt']).optional(),
  sortDirection: z.enum(['asc', 'desc']).optional(),
  page: z.number().int().positive().optional(),
  limit: z.number().int().positive().max(100).optional(),
});

export type ${capitalize_first_letter "$table_name"}Filter = z.infer<typeof ${table_name}FilterSchema>;
EOF
}

# Function to create routes
create_routes() {
  local table_name="$1"
  local backend_type="$2"
  
  echo "Creating routes for $table_name..."
  
  # Create the list route with server action
  create_list_route "$table_name" "$backend_type"
  
  # Create the detail route with server action
  create_detail_route "$table_name" "$backend_type"
  
  # Create the create route with server action
  create_create_route "$table_name" "$backend_type"
  
  # Create the edit route with server action
  create_edit_route "$table_name" "$backend_type"
}

# Function to create list route
create_list_route() {
  local table_name="$1"
  local backend_type="$2"
  local list_route="src/routes/$table_name/+page.svelte"
  local list_server="src/routes/$table_name/+page.server.ts"
  
  # Create the server file first with data loading logic
  cat > "$list_server" << EOF
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import { ${table_name}FilterSchema, type ${capitalize_first_letter "$table_name"} } from '$lib/schemas/${table_name}';

export const load: PageServerLoad = async ({ url }) => {
  try {
    // Parse filter parameters from URL
    const filterParams = {
      name: url.searchParams.get('name') || undefined,
      sortBy: url.searchParams.get('sortBy') || 'createdAt',
      sortDirection: url.searchParams.get('sortDirection') || 'desc',
      page: Number(url.searchParams.get('page') || 1),
      limit: Number(url.searchParams.get('limit') || 10)
    };
    
    // Validate filter parameters
    const filter = ${table_name}FilterSchema.parse(filterParams);
    
    // Calculate offset for pagination
    const offset = (filter.page - 1) * (filter.limit || 10);
    
    // Construct the query
    let query = supabase
      .from('${table_name}')
      .select('*', { count: 'exact' });
    
    // Apply name filter if provided
    if (filter.name) {
      query = query.ilike('name', \`%\${filter.name}%\`);
    }
    
    // Apply sorting
    if (filter.sortBy && filter.sortDirection) {
      query = query.order(filter.sortBy, { ascending: filter.sortDirection === 'asc' });
    }
    
    // Apply pagination
    query = query.range(offset, offset + (filter.limit || 10) - 1);
    
    // Execute the query
    const { data, error: queryError, count } = await query;
    
    if (queryError) throw queryError;
    
    return {
      items: data as ${capitalize_first_letter "$table_name"}[],
      totalCount: count || 0,
      filter
    };
  } catch (err) {
    console.error('Error loading ${table_name}:', err);
    throw error(500, 'Error loading ${table_name}');
  }
};

// Server action to handle deletion
export const actions = {
  delete: async ({ request }) => {
    const formData = await request.formData();
    const id = formData.get('id')?.toString();
    
    if (!id) {
      return { success: false, error: 'ID is required' };
    }
    
    try {
      const { error: deleteError } = await supabase
        .from('${table_name}')
        .delete()
        .eq('id', id);
      
      if (deleteError) throw deleteError;
      
      return { success: true };
    } catch (err) {
      console.error('Error deleting ${table_name}:', err);
      return { success: false, error: 'Failed to delete ${table_name}' };
    }
  }
};
EOF
  
  # Create the client-side component
  cat > "$list_route" << EOF
<script lang="ts">
  import { enhance } from '$app/forms';
  import { page } from '$app/stores';
  import { invalidateAll } from '$app/navigation';
  import { fade } from 'svelte/transition';
  import { flip } from 'svelte/animate';
  import DataTable from '$lib/components/tables/${table_name}Table.svelte';
  import FilterBar from '$lib/components/ui/FilterBar.svelte';
  import Pagination from '$lib/components/ui/Pagination.svelte';
  import type { PageData } from './$types';
  
  export let data: PageData;
  
  // Reactive state
  $: items = data.items;
  $: totalCount = data.totalCount;
  $: filter = data.filter;
  $: totalPages = Math.ceil(totalCount / (filter.limit || 10));
  
  // Store for optimistic UI updates
  import { getOptimisticStore } from '$lib/utils/optimistic';
  const optimisticStore = getOptimisticStore<string>('${table_name}Delete');
  
  // Handle filter changes
  function handleFilterChange(newFilter: any) {
    // Update URL parameters to reflect filter changes
    const url = new URL(window.location.href);
    
    // Remove existing parameters
    url.searchParams.delete('name');
    url.searchParams.delete('sortBy');
    url.searchParams.delete('sortDirection');
    url.searchParams.delete('page');
    url.searchParams.delete('limit');
    
    // Add new filter parameters
    if (newFilter.name) url.searchParams.set('name', newFilter.name);
    if (newFilter.sortBy) url.searchParams.set('sortBy', newFilter.sortBy);
    if (newFilter.sortDirection) url.searchParams.set('sortDirection', newFilter.sortDirection);
    if (newFilter.page) url.searchParams.set('page', newFilter.page.toString());
    if (newFilter.limit) url.searchParams.set('limit', newFilter.limit.toString());
    
    // Navigate to new URL without full page reload
    window.history.pushState({}, '', url.toString());
    
    // Refresh data
    invalidateAll();
  }
  
  // Handle page change
  function handlePageChange(newPage: number) {
    handleFilterChange({ ...filter, page: newPage });
  }
  
  // Handle deletion with optimistic UI update
  function handleDelete(id: string) {
    // Add ID to optimistic store before server confirms deletion
    optimisticStore.add(id);
  }
  
  // Filter items based on optimistic store
  $: displayItems = items.filter(item => !$optimisticStore.includes(item.id));
</script>

<svelte:head>
  <title>${capitalize_first_letter "$table_name"} List</title>
</svelte:head>

<div class="container mx-auto p-4">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold">${capitalize_first_letter "$table_name"} List</h1>
    <a href="/${table_name}/new" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
      New ${capitalize_first_letter "$table_name"}
    </a>
  </div>
  
  <FilterBar {filter} onChange={handleFilterChange} />
  
  {#if displayItems.length > 0}
    <div in:fade={{ duration: 300 }}>
      <DataTable 
        items={displayItems} 
        onDelete={handleDelete} 
      />
    </div>
  {:else}
    <div class="text-center py-10 bg-gray-50 rounded-lg" in:fade>
      <p class="text-gray-500">No ${table_name} found. Try adjusting your filters or create a new one.</p>
    </div>
  {/if}
  
  {#if totalPages > 1}
    <Pagination 
      currentPage={filter.page || 1} 
      totalPages={totalPages} 
      onPageChange={handlePageChange} 
    />
  {/if}
</div>

<div class="fixed bottom-4 right-4">
  {#if $optimisticStore.length > 0}
    <div class="bg-blue-500 text-white px-4 py-2 rounded shadow-lg" in:fade={{ duration: 200 }}>
      Saving changes...
    </div>
  {/if}
</div>
EOF
}

# Function to create detail route
create_detail_route() {
  local table_name="$1"
  local backend_type="$2"
  local detail_route="src/routes/$table_name/[id]/+page.svelte"
  local detail_server="src/routes/$table_name/[id]/+page.server.ts"
  
  # Create directory if it doesn't exist
  mkdir -p "src/routes/$table_name/[id]"
  
  # Create the server file
  cat > "$detail_server" << EOF
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import type { ${capitalize_first_letter "$table_name"} } from '$lib/schemas/${table_name}';

export const load: PageServerLoad = async ({ params }) => {
  try {
    const { id } = params;
    
    if (!id) {
      throw error(400, 'Item ID is required');
    }
    
    // Fetch the item
    const { data, error: queryError } = await supabase
      .from('${table_name}')
      .select('*')
      .eq('id', id)
      .single();
    
    if (queryError) {
      throw error(404, 'Item not found');
    }
    
    return {
      item: data as ${capitalize_first_letter "$table_name"}
    };
  } catch (err) {
    console.error('Error loading ${table_name} detail:', err);
    throw error(500, 'Error loading ${table_name} detail');
  }
};
EOF
  
  # Create the client-side component
  cat > "$detail_route" << EOF
<script lang="ts">
  import { fade } from 'svelte/transition';
  import type { PageData } from './$types';
  
  export let data: PageData;
  
  $: item = data.item;
</script>

<svelte:head>
  <title>${capitalize_first_letter "$table_name"} Detail</title>
</svelte:head>

<div class="container mx-auto p-4" in:fade={{ duration: 300 }}>
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold">${capitalize_first_letter "$table_name"} Detail</h1>
    <div class="space-x-2">
      <a href="/${table_name}" class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded">
        Back to List
      </a>
      <a href="/${table_name}/{item.id}/edit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
        Edit
      </a>
    </div>
  </div>
  
  <div class="bg-white shadow overflow-hidden sm:rounded-lg">
    <div class="px-4 py-5 sm:px-6">
      <h3 class="text-lg leading-6 font-medium text-gray-900">
        {item.name}
      </h3>
      <p class="mt-1 max-w-2xl text-sm text-gray-500">
        Details and information
      </p>
    </div>
    <div class="border-t border-gray-200">
      <dl>
        <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
          <dt class="text-sm font-medium text-gray-500">Name</dt>
          <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{item.name}</dd>
        </div>
        <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
          <dt class="text-sm font-medium text-gray-500">Description</dt>
          <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{item.description}</dd>
        </div>
        <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
          <dt class="text-sm font-medium text-gray-500">Created</dt>
          <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
            {new Date(item.createdAt).toLocaleString()}
          </dd>
        </div>
        <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
          <dt class="text-sm font-medium text-gray-500">Last Updated</dt>
          <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
            {new Date(item.updatedAt).toLocaleString()}
          </dd>
        </div>
        <!-- Add more fields as needed -->
      </dl>
    </div>
  </div>
</div>
EOF
}

# Function to create create route
create_create_route() {
  local table_name="$1"
  local backend_type="$2"
  local create_route="src/routes/$table_name/new/+page.svelte"
  local create_server="src/routes/$table_name/new/+page.server.ts"
  
  # Create directory if it doesn't exist
  mkdir -p "src/routes/$table_name/new"
  
  # Create the server file with server action
  cat > "$create_server" << EOF
import { error, redirect } from '@sveltejs/kit';
import { superValidate } from 'sveltekit-superforms/server';
import { create${capitalize_first_letter "$table_name"}Schema } from '$lib/schemas/${table_name}';
import { supabase } from '$lib/supabase';
import type { Actions, PageServerLoad } from './$types';

// Prepare an empty form for the page load
export const load: PageServerLoad = async () => {
  const form = await superValidate(create${capitalize_first_letter "$table_name"}Schema);
  
  return {
    form
  };
};

// Handle form submission with server action
export const actions: Actions = {
  default: async (event) => {
    const form = await superValidate(event, create${capitalize_first_letter "$table_name"}Schema);
    
    // Validate form input
    if (!form.valid) {
      return { form };
    }
    
    try {
      // Insert the new item
      const { data, error: insertError } = await supabase
        .from('${table_name}')
        .insert([{
          ...form.data,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        }])
        .select()
        .single();
      
      if (insertError) throw insertError;
      
      // Redirect to the new item's detail page
      throw redirect(303, \`/${table_name}/\${data.id}\`);
    } catch (err) {
      console.error('Error creating ${table_name}:', err);
      
      // Set a form-level error message
      return {
        form,
        error: 'Failed to create ${table_name}. Please try again.'
      };
    }
  }
};
EOF
  
  # Create the client-side component with progressive enhancement
  cat > "$create_route" << EOF
<script lang="ts">
  import { enhance, applyAction } from '$app/forms';
  import { superForm } from 'sveltekit-superforms/client';
  import type { PageData } from './$types';
  import ${capitalize_first_letter "$table_name"}Form from '$lib/components/forms/${table_name}Form.svelte';
  
  export let data: PageData;
  
  // Initialize the form with SuperForms
  const { form, errors, enhance: superEnhance } = superForm(data.form, {
    // Use enhance for progressive enhancement
    taintedMessage: false,
    onUpdate({ form }) {
      // This runs after the form is processed by the server action
      if (form.valid) {
        // The redirect will handle navigation on success
      }
    }
  });
</script>

<svelte:head>
  <title>Create ${capitalize_first_letter "$table_name"}</title>
</svelte:head>

<div class="container mx-auto p-4">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold">Create ${capitalize_first_letter "$table_name"}</h1>
    <a href="/${table_name}" class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded">
      Cancel
    </a>
  </div>
  
  <div class="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4">
    <${capitalize_first_letter "$table_name"}Form {form} {errors} />
  </div>
</div>
EOF
}

# Function to create edit route
create_edit_route() {
  local table_name="$1"
  local backend_type="$2"
  local edit_route="src/routes/$table_name/[id]/edit/+page.svelte"
  local edit_server="src/routes/$table_name/[id]/edit/+page.server.ts"
  
  # Create directory if it doesn't exist
  mkdir -p "src/routes/$table_name/[id]/edit"
  
  # Create the server file with server action
  cat > "$edit_server" << EOF
import { error, redirect } from '@sveltejs/kit';
import { superValidate } from 'sveltekit-superforms/server';
import { update${capitalize_first_letter "$table_name"}Schema } from '$lib/schemas/${table_name}';
import { supabase } from '$lib/supabase';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params }) => {
  try {
    const { id } = params;
    
    if (!id) {
      throw error(400, 'Item ID is required');
    }
    
    // Fetch the item
    const { data, error: queryError } = await supabase
      .from('${table_name}')
      .select('*')
      .eq('id', id)
      .single();
    
    if (queryError) {
      throw error(404, 'Item not found');
    }
    
    // Create a form with the existing data
    const form = await superValidate(data, update${capitalize_first_letter "$table_name"}Schema);
    
    return {
      form,
      id
    };
  } catch (err) {
    console.error('Error loading ${table_name} for edit:', err);
    throw error(500, 'Error loading ${table_name} for edit');
  }
};

// Handle form submission with server action
export const actions: Actions = {
  default: async (event) => {
    const { params } = event;
    const { id } = params;
    
    if (!id) {
      throw error(400, 'Item ID is required');
    }
    
    const form = await superValidate(event, update${capitalize_first_letter "$table_name"}Schema);
    
    // Validate form input
    if (!form.valid) {
      return { form };
    }
    
    try {
      // Update the item
      const { error: updateError } = await supabase
        .from('${table_name}')
        .update({
          ...form.data,
          updatedAt: new Date().toISOString()
        })
        .eq('id', id);
      
      if (updateError) throw updateError;
      
      // Redirect to the item's detail page
      throw redirect(303, \`/${table_name}/\${id}\`);
    } catch (err) {
      console.error('Error updating ${table_name}:', err);
      
      // Set a form-level error message
      return {
        form,
        error: 'Failed to update ${table_name}. Please try again.'
      };
    }
  }
};
EOF
  
  # Create the client-side component with progressive enhancement
  cat > "$edit_route" << EOF
<script lang="ts">
  import { enhance, applyAction } from '$app/forms';
  import { superForm } from 'sveltekit-superforms/client';
  import type { PageData } from './$types';
  import ${capitalize_first_letter "$table_name"}Form from '$lib/components/forms/${table_name}Form.svelte';
  
  export let data: PageData;
  
  // Initialize the form with SuperForms
  const { form, errors, enhance: superEnhance } = superForm(data.form, {
    // Use enhance for progressive enhancement
    taintedMessage: false,
    onUpdate({ form }) {
      // This runs after the form is processed by the server action
      if (form.valid) {
        // The redirect will handle navigation on success
      }
    }
  });
</script>

<svelte:head>
  <title>Edit ${capitalize_first_letter "$table_name"}</title>
</svelte:head>

<div class="container mx-auto p-4">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold">Edit ${capitalize_first_letter "$table_name"}</h1>
    <div class="space-x-2">
      <a href="/${table_name}/{data.id}" class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded">
        Cancel
      </a>
    </div>
  </div>
  
  <div class="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4">
    <${capitalize_first_letter "$table_name"}Form {form} {errors} />
  </div>
</div>
EOF
}

# Function to create form components
create_form_components() {
  local table_name="$1"
  local form_component="src/lib/components/forms/${table_name}Form.svelte"
  
  echo "Creating form components for $table_name..."
  
  # Create the form component
  cat > "$form_component" << EOF
<script lang="ts">
  import { enhance } from '$app/forms';
  import type { SuperValidated } from 'sveltekit-superforms';
  import type { AnyZodObject, z } from 'zod';
  import type { create${capitalize_first_letter "$table_name"}Schema } from '$lib/schemas/${table_name}';
  
  // Props
  export let form: SuperValidated<typeof create${capitalize_first_letter "$table_name"}Schema>;
  export let errors: Record<string, string> = {};
  
  // Track form submission state
  let submitting = false;
</script>

<form method="POST" use:enhance={() => {
    // Set submitting state when form is submitted
    submitting = true;
    
    return async ({ update }) => {
      // Reset submitting state when done
      submitting = false;
      await update();
    };
  }}>
  
  <!-- Form fields -->
  <div class="mb-4">
    <label for="name" class="block text-gray-700 text-sm font-bold mb-2">
      Name
    </label>
    <input
      id="name"
      name="name"
      type="text"
      bind:value={$form.name}
      class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
      placeholder="Enter name"
      aria-invalid={$errors.name ? 'true' : undefined}
    />
    {#if $errors.name}
      <p class="text-red-500 text-xs italic">{$errors.name}</p>
    {/if}
  </div>
  
  <div class="mb-6">
    <label for="description" class="block text-gray-700 text-sm font-bold mb-2">
      Description
    </label>
    <textarea
      id="description"
      name="description"
      bind:value={$form.description}
      class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
      placeholder="Enter description"
      rows="4"
      aria-invalid={$errors.description ? 'true' : undefined}
    ></textarea>
    {#if $errors.description}
      <p class="text-red-500 text-xs italic">{$errors.description}</p>
    {/if}
  </div>
  
  <!-- Add more form fields as needed -->
  
  <div class="flex items-center justify-end space-x-2">
    <button
      type="submit"
      disabled={submitting}
      class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline disabled:opacity-50"
    >
      {submitting ? 'Saving...' : 'Save'}
    </button>
  </div>
</form>
EOF
}

# Function to create table components with filtering and pagination
create_table_components() {
  local table_name="$1"
  local table_component="src/lib/components/tables/${table_name}Table.svelte"
  local filter_component="src/lib/components/ui/FilterBar.svelte"
  local pagination_component="src/lib/components/ui/Pagination.svelte"
  
  echo "Creating table components for $table_name..."
  
  # Create the table component
  cat > "$table_component" << EOF
<script lang="ts">
  import { enhance } from '$app/forms';
  import { createEventDispatcher } from 'svelte';
  import { fade, slide } from 'svelte/transition';
  import { flip } from 'svelte/animate';
  import type { ${capitalize_first_letter "$table_name"} } from '$lib/schemas/${table_name}';
  
  // Props
  export let items: ${capitalize_first_letter "$table_name"}[] = [];
  export let onDelete: (id: string) => void = () => {};
  
  // Event dispatcher
  const dispatch = createEventDispatcher<{
    sort: { field: string; direction: 'asc' | 'desc' };
    select: { item: ${capitalize_first_letter "$table_name"} };
  }>();
  
  // Track deletion state
  let deletingId: string | null = null;
  
  // Handle sort request
  function handleSort(field: string, direction: 'asc' | 'desc') {
    dispatch('sort', { field, direction });
  }
  
  // Handle delete with confirmation
  function confirmDelete(id: string) {
    if (confirm('Are you sure you want to delete this item?')) {
      deletingId = id;
      onDelete(id);
    }
  }
</script>

<div class="overflow-x-auto">
  <table class="min-w-full divide-y divide-gray-200">
    <thead class="bg-gray-50">
      <tr>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Name
          <button class="ml-1" on:click={() => handleSort('name', 'asc')}>▲</button>
          <button class="ml-1" on:click={() => handleSort('name', 'desc')}>▼</button>
        </th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Description
        </th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Created
          <button class="ml-1" on:click={() => handleSort('createdAt', 'asc')}>▲</button>
          <button class="ml-1" on:click={() => handleSort('createdAt', 'desc')}>▼</button>
        </th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Actions
        </th>
      </tr>
    </thead>
    <tbody class="bg-white divide-y divide-gray-200">
      {#each items as item (item.id)}
        <tr 
          animate:flip={{ duration: 300 }}
          in:fade={{ duration: 300 }}
          class="hover:bg-gray-50"
        >
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="text-sm font-medium text-gray-900">
              <a href="/${table_name}/{item.id}" class="hover:underline">
                {item.name}
              </a>
            </div>
          </td>
          <td class="px-6 py-4">
            <div class="text-sm text-gray-500 truncate max-w-xs">
              {item.description}
            </div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="text-sm text-gray-500">
              {new Date(item.createdAt).toLocaleDateString()}
            </div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
            <a href="/${table_name}/{item.id}" class="text-indigo-600 hover:text-indigo-900">
              View
            </a>
            <a href="/${table_name}/{item.id}/edit" class="text-blue-600 hover:text-blue-900">
              Edit
            </a>
            <form action="?/delete" method="POST" class="inline" use:enhance={() => {
              return async ({ result }) => {
                // Reset the deleting state
                deletingId = null;
              };
            }}>
              <input type="hidden" name="id" value={item.id} />
              <button 
                type="submit" 
                class="text-red-600 hover:text-red-900"
                disabled={deletingId === item.id}
                on:click|preventDefault={() => confirmDelete(item.id)}
              >
                {deletingId === item.id ? 'Deleting...' : 'Delete'}
              </button>
            </form>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
</div>
EOF
  
  # Create the filter component
  cat > "$filter_component" << EOF
<script lang="ts">
  import { fade } from 'svelte/transition';
  
  // Props
  export let filter: any = {};
  export let onChange: (newFilter: any) => void = () => {};
  
  // Local filter state
  let name = filter.name || '';
  let isFilterVisible = false;
  
  // Apply filters
  function applyFilters() {
    onChange({
      ...filter,
      name,
      page: 1 // Reset to first page when filters change
    });
  }
  
  // Clear filters
  function clearFilters() {
    name = '';
    onChange({
      sortBy: 'createdAt',
      sortDirection: 'desc',
      page: 1,
      limit: 10
    });
  }
  
  // Toggle filter visibility
  function toggleFilters() {
    isFilterVisible = !isFilterVisible;
  }
</script>

<div class="mb-6 bg-white p-4 rounded-lg shadow">
  <div class="flex justify-between items-center">
    <h2 class="text-lg font-semibold">Filters</h2>
    <button 
      on:click={toggleFilters}
      class="text-gray-500 hover:text-gray-700"
    >
      {isFilterVisible ? 'Hide Filters' : 'Show Filters'} {isFilterVisible ? '▲' : '▼'}
    </button>
  </div>
  
  {#if isFilterVisible}
    <div in:fade={{ duration: 200 }} class="mt-4 space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="space-y-2">
          <label for="filter-name" class="block text-sm font-medium text-gray-700">Name</label>
          <input
            id="filter-name"
            type="text"
            bind:value={name}
            placeholder="Filter by name"
            class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        
        <!-- Add more filter fields as needed -->
      </div>
      
      <div class="flex justify-end space-x-2">
        <button
          on:click={clearFilters}
          class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-4 rounded"
        >
          Clear
        </button>
        <button
          on:click={applyFilters}
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Apply Filters
        </button>
      </div>
    </div>
  {/if}
</div>
EOF
  
  # Create the pagination component
  cat > "$pagination_component" << EOF
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  
  // Props
  export let currentPage: number = 1;
  export let totalPages: number = 1;
  export let maxButtons: number = 5;
  export let onPageChange: (page: number) => void = () => {};
  
  // Event dispatcher
  const dispatch = createEventDispatcher<{
    change: number;
  }>();
  
  // Calculate page range
  $: pageNumbers = getPageNumbers(currentPage, totalPages, maxButtons);
  
  // Page number generator
  function getPageNumbers(current: number, total: number, max: number) {
    if (total <= max) {
      return Array.from({ length: total }, (_, i) => i + 1);
    }
    
    const half = Math.floor(max / 2);
    let start = current - half;
    let end = current + half;
    
    if (start < 1) {
      start = 1;
      end = max;
    } else if (end > total) {
      start = total - max + 1;
      end = total;
    }
    
    return Array.from({ length: end - start + 1 }, (_, i) => start + i);
  }
  
  // Handle page change
  function handlePageChange(page: number) {
    if (page !== currentPage && page >= 1 && page <= totalPages) {
      onPageChange(page);
      dispatch('change', page);
    }
  }
</script>

{#if totalPages > 1}
  <div class="flex items-center justify-center my-6">
    <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
      <!-- Previous page -->
      <button 
        on:click={() => handlePageChange(currentPage - 1)}
        disabled={currentPage === 1}
        class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span class="sr-only">Previous</span>
        &larr;
      </button>
      
      <!-- Page numbers -->
      {#each pageNumbers as page}
        <button 
          on:click={() => handlePageChange(page)}
          aria-current={page === currentPage ? 'page' : undefined}
          class="{page === currentPage 
            ? 'z-10 bg-indigo-50 border-indigo-500 text-indigo-600' 
            : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'} relative inline-flex items-center px-4 py-2 border text-sm font-medium"
        >
          {page}
        </button>
      {/each}
      
      <!-- Next page -->
      <button 
        on:click={() => handlePageChange(currentPage + 1)}
        disabled={currentPage === totalPages}
        class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span class="sr-only">Next</span>
        &rarr;
      </button>
    </nav>
  </div>
{/if}
EOF
}

# Function to create optimistic UI utilities
create_optimistic_ui_utils() {
  local table_name="$1"
  local optimistic_utils="src/lib/utils/optimistic.ts"
  
  echo "Creating optimistic UI utilities..."
  
  # Create utils directory if it doesn't exist
  mkdir -p "src/lib/utils"
  
  # Create the optimistic store utility
  cat > "$optimistic_utils" << EOF
import { writable, type Writable } from 'svelte/store';

// Store instances cache
const storeInstances: Record<string, Writable<any[]>> = {};

// Function to get or create an optimistic store
export function getOptimisticStore<T>(key: string): Writable<T[]> {
  if (!storeInstances[key]) {
    // Create a new store for this key
    storeInstances[key] = writable<T[]>([]);
    
    // Clear the store after a delay (simulating server response)
    setTimeout(() => {
      storeInstances[key].set([]);
    }, 1500);
  }
  
  return storeInstances[key];
}

// Create a typed helper for modifying entities
export function createOptimisticHelper<T extends { id: string }>(storeName: string) {
  const store = getOptimisticStore<T>(storeName);
  
  return {
    // Add a temporary entity
    add: (entity: T) => {
      store.update(entities => [...entities, entity]);
      return () => {
        // Return a cancel function
        store.update(entities => entities.filter(e => e.id !== entity.id));
      };
    },
    
    // Mark entity as being deleted
    delete: (id: string) => {
      store.update(ids => [...ids, id]);
      return () => {
        // Return a cancel function
        store.update(ids => ids.filter(i => i !== id));
      };
    },
    
    // Mark entity as being updated
    update: (entity: T) => {
      store.update(entities => [...entities, entity]);
      return () => {
        // Return a cancel function
        store.update(entities => entities.filter(e => e.id !== entity.id));
      };
    },
    
    // Get the store for subscription
    subscribe: store.subscribe
  };
}
EOF
}

# Function to create real-time features
create_realtime_features() {
  local table_name="$1"
  local realtime_store="src/lib/stores/${table_name}Store.ts"
  
  echo "Creating real-time features..."
  
  # Create stores directory if it doesn't exist
  mkdir -p "src/lib/stores"
  
  # Create the real-time store
  cat > "$realtime_store" << EOF
import { writable, derived, get } from 'svelte/store';
import { supabase } from '$lib/supabase';
import type { ${capitalize_first_letter "$table_name"} } from '$lib/schemas/${table_name}';

// Create a store for ${table_name} items
const ${table_name}Store = writable<${capitalize_first_letter "$table_name"}[]>([]);

// Create a loading state store
const loading = writable(false);

// Create an error store
const error = writable<string | null>(null);

// Initialize subscription flag
let isSubscribed = false;

// Fetch ${table_name} data
export async function fetch${capitalize_first_letter "$table_name"}s(filter?: any) {
  loading.set(true);
  error.set(null);
  
  try {
    // Construct the query
    let query = supabase
      .from('${table_name}')
      .select('*');
    
    // Apply name filter if provided
    if (filter?.name) {
      query = query.ilike('name', \`%\${filter.name}%\`);
    }
    
    // Apply sorting
    if (filter?.sortBy && filter?.sortDirection) {
      query = query.order(filter.sortBy, { ascending: filter.sortDirection === 'asc' });
    } else {
      query = query.order('createdAt', { ascending: false });
    }
    
    // Apply pagination
    if (filter?.page && filter?.limit) {
      const offset = (filter.page - 1) * filter.limit;
      query = query.range(offset, offset + filter.limit - 1);
    }
    
    // Execute the query
    const { data, error: queryError } = await query;
    
    if (queryError) throw queryError;
    
    ${table_name}Store.set(data as ${capitalize_first_letter "$table_name"}[]);
    
    // Set up real-time subscription if not already subscribed
    if (!isSubscribed) {
      subscribeToChanges();
    }
    
    return data;
  } catch (err: any) {
    console.error('Error fetching ${table_name}s:', err);
    error.set(err.message || 'Failed to fetch ${table_name}s');
    return [];
  } finally {
    loading.set(false);
  }
}

// Subscribe to real-time changes
function subscribeToChanges() {
  isSubscribed = true;
  
  // Subscribe to inserts
  const insertSubscription = supabase
    .channel('${table_name}_inserts')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: '${table_name}'
    }, (payload) => {
      const newItem = payload.new as ${capitalize_first_letter "$table_name"};
      ${table_name}Store.update(items => [newItem, ...items]);
    })
    .subscribe();
    
  // Subscribe to updates
  const updateSubscription = supabase
    .channel('${table_name}_updates')
    .on('postgres_changes', {
      event: 'UPDATE',
      schema: 'public',
      table: '${table_name}'
    }, (payload) => {
      const updatedItem = payload.new as ${capitalize_first_letter "$table_name"};
      ${table_name}Store.update(items => 
        items.map(item => item.id === updatedItem.id ? updatedItem : item)
      );
    })
    .subscribe();
    
  // Subscribe to deletes
  const deleteSubscription = supabase
    .channel('${table_name}_deletes')
    .on('postgres_changes', {
      event: 'DELETE',
      schema: 'public',
      table: '${table_name}'
    }, (payload) => {
      const deletedId = payload.old.id;
      ${table_name}Store.update(items => 
        items.filter(item => item.id !== deletedId)
      );
    })
    .subscribe();
  
  // Setup cleanup on window unload
  window.addEventListener('beforeunload', () => {
    insertSubscription.unsubscribe();
    updateSubscription.unsubscribe();
    deleteSubscription.unsubscribe();
    isSubscribed = false;
  });
}

// Add a new ${table_name}
export async function add${capitalize_first_letter "$table_name"}(item: Omit<${capitalize_first_letter "$table_name"}, 'id' | 'createdAt' | 'updatedAt'>) {
  loading.set(true);
  error.set(null);
  
  try {
    const now = new Date().toISOString();
    const newItem = {
      ...item,
      createdAt: now,
      updatedAt: now
    };
    
    const { data, error: insertError } = await supabase
      .from('${table_name}')
      .insert([newItem])
      .select()
      .single();
    
    if (insertError) throw insertError;
    
    // Real-time subscription will handle the update
    return data as ${capitalize_first_letter "$table_name"};
  } catch (err: any) {
    console.error('Error adding ${table_name}:', err);
    error.set(err.message || 'Failed to add ${table_name}');
    throw err;
  } finally {
    loading.set(false);
  }
}

// Update a ${table_name}
export async function update${capitalize_first_letter "$table_name"}(id: string, item: Partial<${capitalize_first_letter "$table_name"}>) {
  loading.set(true);
  error.set(null);
  
  try {
    const { data, error: updateError } = await supabase
      .from('${table_name}')
      .update({
        ...item,
        updatedAt: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single();
    
    if (updateError) throw updateError;
    
    // Real-time subscription will handle the update
    return data as ${capitalize_first_letter "$table_name"};
  } catch (err: any) {
    console.error('Error updating ${table_name}:', err);
    error.set(err.message || 'Failed to update ${table_name}');
    throw err;
  } finally {
    loading.set(false);
  }
}

// Delete a ${table_name}
export async function delete${capitalize_first_letter "$table_name"}(id: string) {
  loading.set(true);
  error.set(null);
  
  try {
    const { error: deleteError } = await supabase
      .from('${table_name}')
      .delete()
      .eq('id', id);
    
    if (deleteError) throw deleteError;
    
    // Real-time subscription will handle the update
    return true;
  } catch (err: any) {
    console.error('Error deleting ${table_name}:', err);
    error.set(err.message || 'Failed to delete ${table_name}');
    throw err;
  } finally {
    loading.set(false);
  }
}

// Export derived stores for convenience
export const ${table_name}s = { subscribe: ${table_name}Store.subscribe };
export const isLoading = { subscribe: loading.subscribe };
export const storeError = { subscribe: error.subscribe };
EOF
}

# Function to show ASCII diagram explaining the architecture
show_architecture_diagram() {
  local theme_emoji=""
  
  case "$THEME" in
    "jungle")
      theme_emoji="🐒 "
      ;;
    "hacker")
      theme_emoji="> "
      ;;
    "wizard")
      theme_emoji="✨ "
      ;;
    "cosmic")
      theme_emoji="🚀 "
      ;;
    *)
      theme_emoji="🧩 "
      ;;
  esac
  
  echo ""
  rainbow_box "${theme_emoji}Modern CRUD Architecture"
  echo ""
  cat << EOF
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐     ┌──────────┐ │
│  │          │      │          │      │          │     │          │ │
│  │  Client  │◄────►│  Routes  │◄────►│  Server  │◄───►│ Database │ │
│  │  State   │      │  Forms   │      │ Actions  │     │          │ │
│  │          │      │          │      │          │     │          │ │
│  └──────────┘      └──────────┘      └──────────┘     └──────────┘ │
│        ▲                                    │                      │
│        │                                    │                      │
│        │             ┌──────────┐           │                      │
│        │             │          │           │                      │
│        └─────────────┤ Real-time◄───────────┘                      │
│                      │ Updates  │                                  │
│                      │          │                                  │
│                      └──────────┘                                  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘

      Optimistic UI       Progressive       Type-safe        Filtering &
      Updates             Enhancement       Validation       Pagination
        ↓                    ↓                 ↓                ↓
     ┌─────┐              ┌─────┐           ┌─────┐          ┌─────┐
     │✨ UI│              │🔄 No │           │📝 Zod│          │🔍 URL│
     │Store│              │  JS │           │Schema│          │Params│
     └─────┘              └─────┘           └─────┘          └─────┘
EOF
  echo ""
}

# Helper function to capitalize first letter of a string
capitalize_first_letter() {
  local string="$1"
  echo "$(tr '[:lower:]' '[:upper:]' <<< ${string:0:1})${string:1}"
}

# Call the main function if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  generate_modern_crud_sveltekit "$@"
fi