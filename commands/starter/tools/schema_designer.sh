#!/bin/bash

# ========= GIT MONKEY SCHEMA DESIGNER =========


# Load required utilities
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$(dirname "$DIR")"
source "$PARENT_DIR/utils/style.sh"
source "$PARENT_DIR/utils/config.sh"
source "$PARENT_DIR/utils/ascii_art.sh"


# An interactive terminal UI for designing database schemas


# Get current tone stage and identity for context-aware help
TONE_STAGE=$(get_tone_stage)
THEME=$(get_selected_theme)
IDENTITY=$(get_full_identity)

# Get theme-specific emoji
get_theme_emoji() {
  local emoji_type="$1"
  
  case "$THEME" in
    "jungle")
      case "$emoji_type" in
        "info") echo "🐒" ;;
        "success") echo "🍌" ;;
        "error") echo "🙈" ;;
        "warning") echo "🙊" ;;
        "table") echo "📋" ;;
        "column") echo "🌴" ;;
        "database") echo "🍃" ;;
        "type") echo "🥥" ;;
        "constraint") echo "🦧" ;;
        "relation") echo "🐵" ;;
        *) echo "🐒" ;;
      esac
      ;;
    "hacker")
      case "$emoji_type" in
        "info") echo ">" ;;
        "success") echo "[OK]" ;;
        "error") echo "[ERROR]" ;;
        "warning") echo "[WARNING]" ;;
        "table") echo "[TBL]" ;;
        "column") echo "[COL]" ;;
        "database") echo "[DB]" ;;
        "type") echo "[TYPE]" ;;
        "constraint") echo "[CSTR]" ;;
        "relation") echo "[REL]" ;;
        *) echo ">" ;;
      esac
      ;;
    "wizard")
      case "$emoji_type" in
        "info") echo "✨" ;;
        "success") echo "🧙" ;;
        "error") echo "⚠️" ;;
        "warning") echo "📜" ;;
        "table") echo "📚" ;;
        "column") echo "📝" ;;
        "database") echo "🏮" ;;
        "type") echo "🔮" ;;
        "constraint") echo "🧿" ;;
        "relation") echo "⚡" ;;
        *) echo "✨" ;;
      esac
      ;;
    "cosmic")
      case "$emoji_type" in
        "info") echo "🚀" ;;
        "success") echo "🌠" ;;
        "error") echo "☄️" ;;
        "warning") echo "🌌" ;;
        "table") echo "🪐" ;;
        "column") echo "🌟" ;;
        "database") echo "🌌" ;;
        "type") echo "🛸" ;;
        "constraint") echo "🌍" ;;
        "relation") echo "☄️" ;;
        *) echo "🚀" ;;
      esac
      ;;
    *)
      case "$emoji_type" in
        "info") echo "ℹ️" ;;
        "success") echo "✅" ;;
        "error") echo "❌" ;;
        "warning") echo "⚠️" ;;
        "table") echo "📊" ;;
        "column") echo "📋" ;;
        "database") echo "🗄️" ;;
        "type") echo "🔣" ;;
        "constraint") echo "🔒" ;;
        "relation") echo "🔗" ;;
        *) echo "ℹ️" ;;
      esac
      ;;
  esac
}

# Get theme-specific emojis
info_emoji=$(get_theme_emoji "info")
success_emoji=$(get_theme_emoji "success")
error_emoji=$(get_theme_emoji "error")
warning_emoji=$(get_theme_emoji "warning")
table_emoji=$(get_theme_emoji "table")
column_emoji=$(get_theme_emoji "column")
database_emoji=$(get_theme_emoji "database")
type_emoji=$(get_theme_emoji "type")
constraint_emoji=$(get_theme_emoji "constraint")
relation_emoji=$(get_theme_emoji "relation")

# Available data types
DATA_TYPES=(
  "string|VARCHAR"
  "text|TEXT"
  "number|INTEGER"
  "float|DECIMAL"
  "boolean|BOOLEAN"
  "date|DATE"
  "datetime|TIMESTAMP"
  "time|TIME"
  "uuid|UUID"
  "json|JSON"
  "array|ARRAY"
)

# Available constraints
CONSTRAINTS=(
  "primary|PRIMARY KEY"
  "unique|UNIQUE"
  "notnull|NOT NULL"
  "default|DEFAULT"
  "check|CHECK"
  "foreign|FOREIGN KEY"
)

# Initialize schema structure array
SCHEMA_TABLES=()
SCHEMA_COLUMNS=()
SCHEMA_TYPES=()
SCHEMA_CONSTRAINTS=()
SCHEMA_RELATIONS=()

# Color variables for table display
HEADER_COLOR="\e[1;36m"  # Cyan bold
BORDER_COLOR="\e[1;30m"  # Gray
DATA_COLOR="\e[0m"       # Default
HIGHLIGHT_COLOR="\e[1;33m"  # Yellow bold
RESET_COLOR="\e[0m"      # Reset

# Process flags
output_format="typescript+zod"
visual_mode="true"
output_path=""

for arg in "$@"; do
  case "$arg" in
    --format=*)
      output_format="${arg#*=}"
      shift
      ;;
    --output=*)
      output_path="${arg#*=}"
      shift
      ;;
    --no-visual)
      visual_mode="false"
      shift
      ;;
  esac
done

# Function to show an ASCII welcome banner
show_welcome_banner() {
  case "$THEME" in
    "jungle")
      echo -e "\e[33m"
      cat << 'EOF'
  ,d88b.d88b,         ,d88b.d88b,         ,d88b.d88b,   
  88888888888         88888888888         88888888888   
  'Y8888888Y'       _ 'Y8888888Y' _       'Y8888888Y'   
    'Y888Y'        /|)  'Y888Y'  (|\       'Y888Y'     
      'Y'         / |    (\/)    | \         'Y'       
                 /__|,          ,|__\               
            SCHEMA  //_____    _____\\ MONKEY          
                  ((_______\  /_______))
EOF
      echo -e "\e[0m"
      ;;
    "hacker")
      echo -e "\e[32m"
      cat << 'EOF'
 _______  _______  __   __  _______  __   __  _______    ______   _______ 
|       ||       ||  | |  ||       ||  |_|  ||   _   |  |      | |  _    |
|  _____||       ||  |_|  ||    ___||       ||  |_|  |  |  _    || |_|   |
| |_____ |       ||       ||   |___ |       ||       |  | | |   ||       |
|_____  ||      _||       ||    ___||       ||       |  | |_|   ||  _   | 
 _____| ||     |_ |   _   ||   |___ | ||_|| ||   _   |  |       || |_|   |
|_______||_______||__| |__||_______||_|   |_||__| |__|  |______| |_______|
EOF
      echo -e "\e[0m"
      ;;
    "wizard")
      echo -e "\e[35m"
      cat << 'EOF'
 .*.                      .*. .*.             .*.
@@@@@@@                  @@@@@@@@@@         @@@@@@@
@@@@@@@@@@        @     @@@@@@@@@@@@@     @@@@@@@@@@
 @@@@@@@@@@@     @@     @@@@@@@@@@@@@    @@@@@@@@@@
  @@@@@@@@@@@   @@@@    @@@@@@@@@@@@   @@@@@@@@@@
    @@@@@@@@@@@@@@@@@  @@@@@@@@@@@   @@@@@@@@@@@
      @@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@
        @@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@
          @@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@
            @@@@@@@@@@@   @@@@@@@@@@@@@
                       SCHEMA GRIMOIRE
EOF
      echo -e "\e[0m"
      ;;
    "cosmic")
      echo -e "\e[38;5;33m"
      cat << 'EOF'
      .                 .                  .      .
    .                .                 .
              +.           .      .          .
           .        .                    .
             .            .               .        .
  .                  *       .         .
          .   .                   .               .
    .                .         .        .   .    
  .          .    . .            .        .         .
     .    .            .                        .
           SCHEMA DESIGNER INTERSTELLAR EDITION         
EOF
      echo -e "\e[0m"
      ;;
    *)
      rainbow_box "🛠️  Schema Designer"
      ;;
  esac
}

# Function to draw a table visualization
draw_table_visualization() {
  local table_name="$1"
  local width=54  # Total width of the table visualization
  
  # Draw the table header
  echo -e "${BORDER_COLOR}┌$("printf '%*s' $width | tr ' ' '─'")┐${RESET_COLOR}"
  
  # Draw the table name
  local padding=$(( (width - ${#table_name} - 2) / 2 ))
  local extra_pad=$(( (width - ${#table_name} - 2) % 2 ))
  echo -e "${BORDER_COLOR}│${HEADER_COLOR}$("printf '%*s' $padding")${table_name}$("printf '%*s' $(($padding + $extra_pad)))${BORDER_COLOR}│${RESET_COLOR}"
  
  # Draw the column header divider
  echo -e "${BORDER_COLOR}├$("printf '%*s' 20 | tr ' ' '─')┬$("printf '%*s' 15 | tr ' ' '─')┬$("printf '%*s' $(($width - 20 - 15 - 2)) | tr ' ' '─')┤${RESET_COLOR}"
  
  # Draw the column headers
  echo -e "${BORDER_COLOR}│${HEADER_COLOR} Column               ${BORDER_COLOR}│${HEADER_COLOR} Type            ${BORDER_COLOR}│${HEADER_COLOR} Constraints            ${BORDER_COLOR}│${RESET_COLOR}"
  
  # Draw the data divider
  echo -e "${BORDER_COLOR}├$("printf '%*s' 20 | tr ' ' '─')┼$("printf '%*s' 15 | tr ' ' '─')┼$("printf '%*s' $(($width - 20 - 15 - 2)) | tr ' ' '─')┤${RESET_COLOR}"
  
  # Draw each column row
  for i in $(seq 0 $(( ${#SCHEMA_COLUMNS[@]} - 1 ))); do
    if [[ "${SCHEMA_TABLES[$i]}" == "$table_name" ]]; then
      local column_name="${SCHEMA_COLUMNS[$i]}"
      local column_type="${SCHEMA_TYPES[$i]}"
      local column_constraints="${SCHEMA_CONSTRAINTS[$i]}"
      
      # Truncate long values
      [ ${#column_name} -gt 18 ] && column_name="${column_name:0:15}..."
      [ ${#column_type} -gt 13 ] && column_type="${column_type:0:10}..."
      [ ${#column_constraints} -gt 20 ] && column_constraints="${column_constraints:0:17}..."
      
      # Draw the row
      echo -e "${BORDER_COLOR}│${DATA_COLOR} ${column_name}$("printf '%*s' $((20 - ${#column_name} - 1)))${BORDER_COLOR}│${DATA_COLOR} ${column_type}$("printf '%*s' $((15 - ${#column_type} - 1)))${BORDER_COLOR}│${DATA_COLOR} ${column_constraints}$("printf '%*s' $(($width - 20 - 15 - ${#column_constraints} - 3)))${BORDER_COLOR}│${RESET_COLOR}"
    fi
  done
  
  # Draw the bottom border
  echo -e "${BORDER_COLOR}└$("printf '%*s' 20 | tr ' ' '─')┴$("printf '%*s' 15 | tr ' ' '─')┴$("printf '%*s' $(($width - 20 - 15 - 2)) | tr ' ' '─')┘${RESET_COLOR}"
  echo ""
}

# Function to draw relationship visualization
draw_relationships() {
  if [ ${#SCHEMA_RELATIONS[@]} -eq 0 ]; then
    return
  fi
  
  echo -e "${HEADER_COLOR}${relation_emoji} Table Relationships:${RESET_COLOR}"
  echo -e "${BORDER_COLOR}┌─────────────────────┬─────────────────────┬─────────────────────┐${RESET_COLOR}"
  echo -e "${BORDER_COLOR}│${HEADER_COLOR} Source Table        ${BORDER_COLOR}│${HEADER_COLOR} Source Column       ${BORDER_COLOR}│${HEADER_COLOR} References           ${BORDER_COLOR}│${RESET_COLOR}"
  echo -e "${BORDER_COLOR}├─────────────────────┼─────────────────────┼─────────────────────┤${RESET_COLOR}"
  
  # Process all relations
  for relation in "${SCHEMA_RELATIONS[@]}"; do
    IFS='|' read -r src_table src_col target_table target_col <<< "$relation"
    
    # Truncate long values
    [ ${#src_table} -gt 19 ] && src_table="${src_table:0:16}..."
    [ ${#src_col} -gt 19 ] && src_col="${src_col:0:16}..."
    local refs="${target_table}.${target_col}"
    [ ${#refs} -gt 19 ] && refs="${refs:0:16}..."
    
    # Draw the relation
    echo -e "${BORDER_COLOR}│${DATA_COLOR} ${src_table}$("printf '%*s' $((19 - ${#src_table})))${BORDER_COLOR}│${DATA_COLOR} ${src_col}$("printf '%*s' $((19 - ${#src_col})))${BORDER_COLOR}│${DATA_COLOR} ${refs}$("printf '%*s' $((19 - ${#refs})))${BORDER_COLOR}│${RESET_COLOR}"
  done
  
  echo -e "${BORDER_COLOR}└─────────────────────┴─────────────────────┴─────────────────────┘${RESET_COLOR}"
  echo ""
}

# Function to add a new table to the schema
add_table() {
  echo ""
  echo -e "${HEADER_COLOR}${table_emoji} Create a New Table${RESET_COLOR}"
  echo ""
  
  # Ask for table name
  read -p "Enter table name (e.g. users, products): " table_name
  
  # Validate table name
  if [[ -z "$table_name" ]]; then
    echo -e "${error_emoji} Table name cannot be empty."
    return 1
  fi
  
  # Check for duplicate table
  for t in $(echo "${SCHEMA_TABLES[@]}" | tr ' ' '\n' | sort -u); do
    if [[ "$t" == "$table_name" ]]; then
      echo -e "${error_emoji} Table '$table_name' already exists."
      return 1
    fi
  done
  
  # Success message
  echo -e "${success_emoji} Created table: $table_name"
  echo ""
  
  # Add columns to the table
  add_columns_to_table "$table_name"
  
  # Draw table visualization
  if [ "$visual_mode" = "true" ]; then
    draw_table_visualization "$table_name"
  fi
  
  return 0
}

# Function to add columns to a table
add_columns_to_table() {
  local table_name="$1"
  local continue_adding="true"
  
  # Add ID column by default for new tables
  if [[ $(echo "${SCHEMA_TABLES[@]}" | grep -wc "$table_name") -eq 0 ]]; then
    local id_exists="false"
    
    # Check if we want to add an ID column
    if [ "$TONE_STAGE" -le 3 ]; then
      read -p "Add an ID column as primary key? (Y/n): " add_id
      if [[ "$add_id" != "n" && "$add_id" != "N" ]]; then
        id_exists="true"
        SCHEMA_TABLES+=("$table_name")
        SCHEMA_COLUMNS+=("id")
        SCHEMA_TYPES+=("uuid")
        SCHEMA_CONSTRAINTS+=("PRIMARY KEY")
        
        echo -e "${success_emoji} Added 'id' column as primary key"
      fi
    else
      read -p "Add ID column? (Y/n): " add_id
      if [[ "$add_id" != "n" && "$add_id" != "N" ]]; then
        id_exists="true"
        SCHEMA_TABLES+=("$table_name")
        SCHEMA_COLUMNS+=("id")
        SCHEMA_TYPES+=("uuid")
        SCHEMA_CONSTRAINTS+=("PRIMARY KEY")
      fi
    fi
  fi
  
  echo -e "${info_emoji} Add columns to '$table_name' table:"
  
  while [ "$continue_adding" = "true" ]; do
    # Add a column
    add_column_to_table "$table_name"
    
    # Ask if we want to add another column
    read -p "Add another column? (Y/n): " add_another
    if [[ "$add_another" == "n" || "$add_another" == "N" ]]; then
      continue_adding="false"
    fi
  done
  
  # Ask if we want to add relationships
  read -p "Add foreign key relationships? (y/N): " add_relations
  if [[ "$add_relations" == "y" || "$add_relations" == "Y" ]]; then
    add_relationships "$table_name"
  fi
  
  return 0
}

# Function to add a column to a table
add_column_to_table() {
  local table_name="$1"
  
  # Ask for column name
  read -p "Column name: " column_name
  
  # Validate column name
  if [[ -z "$column_name" ]]; then
    echo -e "${error_emoji} Column name cannot be empty."
    return 1
  fi
  
  # Check for duplicate column in this table
  for i in $(seq 0 $(( ${#SCHEMA_COLUMNS[@]} - 1 ))); do
    if [[ "${SCHEMA_TABLES[$i]}" == "$table_name" && "${SCHEMA_COLUMNS[$i]}" == "$column_name" ]]; then
      echo -e "${error_emoji} Column '$column_name' already exists in table '$table_name'."
      return 1
    fi
  done
  
  # Show data type options
  echo ""
  echo -e "${type_emoji} Available data types:"
  echo ""
  
  local counter=1
  for type_info in "${DATA_TYPES[@]}"; do
    IFS='|' read -r type_name type_db <<< "$type_info"
    echo -e "  $counter) $type_name ($type_db)"
    counter=$((counter + 1))
  done
  
  # Ask for data type
  read -p "Choose data type (1-${#DATA_TYPES[@]}): " type_choice
  
  # Validate type choice
  if ! [[ "$type_choice" =~ ^[0-9]+$ ]] || \
     [ "$type_choice" -lt 1 ] || \
     [ "$type_choice" -gt ${#DATA_TYPES[@]} ]; then
    echo -e "${error_emoji} Invalid type choice."
    return 1
  fi
  
  # Get the selected type
  local type_info="${DATA_TYPES[$((type_choice - 1))]}"
  IFS='|' read -r type_name type_db <<< "$type_info"
  
  # Ask for constraints
  echo ""
  echo -e "${constraint_emoji} Available constraints (select multiple by separating with spaces):"
  echo ""
  
  local counter=1
  for constraint_info in "${CONSTRAINTS[@]}"; do
    IFS='|' read -r constraint_name constraint_db <<< "$constraint_info"
    echo -e "  $counter) $constraint_name ($constraint_db)"
    counter=$((counter + 1))
  done
  echo -e "  0) None"
  
  # Ask for constraints
  read -p "Choose constraints (0 or space-separated numbers): " constraint_choices
  
  # Process constraints
  local column_constraints=""
  if [[ "$constraint_choices" != "0" && -n "$constraint_choices" ]]; then
    for choice in $constraint_choices; do
      if ! [[ "$choice" =~ ^[0-9]+$ ]] || \
         [ "$choice" -lt 1 ] || \
         [ "$choice" -gt ${#CONSTRAINTS[@]} ]; then
        continue
      fi
      
      local constraint_info="${CONSTRAINTS[$((choice - 1))]}"
      IFS='|' read -r constraint_name constraint_db <<< "$constraint_info"
      
      if [[ -n "$column_constraints" ]]; then
        column_constraints="$column_constraints, $constraint_db"
      else
        column_constraints="$constraint_db"
      fi
      
      # If this is a foreign key, we'll need to add relation details later
      if [[ "$constraint_name" == "foreign" ]]; then
        FOREIGN_KEY_PENDING="$table_name|$column_name"
      fi
    done
  fi
  
  # Add the column to the schema
  SCHEMA_TABLES+=("$table_name")
  SCHEMA_COLUMNS+=("$column_name")
  SCHEMA_TYPES+=("$type_db")
  SCHEMA_CONSTRAINTS+=("$column_constraints")
  
  # Success message
  echo -e "${success_emoji} Added column '$column_name' ($type_db) to table '$table_name'"
  
  return 0
}

# Function to add relationships between tables
add_relationships() {
  local table_name="$1"
  local continue_adding="true"
  
  echo ""
  echo -e "${HEADER_COLOR}${relation_emoji} Add Relationships for '$table_name'${RESET_COLOR}"
  echo ""
  
  # If there are no other tables, we can't add relationships
  local other_tables=()
  for t in $(echo "${SCHEMA_TABLES[@]}" | tr ' ' '\n' | sort -u); do
    if [[ "$t" != "$table_name" ]]; then
      other_tables+=("$t")
    fi
  done
  
  if [ ${#other_tables[@]} -eq 0 ]; then
    echo -e "${warning_emoji} No other tables to relate to. Create more tables first."
    return 0
  fi
  
  while [ "$continue_adding" = "true" ]; do
    # Show columns in this table
    echo "Columns in '$table_name':"
    local table_columns=()
    local counter=1
    
    for i in $(seq 0 $(( ${#SCHEMA_COLUMNS[@]} - 1 ))); do
      if [[ "${SCHEMA_TABLES[$i]}" == "$table_name" ]]; then
        echo "  $counter) ${SCHEMA_COLUMNS[$i]} (${SCHEMA_TYPES[$i]})"
        table_columns+=("${SCHEMA_COLUMNS[$i]}")
        counter=$((counter + 1))
      fi
    done
    
    # Ask which column will be the foreign key
    read -p "Which column is the foreign key? (1-${#table_columns[@]}): " fk_choice
    
    # Validate choice
    if ! [[ "$fk_choice" =~ ^[0-9]+$ ]] || \
       [ "$fk_choice" -lt 1 ] || \
       [ "$fk_choice" -gt ${#table_columns[@]} ]; then
      echo -e "${error_emoji} Invalid column choice."
      read -p "Try again? (Y/n): " try_again
      if [[ "$try_again" == "n" || "$try_again" == "N" ]]; then
        continue_adding="false"
      fi
      continue
    fi
    
    local source_column="${table_columns[$((fk_choice - 1))]}"
    
    # Show other tables to relate to
    echo ""
    echo "Available tables to relate to:"
    counter=1
    
    for t in "${other_tables[@]}"; do
      echo "  $counter) $t"
      counter=$((counter + 1))
    done
    
    # Ask which table to relate to
    read -p "Which table does this reference? (1-${#other_tables[@]}): " table_choice
    
    # Validate choice
    if ! [[ "$table_choice" =~ ^[0-9]+$ ]] || \
       [ "$table_choice" -lt 1 ] || \
       [ "$table_choice" -gt ${#other_tables[@]} ]; then
      echo -e "${error_emoji} Invalid table choice."
      read -p "Try again? (Y/n): " try_again
      if [[ "$try_again" == "n" || "$try_again" == "N" ]]; then
        continue_adding="false"
      fi
      continue
    fi
    
    local target_table="${other_tables[$((table_choice - 1))]}"
    
    # Show columns in the target table
    echo ""
    echo "Columns in '$target_table':"
    local target_columns=()
    counter=1
    
    for i in $(seq 0 $(( ${#SCHEMA_COLUMNS[@]} - 1 ))); do
      if [[ "${SCHEMA_TABLES[$i]}" == "$target_table" ]]; then
        echo "  $counter) ${SCHEMA_COLUMNS[$i]} (${SCHEMA_TYPES[$i]})"
        target_columns+=("${SCHEMA_COLUMNS[$i]}")
        counter=$((counter + 1))
      fi
    done
    
    # Ask which column to reference
    read -p "Which column does this reference? (1-${#target_columns[@]}): " ref_choice
    
    # Validate choice
    if ! [[ "$ref_choice" =~ ^[0-9]+$ ]] || \
       [ "$ref_choice" -lt 1 ] || \
       [ "$ref_choice" -gt ${#target_columns[@]} ]; then
      echo -e "${error_emoji} Invalid column choice."
      read -p "Try again? (Y/n): " try_again
      if [[ "$try_again" == "n" || "$try_again" == "N" ]]; then
        continue_adding="false"
      fi
      continue
    fi
    
    local target_column="${target_columns[$((ref_choice - 1))]}"
    
    # Add the relationship
    SCHEMA_RELATIONS+=("$table_name|$source_column|$target_table|$target_column")
    
    # Update the column's constraints to include foreign key relation
    for i in $(seq 0 $(( ${#SCHEMA_COLUMNS[@]} - 1 ))); do
      if [[ "${SCHEMA_TABLES[$i]}" == "$table_name" && "${SCHEMA_COLUMNS[$i]}" == "$source_column" ]]; then
        if [[ -n "${SCHEMA_CONSTRAINTS[$i]}" ]]; then
          SCHEMA_CONSTRAINTS[$i]="${SCHEMA_CONSTRAINTS[$i]}, FOREIGN KEY REFERENCES $target_table($target_column)"
        else
          SCHEMA_CONSTRAINTS[$i]="FOREIGN KEY REFERENCES $target_table($target_column)"
        fi
        break
      fi
    done
    
    # Success message
    echo -e "${success_emoji} Added relationship: $table_name.$source_column -> $target_table.$target_column"
    
    # Ask if we want to add another relationship
    read -p "Add another relationship? (y/N): " add_another
    if [[ "$add_another" != "y" && "$add_another" != "Y" ]]; then
      continue_adding="false"
    fi
  done
  
  return 0
}

# Function to edit an existing table
edit_table() {
  # Get unique table names
  local unique_tables=()
  for t in $(echo "${SCHEMA_TABLES[@]}" | tr ' ' '\n' | sort -u); do
    unique_tables+=("$t")
  done
  
  # If no tables, return
  if [ ${#unique_tables[@]} -eq 0 ]; then
    echo -e "${error_emoji} No tables exist yet. Create a table first."
    return 1
  fi
  
  echo ""
  echo -e "${HEADER_COLOR}${table_emoji} Edit Existing Table${RESET_COLOR}"
  echo ""
  
  # Show available tables
  echo "Available tables:"
  local counter=1
  
  for t in "${unique_tables[@]}"; do
    echo "  $counter) $t"
    counter=$((counter + 1))
  done
  
  # Ask which table to edit
  read -p "Which table do you want to edit? (1-${#unique_tables[@]}): " table_choice
  
  # Validate choice
  if ! [[ "$table_choice" =~ ^[0-9]+$ ]] || \
     [ "$table_choice" -lt 1 ] || \
     [ "$table_choice" -gt ${#unique_tables[@]} ]; then
    echo -e "${error_emoji} Invalid table choice."
    return 1
  fi
  
  local table_name="${unique_tables[$((table_choice - 1))]}"
  
  # Show table visualization
  if [ "$visual_mode" = "true" ]; then
    draw_table_visualization "$table_name"
  fi
  
  # Show edit options
  echo "Edit options for table '$table_name':"
  echo "  1) Add new column"
  echo "  2) Remove column"
  echo "  3) Rename table"
  echo "  4) Add relationship"
  echo "  5) Cancel"
  
  # Ask what to do
  read -p "Choose an option (1-5): " edit_choice
  
  case "$edit_choice" in
    1)
      # Add new column
      add_column_to_table "$table_name"
      ;;
    2)
      # Remove column
      echo "Columns in '$table_name':"
      local table_columns=()
      local counter=1
      
      for i in $(seq 0 $(( ${#SCHEMA_COLUMNS[@]} - 1 ))); do
        if [[ "${SCHEMA_TABLES[$i]}" == "$table_name" ]]; then
          echo "  $counter) ${SCHEMA_COLUMNS[$i]}"
          table_columns+=("$i")
          counter=$((counter + 1))
        fi
      done
      
      read -p "Which column to remove? (1-${#table_columns[@]}): " col_choice
      
      # Validate choice
      if ! [[ "$col_choice" =~ ^[0-9]+$ ]] || \
         [ "$col_choice" -lt 1 ] || \
         [ "$col_choice" -gt ${#table_columns[@]} ]; then
        echo -e "${error_emoji} Invalid column choice."
        return 1
      fi
      
      local col_index="${table_columns[$((col_choice - 1))]}"
      local col_name="${SCHEMA_COLUMNS[$col_index]}"
      
      # Confirm deletion
      read -p "Are you sure you want to delete column '$col_name'? (y/N): " confirm
      if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Cancelled deletion."
        return 0
      fi
      
      # Remove column
      SCHEMA_TABLES=("${SCHEMA_TABLES[@]:0:$col_index}" "${SCHEMA_TABLES[@]:$((col_index + 1))}")
      SCHEMA_COLUMNS=("${SCHEMA_COLUMNS[@]:0:$col_index}" "${SCHEMA_COLUMNS[@]:$((col_index + 1))}")
      SCHEMA_TYPES=("${SCHEMA_TYPES[@]:0:$col_index}" "${SCHEMA_TYPES[@]:$((col_index + 1))}")
      SCHEMA_CONSTRAINTS=("${SCHEMA_CONSTRAINTS[@]:0:$col_index}" "${SCHEMA_CONSTRAINTS[@]:$((col_index + 1))}")
      
      # Also remove any relationships involving this column
      local new_relations=()
      for relation in "${SCHEMA_RELATIONS[@]}"; do
        IFS='|' read -r src_table src_col target_table target_col <<< "$relation"
        if [[ "$src_table" != "$table_name" || "$src_col" != "$col_name" ]] && \
           [[ "$target_table" != "$table_name" || "$target_col" != "$col_name" ]]; then
          new_relations+=("$relation")
        fi
      done
      SCHEMA_RELATIONS=("${new_relations[@]}")
      
      echo -e "${success_emoji} Removed column '$col_name' from table '$table_name'"
      ;;
    3)
      # Rename table
      read -p "New table name: " new_table_name
      
      # Validate new name
      if [[ -z "$new_table_name" ]]; then
        echo -e "${error_emoji} Table name cannot be empty."
        return 1
      fi
      
      # Check for duplicate table
      for t in "${unique_tables[@]}"; do
        if [[ "$t" == "$new_table_name" ]]; then
          echo -e "${error_emoji} Table '$new_table_name' already exists."
          return 1
        fi
      done
      
      # Update table name in all arrays
      for i in $(seq 0 $(( ${#SCHEMA_TABLES[@]} - 1 ))); do
        if [[ "${SCHEMA_TABLES[$i]}" == "$table_name" ]]; then
          SCHEMA_TABLES[$i]="$new_table_name"
        fi
      done
      
      # Update relationships
      for i in $(seq 0 $(( ${#SCHEMA_RELATIONS[@]} - 1 ))); do
        IFS='|' read -r src_table src_col target_table target_col <<< "${SCHEMA_RELATIONS[$i]}"
        
        if [[ "$src_table" == "$table_name" ]]; then
          src_table="$new_table_name"
        fi
        
        if [[ "$target_table" == "$table_name" ]]; then
          target_table="$new_table_name"
        fi
        
        SCHEMA_RELATIONS[$i]="$src_table|$src_col|$target_table|$target_col"
      done
      
      echo -e "${success_emoji} Renamed table from '$table_name' to '$new_table_name'"
      ;;
    4)
      # Add relationship
      add_relationships "$table_name"
      ;;
    5|*)
      echo "Edit cancelled."
      ;;
  esac
  
  # Show updated table visualization
  if [ "$visual_mode" = "true" ]; then
    if [ "$edit_choice" -eq 3 ]; then
      draw_table_visualization "$new_table_name"
    else
      draw_table_visualization "$table_name"
    fi
  fi
  
  return 0
}

# Function to show the complete schema
show_schema() {
  echo ""
  echo -e "${HEADER_COLOR}${database_emoji} Complete Schema Overview${RESET_COLOR}"
  echo ""
  
  # Get unique table names
  local unique_tables=()
  for t in $(echo "${SCHEMA_TABLES[@]}" | tr ' ' '\n' | sort -u); do
    unique_tables+=("$t")
  done
  
  # If no tables, return
  if [ ${#unique_tables[@]} -eq 0 ]; then
    echo -e "${warning_emoji} No tables have been defined yet."
    return 0
  fi
  
  # Show each table
  for table_name in "${unique_tables[@]}"; do
    draw_table_visualization "$table_name"
  done
  
  # Show relationships
  draw_relationships
  
  return 0
}

# Function to generate TypeScript + Zod schema
generate_typescript_zod_schema() {
  local output_content=""
  
  # Output imports
  output_content+="import { z } from 'zod';\n\n"
  
  # Get unique table names
  local unique_tables=()
  for t in $(echo "${SCHEMA_TABLES[@]}" | tr ' ' '\n' | sort -u); do
    unique_tables+=("$t")
  done
  
  # Generate schema for each table
  for table_name in "${unique_tables[@]}"; do
    local pascal_case=$(echo "$table_name" | sed -E 's/(^|_)([a-z])/\U\2/g')
    
    # Start schema definition
    output_content+="// ${pascal_case} Schema\n"
    output_content+="export const ${table_name}Schema = z.object({\n"
    
    # Add each column
    for i in $(seq 0 $(( ${#SCHEMA_COLUMNS[@]} - 1 ))); do
      if [[ "${SCHEMA_TABLES[$i]}" == "$table_name" ]]; then
        local column_name="${SCHEMA_COLUMNS[$i]}"
        local column_type="${SCHEMA_TYPES[$i]}"
        local column_constraints="${SCHEMA_CONSTRAINTS[$i]}"
        
        # Map SQL types to Zod types
        local zod_type=""
        case "$column_type" in
          "VARCHAR"|"TEXT")
            zod_type="z.string()"
            ;;
          "INTEGER")
            zod_type="z.number().int()"
            ;;
          "DECIMAL"|"FLOAT")
            zod_type="z.number()"
            ;;
          "BOOLEAN")
            zod_type="z.boolean()"
            ;;
          "DATE"|"TIMESTAMP"|"TIME")
            zod_type="z.date()"
            ;;
          "UUID")
            zod_type="z.string().uuid()"
            ;;
          "JSON")
            zod_type="z.record(z.unknown())"
            ;;
          "ARRAY")
            zod_type="z.array(z.unknown())"
            ;;
          *)
            zod_type="z.unknown()"
            ;;
        esac
        
        # Add constraints
        if [[ "$column_constraints" == *"NOT NULL"* ]]; then
          # It's required
          output_content+="  ${column_name}: ${zod_type}"
        else
          # It's optional
          output_content+="  ${column_name}: ${zod_type}.optional()"
        fi
        
        # Add comma if not the last column
        if [ $i -lt $(( ${#SCHEMA_COLUMNS[@]} - 1 )) ]; then
          local next_table="${SCHEMA_TABLES[$((i+1))]}"
          if [[ "$next_table" == "$table_name" ]]; then
            output_content+=",\n"
          else
            output_content+="\n"
          fi
        else
          output_content+="\n"
        fi
      fi
    done
    
    # Close schema definition
    output_content+="});\n\n"
    
    # Add type inference
    output_content+="export type ${pascal_case} = z.infer<typeof ${table_name}Schema>;\n\n"
  }
  
  # Return the generated schema
  echo "$output_content"
}

# Function to export the schema
export_schema() {
  echo ""
  echo -e "${HEADER_COLOR}${success_emoji} Export Schema${RESET_COLOR}"
  echo ""
  
  # Get unique table names
  local unique_tables=()
  for t in $(echo "${SCHEMA_TABLES[@]}" | tr ' ' '\n' | sort -u); do
    unique_tables+=("$t")
  done
  
  # If no tables, return
  if [ ${#unique_tables[@]} -eq 0 ]; then
    echo -e "${warning_emoji} No tables have been defined yet. Nothing to export."
    return 0
  fi
  
  # If output path is not set, ask for it
  if [[ -z "$output_path" ]]; then
    read -p "Enter output directory path: " output_dir
    
    if [[ -z "$output_dir" ]]; then
      output_dir="schema"
    fi
    
    # Create the directory if it doesn't exist
    mkdir -p "$output_dir"
    
    # Set the output path based on format
    case "$output_format" in
      "typescript+zod")
        output_path="${output_dir}/schema.ts"
        ;;
      "prisma")
        output_path="${output_dir}/schema.prisma"
        ;;
      "sql")
        output_path="${output_dir}/schema.sql"
        ;;
      *)
        output_path="${output_dir}/schema.ts"
        ;;
    esac
  fi
  
  # Generate schema content based on format
  local schema_content=""
  case "$output_format" in
    "typescript+zod")
      schema_content=$(generate_typescript_zod_schema)
      ;;
    "prisma")
      echo "Prisma export not yet implemented."
      return 1
      ;;
    "sql")
      echo "SQL export not yet implemented."
      return 1
      ;;
    *)
      schema_content=$(generate_typescript_zod_schema)
      ;;
  esac
  
  # Write the schema to the output file
  echo "$schema_content" > "$output_path"
  
  echo -e "${success_emoji} Schema exported to: $output_path"
  return 0
}

# Function to reset the schema
reset_schema() {
  echo ""
  echo -e "${HEADER_COLOR}${warning_emoji} Reset Schema${RESET_COLOR}"
  echo ""
  
  read -p "Are you sure you want to reset the schema? This will delete all tables and relationships. (y/N): " confirm
  
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Reset cancelled."
    return 0
  fi
  
  # Reset all arrays
  SCHEMA_TABLES=()
  SCHEMA_COLUMNS=()
  SCHEMA_TYPES=()
  SCHEMA_CONSTRAINTS=()
  SCHEMA_RELATIONS=()
  
  echo -e "${success_emoji} Schema has been reset."
  return 0
}

# Main menu function
show_main_menu() {
  while true; do
    echo ""
    box "Schema Designer Main Menu"
    echo ""
    echo "1) Add a new table"
    echo "2) Edit existing table"
    echo "3) Show complete schema"
    echo "4) Export schema"
    echo "5) Reset schema"
    echo "6) Exit"
    echo ""
    
    read -p "Choose an option (1-6): " choice
    
    case "$choice" in
      1)
        add_table
        ;;
      2)
        edit_table
        ;;
      3)
        show_schema
        ;;
      4)
        export_schema
        ;;
      5)
        reset_schema
        ;;
      6)
        echo ""
        echo "Exiting Schema Designer..."
        exit 0
        ;;
      *)
        echo -e "${error_emoji} Invalid choice. Please try again."
        ;;
    esac
  done
}

# Initialize schema designer and show intro
initialize() {
  # Show welcome banner
  if [ "$visual_mode" = "true" ]; then
    clear
    show_welcome_banner
  fi
  
  # Tone-aware introduction
  if [ "$TONE_STAGE" -le 2 ]; then
    echo ""
    echo -e "${info_emoji} Hey ${IDENTITY}! Welcome to Schema Designer."
    echo ""
    echo "This tool helps you visually design database schemas and generate"
    echo "TypeScript types and Zod validation schemas for your project."
    echo ""
    echo "Start by creating tables and adding columns. You can then export"
    echo "your schema to TypeScript/Zod or other formats."
    echo ""
  elif [ "$TONE_STAGE" -le 3 ]; then
    echo ""
    echo -e "${info_emoji} Schema Designer: Create database schemas visually"
    echo "and generate type definitions and validation schemas."
    echo ""
  fi
}

# Main function
main() {
  # Initialize the schema designer
  initialize
  
  # Show the main menu
  show_main_menu
}

# Call main if script is executed directly
main
