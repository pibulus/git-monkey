#\!/bin/bash

# Script to run a final check on all command files
# This will check for missing shebang, DIR/PARENT_DIR, and THEME variables

echo "=== Command Files Missing Shebang ==="
find ./commands -type f -name "*.sh" | xargs grep -L "^#\!/bin/bash" | sort
echo ""

echo "=== Command Files Missing DIR/PARENT_DIR ==="
find ./commands -type f -name "*.sh" | xargs grep -L "DIR=" | sort
echo ""

echo "=== Command Files Missing THEME Variable ==="
find ./commands -type f -name "*.sh" | xargs grep -L "THEME=" | sort
echo ""

echo "=== Command Files Still Using Random Functions ==="
grep -r "random_greeting\|random_success\|random_fail\|random_tip" --include="*.sh" ./commands | sort
echo ""

echo "=== Command Files Still Using say_hi ==="
grep -r "\bsay_hi\b" --include="*.sh" ./commands | sort
echo ""

echo "=== Files with Incorrect Source Paths ==="
grep -r "source ./utils/" --include="*.sh" ./commands | sort
echo ""

echo "=== Check Complete ==="
