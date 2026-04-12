#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# test-skill-frontmatter.sh — Validate SKILL.md frontmatter
# Ensures all skills have valid YAML frontmatter with required fields.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../skills" && pwd)"

# Source helpers
source "$SCRIPT_DIR/test-helpers.sh"

section "Skill Frontmatter Validation"

# Get all skill directories
skill_dirs=()
while IFS= read -r dir; do
    skill_dirs+=("$dir")
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

echo "Found ${#skill_dirs[@]} skills"

# Test: Each skill directory has a SKILL.md
section "SKILL.md exists"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    assert_file_exists "$skill_name has SKILL.md" "$dir/SKILL.md"
done

# Test: Each SKILL.md has YAML frontmatter delimiters
section "YAML frontmatter delimiters (---)"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    # Check first line is ---
    first_line=$(head -1 "$skill_file")
    assert_match "$skill_name starts with ---" "$first_line" "^---$"

    # Check there's a closing ---
    # The closing --- should be after the opening one
    closing_line=$(awk '/^---$/{count++; if(count==2){print NR; exit}}' "$skill_file")
    if [[ -n "$closing_line" ]]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        echo -e "  ${GREEN}✓${NC} $skill_name has closing ---"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        echo -e "  ${RED}✗${NC} $skill_name missing closing ---"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

# Test: Each SKILL.md has required 'name' field
section "Required 'name' field"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    # Extract name from frontmatter (between the two --- lines)
    name_value=$(awk '/^---$/{count++; next} count==1 && /^name:/{print $2; exit}' "$skill_file")
    assert_match "$skill_name has name field" "$name_value" ".+"
done

# Test: name field matches directory name
section "name matches directory"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    name_value=$(awk '/^---$/{count++; next} count==1 && /^name:/{gsub(/^name: /, ""); print; exit}' "$skill_file")
    assert_match "$skill_name name=$name_value" "$name_value" "^${skill_name}$"
done

# Test: Each SKILL.md has required 'description' field
section "Required 'description' field"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    # Check that description line exists in frontmatter
    has_desc=$(awk '/^---$/{count++; next} count==1 && /^description:/{print "yes"; exit}' "$skill_file")
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ "$has_desc" == "yes" ]]; then
        echo -e "  ${GREEN}✓${NC} $skill_name has description field"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $skill_name missing description field"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

# Test: description starts with "Use when" (CSO best practice)
section "Description starts with 'Use when' (CSO)"
for dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$dir")
    skill_file="$dir/SKILL.md"

    desc=$(awk '/^---$/{count++; next} count==1 && /^description:/{gsub(/^description: /, ""); print; exit}' "$skill_file")
    assert_match "$skill_name description starts with 'Use when'" "$desc" "^Use when"
done

print_summary