#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Agent Skills Builder — Installer
# Copies skills and AGENTS.md templates into a project or user home directory.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="${SCRIPT_DIR}/skills"
SCRIPTS_SRC="${SCRIPT_DIR}/scripts"
AGENTS_SRC="${SCRIPT_DIR}/project-template/.github/agents"
TEMPLATES_DIR="${SCRIPT_DIR}/agents-md-templates"
PROJECT_TEMPLATE_DIR="${SCRIPT_DIR}/project-template"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install Agent Skills and AGENTS.md templates for IDE coding agents.

OPTIONS:
    --project <path>       Install skills into a specific project directory
    --user                 Install skills globally to ~/.agents/skills/
    --template <name>      AGENTS.md template to use (default: general)
    --agent <list>         Comma-separated list of agents to configure (default: all)
                           Available: cursor, copilot, claude, cline, gemini, windsurf, all
    --reinstall            Force overwrite of existing IDE compatibility files
    --no-compat            Skip creating IDE-specific compatibility files
    --dry-run              Show what would be done without making changes
    -h, --help             Show this help message

EXAMPLES:
    $(basename "$0") --project ~/my-app
    $(basename "$0") --project ~/my-app --template python-fastapi
    $(basename "$0") --user
    $(basename "$0") --project ~/my-app --dry-run

EOF
}

log_info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error()   { echo -e "${RED}✗${NC}  $1"; }

# Defaults
MODE=""
TARGET_DIR=""
TEMPLATE="general"
TARGET_AGENTS="all"
REINSTALL=false
NO_COMPAT=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --project)
            MODE="project"
            TARGET_DIR="$2"
            shift 2
            ;;
        --user)
            MODE="user"
            TARGET_DIR="${HOME}/.agents/skills"
            shift
            ;;
        --template)
            TEMPLATE="$2"
            shift 2
            ;;
        --agent)
            TARGET_AGENTS="$2"
            shift 2
            ;;
        --reinstall)
            REINSTALL=true
            shift
            ;;
        --no-compat)
            NO_COMPAT=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$MODE" ]]; then
    log_error "Must specify --project <path> or --user"
    echo ""
    usage
    exit 1
fi

# Validate template
TEMPLATE_FILE="${TEMPLATES_DIR}/${TEMPLATE}.md"
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    log_error "Template '${TEMPLATE}' not found. Available templates:"
    for t in "${TEMPLATES_DIR}"/*.md; do
        echo "  - $(basename "$t" .md)"
    done
    exit 1
fi

# ---- Execute ----------------------------------------------------------------

should_install_agent() {
    local agent=$1
    if [[ "$TARGET_AGENTS" == "all" || ",${TARGET_AGENTS}," == *",${agent},"* ]]; then
        return 0
    fi
    return 1
}

run_cmd() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  [dry-run] $1"
    else
        eval "$1"
    fi
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 🛠️  Agent Skills Builder — Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ "$MODE" == "project" ]]; then
    # Resolve to absolute path
    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"
    SKILLS_DEST="${TARGET_DIR}/.agents/skills"

    log_info "Mode: Project install"
    log_info "Target: ${TARGET_DIR}"
    log_info "Template: ${TEMPLATE}"
    echo ""

    # 1. Copy skills
    log_info "Installing skills to ${SKILLS_DEST}/ ..."
    run_cmd "mkdir -p '${SKILLS_DEST}'"
    for skill_dir in "${SKILLS_SRC}"/*/; do
        skill_name="$(basename "$skill_dir")"
        if [[ -f "${skill_dir}SKILL.md" ]]; then
            run_cmd "cp -r '${skill_dir}' '${SKILLS_DEST}/${skill_name}'"
            log_success "  ${skill_name}"
        fi
    done

    # 2. Copy custom agents into .github/agents/
    if [[ -d "$AGENTS_SRC" ]]; then
        AGENTS_DEST="${TARGET_DIR}/.github/agents"
        log_info "Installing custom agents to ${AGENTS_DEST}/ ..."
        run_cmd "mkdir -p '${AGENTS_DEST}'"
        for agent_file in "${AGENTS_SRC}"/*.agent.md; do
            if [[ -f "$agent_file" ]]; then
                agent_name="$(basename "$agent_file")"
                run_cmd "cp '${agent_file}' '${AGENTS_DEST}/${agent_name}'"
                log_success "  ${agent_name}"
            fi
        done
    fi

    # 3. Copy shared scripts into .agents/scripts/
    if [[ -d "$SCRIPTS_SRC" ]]; then
        SCRIPTS_DEST="${TARGET_DIR}/.agents/scripts"
        log_info "Installing helper scripts to ${SCRIPTS_DEST}/ ..."
        run_cmd "mkdir -p '${SCRIPTS_DEST}'"
        for script in "${SCRIPTS_SRC}"/*.sh; do
            if [[ -f "$script" ]]; then
                run_cmd "cp '${script}' '${SCRIPTS_DEST}/'"
                run_cmd "chmod +x '${SCRIPTS_DEST}/$(basename "$script")'"
                log_success "  $(basename "$script")"
            fi
        done
    fi

    # 4. Create AGENTS.md from template (if not exists)
    AGENTS_MD="${TARGET_DIR}/AGENTS.md"
    if [[ -f "$AGENTS_MD" ]]; then
        log_warn "AGENTS.md already exists — skipping (preserved during --reinstall)"
    else
        log_info "Creating AGENTS.md from '${TEMPLATE}' template ..."
        run_cmd "cp '${TEMPLATE_FILE}' '${AGENTS_MD}'"
        log_success "AGENTS.md created"
    fi

    # 5. Create IDE compatibility files
    if [[ "$NO_COMPAT" != "true" ]]; then
        echo ""
        log_info "Creating IDE compatibility files ..."

        # GitHub Copilot
        if should_install_agent "copilot"; then
            COPILOT_DIR="${TARGET_DIR}/.github"
            COPILOT_FILE="${COPILOT_DIR}/copilot-instructions.md"
            if [[ ! -f "$COPILOT_FILE" || "$REINSTALL" == "true" ]]; then
                run_cmd "mkdir -p '${COPILOT_DIR}'"
                run_cmd "cp '${PROJECT_TEMPLATE_DIR}/.github/copilot-instructions.md' '${COPILOT_FILE}'"
                log_success ".github/copilot-instructions.md"
            else
                log_warn ".github/copilot-instructions.md already exists — skipping"
            fi
        fi

        # Cursor rules
        if should_install_agent "cursor"; then
            CURSOR_DIR="${TARGET_DIR}/.cursor"
            CURSOR_FILE="${CURSOR_DIR}/rules.md"
            if [[ ! -f "$CURSOR_FILE" || "$REINSTALL" == "true" ]]; then
                run_cmd "mkdir -p '${CURSOR_DIR}'"
                run_cmd "cp '${PROJECT_TEMPLATE_DIR}/.cursor/rules.md' '${CURSOR_FILE}'"
                log_success ".cursor/rules.md"
            else
                log_warn ".cursor/rules.md already exists — skipping"
            fi
        fi

        # Claude Code
        if should_install_agent "claude"; then
            CLAUDE_FILE="${TARGET_DIR}/CLAUDE.md"
            if [[ ! -f "$CLAUDE_FILE" || "$REINSTALL" == "true" ]]; then
                run_cmd "cp '${PROJECT_TEMPLATE_DIR}/CLAUDE.md' '${CLAUDE_FILE}'"
                log_success "CLAUDE.md"
            else
                log_warn "CLAUDE.md already exists — skipping"
            fi
        fi

        # Cline
        if should_install_agent "cline"; then
            CLINE_FILE="${TARGET_DIR}/.clinerules"
            if [[ ! -f "$CLINE_FILE" || "$REINSTALL" == "true" ]]; then
                run_cmd "cp '${PROJECT_TEMPLATE_DIR}/.clinerules' '${CLINE_FILE}'"
                log_success ".clinerules"
            else
                log_warn ".clinerules already exists — skipping"
            fi
        fi

        # Windsurf
        if should_install_agent "windsurf"; then
            WINDSURF_FILE="${TARGET_DIR}/.windsurfrules"
            if [[ ! -f "$WINDSURF_FILE" || "$REINSTALL" == "true" ]]; then
                run_cmd "cp '${PROJECT_TEMPLATE_DIR}/.windsurfrules' '${WINDSURF_FILE}'"
                log_success ".windsurfrules"
            else
                log_warn ".windsurfrules already exists — skipping"
            fi
        fi

        # Google Antigravity
        if should_install_agent "gemini"; then
            GEMINI_FILE="${TARGET_DIR}/GEMINI.md"
            if [[ ! -f "$GEMINI_FILE" || "$REINSTALL" == "true" ]]; then
                run_cmd "cp '${PROJECT_TEMPLATE_DIR}/GEMINI.md' '${GEMINI_FILE}'"
                log_success "GEMINI.md"
            else
                log_warn "GEMINI.md already exists — skipping"
            fi
        fi

        # MCP config templates
        echo ""
        log_info "Creating MCP config templates ..."

        # VS Code MCP config
        VSCODE_DIR="${TARGET_DIR}/.vscode"
        VSCODE_MCP="${VSCODE_DIR}/mcp.json"
        if [[ ! -f "$VSCODE_MCP" || "$REINSTALL" == "true" ]]; then
            run_cmd "mkdir -p '${VSCODE_DIR}'"
            run_cmd "cp '${PROJECT_TEMPLATE_DIR}/.vscode/mcp.json' '${VSCODE_MCP}'"
            log_success ".vscode/mcp.json"
        else
            log_warn ".vscode/mcp.json already exists — skipping"
        fi

        # Cursor MCP config
        if should_install_agent "cursor"; then
            CURSOR_MCP="${CURSOR_DIR}/mcp.json"
            if [[ ! -f "$CURSOR_MCP" || "$REINSTALL" == "true" ]]; then
                run_cmd "mkdir -p '${CURSOR_DIR}'"
                run_cmd "cp '${PROJECT_TEMPLATE_DIR}/.cursor/mcp.json' '${CURSOR_MCP}'"
                log_success ".cursor/mcp.json"
            else
                log_warn ".cursor/mcp.json already exists — skipping"
            fi
        fi
    fi

elif [[ "$MODE" == "user" ]]; then
    log_info "Mode: User-level install"
    log_info "Target: ${TARGET_DIR}"
    echo ""

    # Copy skills to ~/.agents/skills/
    log_info "Installing skills to ${TARGET_DIR}/ ..."
    run_cmd "mkdir -p '${TARGET_DIR}'"
    for skill_dir in "${SKILLS_SRC}"/*/; do
        skill_name="$(basename "$skill_dir")"
        if [[ -f "${skill_dir}SKILL.md" ]]; then
            run_cmd "cp -r '${skill_dir}' '${TARGET_DIR}/${skill_name}'"
            log_success "  ${skill_name}"
        fi
    done

    # Copy shared scripts
    if [[ -d "$SCRIPTS_SRC" ]]; then
        SCRIPTS_DEST="${HOME}/.agents/scripts"
        log_info "Installing helper scripts to ${SCRIPTS_DEST}/ ..."
        run_cmd "mkdir -p '${SCRIPTS_DEST}'"
        for script in "${SCRIPTS_SRC}"/*.sh; do
            if [[ -f "$script" ]]; then
                run_cmd "cp '${script}' '${SCRIPTS_DEST}/'"
                run_cmd "chmod +x '${SCRIPTS_DEST}/$(basename "$script")'"
                log_success "  $(basename "$script")"
            fi
        done
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "Installation complete!"
echo ""

if [[ "$MODE" == "project" ]]; then
    log_info "Next steps:"
    echo "  1. Edit ${TARGET_DIR}/AGENTS.md to match your project"
    echo "  2. Open your project in VS Code / Cursor / your IDE"
    echo "  3. Ask your agent: 'Review my last commit' or 'Write tests for X'"
    echo ""
    log_info "Add custom skills to: ${SKILLS_DEST}/"
    log_info "Custom agents installed to: ${TARGET_DIR}/.github/agents/"
else
    log_info "Skills installed globally. They'll be available in all projects."
    log_info "Add custom skills to: ${TARGET_DIR}/"
fi
echo ""
