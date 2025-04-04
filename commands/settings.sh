#!/bin/bash

# ========= GIT MONKEY SETTINGS MANAGER =========

source ./utils/style.sh
source ./utils/config.sh

say_hi
ascii_spell "Customize your monkey business"

box "Git Monkey Settings"
echo "Current Settings:"
echo "  💫 Animations: $ENABLE_ANIMATIONS"
echo "  🖼️ ASCII Art: $ENABLE_ASCII_ART"
echo "  🌈 Colors: $ENABLE_COLORS"
echo "  📢 Verbosity: $VERBOSITY_LEVEL"
echo ""

PS3=$'\nWhat would you like to change? '
options=(
  "Toggle animations" 
  "Toggle ASCII art" 
  "Toggle colors" 
  "Change verbosity level" 
  "Configure AI features"
  "Reset to defaults"
  "Return to menu"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1)
            if [ "$ENABLE_ANIMATIONS" = "true" ]; then
                update_setting animations false
                echo "🚫 Animations disabled"
            else
                update_setting animations true
                echo "✅ Animations enabled"
            fi
            break
            ;;
        2)
            if [ "$ENABLE_ASCII_ART" = "true" ]; then
                update_setting ascii false
                echo "🚫 ASCII art disabled"
            else
                update_setting ascii true
                echo "✅ ASCII art enabled"
            fi
            break
            ;;
        3)
            if [ "$ENABLE_COLORS" = "true" ]; then
                update_setting colors false
                echo "🚫 Colors disabled"
            else
                update_setting colors true
                echo "✅ Colors enabled"
            fi
            break
            ;;
        4)
            echo ""
            echo "Select verbosity level:"
            echo "1) Minimal - Just the essential information"
            echo "2) Normal - Balanced output (default)"
            echo "3) Verbose - Extra explanations and details"
            read -p "Your choice (1/2/3): " verb_choice
            
            case "$verb_choice" in
                1) update_setting verbosity minimal ;;
                2) update_setting verbosity normal ;;
                3) update_setting verbosity verbose ;;
                *) echo "Invalid choice, keeping current setting" ;;
            esac
            echo "✅ Verbosity set to $VERBOSITY_LEVEL"
            break
            ;;
        5)
            # Launch AI settings menu
            echo "Launching AI settings..."
            source ./commands/settings_ai.sh
            break
            ;;
        6)
            # Reset to defaults
            update_setting animations true
            update_setting ascii true
            update_setting colors true
            update_setting verbosity normal
            rainbow_box "✅ Settings reset to defaults"
            break
            ;;
        7)
            echo "Returning to menu..."
            break
            ;;
        *)
            echo "Please select a valid option" ;;
    esac
done

# Print current settings after changes
echo ""
echo "Updated Settings:"
echo "  💫 Animations: $ENABLE_ANIMATIONS"
echo "  🖼️ ASCII Art: $ENABLE_ASCII_ART"
echo "  🌈 Colors: $ENABLE_COLORS"
echo "  📢 Verbosity: $VERBOSITY_LEVEL"
echo ""