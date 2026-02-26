#!/usr/bin/env bash
# Test: Plugin Loading
# Verifies that the superpowers plugin loads correctly in OpenCode
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Test: Plugin Loading ==="

# Source setup to create isolated environment
source "$SCRIPT_DIR/setup.sh"

# Trap to cleanup on exit
trap cleanup_test_env EXIT

# Test 1: Verify plugin file exists and is registered
echo "Test 1: Checking plugin registration..."
plugin_registration="$HOME/.config/opencode/plugins/superpowers.js"
if [ -L "$plugin_registration" ]; then
    echo "  [PASS] Plugin symlink exists"
elif [ -f "$plugin_registration" ]; then
    echo "  [PASS] Plugin registration file exists (copy fallback)"
else
    echo "  [FAIL] Plugin registration file not found at $plugin_registration"
    exit 1
fi

# Verify symlink target exists when registration is a symlink
if [ -L "$plugin_registration" ] && [ -f "$(readlink -f "$plugin_registration")" ]; then
    echo "  [PASS] Plugin symlink target exists"
elif [ -f "$plugin_registration" ]; then
    echo "  [PASS] Plugin registration file is readable"
else
    echo "  [FAIL] Plugin registration target does not exist"
    exit 1
fi

# Test 2: Verify lib/skills-core.js is in place
echo "Test 2: Checking skills-core.js..."
if [ -f "$HOME/.config/opencode/superpowers/lib/skills-core.js" ]; then
    echo "  [PASS] skills-core.js exists"
else
    echo "  [FAIL] skills-core.js not found"
    exit 1
fi

# Test 3: Verify skills directory is populated
echo "Test 3: Checking skills directory..."
skill_count=$(find "$HOME/.config/opencode/superpowers/skills" -name "SKILL.md" | wc -l)
if [ "$skill_count" -gt 0 ]; then
    echo "  [PASS] Found $skill_count skills installed"
else
    echo "  [FAIL] No skills found in installed location"
    exit 1
fi

# Test 4: Check using-superpowers skill exists (critical for bootstrap)
echo "Test 4: Checking using-superpowers skill (required for bootstrap)..."
if [ -f "$HOME/.config/opencode/superpowers/skills/using-superpowers/SKILL.md" ]; then
    echo "  [PASS] using-superpowers skill exists"
else
    echo "  [FAIL] using-superpowers skill not found (required for bootstrap)"
    exit 1
fi

# Test 5: Verify plugin JavaScript syntax (basic check)
echo "Test 5: Checking plugin JavaScript syntax..."
plugin_file="$HOME/.config/opencode/superpowers/.opencode/plugins/superpowers.js"
plugin_file_for_node="$(to_node_path "$plugin_file")"
if node --check "$plugin_file_for_node" 2>/dev/null; then
    echo "  [PASS] Plugin JavaScript syntax is valid"
else
    echo "  [FAIL] Plugin has JavaScript syntax errors"
    exit 1
fi

# Test 6: Verify personal test skill was created
echo "Test 6: Checking test fixtures..."
if [ -f "$HOME/.config/opencode/skills/personal-test/SKILL.md" ]; then
    echo "  [PASS] Personal test skill fixture created"
else
    echo "  [FAIL] Personal test skill fixture not found"
    exit 1
fi

echo ""
echo "=== All plugin loading tests passed ==="
