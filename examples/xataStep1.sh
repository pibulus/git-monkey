#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to handle errors
handle_error() {
    tput setaf 1
    echo "Error: $1" >&2
    tput sgr0
    exit 1
}

# Function to install a package if it does not exist (Homebrew for Mac, apt-get for Linux)
install_package() {
    local package=$1
    local command=$2
    if ! command_exists $command; then
        echo "Installing $package..."
        if command_exists brew; then
            brew install $package || handle_error "Failed to install $package."
        elif command_exists apt-get; then
            sudo apt-get install -y $package || handle_error "Failed to install $package."
        else
            handle_error "Package manager not found. Install $package manually."
        fi
    fi
}

# Ensure Homebrew or apt-get is available for package installation
if ! command_exists brew && ! command_exists apt-get; then
    handle_error "Neither Homebrew nor apt-get is installed. Please install one of them to proceed."
fi

# Ensure required packages are installed
install_package "lolcat" "lolcat"
install_package "cowsay" "cowsay"
install_package "figlet" "figlet"
install_package "node" "node"
install_package "git" "git"

# Check for required commands
for cmd in npm npx git code; do
    if ! command_exists $cmd; then
        handle_error "$cmd is not installed. Please install it to proceed."
    fi
done

# Prompt for project name if not provided as an argument
project_name=$1
if [ -z "$project_name" ]; then
    read -p "Enter your project name: " project_name
    if [ -z "$project_name" ]; then
        handle_error "Project name cannot be empty."
    fi
fi

# Prompt for Xata API key
read -p "Enter your Xata API key: " xata_api_key
if [ -z "$xata_api_key" ]; then
    handle_error "Xata API key cannot be empty."
fi

# Prompt for Xata workspace slug
read -p "Enter your Xata workspace slug (found in Xata settings): " xata_workspace_slug
if [ -z "$xata_workspace_slug" ]; then
    handle_error "Xata workspace slug cannot be empty."
fi

# Create Xata config directory with appropriate permissions
mkdir -p ~/.config/xata || sudo mkdir -p ~/.config/xata
sudo chown -R $USER ~/.config/xata

# Colorful Introduction with ASCII Art and Instructions
figlet "Pab.io 4 Eva" | lolcat

echo ""
echo "********** WELCOME TO PABLO'S AMAZING SETUP SCRIPT! **********" | lolcat -d 2 -s 10 -a
echo ""

tput setaf 5
echo "* This script will set up a SvelteKit project with the following features:"
echo "* 1. SvelteKit - A framework for building web applications"
echo "* 2. Tailwind CSS - A utility-first CSS framework"
echo "* 3. Skeleton UI - A set of UI components for SvelteKit"
echo "* 4. Xata.io - A serverless database for modern apps"
echo "* 5. Git Repository + creation of .env and .gitignore files"
echo "* Let's get started!"
tput sgr0

# Instructions for Skeleton setup
tput setaf 6
echo ""
echo "Please follow these steps when prompted during the Skeleton setup:"
echo "1. Choose the 'Appshell Starter' template."
echo "2. Select the 'Skeleton' theme."
echo "3. Choose 'Yes' to add Tailwind forms, typography, Codeblock and Popups."
echo "4. Choose 'No' for TypeScript and use JavaScript."
echo "5. Select ESLint for code linting and Prettier for code formatting."
echo ""
tput sgr0 

# Create a new Skeleton project
echo "Creating a new Skeleton project..." | lolcat -d 2 -s 10
npx create-skeleton-app@latest $project_name || handle_error "Failed to create Skeleton project."
cd $project_name || handle_error "Failed to enter project directory."

# Initialize a git repository and set default branch name to main
git init -b main || handle_error "Failed to initialize git repository."

# Install dependencies
echo "Installing dependencies..." | lolcat -d 2 -s 10
npm install || handle_error "Failed to install dependencies."

# Pre-init instructions
echo ""
echo " *** When prompted, please choose 'JavaScript import syntax' for code generation. *** " | lolcat -d 2 -s 10
echo " *** Select 'ap-southeast-2' as your region. ***  " | lolcat -d 2 -s 10
echo ""

# Set up Xata CLI
echo "Installing Xata CLI..." | lolcat -d 2 -s 10
sudo npm install -g @xata.io/cli@latest || handle_error "Failed to install Xata CLI."

# Authenticate Xata CLI
echo "Authenticating Xata CLI..." | lolcat -d 2 -s 10
XATA_API_KEY=$xata_api_key xata auth login || handle_error "Failed to authenticate Xata CLI."

# Create Xata database
echo "Creating Xata database..." | lolcat -d 2 -s 10
xata dbs create $project_name --workspace $xata_workspace_slug || handle_error "Failed to create Xata database."

# Initialize Xata database
xata init --db="https://${xata_workspace_slug}.ap-southeast-2.xata.sh/db/$project_name" --sdk --no-input --yes --codegen=src/xata.ts --force || handle_error "Failed to initialize Xata database."

# Pull Xata schema and generate code
echo "Pulling Xata schema and generating code..." | lolcat -d 2 -s 10
xata codegen || handle_error "Failed to generate Xata client code."

# Next steps
echo ""
echo "********** PABLO IS THE BEST! OUT WITH THE REST **********" | lolcat -d 2 -s 10
echo ""

echo "* To start the development server, run the following command from your project directory:  npm run dev" | lolcat
echo "* Your SvelteKit application will be available at http://localhost:5173" | lolcat
echo ""

tput setaf 5
echo "* Next steps:"
tput setaf 6
echo "1. Navigate to https://app.xata.io/workspaces/$xata_workspace_slug/dbs/$project_name:ap-southeast-2 to create your tables and fields manually in the Xata UI."
echo "2. Run 'xata pull main' to update your local schema."
echo "3. Implement CRUD operations using SvelteKit and Xata client."
echo "4. Generate necessary pages and components for CRUD functionality."
echo "5. Deploy your application on Vercel using 'vercel' CLI."
tput sgr0

# Start development server and open in browser
npm run dev &
sleep 5
open http://localhost:5173

# Open the project in VSCode
code . || handle_error "Failed to open Visual Studio Code."

# Open the Xata UI for table and column setup
open "https://app.xata.io/workspaces/${xata_workspace_slug}/dbs/${project_name}:ap-southeast-2"

# Fun ending message with cowsay and animated lolcat
cowsay "Smoke 'em if you got 'em!" | lolcat -a -d 2 -s 10
echo ""
echo ""
