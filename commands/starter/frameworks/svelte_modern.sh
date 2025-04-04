#!/bin/bash

# ========= MODERN SVELTEKIT SETUP MODULE =========
# Sets up a new SvelteKit project with modern patterns:
# - Server Actions
# - Progressive Enhancement
# - Form Validation
# - Advanced TypeScript patterns

source "$(dirname "${BASH_SOURCE[0]}")/../../utils/performance.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../utils/style.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../utils/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../utils/profile.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../utils/identity.sh"

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
        "server") echo "🌴" ;;
        "svelte") echo "🐵" ;;
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
        "svelte") echo "[SV]" ;;
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
        "svelte") echo "✨" ;;
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
        "svelte") echo "💫" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "server") echo "🖥️" ;;
        "svelte") echo "🧩" ;;
        *) echo "🐒" ;;
      esac
      ;;
  esac
}

setup_modern_sveltekit() {
  local project_name="$1"
  local project_path="$2"
  
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
  server_emoji=$(get_theme_emoji "server")
  svelte_emoji=$(get_theme_emoji "svelte")
  
  # Check if npm is installed
  if ! command -v npm &> /dev/null; then
    typewriter "$error_emoji npm is required to set up SvelteKit." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  fi
  
  # Tone-aware AND theme-aware introduction based on user's experience level
  if [ "$TONE_STAGE" -le 1 ]; then
    # Complete beginners - very friendly, detailed explanation
    case "$THEME" in
      "jungle")
        typewriter "$svelte_emoji Hey $IDENTITY! Let's swing into a Modern SvelteKit jungle!" 0.02
        echo ""
        typewriter "SvelteKit is like a vine that lets monkeys build tree houses super fast." 0.02
        typewriter "We're setting up a special treehouse with banana-powered features:" 0.02
        echo "  • $server_emoji Server Actions - bananas that ripen faster on the server side"
        echo "  • 🍌 Form Validation - keeps bad bananas out of your jungle"
        echo "  • 🐒 Progressive Enhancement - works even if monkeys disable JavaScript!"
        ;;
      "hacker")
        typewriter "$svelte_emoji INITIALIZING MODERN SVELTEKIT FRAMEWORK FOR USER: $IDENTITY" 0.02
        echo ""
        typewriter "SVELTEKIT FRAMEWORK: EFFICIENT REACTIVE DOM MANIPULATION ENGINE" 0.02
        typewriter "INSTALLING ADVANCED MODULES:" 0.02
        echo "  • $server_emoji SERVER ACTIONS: SECURE SERVER-SIDE EXECUTION PROTOCOLS"
        echo "  • [VALID] FORM VALIDATION: INPUT SANITIZATION AND VERIFICATION"
        echo "  • [PROG] PROGRESSIVE ENHANCEMENT: GRACEFUL DEGRADATION SUPPORT"
        ;;
      "wizard")
        typewriter "$svelte_emoji Greetings, $IDENTITY! Let us conjure a Modern SvelteKit spell!" 0.02
        echo ""
        typewriter "SvelteKit is a powerful grimoire for crafting magical web experiences." 0.02
        typewriter "We're enchanting your project with these mystical powers:" 0.02
        echo "  • $server_emoji Server Actions - spells that cast from the server realm"
        echo "  • ✨ Form Validation - magical runes to purify user input"
        echo "  • 🧙 Progressive Enhancement - magic that works even without the aether of JavaScript"
        ;;
      "cosmic")
        typewriter "$svelte_emoji Greetings, $IDENTITY! Launching Modern SvelteKit into orbit!" 0.02
        echo ""
        typewriter "SvelteKit is an interstellar vessel for navigating the web cosmos." 0.02
        typewriter "We're installing these advanced propulsion systems:" 0.02
        echo "  • $server_emoji Server Actions - quantum entanglement with the server dimension"
        echo "  • 🌠 Form Validation - cosmic ray filters for your data streams"
        echo "  • 🚀 Progressive Enhancement - backup thrusters when JavaScript antimatter is unavailable"
        ;;
      *)
        typewriter "$svelte_emoji Hey $IDENTITY! Let's set up a Modern SvelteKit project for you!" 0.02
        echo ""
        typewriter "SvelteKit is a powerful framework that makes building websites super easy." 0.02
        typewriter "We're setting up an enhanced version with cool features like:" 0.02
        echo "  • $server_emoji Server Actions - makes your forms work better and faster"
        echo "  • ✨ Form Validation - keeps your data clean and error-free"
        echo "  • 💪 Progressive Enhancement - works even without JavaScript!"
        ;;
    esac
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users - moderate explanation, somewhat technical
    case "$THEME" in
      "jungle")
        typewriter "$svelte_emoji Setting up a Modern SvelteKit jungle habitat" 0.02
        echo ""
        echo "Building with enhanced vine patterns for agile swinging:"
        echo "• $server_emoji Server-side actions for smarter banana collection"
        echo "• Form validation to keep jungle data clean"
        echo "• Progressive enhancement for all monkey browsers"
        ;;
      "hacker")
        typewriter "$svelte_emoji CONFIGURING SVELTEKIT FRAMEWORK WITH ENHANCED PROTOCOLS" 0.02
        echo ""
        echo "INSTALLING COMPONENTS:"
        echo "• $server_emoji SERVER ACTIONS MODULE: VALIDATED FORM PROCESSING"
        echo "• ZOD SCHEMA VALIDATION: TYPE-SAFE DATA STRUCTURES"
        echo "• PROGRESSIVE ENHANCEMENT: DEGRADATION FAILSAFES"
        ;;
      "wizard")
        typewriter "$svelte_emoji Preparing SvelteKit enchantment with advanced runes" 0.02
        echo ""
        echo "Weaving these magical elements into your spellbook:"
        echo "• $server_emoji Server action incantations for powerful backend magic"
        echo "• Zod validation wards to protect your data"
        echo "• Progressive enhancement charms for universal compatibility"
        ;;
      "cosmic")
        typewriter "$svelte_emoji Launching SvelteKit with advanced propulsion systems" 0.02
        echo ""
        echo "Installing interstellar components:"
        echo "• $server_emoji Server-side action thrusters for optimal performance"
        echo "• Zod validation shields for data integrity"
        echo "• Progressive enhancement backup systems for universal compatibility"
        ;;
      *)
        typewriter "$svelte_emoji Setting up Modern SvelteKit with enhanced patterns and practices" 0.02
        echo ""
        echo "This setup includes server actions, form validation with Zod, and"
        echo "progressive enhancement for better user experience and performance."
        ;;
    esac
    echo ""
  else
    # Advanced users - minimal, technical explanation
    case "$THEME" in
      "jungle")
        echo "$svelte_emoji Configuring SvelteKit with server actions and Zod validation."
        ;;
      "hacker")
        echo "$svelte_emoji SVELTEKIT SETUP: SERVER ACTIONS + ZOD + PROGRESSIVE ENHANCEMENT"
        ;;
      "wizard")
        echo "$svelte_emoji Conjuring SvelteKit with server actions and validation spells."
        ;;
      "cosmic")
        echo "$svelte_emoji Deploying SvelteKit with server actions and type safety protocols."
        ;;
      *)
        echo "$svelte_emoji Configuring SvelteKit with server actions and Zod validation."
        ;;
    esac
    echo ""
  fi
  
  # Navigate to parent directory if creating in a subfolder
  cd "$(dirname "$project_path")" || {
    echo "$(random_fail)"
    return 1
  }
  
  # Create SvelteKit project with npm
  # Show different prompts based on tone stage and theme
  if [ "$TONE_STAGE" -le 1 ]; then
    # Beginners get a longer explanation with theme-specific messages
    case "$THEME" in
      "jungle")
        typewriter "$info_emoji Planting SvelteKit seeds for your project..." 0.02
        ;;
      "hacker")
        typewriter "$info_emoji INITIALIZING SVELTEKIT REPOSITORY CLONE SEQUENCE..." 0.02
        ;;
      "wizard")
        typewriter "$info_emoji Summoning the SvelteKit creation spell..." 0.02
        ;;
      "cosmic")
        typewriter "$info_emoji Launching SvelteKit project construction sequence..." 0.02
        ;;
      *)
        typewriter "$info_emoji Creating your SvelteKit project..." 0.02
        ;;
    esac
  else
    # More advanced users get simpler prompts
    typewriter "$info_emoji Creating SvelteKit project..." 0.02
  fi
  
  # Show simple terminal progress indicator
  echo -n "["
  for i in {1..30}; do
    echo -n "▓"
    sleep 0.01
  done
  echo -n "]"
  echo ""
  
  if [ "$HEADLESS_MODE" = true ]; then
    # Non-interactive mode for automation - show what's happening for transparency
    if [ "$TONE_STAGE" -le 3 ]; then
      echo "$info_emoji Running in automatic mode with these settings:"
      echo "  • Template: Skeleton project (minimal)"
      echo "  • Language: TypeScript"
      echo "  • Linting: ESLint enabled"
      echo "  • Formatting: Prettier enabled"
      echo "  • Testing: Playwright enabled"
      echo ""
    fi
    
    npm create svelte@latest "$project_name" --quiet -- \
      --template skeleton \
      --types typescript \
      --eslint \
      --prettier \
      --playwright \
      --no-git > /dev/null 2>&1
  else
    # Interactive mode with guidance
    if [ "$TONE_STAGE" -le 2 ]; then
      # More detailed guidance for beginners
      box "$svelte_emoji SvelteKit Setup Guide"
      echo ""
      echo "Hey $IDENTITY! The SvelteKit wizard will ask you a few questions:"
      echo ""
      echo "1️⃣ Which Svelte app template?"
      echo "   → Recommended: 'Skeleton project' for a clean start"
      echo ""
      echo "2️⃣ Add type checking with TypeScript?"
      echo "   → Recommended: 'Yes, using TypeScript syntax' for better code quality"
      echo ""
      echo "3️⃣ Select additional options:"
      echo "   → ESLint: Yes (helps catch errors)"
      echo "   → Prettier: Yes (makes code look neat)"
      echo "   → Playwright: Optional (for testing)"
      echo ""
      read -p "$info_emoji Press Enter when you're ready to start..." 
    else
      # Simpler guidance for more experienced users
      echo "$info_emoji Answer the SvelteKit installer prompts:"
      echo "• Template (skeleton recommended)"
      echo "• TypeScript (recommended)"
      echo "• Code quality tools (ESLint, Prettier recommended)"
      echo ""
      read -p "Press Enter to continue..." 
    fi
    echo ""
    
    npm create svelte@latest "$project_name" --quiet -- --no-git
  fi
  
  # Check if creation was successful
  if [ $? -ne 0 ]; then
    typewriter "$(random_fail) Something went wrong creating the SvelteKit project." 0.02
    return 1
  fi
  
  # Navigate to the project directory
  cd "$project_name" || {
    echo "$(random_fail)"
    return 1
  }
  
  # Install dependencies
  typewriter "Installing dependencies..." 0.02
  npm install > /dev/null 2>&1
  
  if [ $? -ne 0 ]; then
    typewriter "$(random_fail) Something went wrong installing dependencies." 0.02
    return 1
  fi
  
  # Add additional modern dependencies - with tone-appropriate explanations
  if [ "$TONE_STAGE" -le 2 ]; then
    # Show a detailed explanation with ASCII diagram for beginners
    case "$THEME" in
      "jungle")
        typewriter "$svelte_emoji Adding modern SvelteKit vines to your jungle..." 0.02
        ;;
      "hacker")
        typewriter "$svelte_emoji INSTALLING ADVANCED MODULES..." 0.02
        ;;
      "wizard")
        typewriter "$svelte_emoji Enchanting your project with magical components..." 0.02
        ;;
      "cosmic")
        typewriter "$svelte_emoji Installing advanced propulsion systems..." 0.02
        ;;
      *)
        typewriter "$svelte_emoji Adding modern SvelteKit patterns and dependencies..." 0.02
        ;;
    esac
    
    echo ""
    echo "This is how Server Actions work in SvelteKit:"
    echo ""
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│                                                            │"
    echo "│   BROWSER                                 SERVER           │"
    echo "│                                                            │"
    echo "│   ┌─────────────┐                     ┌─────────────┐      │"
    echo "│   │  Form Data  │                     │ Server Code │      │"
    echo "│   └──────┬──────┘                     └──────┬──────┘      │"
    echo "│          │                                   │             │"
    echo "│          │  1. Submit Form                   │             │"
    echo "│          │  ─────────────►                   │             │"
    echo "│          │                                   │             │"
    echo "│          │                 2. Validate Input │             │"
    echo "│          │                     ┌─────────────┘             │"
    echo "│          │                     │                           │"
    echo "│          │                     │ 3. Process Data           │"
    echo "│          │                     │    & Database             │"
    echo "│          │                     │                           │"
    echo "│          │                     └─────────────┐             │"
    echo "│          │  5. Update UI                     │             │"
    echo "│          │  ◄─────────────                   │             │"
    echo "│          │                   4. Return Result│             │"
    echo "│          ▼                     ◄─────────────┘             │"
    echo "│   ┌─────────────┐                                          │"
    echo "│   │  UI Result  │                                          │"
    echo "│   └─────────────┘                                          │"
    echo "│                                                            │"
    echo "└────────────────────────────────────────────────────────────┘"
    echo ""
    echo "Benefits of Server Actions:"
    echo "• Works without JavaScript (progressive enhancement)"
    echo "• Secure - validation happens on the server"
    echo "• Less code - no separate API endpoints needed"
    echo "• Type-safe - complete end-to-end type checking"
    echo ""
  else
    # Simpler explanation for experienced users
    typewriter "$svelte_emoji Installing modern SvelteKit dependencies..." 0.02
  fi
  
  # Show loading animation for package installation
  echo -n "Installing packages: "
  
  # Zod for validation
  echo -n "zod "
  npm install zod zod-form-data > /dev/null 2>&1
  
  # Superforms for enhanced form handling with progressive enhancement
  echo -n "superforms "
  npm install sveltekit-superforms > /dev/null 2>&1
  
  # Add class variance authority for component styling
  echo -n "cva "
  npm install class-variance-authority clsx tailwind-merge > /dev/null 2>&1
  
  # Add prettier plugin for svelte
  echo -n "prettier-plugin-svelte"
  npm install -D prettier-plugin-svelte > /dev/null 2>&1
  
  echo " ✓"
  echo ""
  
  # Create utility directories
  mkdir -p src/lib/validators
  mkdir -p src/lib/server
  mkdir -p src/lib/components/ui/form
  mkdir -p src/lib/components/ui/button
  mkdir -p src/lib/components/ui/input
  
  # Create zod schema validation file
  cat > src/lib/validators/schema.ts << 'EOF'
import { z } from 'zod';

// Base user schema for validation
export const userSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(2, { message: 'Name must be at least 2 characters' }),
  email: z.string().email({ message: 'Please enter a valid email address' }),
  role: z.enum(['user', 'admin', 'editor'], { 
    required_error: 'Role is required',
    invalid_type_error: 'Role must be user, admin, or editor'
  }),
  active: z.boolean().default(true),
  createdAt: z.date().optional()
});

// Infer TypeScript type from schema
export type User = z.infer<typeof userSchema>;

// Create schema
export const createUserSchema = userSchema.omit({ id: true, createdAt: true });

// Update schema
export const updateUserSchema = userSchema.partial().required({ id: true });

// Login schema
export const loginSchema = z.object({
  email: z.string().email({ message: 'Please enter a valid email address' }),
  password: z.string().min(6, { message: 'Password must be at least 6 characters' }),
  remember: z.boolean().default(false)
});

// Todo schema (example)
export const todoSchema = z.object({
  id: z.string().optional(),
  title: z.string().min(1, { message: 'Title is required' }),
  description: z.string().optional(),
  completed: z.boolean().default(false),
  dueDate: z.date().optional(),
  priority: z.enum(['low', 'medium', 'high']).default('medium'),
  tags: z.array(z.string()).default([]),
  createdAt: z.date().optional()
});

export type Todo = z.infer<typeof todoSchema>;
EOF
  
  # Create server action utility file
  cat > src/lib/server/actions.ts << 'EOF'
import { fail, type ActionFailure } from '@sveltejs/kit';
import type { ZodSchema } from 'zod';
import { message, superValidate } from 'sveltekit-superforms/server';
import type { AnyZodObject } from 'zod';

/**
 * Creates a type-safe, validated server action
 * @param schema The Zod schema to validate against
 * @param action The action handler function that receives validated data
 */
export function createAction<TSchema extends AnyZodObject, TOutput>(
  schema: TSchema,
  action: (data: ReturnType<TSchema['parse']>) => Promise<TOutput | ActionFailure<{ form: any }>>
) {
  return async (event: any) => {
    // Validate form using superforms
    const form = await superValidate(event, schema);
    
    // Return validation errors if validation fails
    if (!form.valid) {
      return fail(400, { form });
    }
    
    try {
      // Pass validated data to the action handler
      return await action(form.data);
    } catch (error) {
      console.error('Action error:', error);
      
      // Return friendly error message
      return message(form, {
        type: 'error',
        text: error instanceof Error ? error.message : 'An unknown error occurred'
      }, { status: 500 });
    }
  };
}
EOF
  
  # Create a server API utils file
  cat > src/lib/server/api.ts << 'EOF'
import { error } from '@sveltejs/kit';
import type { ZodSchema } from 'zod';

/**
 * Type-safe API handler with Zod validation
 * @param schema The Zod schema to validate against
 * @param handler The handler function that receives validated data
 */
export function createApiHandler<T extends ZodSchema<any>>(
  schema: T,
  handler: (data: ReturnType<T['parse']>) => Promise<Response>
) {
  return async (request: Request) => {
    try {
      // Parse request body as JSON
      const body = await request.json();
      
      // Validate with Zod schema
      const result = schema.safeParse(body);
      
      if (!result.success) {
        // Return validation errors
        return new Response(
          JSON.stringify({
            success: false,
            errors: result.error.format()
          }),
          { status: 400 }
        );
      }
      
      // Call handler with validated data
      return await handler(result.data);
    } catch (err) {
      console.error('API error:', err);
      throw error(500, 'Internal server error');
    }
  };
}
EOF
  
  # Create a basic button component
  cat > src/lib/components/ui/button/button.svelte << 'EOF'
<script lang="ts">
  import { cva, type VariantProps } from 'class-variance-authority';
  import { cn } from '$lib/utils';
  import { createEventDispatcher } from 'svelte';
  
  const dispatch = createEventDispatcher();
  
  const buttonVariants = cva(
    'inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
    {
      variants: {
        variant: {
          default: 'bg-primary text-primary-foreground hover:bg-primary/90',
          destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
          outline: 'border border-input hover:bg-accent hover:text-accent-foreground',
          secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
          ghost: 'hover:bg-accent hover:text-accent-foreground',
          link: 'text-primary underline-offset-4 hover:underline'
        },
        size: {
          default: 'h-10 px-4 py-2',
          sm: 'h-9 rounded-md px-3',
          lg: 'h-11 rounded-md px-8',
          icon: 'h-10 w-10'
        }
      },
      defaultVariants: {
        variant: 'default',
        size: 'default'
      }
    }
  );
  
  type ButtonVariants = VariantProps<typeof buttonVariants>;
  
  export let variant: ButtonVariants['variant'] = 'default';
  export let size: ButtonVariants['size'] = 'default';
  export let disabled = false;
  export let type: 'button' | 'submit' | 'reset' = 'button';
  export let class: string = '';
  
  function handleClick(e: MouseEvent) {
    if (disabled) {
      e.preventDefault();
      return;
    }
    
    dispatch('click', e);
  }
</script>

<button
  type={type}
  class={cn(buttonVariants({ variant, size }), class)}
  {disabled}
  on:click={handleClick}
  {...$$restProps}
>
  <slot />
</button>
EOF
  
  # Create a utilities file
  cat > src/lib/utils.ts << 'EOF'
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Combines class names with Tailwind CSS support
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Format a date to a locale-friendly string
 */
export function formatDate(date: Date | string): string {
  if (!date) return '';
  
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
}

/**
 * Safely parse JSON with a fallback
 */
export function parseJson<T>(json: string, fallback: T): T {
  try {
    return JSON.parse(json) as T;
  } catch (error) {
    return fallback;
  }
}

/**
 * Delay execution (useful for animations and loading states)
 */
export function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}
EOF
  
  # Create an example server action route using the new patterns
  mkdir -p src/routes/examples/server-action
  
  # Create a simple +page.server.ts file for server action
  cat > src/routes/examples/server-action/+page.server.ts << 'EOF'
import { createAction } from '$lib/server/actions';
import { todoSchema } from '$lib/validators/schema';
import { message } from 'sveltekit-superforms/server';
import { fail, redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

// Define a simple in-memory database for demonstration
let todos: any[] = [
  {
    id: '1',
    title: 'Learn SvelteKit',
    description: 'Master server actions and form validation',
    completed: false,
    priority: 'high',
    dueDate: new Date('2024-01-10')
  }
];

// Type-safe loader function for SSR
export const load: PageServerLoad = async () => {
  // In a real app, this would be a database query
  return {
    todos
  };
};

// Create form for the add todo action
export const actions = {
  // Create a new todo with validation
  createTodo: createAction(todoSchema.omit({ id: true, createdAt: true }), async (data) => {
    // Simulate processing delay (for demo only)
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Create a new todo with the validated data
    const newTodo = {
      ...data,
      id: Math.random().toString(36).substring(2, 9),
      createdAt: new Date()
    };
    
    // Save to our "database"
    todos = [...todos, newTodo];
    
    // Return success message with the created todo
    return message({ success: true, todo: newTodo }, { type: 'success', text: 'Todo created successfully!' });
  }),
  
  // Toggle the completed status of a todo
  toggleComplete: createAction(
    todoSchema.pick({ id: true, completed: true }),
    async (data) => {
      const todoIndex = todos.findIndex(todo => todo.id === data.id);
      
      if (todoIndex === -1) {
        return fail(404, { message: 'Todo not found' });
      }
      
      // Update the todo
      todos[todoIndex] = { ...todos[todoIndex], completed: data.completed };
      
      return { success: true };
    }
  ),
  
  // Delete a todo
  deleteTodo: createAction(
    todoSchema.pick({ id: true }),
    async (data) => {
      todos = todos.filter(todo => todo.id !== data.id);
      return { success: true };
    }
  )
};
EOF
  
  # Create the corresponding +page.svelte file with progressive enhancement
  cat > src/routes/examples/server-action/+page.svelte << 'EOF'
<script lang="ts">
  import { enhance } from '$app/forms';
  import { superForm } from 'sveltekit-superforms/client';
  import type { PageData } from './$types';
  import { formatDate } from '$lib/utils';
  
  export let data: PageData;
  
  // Create a type-safe form with progressive enhancement
  const { form, errors, message, constraints, submitting, reset } = superForm(data.form, {
    id: 'todo-form',
    resetForm: true,
    taintedMessage: false
  });
</script>

<svelte:head>
  <title>Server Actions Example</title>
</svelte:head>

<div class="container mx-auto p-4 max-w-4xl">
  <h1 class="text-3xl font-bold mb-6">Server Actions Example</h1>
  
  <!-- Todo create form with validation -->
  <div class="bg-gray-100 p-6 rounded-lg mb-8">
    <h2 class="text-xl font-semibold mb-4">Create a new Todo</h2>
    
    {#if $message}
      <div class="p-4 mb-4 rounded-md {$message.type === 'error' ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'}">
        {$message.text}
      </div>
    {/if}
    
    <form method="POST" action="?/createTodo" class="space-y-4" use:enhance>
      <div>
        <label for="title" class="block text-sm font-medium text-gray-700 mb-1">Title</label>
        <input 
          id="title"
          name="title"
          bind:value={$form.title}
          aria-invalid={$errors.title ? 'true' : undefined}
          class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
          {...$constraints.title}
        />
        {#if $errors.title}
          <p class="mt-1 text-sm text-red-600">{$errors.title}</p>
        {/if}
      </div>
      
      <div>
        <label for="description" class="block text-sm font-medium text-gray-700 mb-1">Description</label>
        <textarea 
          id="description"
          name="description"
          bind:value={$form.description}
          class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
          rows="3"
        ></textarea>
      </div>
      
      <div>
        <label for="priority" class="block text-sm font-medium text-gray-700 mb-1">Priority</label>
        <select 
          id="priority"
          name="priority"
          bind:value={$form.priority}
          class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
        >
          <option value="low">Low</option>
          <option value="medium">Medium</option>
          <option value="high">High</option>
        </select>
      </div>
      
      <div>
        <label class="flex items-center space-x-2">
          <input 
            type="checkbox"
            name="completed"
            bind:checked={$form.completed}
            class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
          />
          <span class="text-sm font-medium text-gray-700">Completed</span>
        </label>
      </div>
      
      <div class="flex justify-end">
        <button
          type="submit"
          disabled={$submitting}
          class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
        >
          {$submitting ? 'Creating...' : 'Create Todo'}
        </button>
      </div>
    </form>
  </div>
  
  <!-- Todo list with actions -->
  <div>
    <h2 class="text-xl font-semibold mb-4">Todo List</h2>
    
    {#if data.todos.length === 0}
      <p class="text-gray-500 italic">No todos yet. Create one above!</p>
    {:else}
      <ul class="space-y-4">
        {#each data.todos as todo (todo.id)}
          <li class="border rounded-md p-4 {todo.completed ? 'bg-gray-50' : 'bg-white'}">
            <div class="flex justify-between">
              <div class="flex items-start gap-3">
                <form method="POST" action="?/toggleComplete" use:enhance>
                  <input type="hidden" name="id" value={todo.id} />
                  <input type="hidden" name="completed" value={!todo.completed} />
                  <button class="mt-1" type="submit">
                    <div class="h-5 w-5 border rounded-md {todo.completed ? 'bg-indigo-600 border-indigo-600' : 'border-gray-300'}">
                      {#if todo.completed}
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white" class="w-5 h-5">
                          <path fill-rule="evenodd" d="M19.916 4.626a.75.75 0 01.208 1.04l-9 13.5a.75.75 0 01-1.154.114l-6-6a.75.75 0 011.06-1.06l5.353 5.353 8.493-12.739a.75.75 0 011.04-.208z" clip-rule="evenodd" />
                        </svg>
                      {/if}
                    </div>
                  </button>
                </form>
                
                <div>
                  <h3 class="font-medium text-lg {todo.completed ? 'line-through text-gray-500' : ''}">
                    {todo.title}
                  </h3>
                  {#if todo.description}
                    <p class="text-gray-600 mt-1">{todo.description}</p>
                  {/if}
                  <div class="flex gap-2 mt-2">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium 
                      {todo.priority === 'high' ? 'bg-red-100 text-red-800' : 
                      todo.priority === 'medium' ? 'bg-yellow-100 text-yellow-800' : 
                      'bg-green-100 text-green-800'}">
                      {todo.priority}
                    </span>
                    {#if todo.dueDate}
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        Due: {formatDate(todo.dueDate)}
                      </span>
                    {/if}
                  </div>
                </div>
              </div>
              
              <form method="POST" action="?/deleteTodo" use:enhance>
                <input type="hidden" name="id" value={todo.id} />
                <button 
                  type="submit"
                  class="text-red-600 hover:text-red-800"
                  aria-label="Delete todo"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
                  </svg>
                </button>
              </form>
            </div>
          </li>
        {/each}
      </ul>
    {/if}
  </div>
</div>
EOF

  # Create a +layout.svelte file with responsive layout
  cat > src/routes/+layout.svelte << 'EOF'
<script lang="ts">
  import '../app.postcss';
</script>

<div class="min-h-screen flex flex-col">
  <header class="bg-indigo-600 text-white">
    <div class="container mx-auto px-4 py-4 flex justify-between items-center">
      <a href="/" class="text-xl font-bold">Modern SvelteKit</a>
      <nav class="space-x-4">
        <a href="/" class="hover:underline">Home</a>
        <a href="/examples/server-action" class="hover:underline">Server Actions</a>
      </nav>
    </div>
  </header>
  
  <main class="flex-grow">
    <slot />
  </main>
  
  <footer class="bg-gray-100 py-6">
    <div class="container mx-auto px-4 text-center text-gray-600">
      <p>Built with SvelteKit and Git Monkey 🐒</p>
    </div>
  </footer>
</div>
EOF

  # Create a home page
  cat > src/routes/+page.svelte << 'EOF'
<script lang="ts">
  // Import necessary components or data here
</script>

<svelte:head>
  <title>Modern SvelteKit App</title>
</svelte:head>

<div class="container mx-auto px-4 py-12">
  <div class="text-center max-w-3xl mx-auto">
    <h1 class="text-4xl font-bold mb-4">Welcome to Modern SvelteKit</h1>
    <p class="text-xl text-gray-600 mb-8">
      This project template features server actions, progressive enhancement, 
      form validation, and modern TypeScript patterns
    </p>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-12">
      <a href="/examples/server-action" class="block p-6 bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow">
        <h2 class="text-2xl font-semibold mb-3">Server Actions Example</h2>
        <p class="text-gray-600">
          See how to build forms with validation, progressive enhancement,
          and server-side processing.
        </p>
      </a>
      
      <div class="block p-6 bg-white rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-3">More Coming Soon</h2>
        <p class="text-gray-600">
          Additional examples and patterns will be added here.
        </p>
      </div>
    </div>
  </div>
</div>
EOF

  # Create postcss.config.js for Tailwind
  cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOF

  # Create a tailwind.config.js
  cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#4f46e5',
          foreground: '#ffffff'
        },
        secondary: {
          DEFAULT: '#6b7280',
          foreground: '#ffffff'
        },
        destructive: {
          DEFAULT: '#ef4444',
          foreground: '#ffffff'
        },
        muted: {
          DEFAULT: '#f3f4f6',
          foreground: '#1f2937'
        },
        accent: {
          DEFAULT: '#e5e7eb',
          foreground: '#1f2937'
        },
      }
    },
  },
  plugins: [],
};
EOF

  # Create app.postcss file
  cat > src/app.postcss << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  h1 {
    @apply text-3xl font-bold;
  }
  h2 {
    @apply text-2xl font-bold;
  }
  h3 {
    @apply text-xl font-bold;
  }
}

@layer components {
  .btn {
    @apply px-4 py-2 rounded-md font-medium;
  }
  .btn-primary {
    @apply bg-primary text-white hover:bg-primary/90;
  }
  .btn-secondary {
    @apply bg-secondary text-white hover:bg-secondary/90;
  }
}
EOF

  # Add demonstration of terminal efficiency
  local duration=$(end_timing "$start_time")
  local time_saved=$(echo "180.0 - $duration" | bc -l)  # Estimate GUI setup at 3 minutes
  record_operation_time "svelte_modern_setup" "$duration"
  
  # Show theme and tone-appropriate completion message
  if [ "$TONE_STAGE" -le 1 ]; then
    # Beginners get a colorful, enthusiastic message
    case "$THEME" in
      "jungle")
        rainbow_box "🍌 Jungle SvelteKit project created for $IDENTITY!"
        echo "🐒 Your project was built in $(printf "%.1f" "$duration") jungle seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than climbing the GUI trees!"
        echo ""
        echo "Your jungle treehouse has these special vines:"
        echo "  • $server_emoji Server-side vines for swinging data back and forth"
        echo "  • 🍌 Form validation to keep bad bananas out"
        echo "  • 🐒 Progressive enhancement so all monkeys can use your app"
        echo "  • 🌴 Modern component patterns for building better treehouses"
        echo "  • 🦍 Responsive layout for all jungle device sizes"
        ;;
      "hacker")
        rainbow_box "[SYS] SVELTEKIT MODERN DEPLOYMENT COMPLETE"
        echo "[PERF] EXECUTION TIME: $(printf "%.1f" "$duration")s | EFFICIENCY GAIN: $(printf "%.1f" "$time_saved")s"
        echo "[INFO] GUI ALTERNATIVE ESTIMATED AT 180.0s ($(printf "%.1f" "$(echo "($time_saved / 180.0) * 100" | bc -l)")% FASTER)"
        echo ""
        echo "DEPLOYMENT PACKAGE CONTENTS:"
        echo "  • $server_emoji SERVER-SIDE EXECUTION MODULES"
        echo "  • [VALID] FORM VALIDATION PROTOCOLS"
        echo "  • [PROG] PROGRESSIVE ENHANCEMENT FALLBACKS"
        echo "  • [COMP] COMPONENT ARCHITECTURE PATTERNS"
        echo "  • [RESP] MULTI-VIEWPORT LAYOUT ALGORITHMS"
        ;;
      "wizard")
        rainbow_box "✨ Your SvelteKit Spellbook is Ready, $IDENTITY!"
        echo "🧙 Your magical tome was conjured in $(printf "%.1f" "$duration") arcane seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than manual incantations!"
        echo ""
        echo "Your spellbook contains these magical enchantments:"
        echo "  • $server_emoji Server Action spells for powerful backend magic"
        echo "  • ✨ Form Validation runes to purify user input"
        echo "  • 🧙 Progressive Enhancement charms for universal compatibility"
        echo "  • 📜 Modern component patterns for elegant spell composition"
        echo "  • 🔮 Responsive layout for all magical viewing devices"
        ;;
      "cosmic")
        rainbow_box "🚀 SvelteKit Space Station Deployed for $IDENTITY!"
        echo "💫 Your station was constructed in $(printf "%.1f" "$duration") cosmic seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than manual construction!"
        echo ""
        echo "Your space station features these advanced systems:"
        echo "  • $server_emoji Server Action thrusters for optimal data propulsion"
        echo "  • 🌠 Form Validation shields to protect against invalid data meteors"
        echo "  • 🚀 Progressive Enhancement backup systems for universal compatibility"
        echo "  • 🛰️ Modern component patterns for modular space construction"
        echo "  • 🌌 Responsive layout for all viewport dimensions"
        ;;
      *)
        rainbow_box "✅ Modern SvelteKit project created for $IDENTITY!"
        echo "🚀 Your project was created in $(printf "%.1f" "$duration") seconds!"
        echo "⚡ That's $(printf "%.1f" "$time_saved") seconds faster than setting it up manually!"
        echo ""
        echo "📋 Your modern SvelteKit project includes:"
        echo "  • Server Actions with type safety"
        echo "  • Form validation with Zod"
        echo "  • Progressive enhancement"
        echo "  • Modern component patterns"
        echo "  • Responsive layout with Tailwind CSS"
        ;;
    esac
    
    # Show time efficiency visualization for beginners
    echo ""
    echo "Time efficiency comparison:"
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Terminal: $(printf "%3.1f" "$duration")s  $(progress_bar "$duration" 30 180)                    │"
    echo "│ GUI:      180.0s  $(progress_bar 180 30 180)  │"
    echo "└────────────────────────────────────────────────────────────┘"
    
  elif [ "$TONE_STAGE" -le 3 ]; then
    # Intermediate users get a moderate message
    rainbow_box "$success_emoji Modern SvelteKit project created!"
    echo "$info_emoji Setup completed in $(printf "%.1f" "$duration") seconds (estimated $(printf "%.1f" "$time_saved")s faster than manual setup)"
    echo ""
    echo "Project features:"
    echo "• Server Actions for type-safe form handling"
    echo "• Zod validation with SuperForms integration"
    echo "• Progressive enhancement patterns"
    echo "• Component architecture with TypeScript"
    echo "• Responsive UI with Tailwind CSS"
  else
    # Advanced users get minimal output
    echo "$success_emoji Modern SvelteKit setup complete. ($(printf "%.1f" "$duration")s)"
    echo "Includes: server actions, Zod validation, progressive enhancement, TypeScript."
  fi
  
  # Random success message (fun for all tone levels)
  echo ""
  echo "$(random_success)"
  
  # Next steps - tone appropriate
  echo ""
  if [ "$TONE_STAGE" -le 2 ]; then
    echo "🚀 What's next, $IDENTITY?"
    echo "  1. Move into your project folder:  cd $project_name"
    echo "  2. Start the development server:   npm run dev -- --open"
    echo "  3. Check out the example page:     http://localhost:5173/examples/server-action"
    echo ""
    echo "Happy coding! Remember, Git Monkey is here to help if you need it!"
  else
    echo "To get started:"
    echo "  cd $project_name"
    echo "  npm run dev -- --open"
    echo "  # Example at: /examples/server-action"
  fi
  echo ""
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
  
  return 0
}