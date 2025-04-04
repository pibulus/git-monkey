#!/bin/bash

# Set directory paths for consistent imports
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
# Get current theme
THEME=$(get_selected_theme)
#!/bin/bash

# ========= FLOWBITE SETUP MODULE =========
# Sets up Flowbite with Tailwind CSS

setup_flowbite() {
  local project_path="$1"
  local framework_type="$2"  # svelte, node, or static
  
  # Check if npm is installed
  if ! check_command "npm"; then
    typewriter "❌ npm is required to set up Flowbite." 0.02
    typewriter "Please install Node.js from https://nodejs.org" 0.02
    return 1
  }
  
  # Navigate to project directory
  cd "$project_path" || {
    echo "$(display_error "$THEME")"
    return 1
  }
  
  # Friendly intro
  typewriter "🌊 Setting up Flowbite - Tailwind CSS component library" 0.02
  typewriter "💡 This will add a comprehensive set of UI components to your project" 0.02
  echo ""
  
  # Check if Tailwind is set up
  if [ ! -f "tailwind.config.js" ] && [ ! -f "tailwind.config.cjs" ]; then
    typewriter "❌ Tailwind CSS needs to be set up first. Let's do that..." 0.02
    setup_tailwind "$project_path" "$framework_type"
  fi
  
  # Install Flowbite
  typewriter "Installing Flowbite..." 0.02
  
  # Different setup based on framework
  case "$framework_type" in
    svelte)
      # For SvelteKit
      npm install flowbite flowbite-svelte > /dev/null 2>&1
      
      # Check if installation was successful
      if [ $? -ne 0 ]; then
        typewriter "$(display_error "$THEME") Something went wrong installing Flowbite." 0.02
        return 1
      fi
      
      # Update tailwind.config.js or tailwind.config.cjs
      typewriter "Configuring Flowbite in Tailwind..." 0.02
      
      # Determine the Tailwind config file name
      TAILWIND_CONFIG="tailwind.config.js"
      if [ -f "tailwind.config.cjs" ]; then
        TAILWIND_CONFIG="tailwind.config.cjs"
      fi
      
      # Create a temporary file
      temp_config=$(mktemp)
      
      # Update the content and plugins sections
      if grep -q "plugins:" "$TAILWIND_CONFIG"; then
        awk '{
          if ($0 ~ /content: \[/) {
            print "  content: ["
            print "    \"./node_modules/flowbite-svelte/**/*.{html,js,svelte,ts}\","
            print "    \"./src/**/*.{html,js,svelte,ts}\","
          } else if ($0 ~ /plugins: \[/) {
            if ($0 ~ /plugins: \[\]/) {
              print "  plugins: [require(\"flowbite/plugin\")],"
            } else {
              gsub(/plugins: \[/, "plugins: [require(\"flowbite/plugin\"),")
              print $0
            }
          } else {
            print $0
          }
        }' "$TAILWIND_CONFIG" > "$temp_config"
        mv "$temp_config" "$TAILWIND_CONFIG"
      else
        # If we can't find the plugins section, create a new config
        cat > "$TAILWIND_CONFIG" << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./node_modules/flowbite-svelte/**/*.{html,js,svelte,ts}",
    "./src/**/*.{html,js,svelte,ts}"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("flowbite/plugin")
  ],
  darkMode: "class"
}
EOF
      fi
      
      # Create a theme file
      mkdir -p src/lib
      
      # Create a theme configuration file
      cat > src/lib/flowbite-theme.js << 'EOF'
// Flowbite theme settings
// This can be imported in your +layout.svelte file

// Define your custom theme
export const customTheme = {
  // Primary colors
  primary: {
    50: '#f0f9ff',
    100: '#e0f2fe',
    200: '#bae6fd',
    300: '#7dd3fc',
    400: '#38bdf8',
    500: '#0ea5e9',
    600: '#0284c7',
    700: '#0369a1',
    800: '#075985',
    900: '#0c4a6e'
  }
};

// Button specific customization
export const buttonTheme = {
  base: 'flex items-center justify-center text-center font-medium focus:ring-4 focus:outline-none',
  fullSized: 'w-full',
  color: {
    primary: 'text-white bg-primary-600 hover:bg-primary-700 focus:ring-primary-300 dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800',
    secondary: 'text-white bg-gray-600 hover:bg-gray-700 focus:ring-gray-300 dark:bg-gray-600 dark:hover:bg-gray-700 dark:focus:ring-gray-800',
    green: 'text-white bg-green-600 hover:bg-green-700 focus:ring-green-300 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800',
    red: 'text-white bg-red-600 hover:bg-red-700 focus:ring-red-300 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-800',
    yellow: 'text-white bg-yellow-600 hover:bg-yellow-700 focus:ring-yellow-300 dark:bg-yellow-600 dark:hover:bg-yellow-700 dark:focus:ring-yellow-800',
    blue: 'text-white bg-blue-600 hover:bg-blue-700 focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800',
    purple: 'text-white bg-purple-600 hover:bg-purple-700 focus:ring-purple-300 dark:bg-purple-600 dark:hover:bg-purple-700 dark:focus:ring-purple-800',
    light: 'text-gray-900 bg-white hover:bg-gray-100 focus:ring-gray-300 dark:bg-gray-800 dark:text-white dark:hover:bg-gray-700 dark:focus:ring-gray-700',
    dark: 'text-white bg-gray-800 hover:bg-gray-900 focus:ring-gray-300 dark:bg-gray-800 dark:hover:bg-gray-700 dark:focus:ring-gray-700'
  },
  size: {
    xs: 'px-2 py-1 text-xs',
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-sm',
    lg: 'px-5 py-2.5 text-base',
    xl: 'px-6 py-3 text-base'
  }
};
EOF
      
      # Create an example page with Flowbite components
      if [ ! -f "src/routes/flowbite-demo.svelte" ]; then
        mkdir -p src/routes
        
        cat > src/routes/flowbite-demo.svelte << 'EOF'
<script>
  // Import Flowbite components
  import { 
    Button, 
    Card, 
    Input, 
    Label, 
    Checkbox, 
    Select, 
    Radio, 
    Textarea, 
    Modal, 
    Tabs, 
    TabItem, 
    Accordion, 
    AccordionItem,
    Alert,
    Badge
  } from 'flowbite-svelte';
  
  // Import theme settings
  import { customTheme, buttonTheme } from '$lib/flowbite-theme';
  
  let showModal = false;
  
  // Example data for select
  const countries = [
    { value: 'us', name: 'United States' },
    { value: 'ca', name: 'Canada' },
    { value: 'uk', name: 'United Kingdom' },
    { value: 'de', name: 'Germany' },
  ];
  
  // Demo form values
  let email = '';
  let password = '';
  let checked = false;
</script>

<svelte:head>
  <title>Flowbite Components Demo</title>
</svelte:head>

<div class="container mx-auto p-8">
  <h1 class="text-3xl font-bold mb-8">Flowbite Components</h1>
  
  <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
    <div>
      <section class="mb-8">
        <h2 class="text-2xl font-semibold mb-4">Buttons</h2>
        <div class="flex flex-wrap gap-2">
          <Button>Default</Button>
          <Button color="primary">Primary</Button>
          <Button color="green">Green</Button>
          <Button color="red">Red</Button>
          <Button color="yellow">Yellow</Button>
          <Button color="purple">Purple</Button>
        </div>
        
        <div class="flex flex-wrap gap-2 mt-4">
          <Button size="xs">Extra Small</Button>
          <Button size="sm">Small</Button>
          <Button size="md">Medium</Button>
          <Button size="lg">Large</Button>
          <Button size="xl">Extra Large</Button>
        </div>
        
        <div class="flex flex-wrap gap-2 mt-4">
          <Button pill={true}>Pill Button</Button>
          <Button outline={true}>Outline</Button>
          <Button gradient={true} color="purple">Gradient</Button>
        </div>
      </section>
      
      <section class="mb-8">
        <h2 class="text-2xl font-semibold mb-4">Forms</h2>
        <div class="mb-4">
          <Label for="email">Email address</Label>
          <Input type="email" id="email" placeholder="name@example.com" bind:value={email} />
        </div>
        
        <div class="mb-4">
          <Label for="password">Password</Label>
          <Input type="password" id="password" bind:value={password} />
        </div>
        
        <div class="mb-4">
          <Label for="countries">Select your country</Label>
          <Select items={countries} />
        </div>
        
        <div class="mb-4">
          <Checkbox bind:checked>Remember me</Checkbox>
        </div>
        
        <div class="mb-4">
          <Radio name="example" value="option1">Option 1</Radio>
          <Radio name="example" value="option2">Option 2</Radio>
          <Radio name="example" value="option3">Option 3</Radio>
        </div>
        
        <div class="mb-4">
          <Label for="comment">Your message</Label>
          <Textarea id="comment" placeholder="Write your thoughts here..." rows="4" />
        </div>
        
        <Button color="primary">Submit</Button>
      </section>
    </div>
    
    <div>
      <section class="mb-8">
        <h2 class="text-2xl font-semibold mb-4">Cards</h2>
        <Card>
          <h5 class="mb-2 text-2xl font-bold tracking-tight">Noteworthy technology</h5>
          <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">
            Here are the biggest enterprise technology acquisitions of 2021 so far, in reverse chronological order.
          </p>
          <Button>
            Read more
            <svg class="w-3.5 h-3.5 ml-2" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
            </svg>
          </Button>
        </Card>
      </section>
      
      <section class="mb-8">
        <h2 class="text-2xl font-semibold mb-4">Tabs</h2>
        <Tabs>
          <TabItem open title="Profile">
            <p class="text-sm text-gray-500 dark:text-gray-400">
              This is your profile information. You can edit or update your details here.
            </p>
          </TabItem>
          <TabItem title="Settings">
            <p class="text-sm text-gray-500 dark:text-gray-400">
              Manage your account settings and preferences.
            </p>
          </TabItem>
          <TabItem title="Messages">
            <p class="text-sm text-gray-500 dark:text-gray-400">
              Read and respond to your messages.
            </p>
          </TabItem>
        </Tabs>
      </section>
      
      <section class="mb-8">
        <h2 class="text-2xl font-semibold mb-4">Alerts</h2>
        <div class="space-y-4">
          <Alert>
            Default alert! Check it out!
          </Alert>
          <Alert color="blue">
            Info alert! Check it out!
          </Alert>
          <Alert color="red">
            Error alert! Check it out!
          </Alert>
          <Alert color="green">
            Success alert! Check it out!
          </Alert>
          <Alert color="yellow">
            Warning alert! Check it out!
          </Alert>
        </div>
      </section>
      
      <section class="mb-8">
        <h2 class="text-2xl font-semibold mb-4">Badges</h2>
        <div class="flex flex-wrap gap-2">
          <Badge>Default</Badge>
          <Badge color="blue">Blue</Badge>
          <Badge color="green">Green</Badge>
          <Badge color="red">Red</Badge>
          <Badge color="purple">Purple</Badge>
          <Badge color="yellow">Yellow</Badge>
        </div>
      </section>
      
      <section class="mb-8">
        <h2 class="text-2xl font-semibold mb-4">Modal</h2>
        <Button on:click={() => (showModal = true)}>Open Modal</Button>
        <Modal title="Terms of Service" bind:open={showModal} autoclose>
          <p class="text-base leading-relaxed text-gray-500 dark:text-gray-400">
            By accepting these terms, you agree to follow these guidelines and rules for using our service.
          </p>
          <p class="text-base leading-relaxed text-gray-500 dark:text-gray-400">
            The General Data Protection Regulation (GDPR) is a regulation in EU law on data protection and privacy for all individuals within the European Union and the European Economic Area.
          </p>
          <svelte:fragment slot="footer">
            <Button on:click={() => (showModal = false)}>I accept</Button>
            <Button color="light" on:click={() => (showModal = false)}>Decline</Button>
          </svelte:fragment>
        </Modal>
      </section>
    </div>
  </div>
</div>
EOF
      fi
      
      # Update the layout file if it exists
      if [ -f "src/routes/+layout.svelte" ]; then
        # Check if Flowbite is already imported
        if ! grep -q "flowbite-svelte" "src/routes/+layout.svelte"; then
          # Create a temporary file
          temp_layout=$(mktemp)
          
          # Add Flowbite imports to the layout
          awk '{
            if ($0 ~ /<script>/) {
              print $0
              print "  // Flowbite theme and styles"
              print "  import { DarkMode } from \"flowbite-svelte\";"
              print "  import \"flowbite/dist/flowbite.css\";"
            } else {
              print $0
            }
          }' "src/routes/+layout.svelte" > "$temp_layout"
          
          # Update the layout body to include DarkMode toggle
          awk '{
            if ($0 ~ /<slot \/>/) {
              print "  <div class=\"p-4\">"
              print "    <DarkMode class=\"fixed right-4 top-4\" />"
              print "  </div>"
              print "  <slot />"
            } else {
              print $0
            }
          }' "$temp_layout" > "src/routes/+layout.svelte"
        else
          typewriter "🔍 Flowbite already imported in layout file." 0.02
        fi
      else
        # Create a new layout file
        mkdir -p src/routes
        
        cat > src/routes/+layout.svelte << 'EOF'
<script>
  // Flowbite theme and styles
  import { DarkMode } from "flowbite-svelte";
  import "flowbite/dist/flowbite.css";
  
  // App CSS
  import "../app.css";
</script>

<div class="p-4">
  <DarkMode class="fixed right-4 top-4" />
</div>

<slot />
EOF
      fi
      ;;
      
    node)
      # For Node/Express projects
      npm install flowbite > /dev/null 2>&1
      
      # Check if installation was successful
      if [ $? -ne 0 ]; then
        typewriter "$(display_error "$THEME") Something went wrong installing Flowbite." 0.02
        return 1
      fi
      
      # Update tailwind.config.js
      typewriter "Configuring Flowbite in Tailwind..." 0.02
      
      # Determine the Tailwind config file name
      TAILWIND_CONFIG="tailwind.config.js"
      if [ -f "tailwind.config.cjs" ]; then
        TAILWIND_CONFIG="tailwind.config.cjs"
      fi
      
      # Create a temporary file
      temp_config=$(mktemp)
      
      # Update the content and plugins sections
      if grep -q "plugins:" "$TAILWIND_CONFIG"; then
        awk '{
          if ($0 ~ /content: \[/) {
            print "  content: ["
            print "    \"./node_modules/flowbite/**/*.js\","
            print "    \"./views/**/*.ejs\","
            print "    \"./public/**/*.{html,js}\","
          } else if ($0 ~ /plugins: \[/) {
            if ($0 ~ /plugins: \[\]/) {
              print "  plugins: [require(\"flowbite/plugin\")],"
            } else {
              gsub(/plugins: \[/, "plugins: [require(\"flowbite/plugin\"),")
              print $0
            }
          } else {
            print $0
          }
        }' "$TAILWIND_CONFIG" > "$temp_config"
        mv "$temp_config" "$TAILWIND_CONFIG"
      else
        # If we can't find the plugins section, create a new config
        cat > "$TAILWIND_CONFIG" << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./node_modules/flowbite/**/*.js",
    "./views/**/*.ejs",
    "./public/**/*.{html,js}"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("flowbite/plugin")
  ],
  darkMode: "class"
}
EOF
      fi
      
      # Create an example EJS view for Flowbite
      mkdir -p views
      
      if [ ! -f "views/flowbite.ejs" ]; then
        cat > views/flowbite.ejs << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Flowbite Components</title>
  <link rel="stylesheet" href="/css/styles.css">
  <script src="/node_modules/flowbite/dist/flowbite.js" defer></script>
</head>
<body class="bg-gray-50 dark:bg-gray-900">
  <div class="container mx-auto p-8">
    <h1 class="text-3xl font-bold mb-8 text-gray-900 dark:text-white">Flowbite Components</h1>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <div>
        <!-- Buttons -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Buttons</h2>
          <div class="flex flex-wrap gap-2">
            <button type="button" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800">Default</button>
            <button type="button" class="py-2.5 px-5 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700">Alternative</button>
            <button type="button" class="text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-green-600 dark:hover:bg-green-700 focus:outline-none dark:focus:ring-green-800">Green</button>
            <button type="button" class="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-red-600 dark:hover:bg-red-700 focus:outline-none dark:focus:ring-red-800">Red</button>
            <button type="button" class="text-white bg-purple-700 hover:bg-purple-800 focus:ring-4 focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-purple-600 dark:hover:bg-purple-700 focus:outline-none dark:focus:ring-purple-800">Purple</button>
          </div>
          
          <div class="flex flex-wrap gap-2 mt-4">
            <button type="button" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Pill Button</button>
            <button type="button" class="text-blue-700 hover:text-white border border-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white dark:hover:bg-blue-500 dark:focus:ring-blue-800">Outline</button>
            <button type="button" class="relative inline-flex items-center justify-center p-0.5 mb-2 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800">
              <span class="relative px-5 py-2 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0">
                Gradient
              </span>
            </button>
          </div>
        </section>
        
        <!-- Form Elements -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Forms</h2>
          <form>
            <div class="mb-6">
              <label for="email" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Email address</label>
              <input type="email" id="email" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="name@example.com" required>
            </div>
            
            <div class="mb-6">
              <label for="password" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Password</label>
              <input type="password" id="password" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" required>
            </div>
            
            <div class="mb-6">
              <label for="countries" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Select your country</label>
              <select id="countries" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
                <option selected>Choose a country</option>
                <option value="US">United States</option>
                <option value="CA">Canada</option>
                <option value="UK">United Kingdom</option>
                <option value="DE">Germany</option>
              </select>
            </div>
            
            <div class="flex items-start mb-6">
              <div class="flex items-center h-5">
                <input id="remember" type="checkbox" value="" class="w-4 h-4 border border-gray-300 rounded bg-gray-50 focus:ring-3 focus:ring-blue-300 dark:bg-gray-700 dark:border-gray-600 dark:focus:ring-blue-600 dark:ring-offset-gray-800" required>
              </div>
              <label for="remember" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">Remember me</label>
            </div>
            
            <button type="submit" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Submit</button>
          </form>
        </section>
      </div>
      
      <div>
        <!-- Card -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Card</h2>
          <div class="max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700">
            <a href="#">
              <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">Noteworthy technology</h5>
            </a>
            <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">Here are the biggest enterprise technology acquisitions of 2021 so far, in reverse chronological order.</p>
            <a href="#" class="inline-flex items-center px-3 py-2 text-sm font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
              Read more
              <svg class="w-3.5 h-3.5 ml-2" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
              </svg>
            </a>
          </div>
        </section>
        
        <!-- Tabs -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Tabs</h2>
          <div class="mb-4 border-b border-gray-200 dark:border-gray-700">
            <ul class="flex flex-wrap -mb-px text-sm font-medium text-center" id="default-tab" data-tabs-toggle="#default-tab-content" role="tablist">
              <li class="mr-2" role="presentation">
                <button class="inline-block p-4 border-b-2 rounded-t-lg" id="profile-tab" data-tabs-target="#profile" type="button" role="tab" aria-controls="profile" aria-selected="false">Profile</button>
              </li>
              <li class="mr-2" role="presentation">
                <button class="inline-block p-4 border-b-2 border-transparent rounded-t-lg hover:text-gray-600 hover:border-gray-300 dark:hover:text-gray-300" id="dashboard-tab" data-tabs-target="#dashboard" type="button" role="tab" aria-controls="dashboard" aria-selected="false">Dashboard</button>
              </li>
              <li class="mr-2" role="presentation">
                <button class="inline-block p-4 border-b-2 border-transparent rounded-t-lg hover:text-gray-600 hover:border-gray-300 dark:hover:text-gray-300" id="settings-tab" data-tabs-target="#settings" type="button" role="tab" aria-controls="settings" aria-selected="false">Settings</button>
              </li>
            </ul>
          </div>
          <div id="default-tab-content">
            <div class="hidden p-4 rounded-lg bg-gray-50 dark:bg-gray-800" id="profile" role="tabpanel" aria-labelledby="profile-tab">
              <p class="text-sm text-gray-500 dark:text-gray-400">This is your profile tab content.</p>
            </div>
            <div class="hidden p-4 rounded-lg bg-gray-50 dark:bg-gray-800" id="dashboard" role="tabpanel" aria-labelledby="dashboard-tab">
              <p class="text-sm text-gray-500 dark:text-gray-400">This is your dashboard tab content.</p>
            </div>
            <div class="hidden p-4 rounded-lg bg-gray-50 dark:bg-gray-800" id="settings" role="tabpanel" aria-labelledby="settings-tab">
              <p class="text-sm text-gray-500 dark:text-gray-400">This is your settings tab content.</p>
            </div>
          </div>
        </section>
        
        <!-- Alerts -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Alerts</h2>
          <div class="flex flex-col gap-4">
            <div class="p-4 mb-4 text-sm text-blue-800 rounded-lg bg-blue-50 dark:bg-gray-800 dark:text-blue-400" role="alert">
              <span class="font-medium">Info alert!</span> Change a few things up and try submitting again.
            </div>
            <div class="p-4 mb-4 text-sm text-red-800 rounded-lg bg-red-50 dark:bg-gray-800 dark:text-red-400" role="alert">
              <span class="font-medium">Danger alert!</span> Change a few things up and try submitting again.
            </div>
            <div class="p-4 mb-4 text-sm text-green-800 rounded-lg bg-green-50 dark:bg-gray-800 dark:text-green-400" role="alert">
              <span class="font-medium">Success alert!</span> Change a few things up and try submitting again.
            </div>
            <div class="p-4 mb-4 text-sm text-yellow-800 rounded-lg bg-yellow-50 dark:bg-gray-800 dark:text-yellow-300" role="alert">
              <span class="font-medium">Warning alert!</span> Change a few things up and try submitting again.
            </div>
          </div>
        </section>
        
        <!-- Modal -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Modal</h2>
          <!-- Modal toggle -->
          <button data-modal-target="defaultModal" data-modal-toggle="defaultModal" class="block text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800" type="button">
            Toggle modal
          </button>

          <!-- Main modal -->
          <div id="defaultModal" tabindex="-1" aria-hidden="true" class="fixed top-0 left-0 right-0 z-50 hidden w-full p-4 overflow-x-hidden overflow-y-auto md:inset-0 h-[calc(100%-1rem)] max-h-full">
            <div class="relative w-full max-w-2xl max-h-full">
              <!-- Modal content -->
              <div class="relative bg-white rounded-lg shadow dark:bg-gray-700">
                <!-- Modal header -->
                <div class="flex items-start justify-between p-4 border-b rounded-t dark:border-gray-600">
                  <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                    Terms of Service
                  </h3>
                  <button type="button" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ml-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white" data-modal-hide="defaultModal">
                    <svg class="w-3 h-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
                      <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
                    </svg>
                    <span class="sr-only">Close modal</span>
                  </button>
                </div>
                <!-- Modal body -->
                <div class="p-6 space-y-6">
                  <p class="text-base leading-relaxed text-gray-500 dark:text-gray-400">
                    With less than a month to go before the European Union enacts new consumer privacy laws for its citizens, companies around the world are updating their terms of service agreements to comply.
                  </p>
                  <p class="text-base leading-relaxed text-gray-500 dark:text-gray-400">
                    The European Union's General Data Protection Regulation (G.D.P.R.) goes into effect on May 25 and is meant to ensure a common set of data rights in the European Union. It requires organizations to notify users as soon as possible of high-risk data breaches that could personally affect them.
                  </p>
                </div>
                <!-- Modal footer -->
                <div class="flex items-center p-6 space-x-2 border-t border-gray-200 rounded-b dark:border-gray-600">
                  <button data-modal-hide="defaultModal" type="button" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">I accept</button>
                  <button data-modal-hide="defaultModal" type="button" class="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-blue-300 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10 dark:bg-gray-700 dark:text-gray-300 dark:border-gray-500 dark:hover:text-white dark:hover:bg-gray-600 dark:focus:ring-gray-600">Decline</button>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
    
    <!-- Dark Mode Toggle -->
    <div class="flex justify-end mt-8">
      <button id="theme-toggle" type="button" class="text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5">
        <svg id="theme-toggle-dark-icon" class="hidden w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path></svg>
        <svg id="theme-toggle-light-icon" class="hidden w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" fill-rule="evenodd" clip-rule="evenodd"></path></svg>
      </button>
    </div>
  </div>
  
  <script>
    // Dark mode toggle
    var themeToggleDarkIcon = document.getElementById('theme-toggle-dark-icon');
    var themeToggleLightIcon = document.getElementById('theme-toggle-light-icon');

    // Change the icons inside the button based on previous settings
    if (localStorage.getItem('color-theme') === 'dark' || (!('color-theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
        themeToggleLightIcon.classList.remove('hidden');
        document.documentElement.classList.add('dark');
    } else {
        themeToggleDarkIcon.classList.remove('hidden');
        document.documentElement.classList.remove('dark');
    }

    var themeToggleBtn = document.getElementById('theme-toggle');

    themeToggleBtn.addEventListener('click', function() {
        // Toggle icons
        themeToggleDarkIcon.classList.toggle('hidden');
        themeToggleLightIcon.classList.toggle('hidden');

        // Toggle dark class
        document.documentElement.classList.toggle('dark');

        // Save preference to localStorage
        if (document.documentElement.classList.contains('dark')) {
            localStorage.setItem('color-theme', 'dark');
        } else {
            localStorage.setItem('color-theme', 'light');
        }
    });
  </script>
</body>
</html>
EOF
      fi
      
      # Add a route for the Flowbite demo
      if [ -f "index.js" ]; then
        # Check if the route already exists
        if ! grep -q "'/flowbite'" "index.js"; then
          # Add the route
          temp_file=$(mktemp)
          awk '{
            if ($0 ~ /app.use\(.*\);/) {
              print $0
              print ""
              print "// Flowbite demo route"
              print "app.get(\"/flowbite\", (req, res) => {"
              print "  res.render(\"flowbite\");"
              print "});"
            } else {
              print $0
            }
          }' "index.js" > "$temp_file"
          mv "$temp_file" "index.js"
        fi
      fi
      ;;
      
    static)
      # For static sites
      npm install flowbite > /dev/null 2>&1
      
      # Check if installation was successful
      if [ $? -ne 0 ]; then
        typewriter "$(display_error "$THEME") Something went wrong installing Flowbite." 0.02
        return 1
      fi
      
      # Update tailwind.config.js
      typewriter "Configuring Flowbite in Tailwind..." 0.02
      
      # Determine the Tailwind config file name
      TAILWIND_CONFIG="tailwind.config.js"
      if [ -f "tailwind.config.cjs" ]; then
        TAILWIND_CONFIG="tailwind.config.cjs"
      fi
      
      # Create a temporary file
      temp_config=$(mktemp)
      
      # Update the content and plugins sections
      if grep -q "plugins:" "$TAILWIND_CONFIG"; then
        awk '{
          if ($0 ~ /content: \[/) {
            print "  content: ["
            print "    \"./node_modules/flowbite/**/*.js\","
            print "    \"./*.html\","
            print "    \"./js/**/*.js\","
          } else if ($0 ~ /plugins: \[/) {
            if ($0 ~ /plugins: \[\]/) {
              print "  plugins: [require(\"flowbite/plugin\")],"
            } else {
              gsub(/plugins: \[/, "plugins: [require(\"flowbite/plugin\"),")
              print $0
            }
          } else {
            print $0
          }
        }' "$TAILWIND_CONFIG" > "$temp_config"
        mv "$temp_config" "$TAILWIND_CONFIG"
      else
        # If we can't find the plugins section, create a new config
        cat > "$TAILWIND_CONFIG" << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./node_modules/flowbite/**/*.js",
    "./*.html",
    "./js/**/*.js"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("flowbite/plugin")
  ],
  darkMode: "class"
}
EOF
      fi
      
      # Create an example HTML file with Flowbite components
      if [ ! -f "flowbite.html" ]; then
        cat > flowbite.html << 'EOF'
<!DOCTYPE html>
<html lang="en" class="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Flowbite Components</title>
  <link rel="stylesheet" href="css/styles.css">
</head>
<body class="bg-gray-50 dark:bg-gray-900">
  <div class="container mx-auto p-8">
    <h1 class="text-3xl font-bold mb-8 text-gray-900 dark:text-white">Flowbite Components</h1>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <div>
        <!-- Buttons -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Buttons</h2>
          <div class="flex flex-wrap gap-2">
            <button type="button" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800">Default</button>
            <button type="button" class="py-2.5 px-5 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700">Alternative</button>
            <button type="button" class="text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-green-600 dark:hover:bg-green-700 focus:outline-none dark:focus:ring-green-800">Green</button>
            <button type="button" class="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-red-600 dark:hover:bg-red-700 focus:outline-none dark:focus:ring-red-800">Red</button>
          </div>
          
          <div class="flex flex-wrap gap-2 mt-4">
            <button type="button" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Pill Button</button>
            <button type="button" class="text-blue-700 hover:text-white border border-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white dark:hover:bg-blue-500 dark:focus:ring-blue-800">Outline</button>
            <button type="button" class="relative inline-flex items-center justify-center p-0.5 mb-2 overflow-hidden text-sm font-medium text-gray-900 rounded-lg group bg-gradient-to-br from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white dark:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800">
              <span class="relative px-5 py-2.5 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0">
                Gradient
              </span>
            </button>
          </div>
        </section>
        
        <!-- Form Elements -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Forms</h2>
          <form>
            <div class="mb-6">
              <label for="email" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Email address</label>
              <input type="email" id="email" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="name@example.com" required>
            </div>
            
            <div class="mb-6">
              <label for="password" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Password</label>
              <input type="password" id="password" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" required>
            </div>
            
            <div class="mb-6">
              <label for="countries" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Select your country</label>
              <select id="countries" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
                <option selected>Choose a country</option>
                <option value="US">United States</option>
                <option value="CA">Canada</option>
                <option value="UK">United Kingdom</option>
                <option value="DE">Germany</option>
              </select>
            </div>
            
            <div class="flex items-start mb-6">
              <div class="flex items-center h-5">
                <input id="remember" type="checkbox" value="" class="w-4 h-4 border border-gray-300 rounded bg-gray-50 focus:ring-3 focus:ring-blue-300 dark:bg-gray-700 dark:border-gray-600 dark:focus:ring-blue-600 dark:ring-offset-gray-800" required>
              </div>
              <label for="remember" class="ml-2 text-sm font-medium text-gray-900 dark:text-gray-300">Remember me</label>
            </div>
            
            <button type="submit" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Submit</button>
          </form>
        </section>
      </div>
      
      <div>
        <!-- Card -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Card</h2>
          <div class="max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700">
            <a href="#">
              <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">Noteworthy technology</h5>
            </a>
            <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">Here are the biggest enterprise technology acquisitions of 2021 so far, in reverse chronological order.</p>
            <a href="#" class="inline-flex items-center px-3 py-2 text-sm font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
              Read more
              <svg class="w-3.5 h-3.5 ml-2" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
              </svg>
            </a>
          </div>
        </section>
        
        <!-- Tabs -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Tabs</h2>
          <div class="mb-4 border-b border-gray-200 dark:border-gray-700">
            <ul class="flex flex-wrap -mb-px text-sm font-medium text-center" id="default-tab" data-tabs-toggle="#default-tab-content" role="tablist">
              <li class="mr-2" role="presentation">
                <button class="inline-block p-4 border-b-2 rounded-t-lg" id="profile-tab" data-tabs-target="#profile" type="button" role="tab" aria-controls="profile" aria-selected="false">Profile</button>
              </li>
              <li class="mr-2" role="presentation">
                <button class="inline-block p-4 border-b-2 border-transparent rounded-t-lg hover:text-gray-600 hover:border-gray-300 dark:hover:text-gray-300" id="dashboard-tab" data-tabs-target="#dashboard" type="button" role="tab" aria-controls="dashboard" aria-selected="false">Dashboard</button>
              </li>
              <li class="mr-2" role="presentation">
                <button class="inline-block p-4 border-b-2 border-transparent rounded-t-lg hover:text-gray-600 hover:border-gray-300 dark:hover:text-gray-300" id="settings-tab" data-tabs-target="#settings" type="button" role="tab" aria-controls="settings" aria-selected="false">Settings</button>
              </li>
            </ul>
          </div>
          <div id="default-tab-content">
            <div class="hidden p-4 rounded-lg bg-gray-50 dark:bg-gray-800" id="profile" role="tabpanel" aria-labelledby="profile-tab">
              <p class="text-sm text-gray-500 dark:text-gray-400">This is your profile tab content.</p>
            </div>
            <div class="hidden p-4 rounded-lg bg-gray-50 dark:bg-gray-800" id="dashboard" role="tabpanel" aria-labelledby="dashboard-tab">
              <p class="text-sm text-gray-500 dark:text-gray-400">This is your dashboard tab content.</p>
            </div>
            <div class="hidden p-4 rounded-lg bg-gray-50 dark:bg-gray-800" id="settings" role="tabpanel" aria-labelledby="settings-tab">
              <p class="text-sm text-gray-500 dark:text-gray-400">This is your settings tab content.</p>
            </div>
          </div>
        </section>
        
        <!-- Alerts -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Alerts</h2>
          <div class="flex flex-col gap-4">
            <div class="p-4 mb-4 text-sm text-blue-800 rounded-lg bg-blue-50 dark:bg-gray-800 dark:text-blue-400" role="alert">
              <span class="font-medium">Info alert!</span> Change a few things up and try submitting again.
            </div>
            <div class="p-4 mb-4 text-sm text-red-800 rounded-lg bg-red-50 dark:bg-gray-800 dark:text-red-400" role="alert">
              <span class="font-medium">Danger alert!</span> Change a few things up and try submitting again.
            </div>
            <div class="p-4 mb-4 text-sm text-green-800 rounded-lg bg-green-50 dark:bg-gray-800 dark:text-green-400" role="alert">
              <span class="font-medium">Success alert!</span> Change a few things up and try submitting again.
            </div>
            <div class="p-4 mb-4 text-sm text-yellow-800 rounded-lg bg-yellow-50 dark:bg-gray-800 dark:text-yellow-300" role="alert">
              <span class="font-medium">Warning alert!</span> Change a few things up and try submitting again.
            </div>
          </div>
        </section>
        
        <!-- Modal -->
        <section class="mb-8">
          <h2 class="text-2xl font-semibold mb-4 text-gray-900 dark:text-white">Modal</h2>
          <!-- Modal toggle -->
          <button data-modal-target="defaultModal" data-modal-toggle="defaultModal" class="block text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800" type="button">
            Toggle modal
          </button>

          <!-- Main modal -->
          <div id="defaultModal" tabindex="-1" aria-hidden="true" class="fixed top-0 left-0 right-0 z-50 hidden w-full p-4 overflow-x-hidden overflow-y-auto md:inset-0 h-[calc(100%-1rem)] max-h-full">
            <div class="relative w-full max-w-2xl max-h-full">
              <!-- Modal content -->
              <div class="relative bg-white rounded-lg shadow dark:bg-gray-700">
                <!-- Modal header -->
                <div class="flex items-start justify-between p-4 border-b rounded-t dark:border-gray-600">
                  <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                    Terms of Service
                  </h3>
                  <button type="button" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ml-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white" data-modal-hide="defaultModal">
                    <svg class="w-3 h-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
                      <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
                    </svg>
                    <span class="sr-only">Close modal</span>
                  </button>
                </div>
                <!-- Modal body -->
                <div class="p-6 space-y-6">
                  <p class="text-base leading-relaxed text-gray-500 dark:text-gray-400">
                    With less than a month to go before the European Union enacts new consumer privacy laws for its citizens, companies around the world are updating their terms of service agreements to comply.
                  </p>
                  <p class="text-base leading-relaxed text-gray-500 dark:text-gray-400">
                    The European Union's General Data Protection Regulation (G.D.P.R.) goes into effect on May 25 and is meant to ensure a common set of data rights in the European Union. It requires organizations to notify users as soon as possible of high-risk data breaches that could personally affect them.
                  </p>
                </div>
                <!-- Modal footer -->
                <div class="flex items-center p-6 space-x-2 border-t border-gray-200 rounded-b dark:border-gray-600">
                  <button data-modal-hide="defaultModal" type="button" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">I accept</button>
                  <button data-modal-hide="defaultModal" type="button" class="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-blue-300 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10 dark:bg-gray-700 dark:text-gray-300 dark:border-gray-500 dark:hover:text-white dark:hover:bg-gray-600 dark:focus:ring-gray-600">Decline</button>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
    
    <!-- Dark Mode Toggle -->
    <div class="flex justify-end mt-8">
      <button id="theme-toggle" type="button" class="text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5">
        <svg id="theme-toggle-dark-icon" class="hidden w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path></svg>
        <svg id="theme-toggle-light-icon" class="hidden w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" fill-rule="evenodd" clip-rule="evenodd"></path></svg>
      </button>
    </div>
  </div>
  
  <!-- Include Flowbite JS -->
  <script src="node_modules/flowbite/dist/flowbite.min.js"></script>
  
  <script>
    // Dark mode toggle
    var themeToggleDarkIcon = document.getElementById('theme-toggle-dark-icon');
    var themeToggleLightIcon = document.getElementById('theme-toggle-light-icon');

    // Change the icons inside the button based on previous settings
    if (localStorage.getItem('color-theme') === 'dark' || (!('color-theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
        themeToggleLightIcon.classList.remove('hidden');
        document.documentElement.classList.add('dark');
    } else {
        themeToggleDarkIcon.classList.remove('hidden');
        document.documentElement.classList.remove('dark');
    }

    var themeToggleBtn = document.getElementById('theme-toggle');

    themeToggleBtn.addEventListener('click', function() {
        // Toggle icons
        themeToggleDarkIcon.classList.toggle('hidden');
        themeToggleLightIcon.classList.toggle('hidden');

        // Toggle dark class
        document.documentElement.classList.toggle('dark');

        // Save preference to localStorage
        if (document.documentElement.classList.contains('dark')) {
            localStorage.setItem('color-theme', 'dark');
        } else {
            localStorage.setItem('color-theme', 'light');
        }
    });
  </script>
</body>
</html>
EOF
      fi
      
      # Add a link to the Flowbite demo in index.html
      if [ -f "index.html" ]; then
        # Check if link already exists
        if ! grep -q "flowbite.html" "index.html"; then
          # Create a temporary file
          temp_file=$(mktemp)
          
          # Add the link to the navigation
          awk '{
            if ($0 ~ /<li><a href="[^"]*">Contact<\/a><\/li>/) {
              print $0
              print "        <li><a href=\"flowbite.html\">Flowbite Demo</a></li>"
            } else {
              print $0
            }
          }' "index.html" > "$temp_file"
          
          # Replace the file
          mv "$temp_file" "index.html"
        fi
      fi
      ;;
      
    *)
      typewriter "❌ Unknown framework type for Flowbite setup: $framework_type" 0.02
      return 1
      ;;
  esac
  
  # Create a README section with instructions
  if [ -f "README.md" ]; then
    cat >> README.md << 'EOF'

## Flowbite UI Components

This project uses Flowbite, a collection of UI components built with Tailwind CSS.

### Using Flowbite

Flowbite provides prebuilt components like:
- Buttons, cards, and form elements
- Navigation components
- Modals and dropdowns
- Alerts and notifications

Example button:
```html
<button type="button" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800">
  Default button
</button>
```

For full documentation, visit [Flowbite.com](https://flowbite.com/).
EOF
  fi
  
  # Success message
  rainbow_box "✅ Flowbite set up successfully!"
  echo "$(display_success "$THEME")"
  
  return 0
}