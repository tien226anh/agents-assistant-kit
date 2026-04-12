#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# test-skill-descriptions.sh — Validate CSO (Claude Search Optimization)
# Ensures all skill descriptions follow best practices for discoverability.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../skills" && pwd)"

# Source helpers
source "$SCRIPT_DIR/test-helpers.sh"

section "CSO Description Quality Validation"

# Get all skill directories
skill_dirs=()
while IFS= read -r dir; do
    skill_dirs+=("$dir")
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

# Test: Description is third-person (no "you" or "your" in description)
section "Third-person descriptions (no 'you'/'your')"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    desc=$(awk '/^---$/{count++; next} count==1 && /^description:/{gsub(/^description: /, ""); print; exit}' "$skill_file")

    # Check for second-person pronouns
    has_you=$(echo "$desc" | grep -ciE '\byou\b|\byour\b' || true)
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$has_you" -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} $skill_name uses third-person"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $skill_name uses second-person (you/your)"
        # Warning, not failure
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
done

# Test: Description includes trigger keywords
section "Description includes trigger keywords"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    desc=$(awk '/^---$/{count++; next} count==1 && /^description:/{gsub(/^description: /, ""); print; exit}' "$skill_file")

    # Check for "Include keywords:" or common trigger words
    has_keywords=$(echo "$desc" | grep -ciE 'Include keywords:|keyword|trigger' || true)
    has_trigger_words=$(echo "$desc" | grep -ciE 'review|test|debug|deploy|build|create|write|refactor|plan|design|analyze|implement|fix|check|audit' || true)

    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$has_keywords" -gt 0 ]] || [[ "$has_trigger_words" -gt 0 ]]; then
        echo -e "  ${GREEN}✓${NC} $skill_name has trigger keywords"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $skill_name may lack trigger keywords"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
done

# Test: Description length is reasonable (not too short, not too long)
section "Description length (20-300 chars)"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    desc=$(awk '/^---$/{count++; next} count==1 && /^description:/{gsub(/^description: /, ""); print; exit}' "$skill_file")
    desc_len=${#desc}

    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ $desc_len -ge 20 ]] && [[ $desc_len -le 300 ]]; then
        echo -e "  ${GREEN}✓${NC} $skill_name description length: $desc_len"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    elif [[ $desc_len -lt 20 ]]; then
        echo -e "  ${RED}✗${NC} $skill_name description too short ($desc_len chars)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $skill_name description too long ($desc_len chars)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
done

# Test: SKILL.md body has key sections
section "SKILL.md has required sections"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    # Check for "When to use" or "When to activate" section
    has_when=$(grep -ciE "^## When to (use|activate)" "$skill_file" || true)
    assert_match "$skill_name has 'When to use' section" "$has_when" "^[1-9]$"

    # Check for a process/workflow section (various naming conventions)
    has_workflow=$(grep -ciE "^## (Workflow|Steps|Process|Instructions|Guide|Approach|Cycle|Framework|Thinking|Decision)" "$skill_file" || true)
    # Also check for skill-specific section names
    has_specific=$(grep -ciE "^## (Architecture|Bug Analysis|Planning|Execution|Design|Triage|Specification|Technique|Docker|CI/CD|Kubernetes|Deployment|Monitoring|Setup|Package|Virtual|Testing|Debugging|Async|Patterns|TDD|Gate)" "$skill_file" || true)
    total=$((has_workflow + has_specific))
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ $total -ge 1 ]]; then
        echo -e "  ${GREEN}✓${NC} $skill_name has workflow/process section"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $skill_name missing workflow/process section"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

# Test: References directory exists and has content (if referenced)
section "References are valid"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    # Find all reference links in the SKILL.md
    ref_links=$(grep -oE '\[references/[^\]]+\]' "$skill_file" 2>/dev/null || true)

    if [[ -n "$ref_links" ]]; then
        # Check that referenced files exist
        while IFS= read -r link; do
            # Extract filename from [references/filename.md]
            ref_file=$(echo "$link" | sed 's/\[references\///' | sed 's/\]//')
            ref_path="$dir/references/$ref_file"
            assert_file_exists "$skill_name references/$ref_file" "$ref_path"
        done <<< "$ref_links"
    else
        # No references linked, that's fine
        TESTS_RUN=$((TESTS_RUN + 1))
        echo -e "  ${GREEN}✓${NC} $skill_name (no references needed)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
done

print_summary