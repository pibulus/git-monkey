#!/bin/bash

# ========= SKELETON UI ENHANCED SETUP MODULE =========
# Sets up Skeleton UI with Tailwind CSS for SvelteKit
# Enhanced with form patterns, data tables, and advanced customization

source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/performance.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/style.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/profile.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../../utils/identity.sh"

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"  # Can be "info", "success", "error", "warning"
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        "component") echo "🦍" ;;
        "ui") echo "🌴" ;;
        "form") echo "📝" ;;
        "table") echo "🍃" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "component") echo "[COMP]" ;;
        "ui") echo "[UI]" ;;
        "form") echo "[FORM]" ;;
        "table") echo "[TABLE]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "component") echo "🔮" ;;
        "ui") echo "🧪" ;;
        "form") echo "📚" ;;
        "table") echo "🧿" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "component") echo "👽" ;;
        "ui") echo "🛸" ;;
        "form") echo "📡" ;;
        "table") echo "🪐" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "ℹ️" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "component") echo "🧩" ;;
        "ui") echo "🎨" ;;
        "form") echo "📝" ;;
        "table") echo "📊" ;;
        *) echo "ℹ️" ;;
      esac
      ;;
  esac
}

setup_skeleton_enhanced() {
  local project_path="$1"
  local framework_type="$2"  # should be svelte for Skeleton
  
  # Start timing for performance metrics
  local start_time=$(start_timing)
  
  # Get current tone stage and identity for context-aware help
  TONE_STAGE=$(get_tone_stage)
  THEME=$(get_selected_theme)
  IDENTITY=$(get_full_identity)
  
  # Get theme-specific emojis
  info_emoji=$(get_theme_emoji "info")
  success_emoji=$(get_theme_emoji "success")
  error_emoji=$(get_theme_emoji "error")
  warning_emoji=$(get_theme_emoji "warning")
  component_emoji=$(get_theme_emoji "component")
  ui_emoji=$(get_theme_emoji "ui")
  form_emoji=$(get_theme_emoji "form")
  table_emoji=$(get_theme_emoji "table")
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "$error_emoji npm is required to set up Skeleton UI." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Skeleton only works with SvelteKit
  if [ "$framework_type" != "svelte" ]; then
    typewriter "$error_emoji Skeleton UI is designed specifically for SvelteKit projects." 0.02
    typewriter "Please choose a different UI library for $framework_type projects." 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Tone-aware AND theme-aware introduction based on user's experience level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners - very friendly, detailed explanation
    case "$THEME" in
      "jungle")
        typewriter "$ui_emoji Hey $IDENTITY! Let's enhance your jungle with Skeleton UI treasures!" 0.02
        echo ""
        typewriter "Skeleton UI is like having a toolkit for building amazing tree houses!" 0.02
        typewriter "We're setting up an enhanced version with lots of extra goodies:" 0.02
        echo "  • $component_emoji Beautiful jungle-themed components ready to use"
        echo "  • $form_emoji Smart form validation so monkey inputs are always correct"
        echo "  • $table_emoji Data tables for organizing all your jungle treasures"
        echo "  • 🌈 Custom themes to make your jungle look amazing"
        ;;
      "hacker")
        typewriter "$ui_emoji INITIALIZING ADVANCED SKELETON UI FOR USER: $IDENTITY" 0.02
        echo ""
        typewriter "SKELETON UI: COMPREHENSIVE INTERFACE FRAMEWORK" 0.02
        typewriter "INSTALLING ENHANCED MODULES:" 0.02
        echo "  • $component_emoji COMPONENT ARCHITECTURE: MODULAR DESIGN PATTERNS"
        echo "  • $form_emoji FORM VALIDATION: INPUT SANITIZATION AND ERROR HANDLING"
        echo "  • $table_emoji DATA VISUALIZATION: GRID-BASED INFORMATION DISPLAY"
        echo "  • [THEME] DYNAMIC THEMING: VARIABLE-BASED COLOR SCHEMES"
        ;;
      "wizard")
        typewriter "$ui_emoji Greetings, $IDENTITY! Let us enhance your magical interface with Skeleton UI!" 0.02
        echo ""
        typewriter "Skeleton UI is a powerful grimoire of interface enchantments." 0.02
        typewriter "We're conjuring these mystical enhancements for you:" 0.02
        echo "  • $component_emoji Magical components for your arcane interface"
        echo "  • $form_emoji Enchanted forms with validation spells"
        echo "  • $table_emoji Mystical data tables for your magical knowledge"
        echo "  • 🌟 Theme enchantments to customize your magical appearance"
        ;;
      "cosmic")
        typewriter "$ui_emoji Greetings, $IDENTITY! Upgrading your space station with Skeleton UI!" 0.02
        echo ""
        typewriter "Skeleton UI is like having a cosmic toolkit for building stellar interfaces." 0.02
        typewriter "We're installing these advanced modules into your ship:" 0.02
        echo "  • $component_emoji Cosmic interface components for your control panels"
        echo "  • $form_emoji Intelligent form systems with validation protocols"
        echo "  • $table_emoji Stellar data grids for universal information display"
        echo "  • 🌠 Theme customization for your unique cosmic signature"
        ;;
      *)
        typewriter "$ui_emoji Hey $IDENTITY! Let's enhance your project with Skeleton UI!" 0.02
        echo ""
        typewriter "Skeleton UI gives you a complete toolkit for building amazing interfaces." 0.02
        typewriter "We're setting up an enhanced version with extra features:" 0.02
        echo "  • $component_emoji Beautiful, accessible components ready to use"
        echo "  • $form_emoji Smart form validation to handle user input"
        echo "  • $table_emoji Data tables for organizing information"
        echo "  • 🎨 Customizable themes to match your style"
        ;;
    esac
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users - moderate explanation, somewhat technical
    case "$THEME" in
      "jungle")
        typewriter "$ui_emoji Setting up enhanced Skeleton UI for your jungle project" 0.02
        echo ""
        echo "Adding advanced components to your treehouse:"
        echo "• $component_emoji Complete component ecosystem"
        echo "• $form_emoji Form validation patterns"
        echo "• $table_emoji Data table integration"
        echo "• Custom theme system with variants"
        ;;
      "hacker")
        typewriter "$ui_emoji INITIALIZING SKELETON UI: ADVANCED CONFIGURATION" 0.02
        echo ""
        echo "INSTALLING MODULES:"
        echo "• $component_emoji COMPONENT LIBRARY WITH ADVANCED PATTERNS"
        echo "• $form_emoji FORM VALIDATION SYSTEM WITH ERROR HANDLING"
        echo "• $table_emoji DATA GRID IMPLEMENTATION"
        echo "• THEME CUSTOMIZATION ENGINE"
        ;;
      "wizard")
        typewriter "$ui_emoji Preparing enhanced component grimoire for your magical interface" 0.02
        echo ""
        echo "Adding these arcane elements to your spellbook:"
        echo "• $component_emoji Advanced component enchantments"
        echo "• $form_emoji Form validation spells"
        echo "• $table_emoji Data visualization rituals"
        echo "• Theme customization magic"
        ;;
      "cosmic")
        typewriter "$ui_emoji Installing enhanced UI systems to your space station" 0.02
        echo ""
        echo "Adding advanced interface modules:"
        echo "• $component_emoji Comprehensive component system"
        echo "• $form_emoji Form validation with error handling"
        echo "• $table_emoji Interactive data grids"
        echo "• Dynamic theme configuration"
        ;;
      *)
        typewriter "$ui_emoji Setting up enhanced Skeleton UI for your project" 0.02
        echo ""
        echo "Installing a complete UI system with:"
        echo "• Advanced component patterns with accessibility"
        echo "• Form validation and error handling"
        echo "• Data table integration"
        echo "• Dynamic theme customization"
        ;;
    esac
    echo ""
  else
    # Advanced users - minimal, technical explanation
    case "$THEME" in
      "jungle")
        echo "$ui_emoji Installing enhanced Skeleton UI with forms, tables and theme customization."
        ;;
      "hacker")
        echo "$ui_emoji SKELETON UI SETUP: ADVANCED COMPONENTS + FORM VALIDATION + DATA TABLES"
        ;;
      "wizard")
        echo "$ui_emoji Conjuring enhanced Skeleton UI with form validation and data visualization."
        ;;
      "cosmic")
        echo "$ui_emoji Deploying enhanced Skeleton UI with advanced patterns and theme system."
        ;;
      *)
        echo "$ui_emoji Installing enhanced Skeleton UI with form validation, data tables, and theming."
        ;;
    esac
    echo ""
  fi
  
  # Check if Skeleton base is set up
  if ! grep -q "@skeletonlabs/skeleton" "package.json" 2>/dev/null; then
    typewriter "$warning_emoji Basic Skeleton UI needs to be set up first. Let's do that..." 0.02
    setup_skeleton "$project_path" "$framework_type"
  fi
  
  # Show ASCII diagram for component architecture if tone stage is low
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "Skeleton UI Enhanced Architecture:"
    echo ""
    echo "┌──────────────────────────────────────────────────────────┐"
    echo "│                SKELETON UI ECOSYSTEM                      │"
    echo "│                                                          │"
    echo "│  ┌───────────────┐     ┌───────────────┐                 │"
    echo "│  │  COMPONENTS   │     │    THEMES     │                 │"
    echo "│  │   Buttons     │     │   Default     │                 │"
    echo "│  │   Cards       │     │   Crimson     │                 │"
    echo "│  │   Drawers     │     │   Skeleton    │                 │"
    echo "│  │   Modals      │     │   Modern      │                 │"
    echo "│  │   Toasts      │     │   Vintage     │                 │"
    echo "│  │   ...         │     │   Custom      │                 │"
    echo "│  └───────────────┘     └───────────────┘                 │"
    echo "│           │                   │                          │"
    echo "│           └───────────┬───────┘                          │"
    echo "│                       │                                  │"
    echo "│               ┌───────┴───────┐                          │"
    echo "│               │  APP SHELL    │                          │"
    echo "│               └───────┬───────┘                          │"
    echo "│                       │                                  │"
    echo "│           ┌───────────┴───────────┐                      │"
    echo "│           │                       │                      │"
    echo "│  ┌────────┴─────────┐   ┌─────────┴────────┐             │"
    echo "│  │   FORM SYSTEM    │   │   DATA TABLES    │             │"
    echo "│  │  Input           │   │  Sortable        │             │"
    echo "│  │  Validation      │   │  Filterable      │             │"
    echo "│  │  Error Handling  │   │  Pagination      │             │"
    echo "│  │  Form Actions    │   │  Row Selection   │             │"
    echo "│  └──────────────────┘   └──────────────────┘             │"
    echo "│                                                          │"
    echo "└──────────────────────────────────────────────────────────┘"
    echo ""
  fi
  
  # Install additional dependencies
  typewriter "$info_emoji Installing enhanced Skeleton UI dependencies..." 0.02
  
  # Show loading animation for npm install
  echo -n "Installing packages: "
  
  # Install Svelte Forms Lib for form validation
  echo -n "svelte-forms-lib "
  npm install svelte-forms-lib yup > /dev/null 2>&1
  
  # Install Svelte Table for data tables
  echo -n "svelte-table "
  npm install svelte-table > /dev/null 2>&1
  
  # Install additional utilities
  echo -n "svelte-select date-fns "
  npm install svelte-select date-fns > /dev/null 2>&1
  
  # Install additional Skeleton plugins
  echo -n "@skeletonlabs/skeleton-plugin-dashboard "
  npm install -D @skeletonlabs/skeleton-plugin-dashboard > /dev/null 2>&1
  
  echo " ✓"
  echo ""
  
  # Check if installation was successful
  if [ $? -ne 0 ]; then
    typewriter "$error_emoji $(display_error "$THEME") Something went wrong installing enhanced dependencies." 0.02
    return 1
  fi
  
  # Create lib directories for form utilities
  mkdir -p src/lib/forms
  mkdir -p src/lib/components/data-tables
  mkdir -p src/lib/components/forms
  mkdir -p src/lib/utils
  mkdir -p src/lib/stores
  
  # Create form validation utilities
  typewriter "$form_emoji Creating form validation utilities..." 0.02
  
  cat > src/lib/forms/validation.ts << 'EOF'
import * as yup from 'yup';
import { createForm } from 'svelte-forms-lib';

// Common validation schemas
export const emailSchema = yup.string()
  .email('Please enter a valid email address')
  .required('Email is required');

export const passwordSchema = yup.string()
  .min(8, 'Password must be at least 8 characters')
  .matches(/[A-Z]/, 'Password must contain at least one uppercase letter')
  .matches(/[a-z]/, 'Password must contain at least one lowercase letter')
  .matches(/[0-9]/, 'Password must contain at least one number')
  .required('Password is required');

export const nameSchema = yup.string()
  .min(2, 'Name must be at least 2 characters')
  .max(50, 'Name must be less than 50 characters')
  .required('Name is required');

export const phoneSchema = yup.string()
  .matches(/^(\+\d{1,3}[- ]?)?\d{10}$/, 'Please enter a valid phone number')
  .required('Phone number is required');

// Form creator with common configuration
export function createValidationForm(options) {
  return createForm({
    validationSchema: yup.object().shape(options.schema),
    initialValues: options.initialValues || {},
    onSubmit: options.onSubmit || (values => console.log('Form submitted', values))
  });
}

// Helper to create login form
export function createLoginForm({ onSubmit }) {
  return createValidationForm({
    schema: {
      email: emailSchema,
      password: passwordSchema,
      rememberMe: yup.boolean()
    },
    initialValues: {
      email: '',
      password: '',
      rememberMe: false
    },
    onSubmit
  });
}

// Helper to create registration form
export function createRegistrationForm({ onSubmit }) {
  return createValidationForm({
    schema: {
      name: nameSchema,
      email: emailSchema,
      password: passwordSchema,
      confirmPassword: yup.string()
        .oneOf([yup.ref('password')], 'Passwords must match')
        .required('Please confirm your password'),
      terms: yup.boolean()
        .oneOf([true], 'You must accept the terms and conditions')
    },
    initialValues: {
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
      terms: false
    },
    onSubmit
  });
}
EOF
  
  # Create form components
  cat > src/lib/components/forms/FormField.svelte << 'EOF'
<script>
  export let label = '';
  export let name = '';
  export let type = 'text';
  export let placeholder = '';
  export let value = '';
  export let error = '';
  export let disabled = false;
  export let required = false;
  export let readonly = false;
  export let autocomplete = 'on';
  export let min = undefined;
  export let max = undefined;
  export let step = undefined;
  
  // Svelte bind:value directive needs this
  function handleInput(e) {
    value = type === 'number' ? +e.target.value : e.target.value;
  }
</script>

<div class="form-field space-y-2">
  {#if label}
    <label for={name} class="label">
      <span class="font-medium">{label}{required ? ' *' : ''}</span>
    </label>
  {/if}
  
  <input
    {name}
    {type}
    {placeholder}
    {disabled}
    {readonly}
    {autocomplete}
    {min}
    {max}
    {step}
    class="input"
    class:input-error={error}
    value={value}
    on:input={handleInput}
    on:change
    on:blur
    on:focus
    {...$$restProps}
  />
  
  {#if error}
    <p class="text-error-500 text-sm">{error}</p>
  {/if}
</div>
EOF
  
  cat > src/lib/components/forms/FormSelect.svelte << 'EOF'
<script>
  import Select from 'svelte-select';
  
  export let label = '';
  export let name = '';
  export let value = null;
  export let options = [];
  export let placeholder = 'Select...';
  export let error = '';
  export let disabled = false;
  export let required = false;
  export let multiple = false;
  export let clearable = true;
  
  function handleSelect(event) {
    value = event.detail;
  }
  
  function handleClear() {
    value = multiple ? [] : null;
  }
  
  $: selectedValue = value;
</script>

<div class="form-field space-y-2">
  {#if label}
    <label for={name} class="label">
      <span class="font-medium">{label}{required ? ' *' : ''}</span>
    </label>
  {/if}
  
  <Select
    inputAttributes={{ name }}
    {placeholder}
    {multiple}
    {disabled}
    {clearable}
    items={options}
    value={selectedValue}
    on:select={handleSelect}
    on:clear={handleClear}
    class="select-container"
    selectedItemClass="selected-item"
    hasError={!!error}
  />
  
  {#if error}
    <p class="text-error-500 text-sm">{error}</p>
  {/if}
</div>

<style>
  :global(.select-container) {
    --border-radius: var(--theme-rounded-container);
    --background: var(--theme-bg-surface-form-element);
    --border: var(--theme-border-base);
    --listBackground: var(--theme-bg-dropdown);
    --itemHoverBG: var(--theme-bg-hover);
  }
  
  :global(.selected-item) {
    background-color: var(--theme-bg-primary);
    color: var(--theme-text-on-primary);
  }
</style>
EOF
  
  cat > src/lib/components/forms/FormCheckbox.svelte << 'EOF'
<script>
  export let label = '';
  export let name = '';
  export let checked = false;
  export let error = '';
  export let disabled = false;
  export let required = false;
  
  function handleChange(e) {
    checked = e.target.checked;
  }
</script>

<div class="form-field">
  <label class="flex items-center space-x-2">
    <input
      type="checkbox"
      {name}
      {disabled}
      {required}
      {checked}
      on:change={handleChange}
      class="checkbox"
      {...$$restProps}
    />
    <span>{label}</span>
  </label>
  
  {#if error}
    <p class="text-error-500 text-sm mt-1">{error}</p>
  {/if}
</div>
EOF
  
  # Create data table component
  typewriter "$table_emoji Creating data table components..." 0.02
  
  cat > src/lib/components/data-tables/DataTable.svelte << 'EOF'
<script>
  import { fade } from 'svelte/transition';
  import SvelteTable from 'svelte-table';
  
  export let data = [];
  export let columns = [];
  export let title = '';
  export let description = '';
  export let pagination = true;
  export let pageSize = 10;
  export let pageSizeOptions = [5, 10, 20, 50, 100];
  export let sortable = true;
  export let filterable = true;
  export let rowSelection = false;
  export let loading = false;
  
  // Internal state
  let selectedRows = [];
  let currentPage = 0;
  let currentPageSize = pageSize;
  let searchTerm = '';
  
  $: paginatedData = pagination 
    ? data.slice(currentPage * currentPageSize, (currentPage + 1) * currentPageSize) 
    : data;
  
  $: totalPages = pagination ? Math.ceil(data.length / currentPageSize) : 1;
  
  $: visibleData = searchTerm && filterable 
    ? data.filter(row => 
        columns.some(col => {
          const value = row[col.key];
          return value && value.toString().toLowerCase().includes(searchTerm.toLowerCase());
        })
      )
    : data;
  
  $: paginatedVisibleData = pagination 
    ? visibleData.slice(currentPage * currentPageSize, (currentPage + 1) * currentPageSize) 
    : visibleData;
  
  function handleRowClick(row) {
    if (!rowSelection) return;
    
    const index = selectedRows.findIndex(r => r === row.detail);
    if (index === -1) {
      selectedRows = [...selectedRows, row.detail];
    } else {
      selectedRows = selectedRows.filter((_, i) => i !== index);
    }
  }
  
  function nextPage() {
    if (currentPage < totalPages - 1) {
      currentPage++;
    }
  }
  
  function prevPage() {
    if (currentPage > 0) {
      currentPage--;
    }
  }
  
  function setPage(page) {
    if (page >= 0 && page < totalPages) {
      currentPage = page;
    }
  }
  
  function setPageSize(size) {
    currentPageSize = size;
    currentPage = 0;
  }
  
  function clearSearch() {
    searchTerm = '';
  }
  
  function clearSelection() {
    selectedRows = [];
  }
  
  // Create enhanced columns with row selection if needed
  $: enhancedColumns = rowSelection 
    ? [
        {
          key: '_selection',
          title: '',
          value: (row) => {
            const isSelected = selectedRows.includes(row);
            return `<input type="checkbox" ${isSelected ? 'checked' : ''} />`;
          },
          renderValue: row => row.value,
          sortable: false,
          filterable: false,
          headerClass: 'w-8'
        },
        ...columns
      ]
    : columns;
</script>

<div class="data-table-container card p-4">
  {#if title}
    <header class="mb-4">
      <h3 class="h3">{title}</h3>
      {#if description}
        <p class="text-sm opacity-70">{description}</p>
      {/if}
    </header>
  {/if}
  
  <div class="mb-4 flex flex-wrap justify-between gap-2">
    {#if filterable}
      <div class="search-container input-group input-group-divider grid-cols-[auto_1fr_auto]">
        <div class="input-group-shim">
          <i class="fa-solid fa-search"></i>
        </div>
        <input 
          type="search" 
          bind:value={searchTerm} 
          placeholder="Search..." 
          class="input"
        />
        {#if searchTerm}
          <button class="variant-filled-error btn-icon btn-sm" on:click={clearSearch}>
            <i class="fa-solid fa-times"></i>
          </button>
        {/if}
      </div>
    {/if}
    
    <div class="flex-1"></div>
    
    {#if rowSelection && selectedRows.length > 0}
      <div class="flex items-center gap-2">
        <span class="badge variant-filled">{selectedRows.length} selected</span>
        <button class="btn btn-sm variant-ghost-surface" on:click={clearSelection}>
          Clear
        </button>
      </div>
    {/if}
  </div>
  
  <div class="relative">
    {#if loading}
      <div class="absolute inset-0 flex items-center justify-center bg-surface-100-800-token/30 z-10" transition:fade={{ duration: 100 }}>
        <div class="spinner-third"></div>
      </div>
    {/if}
    
    <div class="table-container">
      <SvelteTable
        {columns}
        rows={paginatedVisibleData}
        classNameTable="table table-hover"
        classNameThead="bg-surface-100-800-token"
        classNameCell="p-2"
        classNameCellHeader="p-2 text-left font-bold"
        classNameRow={(row) => selectedRows.includes(row) ? 'bg-primary-hover' : ''}
        on:clickRow={handleRowClick}
      />
    </div>
  </div>
  
  {#if pagination && data.length > 0}
    <footer class="mt-4 flex justify-between items-center">
      <div class="flex items-center gap-2">
        <select bind:value={currentPageSize} on:change={() => setPageSize(currentPageSize)} class="select select-sm">
          {#each pageSizeOptions as size}
            <option value={size}>{size} rows</option>
          {/each}
        </select>
        <span class="text-sm opacity-70">
          Showing {Math.min(currentPage * currentPageSize + 1, visibleData.length)} - 
          {Math.min((currentPage + 1) * currentPageSize, visibleData.length)} of {visibleData.length}
        </span>
      </div>
      
      <div class="flex items-center gap-1">
        <button class="btn btn-sm variant-ghost" disabled={currentPage === 0} on:click={() => setPage(0)}>
          First
        </button>
        <button class="btn btn-sm variant-ghost" disabled={currentPage === 0} on:click={prevPage}>
          Prev
        </button>
        
        <span class="px-2">
          Page {currentPage + 1} of {totalPages}
        </span>
        
        <button class="btn btn-sm variant-ghost" disabled={currentPage === totalPages - 1} on:click={nextPage}>
          Next
        </button>
        <button class="btn btn-sm variant-ghost" disabled={currentPage === totalPages - 1} on:click={() => setPage(totalPages - 1)}>
          Last
        </button>
      </div>
    </footer>
  {/if}
</div>
EOF
  
  # Create theme store for dynamic theme switching
  typewriter "$ui_emoji Creating theme customization store..." 0.02
  
  # Create the theme store
  mkdir -p src/lib/stores
  
  cat > src/lib/stores/theme.ts << 'EOF'
import { writable } from 'svelte/store';
import { browser } from '$app/environment';

// Available themes from Skeleton
export const availableThmes = [
  'skeleton',
  'modern',
  'hamlindigo',
  'rocket',
  'seafoam',
  'vintage',
  'sahara',
  'crimson',
  'gold-nouveau',
  'wintry',
];

// Initialize theme from localStorage or default to skeleton
const userTheme = browser 
  ? window.localStorage.getItem('theme') || 'skeleton'
  : 'skeleton';

// Create the theme store
export const theme = writable(userTheme);

// Function to update the theme
export function setTheme(newTheme) {
  if (!availableThmes.includes(newTheme)) {
    console.warn(`Theme "${newTheme}" is not available. Using "skeleton" instead.`);
    newTheme = 'skeleton';
  }
  
  theme.set(newTheme);
  
  // Persist to localStorage and update HTML attribute
  if (browser) {
    window.localStorage.setItem('theme', newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  }
}

// Initialize the theme
export function initializeTheme() {
  if (browser) {
    let currentTheme;
    const unsubscribe = theme.subscribe(value => {
      currentTheme = value;
    });
    
    setTheme(currentTheme);
    unsubscribe();
  }
}
EOF
  
  # Create theme switcher component
  mkdir -p src/lib/components/theme-switcher
  
  cat > src/lib/components/theme-switcher/ThemeSwitcher.svelte << 'EOF'
<script>
  import { onMount } from 'svelte';
  import { popup } from '@skeletonlabs/skeleton';
  import { theme, availableThmes, setTheme, initializeTheme } from '$lib/stores/theme';
  
  // Initialize theme on mount
  onMount(() => {
    initializeTheme();
  });
  
  // Preview of themes
  const themeColors = {
    'skeleton': { primary: '#0FBA81', secondary: '#4F46E5' },
    'modern': { primary: '#0EA5E9', secondary: '#EC4899' },
    'hamlindigo': { primary: '#818CF8', secondary: '#6366F1' },
    'rocket': { primary: '#FF5733', secondary: '#6366F1' },
    'seafoam': { primary: '#0CB9C1', secondary: '#3B82F6' },
    'vintage': { primary: '#A27B5C', secondary: '#7C3AED' },
    'sahara': { primary: '#F97316', secondary: '#9A3412' },
    'crimson': { primary: '#DC2626', secondary: '#9D174D' },
    'gold-nouveau': { primary: '#F59E0B', secondary: '#78350F' },
    'wintry': { primary: '#94A3B8', secondary: '#334155' },
  };
</script>

<div class="relative">
  <button
    class="btn variant-filled-primary rounded-sm"
    use:popup={{ event: 'click', target: 'themePopup', placement: 'bottom' }}
  >
    <span>Theme</span>
    <i class="fa-solid fa-palette"></i>
  </button>
  
  <div class="card p-4 w-64 shadow-xl" data-popup="themePopup">
    <div class="grid grid-cols-2 gap-2">
      {#each availableThmes as themeName}
        <button 
          class="text-left p-2 rounded-md flex flex-col gap-1 hover:bg-primary-hover-token"
          class:variant-soft-primary={$theme === themeName}
          on:click={() => setTheme(themeName)}
        >
          <span class="font-medium">{themeName}</span>
          <div class="flex gap-2">
            <div class="w-6 h-6 rounded-full" style="background-color: {themeColors[themeName]?.primary || '#888'}"></div>
            <div class="w-6 h-6 rounded-full" style="background-color: {themeColors[themeName]?.secondary || '#888'}"></div>
          </div>
        </button>
      {/each}
    </div>
    
    <div class="arrow bg-surface-100-800-token"></div>
  </div>
</div>
EOF
  
  # Create example pages
  typewriter "$info_emoji Creating example pages with enhanced components..." 0.02
  
  # Create form examples
  mkdir -p src/routes/examples/forms
  
  cat > src/routes/examples/forms/+page.svelte << 'EOF'
<script>
  import { page } from '$app/stores';
  import { createLoginForm, createRegistrationForm } from '$lib/forms/validation';
  import FormField from '$lib/components/forms/FormField.svelte';
  import FormCheckbox from '$lib/components/forms/FormCheckbox.svelte';
  import FormSelect from '$lib/components/forms/FormSelect.svelte';
  
  // Login form
  const { form: loginForm, handleSubmit: handleLoginSubmit, errors: loginErrors } = createLoginForm({
    onSubmit: values => {
      alert(`Login form submitted with: ${JSON.stringify(values, null, 2)}`);
    }
  });
  
  // Registration form
  const { form: registrationForm, handleSubmit: handleRegistrationSubmit, errors: registrationErrors } = createRegistrationForm({
    onSubmit: values => {
      alert(`Registration form submitted with: ${JSON.stringify(values, null, 2)}`);
    }
  });
  
  // Country options for select
  const countryOptions = [
    { value: 'us', label: 'United States' },
    { value: 'ca', label: 'Canada' },
    { value: 'mx', label: 'Mexico' },
    { value: 'uk', label: 'United Kingdom' },
    { value: 'fr', label: 'France' },
    { value: 'de', label: 'Germany' },
    { value: 'jp', label: 'Japan' },
    { value: 'au', label: 'Australia' },
  ];
  
  // For profile form
  let selectedCountry = null;
  let profileErrors = {};
</script>

<div class="container mx-auto p-4 max-w-4xl space-y-8">
  <header class="space-y-2 text-center my-8">
    <h1 class="h1">Form Examples</h1>
    <p class="text-lg">Enhanced form components with validation</p>
  </header>
  
  <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
    <!-- Login Form -->
    <div class="card p-4">
      <header class="card-header">
        <h2 class="h2">Login Form</h2>
        <p class="opacity-70">With validation and error handling</p>
      </header>
      
      <form on:submit|preventDefault={handleLoginSubmit} class="p-4 space-y-4">
        <FormField
          label="Email"
          name="email"
          type="email"
          placeholder="your@email.com"
          bind:value={$loginForm.email}
          error={$loginErrors.email}
          required
        />
        
        <FormField
          label="Password"
          name="password"
          type="password"
          placeholder="••••••••"
          bind:value={$loginForm.password}
          error={$loginErrors.password}
          required
        />
        
        <FormCheckbox
          label="Remember me"
          name="rememberMe"
          bind:checked={$loginForm.rememberMe}
        />
        
        <div class="flex justify-end">
          <button type="submit" class="btn variant-filled-primary">Log In</button>
        </div>
      </form>
    </div>
    
    <!-- Registration Form -->
    <div class="card p-4">
      <header class="card-header">
        <h2 class="h2">Registration Form</h2>
        <p class="opacity-70">Create a new account</p>
      </header>
      
      <form on:submit|preventDefault={handleRegistrationSubmit} class="p-4 space-y-4">
        <FormField
          label="Full Name"
          name="name"
          placeholder="John Doe"
          bind:value={$registrationForm.name}
          error={$registrationErrors.name}
          required
        />
        
        <FormField
          label="Email"
          name="email"
          type="email"
          placeholder="your@email.com"
          bind:value={$registrationForm.email}
          error={$registrationErrors.email}
          required
        />
        
        <FormField
          label="Password"
          name="password"
          type="password"
          placeholder="••••••••"
          bind:value={$registrationForm.password}
          error={$registrationErrors.password}
          required
        />
        
        <FormField
          label="Confirm Password"
          name="confirmPassword"
          type="password"
          placeholder="••••••••"
          bind:value={$registrationForm.confirmPassword}
          error={$registrationErrors.confirmPassword}
          required
        />
        
        <FormCheckbox
          label="I agree to the terms and conditions"
          name="terms"
          bind:checked={$registrationForm.terms}
          error={$registrationErrors.terms}
          required
        />
        
        <div class="flex justify-end">
          <button type="submit" class="btn variant-filled-primary">Register</button>
        </div>
      </form>
    </div>
  </div>
  
  <!-- Profile Form with Select -->
  <div class="card p-4">
    <header class="card-header">
      <h2 class="h2">Profile Information</h2>
      <p class="opacity-70">With custom select component</p>
    </header>
    
    <form class="p-4 space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <FormField
          label="First Name"
          name="firstName"
          placeholder="John"
          required
        />
        
        <FormField
          label="Last Name"
          name="lastName"
          placeholder="Doe"
          required
        />
        
        <FormField
          label="Email"
          name="email"
          type="email"
          placeholder="your@email.com"
          required
        />
        
        <FormField
          label="Phone"
          name="phone"
          placeholder="+1 (123) 456-7890"
        />
        
        <FormSelect
          label="Country"
          name="country"
          bind:value={selectedCountry}
          options={countryOptions}
          placeholder="Select your country"
          error={profileErrors.country}
        />
        
        <FormField
          label="Postal Code"
          name="postalCode"
          placeholder="12345"
        />
      </div>
      
      <div class="space-y-2">
        <label class="label">
          <span class="font-medium">Bio</span>
        </label>
        <textarea
          name="bio"
          rows="4"
          class="textarea"
          placeholder="Tell us about yourself..."
        ></textarea>
      </div>
      
      <div class="card-footer flex justify-end gap-2">
        <button type="button" class="btn variant-ghost-surface">Cancel</button>
        <button type="submit" class="btn variant-filled-primary">Save Profile</button>
      </div>
    </form>
  </div>
</div>
EOF

  # Create table examples
  mkdir -p src/routes/examples/tables
  
  cat > src/routes/examples/tables/+page.svelte << 'EOF'
<script>
  import { onMount } from 'svelte';
  import DataTable from '$lib/components/data-tables/DataTable.svelte';
  import { formatDate } from 'date-fns';
  
  // Sample data
  let users = [];
  let loading = true;
  
  // Get mock data
  onMount(async () => {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 800));
    
    // Generate mock data
    users = Array.from({ length: 50 }, (_, i) => ({
      id: i + 1,
      name: `User ${i + 1}`,
      email: `user${i + 1}@example.com`,
      role: ['Admin', 'User', 'Editor', 'Viewer'][Math.floor(Math.random() * 4)],
      status: ['Active', 'Inactive', 'Pending'][Math.floor(Math.random() * 3)],
      lastLogin: new Date(Date.now() - Math.floor(Math.random() * 30) * 24 * 60 * 60 * 1000),
      createdAt: new Date(Date.now() - Math.floor(Math.random() * 365) * 24 * 60 * 60 * 1000),
    }));
    
    loading = false;
  });
  
  // Define columns
  const userColumns = [
    {
      key: 'name',
      title: 'Name',
      value: row => row.name,
      sortable: true
    },
    {
      key: 'email',
      title: 'Email',
      value: row => row.email,
      sortable: true
    },
    {
      key: 'role',
      title: 'Role',
      value: row => row.role,
      sortable: true
    },
    {
      key: 'status',
      title: 'Status',
      value: row => row.status,
      renderValue: row => {
        const status = row.status;
        const bgColor = status === 'Active' 
          ? 'variant-soft-success' 
          : status === 'Inactive' 
          ? 'variant-soft-error' 
          : 'variant-soft-warning';
        
        return `<span class="badge ${bgColor}">${status}</span>`;
      },
      sortable: true
    },
    {
      key: 'lastLogin',
      title: 'Last Login',
      value: row => row.lastLogin,
      renderValue: row => formatDate(row.lastLogin, 'MMM d, yyyy'),
      sortable: true
    },
    {
      key: 'actions',
      title: 'Actions',
      value: row => row.id,
      renderValue: row => `
        <div class="flex space-x-2">
          <button class="btn btn-sm variant-ghost" data-action="edit" data-id="${row.id}">Edit</button>
          <button class="btn btn-sm variant-ghost-error" data-action="delete" data-id="${row.id}">Delete</button>
        </div>
      `,
      sortable: false
    }
  ];
  
  // Sample products data
  let products = [
    { id: 1, name: 'Laptop', category: 'Electronics', price: 999.99, stock: 45, rating: 4.5 },
    { id: 2, name: 'Smartphone', category: 'Electronics', price: 699.99, stock: 120, rating: 4.8 },
    { id: 3, name: 'Headphones', category: 'Audio', price: 149.99, stock: 78, rating: 4.2 },
    { id: 4, name: 'Monitor', category: 'Electronics', price: 249.99, stock: 32, rating: 4.6 },
    { id: 5, name: 'Keyboard', category: 'Accessories', price: 89.99, stock: 54, rating: 4.1 },
    { id: 6, name: 'Mouse', category: 'Accessories', price: 49.99, stock: 65, rating: 4.3 },
    { id: 7, name: 'Speakers', category: 'Audio', price: 129.99, stock: 41, rating: 4.4 },
    { id: 8, name: 'Tablet', category: 'Electronics', price: 349.99, stock: 38, rating: 4.7 },
    { id: 9, name: 'Camera', category: 'Photography', price: 549.99, stock: 22, rating: 4.9 },
    { id: 10, name: 'Printer', category: 'Office', price: 199.99, stock: 17, rating: 3.9 },
    { id: 11, name: 'External SSD', category: 'Storage', price: 129.99, stock: 89, rating: 4.7 },
    { id: 12, name: 'USB Hub', category: 'Accessories', price: 39.99, stock: 112, rating: 4.0 },
  ];
  
  // Define columns for products
  const productColumns = [
    {
      key: 'name',
      title: 'Product Name',
      value: row => row.name,
      sortable: true
    },
    {
      key: 'category',
      title: 'Category',
      value: row => row.category,
      sortable: true
    },
    {
      key: 'price',
      title: 'Price',
      value: row => row.price,
      renderValue: row => `$${row.price.toFixed(2)}`,
      sortable: true
    },
    {
      key: 'stock',
      title: 'In Stock',
      value: row => row.stock,
      renderValue: row => {
        const stock = row.stock;
        const stockClass = stock > 50 
          ? 'text-success-500' 
          : stock > 20 
          ? 'text-warning-500' 
          : 'text-error-500';
        
        return `<span class="${stockClass} font-medium">${stock}</span>`;
      },
      sortable: true
    },
    {
      key: 'rating',
      title: 'Rating',
      value: row => row.rating,
      renderValue: row => {
        const rating = row.rating;
        const fullStars = Math.floor(rating);
        const hasHalfStar = rating % 1 >= 0.5;
        
        let stars = '';
        for (let i = 0; i < fullStars; i++) {
          stars += '★';
        }
        
        if (hasHalfStar) {
          stars += '½';
        }
        
        const emptyStars = 5 - Math.ceil(rating);
        for (let i = 0; i < emptyStars; i++) {
          stars += '☆';
        }
        
        return `<span class="text-warning-500">${stars}</span> <span class="text-sm">(${rating})</span>`;
      },
      sortable: true
    }
  ];
</script>

<div class="container mx-auto p-4 space-y-10">
  <header class="space-y-2 text-center my-8">
    <h1 class="h1">Data Tables</h1>
    <p class="text-lg">Enhanced table components with sorting, filtering, and pagination</p>
  </header>
  
  <!-- Users Table -->
  <section class="space-y-4">
    <h2 class="h2">Users Table</h2>
    <p>With row selection, filtering, and pagination</p>
    
    <DataTable
      data={users}
      columns={userColumns}
      title="User Management"
      description="View and manage system users"
      pagination={true}
      pageSize={10}
      sortable={true}
      filterable={true}
      rowSelection={true}
      {loading}
    />
  </section>
  
  <!-- Products Table -->
  <section class="space-y-4">
    <h2 class="h2">Products Table</h2>
    <p>With custom rendering and smaller page size</p>
    
    <DataTable
      data={products}
      columns={productColumns}
      title="Product Inventory"
      description="Current product stock and pricing"
      pagination={true}
      pageSize={5}
      sortable={true}
      filterable={true}
      rowSelection={false}
    />
  </section>
</div>
EOF
  
  # Create a dashboard example
  mkdir -p src/routes/examples/dashboard
  
  cat > src/routes/examples/dashboard/+page.svelte << 'EOF'
<script>
  import { browser } from '$app/environment';
  import ThemeSwitcher from '$lib/components/theme-switcher/ThemeSwitcher.svelte';
  
  // Mock data
  const stats = [
    { label: 'Total Users', value: '12,345', change: '+12%', icon: 'fa-users' },
    { label: 'Revenue', value: '$54,321', change: '+8%', icon: 'fa-dollar-sign' },
    { label: 'Active Projects', value: '48', change: '+5%', icon: 'fa-briefcase' },
    { label: 'Completion Rate', value: '93%', change: '+2%', icon: 'fa-chart-line' },
  ];
  
  const recentActivity = [
    { user: 'John Doe', action: 'Created a new project', time: '5 minutes ago', avatar: 'JD' },
    { user: 'Jane Smith', action: 'Completed task "Design Homepage"', time: '1 hour ago', avatar: 'JS' },
    { user: 'Mike Johnson', action: 'Commented on "API Integration"', time: '3 hours ago', avatar: 'MJ' },
    { user: 'Sarah Lee', action: 'Approved expense report', time: '5 hours ago', avatar: 'SL' },
    { user: 'David Wilson', action: 'Updated project timeline', time: '1 day ago', avatar: 'DW' },
  ];
  
  // Simple chart data using div heights
  let chartData = [65, 40, 85, 30, 55, 60, 70, 45, 90, 80, 35, 60];
  let chartDataMobile = [65, 85, 55, 60, 90, 35];
  
  // Labels for chart
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const mobileMonths = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
  
  // Determine if mobile view based on viewport
  let isMobile = false;
  
  function updateIsMobile() {
    isMobile = window.innerWidth < 768;
  }
  
  // Update on mount and window resize
  $: displayChartData = isMobile ? chartDataMobile : chartData;
  $: displayMonths = isMobile ? mobileMonths : months;
  
  onMount(() => {
    updateIsMobile();
    window.addEventListener('resize', updateIsMobile);
    return () => window.removeEventListener('resize', updateIsMobile);
  });
</script>

<div class="container mx-auto p-4 space-y-6">
  <!-- Dashboard Header -->
  <header class="flex justify-between items-center mb-6">
    <div>
      <h1 class="h1">Dashboard</h1>
      <p class="text-surface-600-300-token">Welcome back! Here's an overview of your data.</p>
    </div>
    
    <div class="flex items-center gap-2">
      <ThemeSwitcher />
      <button class="btn variant-filled-secondary">
        <i class="fa-solid fa-download mr-2"></i>
        Export
      </button>
    </div>
  </header>
  
  <!-- Stats Cards -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
    {#each stats as stat}
      <div class="card p-4 flex items-center">
        <div class="rounded-full bg-primary-500/20 p-3 mr-4">
          <i class="fa-solid {stat.icon} text-primary-500 text-xl"></i>
        </div>
        <div>
          <p class="font-bold text-2xl">{stat.value}</p>
          <p class="text-sm text-surface-600-300-token">{stat.label}</p>
          <p class="text-xs text-success-500">{stat.change} from last month</p>
        </div>
      </div>
    {/each}
  </div>
  
  <!-- Main Content -->
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Chart Section -->
    <div class="card p-4 lg:col-span-2">
      <header class="card-header">
        <h2 class="h3">Monthly Performance</h2>
        <p class="opacity-70">User activity over time</p>
      </header>
      
      <div class="p-4">
        <!-- Simple Chart using CSS -->
        <div class="mt-6 relative" style="height: 200px;">
          <div class="absolute inset-0 grid place-items-center opacity-10">
            <div class="w-full border-b border-dashed border-surface-500"></div>
            <div class="w-full border-b border-dashed border-surface-500"></div>
            <div class="w-full border-b border-dashed border-surface-500"></div>
          </div>
          
          <div class="relative h-full flex items-end justify-between">
            {#each displayChartData as value, i}
              <div class="flex flex-col items-center flex-1">
                <div
                  class="w-full max-w-[30px] bg-primary-500 rounded-t-sm transition-all duration-500"
                  style="height: {value}%;"
                  role="presentation"
                  aria-label="{displayMonths[i]}: {value}%"
                ></div>
                <span class="text-xs mt-2">{displayMonths[i]}</span>
              </div>
            {/each}
          </div>
        </div>
      </div>
      
      <footer class="card-footer">
        <button class="btn variant-ghost-surface">View Details</button>
      </footer>
    </div>
    
    <!-- Recent Activity -->
    <div class="card p-4">
      <header class="card-header">
        <h2 class="h3">Recent Activity</h2>
        <p class="opacity-70">Latest actions from your team</p>
      </header>
      
      <div class="p-2">
        <div class="divide-y divide-surface-200-700-token">
          {#each recentActivity as activity}
            <div class="py-3 flex items-start">
              <div class="avatar bg-primary-500 text-white flex items-center justify-center h-8 w-8 rounded-full text-sm font-bold mr-3">
                {activity.avatar}
              </div>
              <div class="flex-1">
                <p class="font-semibold">{activity.user}</p>
                <p class="text-sm opacity-70">{activity.action}</p>
                <p class="text-xs opacity-50">{activity.time}</p>
              </div>
            </div>
          {/each}
        </div>
      </div>
      
      <footer class="card-footer">
        <button class="btn variant-ghost-surface w-full">View All Activity</button>
      </footer>
    </div>
  </div>
  
  <!-- Project Summary Section -->
  <div class="card p-4">
    <header class="card-header">
      <h2 class="h3">Project Summary</h2>
      <p class="opacity-70">Overview of project status</p>
    </header>
    
    <div class="p-4">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Completed Projects -->
        <div class="rounded-container-token border border-surface-300-600-token p-4">
          <h3 class="h4 text-center">Completed</h3>
          <div class="text-center mt-4 mb-2">
            <div class="text-3xl font-bold text-success-500">24</div>
            <div class="text-sm opacity-70">Projects</div>
          </div>
          <div class="progress-bar h-2 mt-2">
            <div class="progress-bar-track rounded-full bg-surface-300-600-token">
              <div class="progress-bar-fill rounded-full bg-success-500 h-full" style="width: 100%;"></div>
            </div>
          </div>
        </div>
        
        <!-- In Progress Projects -->
        <div class="rounded-container-token border border-surface-300-600-token p-4">
          <h3 class="h4 text-center">In Progress</h3>
          <div class="text-center mt-4 mb-2">
            <div class="text-3xl font-bold text-warning-500">18</div>
            <div class="text-sm opacity-70">Projects</div>
          </div>
          <div class="progress-bar h-2 mt-2">
            <div class="progress-bar-track rounded-full bg-surface-300-600-token">
              <div class="progress-bar-fill rounded-full bg-warning-500 h-full" style="width: 65%;"></div>
            </div>
          </div>
        </div>
        
        <!-- Pending Projects -->
        <div class="rounded-container-token border border-surface-300-600-token p-4">
          <h3 class="h4 text-center">Pending</h3>
          <div class="text-center mt-4 mb-2">
            <div class="text-3xl font-bold text-error-500">6</div>
            <div class="text-sm opacity-70">Projects</div>
          </div>
          <div class="progress-bar h-2 mt-2">
            <div class="progress-bar-track rounded-full bg-surface-300-600-token">
              <div class="progress-bar-fill rounded-full bg-error-500 h-full" style="width: 30%;"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <footer class="card-footer flex justify-end gap-2">
      <button class="btn variant-ghost-surface">View All Projects</button>
      <button class="btn variant-filled-primary">New Project</button>
    </footer>
  </div>
</div>
EOF
  
  # Create an examples index page
  mkdir -p src/routes/examples
  
  cat > src/routes/examples/+page.svelte << 'EOF'
<script>
  import { AppBar } from '@skeletonlabs/skeleton';
  import ThemeSwitcher from '$lib/components/theme-switcher/ThemeSwitcher.svelte';
  
  const examples = [
    {
      title: 'Form Validation',
      description: 'Advanced form components with validation',
      link: '/examples/forms',
      icon: 'fa-clipboard-list'
    },
    {
      title: 'Data Tables',
      description: 'Interactive tables with sorting, filtering, and pagination',
      link: '/examples/tables',
      icon: 'fa-table'
    },
    {
      title: 'Dashboard',
      description: 'Complete dashboard UI with charts and stats',
      link: '/examples/dashboard',
      icon: 'fa-chart-pie'
    }
  ];
</script>

<div class="container mx-auto p-4 max-w-4xl">
  <AppBar class="mb-8">
    <svelte:fragment slot="lead">
      <strong class="text-xl">Skeleton UI Enhanced</strong>
    </svelte:fragment>
    <svelte:fragment slot="trail">
      <ThemeSwitcher />
    </svelte:fragment>
  </AppBar>
  
  <header class="text-center mb-12">
    <h1 class="h1 mb-4">Enhanced Skeleton UI Examples</h1>
    <p class="text-lg">Explore advanced components and patterns for your SvelteKit projects</p>
  </header>
  
  <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
    {#each examples as example}
      <a href={example.link} class="card p-6 flex flex-col items-center text-center hover:bg-primary-hover-token transition-colors">
        <div class="bg-primary-500/20 p-4 rounded-full mb-4">
          <i class="fa-solid {example.icon} text-primary-500 text-2xl"></i>
        </div>
        <h2 class="h3 mb-2">{example.title}</h2>
        <p class="opacity-70">{example.description}</p>
      </a>
    {/each}
  </div>
  
  <div class="card p-6 mt-12">
    <header class="card-header">
      <h2 class="h2">Getting Started</h2>
    </header>
    <section class="p-4">
      <p class="mb-4">These examples demonstrate enhanced Skeleton UI components with:</p>
      <ul class="list-disc list-inside space-y-2 mb-4">
        <li>Form validation with error handling</li>
        <li>Data tables with advanced features</li>
        <li>Dynamic theme switching</li>
        <li>Dashboard UI patterns</li>
      </ul>
      <p>All components are designed to work seamlessly with SvelteKit and Skeleton UI.</p>
    </section>
    <footer class="card-footer flex justify-between">
      <a href="/" class="btn variant-ghost-surface">Back to Home</a>
      <a href="https://skeleton.dev" target="_blank" rel="noopener noreferrer" class="btn variant-filled-primary">
        Learn More
        <i class="fa-solid fa-arrow-right ml-2"></i>
      </a>
    </footer>
  </div>
</div>
EOF
  
  # Update layout to use Font Awesome icons if needed
  if [ -f "src/routes/+layout.svelte" ]; then
    # Check if we already have Font Awesome
    if ! grep -q "font-awesome" "src/routes/+layout.svelte"; then
      sed -i '/<script>/a\  // Add Font Awesome for icons\n  import { onMount } from "svelte";\n  \n  onMount(() => {\n    // Add Font Awesome\n    const link = document.createElement("link");\n    link.rel = "stylesheet";\n    link.href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css";\n    document.head.appendChild(link);\n  });' "src/routes/+layout.svelte"
    fi
  fi
  
  # Measure duration for performance comparison
  local duration=$(end_timing "$start_time")
  local time_saved=$(echo "300.0 - $duration" | bc -l)  # Estimate GUI setup at 5 minutes
  record_operation_time "skeleton_enhanced_setup" "$duration"
  
  # Show theme and tone-appropriate completion message
  if [ "$TONE_STAGE" -le 1 ]; then
    # Beginners get a colorful, enthusiastic message
    case "$THEME" in
      "jungle")
        rainbow_box "🍌 Enhanced Skeleton UI now in your jungle treehouse!"
        echo "🐒 Your enhancements were planted in $(printf "%.1f" "$duration") jungle seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than climbing the GUI trees!"
        echo ""
        echo "Your jungle now has these amazing new features:"
        echo "  • $form_emoji Smart jungle forms that validate all monkey inputs"
        echo "  • $table_emoji Beautiful tables to organize all your jungle data"
        echo "  • $ui_emoji Theme switching to change your jungle colors"
        echo "  • 🦍 Complete dashboard for monitoring your jungle"
        echo "  • 🌴 Working examples to explore and learn from"
        ;;
      "hacker")
        rainbow_box "[SYS] ENHANCED SKELETON UI DEPLOYED SUCCESSFULLY"
        echo "[PERF] EXECUTION TIME: $(printf "%.1f" "$duration")s | EFFICIENCY GAIN: $(printf "%.1f" "$time_saved")s"
        echo "[INFO] GUI ALTERNATIVE ESTIMATED AT 300.0s ($(printf "%.1f" "$(echo "($time_saved / 300.0) * 100" | bc -l)")% FASTER)"
        echo ""
        echo "COMPONENT MODULES INSTALLED:"
        echo "  • $form_emoji FORM VALIDATION SYSTEM: INPUT SANITIZATION WITH ERROR HANDLING"
        echo "  • $table_emoji DATA VISUALIZATION: SORTABLE AND FILTERABLE TABLE MODULES"
        echo "  • $ui_emoji THEME CUSTOMIZATION: VARIABLE-BASED COLOR SCHEME PROTOCOLS"
        echo "  • [DASH] DASHBOARD IMPLEMENTATION: METRIC VISUALIZATION INTERFACE"
        echo "  • [DEMO] EXAMPLE IMPLEMENTATIONS: FUNCTIONAL CODE PATTERNS"
        ;;
      "wizard")
        rainbow_box "✨ Your Enhanced Magical Interface is Ready, $IDENTITY!"
        echo "🧙 Your enhancements were conjured in $(printf "%.1f" "$duration") arcane seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than manual enchantments!"
        echo ""
        echo "Your spellbook contains these new magical components:"
        echo "  • $form_emoji Form validation spells to ensure correct magical inputs"
        echo "  • $table_emoji Mystical data tables for organizing your scrolls"
        echo "  • $ui_emoji Theme switching enchantments to change your magical appearance"
        echo "  • 🔮 Dashboard scrying glass to monitor your magical realm"
        echo "  • 📜 Example spells to study and learn from"
        ;;
      "cosmic")
        rainbow_box "🚀 Enhanced Skeleton UI Space Station Modules Installed!"
        echo "💫 Your modules were constructed in $(printf "%.1f" "$duration") cosmic seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than manual construction!"
        echo ""
        echo "Your space station now has these advanced systems:"
        echo "  • $form_emoji Form validation protocols for data integrity"
        echo "  • $table_emoji Data grid systems for universal information management"
        echo "  • $ui_emoji Theme switching mechanisms for visual customization"
        echo "  • 👽 Dashboard control panels for monitoring your space station"
        echo "  • 🛸 Example implementations for your crew to explore"
        ;;
      *)
        rainbow_box "✅ Enhanced Skeleton UI features added to your project!"
        echo "🚀 Features were set up in $(printf "%.1f" "$duration") seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than setting up manually!"
        echo ""
        echo "📋 Your enhanced Skeleton UI integration includes:"
        echo "  • Form validation with error handling"
        echo "  • Data tables with sorting, filtering, and pagination"
        echo "  • Theme switching capability with multiple themes"
        echo "  • Dashboard UI patterns and examples"
        echo "  • Working examples of all new features"
        ;;
    esac
    
    # Show time efficiency visualization for beginners
    echo ""
    echo "Time efficiency comparison:"
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Terminal: $(printf "%3.1f" "$duration")s  $(progress_bar "$duration" 30 300)                    │"
    echo "│ GUI:      300.0s  $(progress_bar 300 30 300)  │"
    echo "└────────────────────────────────────────────────────────────┘"
    
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get a moderate message
    rainbow_box "$success_emoji Enhanced Skeleton UI installed successfully!"
    echo "$info_emoji Setup completed in $(printf "%.1f" "$duration") seconds (estimated $(printf "%.1f" "$time_saved")s faster than manual setup)"
    echo ""
    echo "Enhanced features:"
    echo "• Form validation system with error handling"
    echo "• Data tables with sorting, filtering, and pagination"
    echo "• Theme switching with multiple themes"
    echo "• Dashboard UI components and examples"
    echo "• Working example pages at /examples"
  else
    # Advanced users get minimal output
    echo "$success_emoji Enhanced Skeleton UI setup complete. ($(printf "%.1f" "$duration")s)"
    echo "Added: form validation, data tables, theme switching, dashboard components."
    echo "Examples at: /examples"
  fi
  
  # Random success message (fun for all tone levels)
  echo ""
  echo "$(display_success "$THEME")"
  
  # Next steps - tone appropriate
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo "🚀 Next steps, $IDENTITY:"
    echo "  1. Start your development server:  npm run dev -- --open"
    echo "  2. Check out the examples:         http://localhost:5173/examples"
    echo "  3. Use the components in your app: import { FormField } from '\$lib/components/forms/FormField.svelte';"
    echo ""
    echo "Happy coding! Git Monkey is here to help if you need anything else!"
  fi
  echo ""
  
  return 0
}

# Helper function to create a progress bar
progress_bar() {
  local value=$1
  local max_length=$2
  local full_value=$3
  local filled_length=$(echo "($value / $full_value) * $max_length" | bc -l | cut -d. -f1)
  
  local bar=""
  for ((i=0; i<filled_length; i++)); do
    bar="${bar}█"
  done
  
  for ((i=filled_length; i<max_length; i++)); do
    bar="${bar}░"
  done
  
  echo "$bar"
}