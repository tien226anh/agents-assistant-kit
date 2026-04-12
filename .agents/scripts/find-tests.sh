#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# find-tests.sh — Find test files related to a given source file
# Used by test-writer and debug-assistant skills.
# ============================================================================

if [[ "${1:-}" == "--help" || -z "${1:-}" ]]; then
    cat <<EOF
Usage: find-tests.sh <source-file> [OPTIONS]

Find test files related to a given source file by naming convention.

OPTIONS:
    --json            Output as JSON array (default: one path per line)
    --help            Show this help message

CONVENTIONS CHECKED:
    source: src/auth/login.py
    looks for:
      - tests/test_login.py
      - tests/auth/test_login.py
      - src/auth/test_login.py
      - src/auth/login_test.py
      - src/auth/login.test.py

    source: src/components/Button.tsx
    looks for:
      - src/components/Button.test.tsx
      - src/components/Button.spec.tsx
      - __tests__/Button.test.tsx
      - tests/components/Button.test.tsx

EXAMPLES:
    find-tests.sh src/auth/login.py
    find-tests.sh src/components/Button.tsx --json

EXIT CODES:
    0  Found one or more test files
    1  No test files found
EOF
    exit 0
fi

SOURCE_FILE="$1"
FORMAT="text"
if [[ "${2:-}" == "--json" ]]; then
    FORMAT="json"
fi

# Extract components
BASENAME=$(basename "$SOURCE_FILE")
DIRNAME=$(dirname "$SOURCE_FILE")
FILENAME="${BASENAME%.*}"
EXTENSION="${BASENAME##*.}"

# Remove common prefixes for searching
RELATIVE_DIR="${DIRNAME#./}"

# Build list of candidate patterns
CANDIDATES=()

# Python conventions
if [[ "$EXTENSION" == "py" ]]; then
    CANDIDATES+=(
        "test_${FILENAME}.py"
        "${FILENAME}_test.py"
        "${FILENAME}.test.py"
    )
fi

# JavaScript/TypeScript conventions
if [[ "$EXTENSION" =~ ^(js|jsx|ts|tsx|mjs)$ ]]; then
    CANDIDATES+=(
        "${FILENAME}.test.${EXTENSION}"
        "${FILENAME}.spec.${EXTENSION}"
        "${FILENAME}.test.ts"
        "${FILENAME}.test.tsx"
        "${FILENAME}.spec.ts"
        "${FILENAME}.spec.tsx"
        "${FILENAME}.test.js"
        "${FILENAME}.spec.js"
    )
fi

# Go conventions
if [[ "$EXTENSION" == "go" ]]; then
    CANDIDATES+=(
        "${FILENAME}_test.go"
    )
fi

# Rust conventions
if [[ "$EXTENSION" == "rs" ]]; then
    CANDIDATES+=(
        "${FILENAME}_test.rs"
        "test_${FILENAME}.rs"
    )
fi

# General fallback
CANDIDATES+=(
    "test_${FILENAME}.${EXTENSION}"
    "${FILENAME}_test.${EXTENSION}"
    "${FILENAME}.test.${EXTENSION}"
    "${FILENAME}.spec.${EXTENSION}"
)

# Search for matching files
FOUND=()

for candidate in "${CANDIDATES[@]}"; do
    # Search from project root
    MATCHES=$(find . -name "$candidate" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/__pycache__/*" -not -path "*/venv/*" 2>/dev/null || true)
    while IFS= read -r match; do
        if [[ -n "$match" && -f "$match" ]]; then
            # Deduplicate
            ALREADY_FOUND=false
            for existing in "${FOUND[@]:-}"; do
                if [[ "$existing" == "$match" ]]; then
                    ALREADY_FOUND=true
                    break
                fi
            done
            if [[ "$ALREADY_FOUND" == "false" ]]; then
                FOUND+=("$match")
            fi
        fi
    done <<< "$MATCHES"
done

# Output results
if [[ ${#FOUND[@]} -eq 0 ]]; then
    if [[ "$FORMAT" == "json" ]]; then
        echo '{"source": "'"$SOURCE_FILE"'", "tests": [], "found": false}'
    else
        echo "No test files found for: $SOURCE_FILE"
    fi
    exit 1
fi

if [[ "$FORMAT" == "json" ]]; then
    JSON_ARRAY="["
    FIRST=true
    for f in "${FOUND[@]}"; do
        if [[ "$FIRST" == "true" ]]; then
            FIRST=false
        else
            JSON_ARRAY+=","
        fi
        JSON_ARRAY+="\"$f\""
    done
    JSON_ARRAY+="]"
    echo '{"source": "'"$SOURCE_FILE"'", "tests": '"$JSON_ARRAY"', "found": true}'
else
    for f in "${FOUND[@]}"; do
        echo "$f"
    done
fi
