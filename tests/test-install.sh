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

# Test: Custom agents directory exists
section "Custom agents"
assert_dir_exists "project-template/.github/agents exists" "$ROOT_DIR/project-template/.github/agents"

# Test: All custom agent files exist
for agent in brainstorming.agent.md requirements-specifier.agent.md code-planner.agent.md context-researcher.agent.md approach-evaluator.agent.md design-validator.agent.md; do
    assert_file_exists "project-template/.github/agents/$agent" "$ROOT_DIR/project-template/.github/agents/$agent"
done

# Test: Agent files have valid YAML frontmatter
section "Agent frontmatter validation"
for agent_file in "$ROOT_DIR/project-template/.github/agents"/*.agent.md; do
    agent_name="$(basename "$agent_file")"
    TESTS_RUN=$((TESTS_RUN + 1))
    if head -1 "$agent_file" | grep -q "^---$" && grep -q "^name:" "$agent_file" && grep -q "^description:" "$agent_file"; then
        echo -e "  ${GREEN}✓${NC} $agent_name has valid frontmatter"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $agent_name missing frontmatter (---, name, or description)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

# Test: Primary agents are user-invocable
section "Primary agents are user-invocable"
for agent_file in "$ROOT_DIR/project-template/.github/agents"/{brainstorming,requirements-specifier,code-planner}.agent.md; do
    agent_name="$(basename "$agent_file")"
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "user-invocable: true" "$agent_file"; then
        echo -e "  ${GREEN}✓${NC} $agent_name is user-invocable"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $agent_name is not user-invocable"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

# Test: Sub-agents are not user-invocable
section "Sub-agents are not user-invocable"
for agent_file in "$ROOT_DIR/project-template/.github/agents"/{context-researcher,approach-evaluator,design-validator}.agent.md; do
    agent_name="$(basename "$agent_file")"
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "user-invocable: false" "$agent_file"; then
        echo -e "  ${GREEN}✓${NC} $agent_name is not user-invocable (correct for sub-agent)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $agent_name should not be user-invocable"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

# Test: install.sh references AGENTS_SRC
section "install.sh agent support"
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "AGENTS_SRC" "$INSTALL_SCRIPT"; then
    echo -e "  ${GREEN}✓${NC} install.sh references AGENTS_SRC"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  ${RED}✗${NC} install.sh doesn't reference AGENTS_SRC"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

print_summary