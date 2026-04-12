#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# test-helpers.sh — Shared test utilities for skill validation
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Print a section header
section() {
    echo ""
    echo -e "${BLUE}━━━ $1 ━━━${NC}"
}

# Assert that a command succeeds
assert_success() {
    local desc="$1"
    shift
    TESTS_RUN=$((TESTS_RUN + 1))
    if "$@" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $desc"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $desc"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Assert that a command fails
assert_failure() {
    local desc="$1"
    shift
    TESTS_RUN=$((TESTS_RUN + 1))
    if "$@" >/dev/null 2>&1; then
        echo -e "  ${RED}✗${NC} $desc (expected failure but succeeded)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "  ${GREEN}✓${NC} $desc"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
}

# Assert that a string matches a pattern
assert_match() {
    local desc="$1"
    local actual="$2"
    local pattern="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if echo "$actual" | grep -qE "$pattern"; then
        echo -e "  ${GREEN}✓${NC} $desc"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $desc"
        echo -e "    Expected pattern: $pattern"
        echo -e "    Actual: $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Assert that a file exists
assert_file_exists() {
    local desc="$1"
    local path="$2"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ -f "$path" ]]; then
        echo -e "  ${GREEN}✓${NC} $desc"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $desc (file not found: $path)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Assert that a directory exists
assert_dir_exists() {
    local desc="$1"
    local path="$2"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ -d "$path" ]]; then
        echo -e "  ${GREEN}✓${NC} $desc"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $desc (directory not found: $path)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Print summary
print_summary() {
    echo ""
    echo -e "${BLUE}━━━ Summary ━━━${NC}"
    echo -e "  Tests run:    $TESTS_RUN"
    echo -e "  Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Tests failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}Some tests failed.${NC}"
        return 1
    fi
}