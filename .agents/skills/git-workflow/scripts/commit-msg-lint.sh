#!/usr/bin/env bash
set -euo pipefail

# Validates a commit message against Conventional Commits format.
# Usage: commit-msg-lint.sh "<commit message>"
# Exit 0 = valid, Exit 1 = invalid

if [[ "${1:-}" == "--help" || -z "${1:-}" ]]; then
    cat <<EOF
Usage: commit-msg-lint.sh "<commit message>"

Validates a commit message against Conventional Commits format.

Expected format:
  <type>(<scope>): <subject>

Valid types: feat, fix, refactor, chore, docs, test, perf, ci, style, build, revert

Examples:
  commit-msg-lint.sh "feat(auth): add login endpoint"     # ✓ valid
  commit-msg-lint.sh "fixed the login bug"                 # ✗ invalid
  commit-msg-lint.sh "feat: add dark mode"                 # ✓ valid (scope optional)

Exit codes:
  0  Valid commit message
  1  Invalid commit message
EOF
    exit 0
fi

MSG="$1"
FIRST_LINE="$(echo "$MSG" | head -1)"

# Valid types
TYPES="feat|fix|refactor|chore|docs|test|perf|ci|style|build|revert"

# Pattern: type(scope): subject  OR  type: subject
PATTERN="^(${TYPES})(\([a-z0-9_-]+\))?: .{1,72}$"

if echo "$FIRST_LINE" | grep -qE "$PATTERN"; then
    echo '{"valid": true, "message": "Commit message follows Conventional Commits format."}'
    exit 0
else
    echo '{"valid": false, "message": "Invalid commit message.", "expected": "<type>(<scope>): <subject>", "valid_types": "feat, fix, refactor, chore, docs, test, perf, ci, style, build, revert", "received": "'"${FIRST_LINE}"'"}'
    exit 1
fi
