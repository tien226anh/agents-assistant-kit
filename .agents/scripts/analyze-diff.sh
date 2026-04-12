#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# analyze-diff.sh — Parse git diff output into structured JSON
# Used by the code-review skill to understand changes.
# ============================================================================

if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF
Usage: analyze-diff.sh [OPTIONS]

Analyze git diff output and produce a structured JSON summary.

OPTIONS:
    --staged          Analyze staged changes (git diff --cached)
    --last-commit     Analyze the last commit (git diff HEAD~1)
    --branch <name>   Compare current branch against <name> (default: main)
    --help            Show this help message

OUTPUT (JSON):
    {
      "total_files": 3,
      "total_additions": 45,
      "total_deletions": 12,
      "files": [
        {
          "path": "src/auth.py",
          "status": "modified",
          "additions": 20,
          "deletions": 5
        }
      ]
    }

EXAMPLES:
    analyze-diff.sh                      # Unstaged changes
    analyze-diff.sh --staged             # Staged changes
    analyze-diff.sh --last-commit        # Last commit
    analyze-diff.sh --branch develop     # Compare against develop

EOF
    exit 0
fi

# Parse arguments
DIFF_CMD="git diff"
case "${1:-}" in
    --staged)
        DIFF_CMD="git diff --cached"
        ;;
    --last-commit)
        DIFF_CMD="git diff HEAD~1"
        ;;
    --branch)
        BRANCH="${2:-main}"
        DIFF_CMD="git diff ${BRANCH}..HEAD"
        ;;
esac

# Check we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo '{"error": "Not inside a git repository."}'
    exit 1
fi

# Get diff stats
STAT_OUTPUT=$(eval "$DIFF_CMD --stat --stat-width=200" 2>/dev/null || true)
NUMSTAT_OUTPUT=$(eval "$DIFF_CMD --numstat" 2>/dev/null || true)

if [[ -z "$NUMSTAT_OUTPUT" ]]; then
    echo '{"total_files": 0, "total_additions": 0, "total_deletions": 0, "files": []}'
    exit 0
fi

# Build JSON output
TOTAL_FILES=0
TOTAL_ADD=0
TOTAL_DEL=0
FILES_JSON="["
FIRST=true

while IFS=$'\t' read -r additions deletions filepath; do
    [[ -z "$filepath" ]] && continue

    # Handle binary files
    if [[ "$additions" == "-" ]]; then
        additions=0
        deletions=0
        status="binary"
    else
        # Determine status
        if [[ "$additions" -gt 0 && "$deletions" -gt 0 ]]; then
            status="modified"
        elif [[ "$additions" -gt 0 ]]; then
            status="added"
        elif [[ "$deletions" -gt 0 ]]; then
            status="deleted"
        else
            status="unchanged"
        fi
    fi

    TOTAL_FILES=$((TOTAL_FILES + 1))
    TOTAL_ADD=$((TOTAL_ADD + additions))
    TOTAL_DEL=$((TOTAL_DEL + deletions))

    if [[ "$FIRST" == "true" ]]; then
        FIRST=false
    else
        FILES_JSON+=","
    fi

    FILES_JSON+=$(printf '{"path":"%s","status":"%s","additions":%d,"deletions":%d}' \
        "$filepath" "$status" "$additions" "$deletions")

done <<< "$NUMSTAT_OUTPUT"

FILES_JSON+="]"

printf '{"total_files":%d,"total_additions":%d,"total_deletions":%d,"files":%s}\n' \
    "$TOTAL_FILES" "$TOTAL_ADD" "$TOTAL_DEL" "$FILES_JSON"
