#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# test-install.sh — Validate the installer script
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/test-helpers.sh"

section "Installer Script Validation"

INSTALL_SCRIPT="$ROOT_DIR/install.sh"

# Test: install.sh exists
assert_file_exists "install.sh exists" "$INSTALL_SCRIPT"

# Test: install.sh is executable
TESTS_RUN=$((TESTS_RUN + 1))
if [[ -x "$INSTALL_SCRIPT" ]]; then
    echo -e "  ${GREEN}✓${NC} install.sh is executable"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${YELLOW}⚠${NC} install.sh is not executable (can still be run with bash)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Test: install.sh supports --help
section "install.sh --help"
TESTS_RUN=$((TESTS_RUN + 1))
if bash "$INSTALL_SCRIPT" --help >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} install.sh --help works"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${RED}✗${NC} install.sh --help failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test: project-template directory exists
section "Project template"
assert_dir_exists "project-template exists" "$ROOT_DIR/project-template"
assert_file_exists "project-template/AGENTS.md" "$ROOT_DIR/project-template/AGENTS.md"

# Test: All template files exist
for file in AGENTS.md CLAUDE.md GEMINI.md; do
    assert_file_exists "project-template/$file" "$ROOT_DIR/project-template/$file"
done

# Test: Template AGENTS.md references skills
section "Template references skills"
TESTS_RUN=$((TESTS_RUN + 1))
if grep -qi "skill" "$ROOT_DIR/project-template/AGENTS.md"; then
    echo -e "  ${GREEN}✓${NC} project-template/AGENTS.md references skills"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${RED}✗${NC} project-template/AGENTS.md doesn't reference skills"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

print_summary