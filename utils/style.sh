#!/bin/bash

# ========= STYLE UTILITY LIBRARY =========

# Typewriter effect
typewriter() {
  local text="$1"
  local delay="${2:-0.02}"
  for ((i=0; i<${#text}; i++)); do
    echo -n "${text:$i:1}"
    sleep $delay
  done
  echo ""
}

# Figlet banner
ascii_banner() {
  if command -v figlet >/dev/null && command -v lolcat >/dev/null; then
    figlet -w 120 "$1" | lolcat
  else
    echo "==== $1 ===="
  fi
}

# Toilet banner
ascii_toilet() {
  if command -v toilet >/dev/null && command -v lolcat >/dev/null; then
    toilet -f pagga "$1" | lolcat
  else
    echo "==== $1 ===="
  fi
}

# Banner fallback logic
banner_or_box() {
  if command -v figlet >/dev/null; then
    ascii_banner "$1"
  elif command -v toilet >/dev/null; then
    ascii_toilet "$1"
  else
    box "$1"
  fi
}

# Basic box wrapper
box() {
  echo ""
  echo "╭────────────────────────────────────────────╮"
  printf "│ %-42s │\n" "$1"
  echo "╰────────────────────────────────────────────╯"
  echo ""
}

# Rainbow box for special moments
rainbow_box() {
  echo ""
  echo "╔════════════════════════════════════════════╗" | lolcat
  printf "║ %-42s ║\n" "$1" | lolcat
  echo "╚════════════════════════════════════════════╝" | lolcat
  echo ""
}

# Horizontal line divider
line() {
  echo "────────────────────────────────────────────" | lolcat
}

# ASCII spell sparkle wrapper
ascii_spell() {
  local text="$1"
  echo ""
  echo "✨ $(echo "$text" | sed 's/./& /g') ✨" | lolcat
  echo ""
}

# Monkey welcome intro
say_hi() {
  clear
  ascii_banner "GIT MONKEY"
  typewriter "Welcome to the jungle, baby." 0.02
  line
}


# ========= RANDOM PHRASES =========

random_greeting() {
  phrases=(
    "Swinging in!"
    "Back in the terminal treehouse."
    "Welcome back, banana technician."
    "Reporting for shell duty, chief."
    "You again? Let’s do this."
    "Terminal’s warm. Vibes are set."
    "Git funky. Git focused."
  )
  echo "${phrases[$RANDOM % ${#phrases[@]}]}"
}

random_success() {
  phrases=(
    "All done. Like a banana split."
    "Smooth as monkey jazz."
    "✨ Task complete. Git on with your life."
    "Monkey magic: deployed."
    "Well that was clean. Like, Svelte-level clean."
    "Easy breezy. Terminal sorcery complete."
    "You're learning fast. This is the way."
  )
  echo "${phrases[$RANDOM % ${#phrases[@]}]}"
}

random_fail() {
  phrases=(
    "Hmm. That didn't quite work."
    "We slipped on a 🍌. Not fatal though."
    "Terminal threw a lil tantrum."
    "Something’s off, but we’re not lost."
    "🧨 Boom! But not the good kind."
    "No biggie. Might just be a typo or a missing link."
    "That was a fumble, not a fall. Let’s troubleshoot it."
  )
  echo "${phrases[$RANDOM % ${#phrases[@]}]}"
}

random_tip() {
  tips=(
    "Double-check that link. Is it public? Does it end in .git?"
    "Try running 'git status' to see what’s up."
    "Are you on the right branch? 'git branch' can tell you."
    "Use 'git log --oneline' to trace your last steps."
    "Try again, but slower. Most errors are just typos."
    "Not the end of the world. Just the terminal asking for clarity."
  )
  echo "${tips[$RANDOM % ${#tips[@]}]}"
}

