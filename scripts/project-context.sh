#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# project-context.sh — Gather project metadata and structure
# Used by multiple skills to understand the project environment.
# ============================================================================

if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF
Usage: project-context.sh [OPTIONS]

Gather project metadata: language, framework, dependencies, and directory structure.

OPTIONS:
    --dir <path>      Project directory to analyze (default: current directory)
    --depth <n>       Directory tree depth (default: 3)
    --help            Show this help message

OUTPUT (JSON):
    {
      "project_dir": "/path/to/project",
      "languages": ["python", "typescript"],
      "frameworks": ["fastapi", "react"],
      "package_managers": ["uv", "pnpm"],
      "has_tests": true,
      "has_ci": true,
      "has_agents_md": true,
      "has_skills": true,
      "git_branch": "main",
      "structure": "..."
    }

EXAMPLES:
    project-context.sh
    project-context.sh --dir ~/my-project
    project-context.sh --depth 2

EOF
    exit 0
fi

# Parse arguments
PROJECT_DIR="."
DEPTH=3

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --depth)
            DEPTH="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# ---- Detect languages ----
LANGUAGES=()

[[ -f "$PROJECT_DIR/pyproject.toml" || -f "$PROJECT_DIR/setup.py" || -f "$PROJECT_DIR/requirements.txt" ]] && LANGUAGES+=("python")
[[ -f "$PROJECT_DIR/package.json" ]] && LANGUAGES+=("javascript")
[[ -f "$PROJECT_DIR/tsconfig.json" ]] && LANGUAGES+=("typescript")
[[ -f "$PROJECT_DIR/go.mod" ]] && LANGUAGES+=("go")
[[ -f "$PROJECT_DIR/Cargo.toml" ]] && LANGUAGES+=("rust")
[[ -f "$PROJECT_DIR/Gemfile" ]] && LANGUAGES+=("ruby")
[[ -f "$PROJECT_DIR/pom.xml" || -f "$PROJECT_DIR/build.gradle" ]] && LANGUAGES+=("java")

# ---- Detect frameworks ----
FRAMEWORKS=()

# Python frameworks
if [[ " ${LANGUAGES[*]:-} " =~ " python " ]]; then
    grep -ql "fastapi" "$PROJECT_DIR/pyproject.toml" "$PROJECT_DIR/requirements.txt" 2>/dev/null && FRAMEWORKS+=("fastapi")
    grep -ql "django" "$PROJECT_DIR/pyproject.toml" "$PROJECT_DIR/requirements.txt" 2>/dev/null && FRAMEWORKS+=("django")
    grep -ql "flask" "$PROJECT_DIR/pyproject.toml" "$PROJECT_DIR/requirements.txt" 2>/dev/null && FRAMEWORKS+=("flask")
fi

# JS/TS frameworks
if [[ -f "$PROJECT_DIR/package.json" ]]; then
    grep -q '"next"' "$PROJECT_DIR/package.json" 2>/dev/null && FRAMEWORKS+=("nextjs")
    grep -q '"react"' "$PROJECT_DIR/package.json" 2>/dev/null && FRAMEWORKS+=("react")
    grep -q '"vue"' "$PROJECT_DIR/package.json" 2>/dev/null && FRAMEWORKS+=("vue")
    grep -q '"express"' "$PROJECT_DIR/package.json" 2>/dev/null && FRAMEWORKS+=("express")
    grep -q '"fastify"' "$PROJECT_DIR/package.json" 2>/dev/null && FRAMEWORKS+=("fastify")
    grep -q '"@nestjs/core"' "$PROJECT_DIR/package.json" 2>/dev/null && FRAMEWORKS+=("nestjs")
    grep -q '"hono"' "$PROJECT_DIR/package.json" 2>/dev/null && FRAMEWORKS+=("hono")
fi

# ---- Detect package managers ----
PKG_MANAGERS=()

[[ -f "$PROJECT_DIR/uv.lock" ]] && PKG_MANAGERS+=("uv")
[[ -f "$PROJECT_DIR/poetry.lock" ]] && PKG_MANAGERS+=("poetry")
[[ -f "$PROJECT_DIR/Pipfile.lock" ]] && PKG_MANAGERS+=("pipenv")
[[ -f "$PROJECT_DIR/pnpm-lock.yaml" ]] && PKG_MANAGERS+=("pnpm")
[[ -f "$PROJECT_DIR/yarn.lock" ]] && PKG_MANAGERS+=("yarn")
[[ -f "$PROJECT_DIR/package-lock.json" ]] && PKG_MANAGERS+=("npm")
[[ -f "$PROJECT_DIR/bun.lockb" || -f "$PROJECT_DIR/bun.lock" ]] && PKG_MANAGERS+=("bun")
[[ -f "$PROJECT_DIR/go.sum" ]] && PKG_MANAGERS+=("go-modules")
[[ -f "$PROJECT_DIR/Cargo.lock" ]] && PKG_MANAGERS+=("cargo")

# ---- Detect testing ----
TEST_FRAMEWORKS=()
HAS_TESTS=false
[[ -d "$PROJECT_DIR/tests" || -d "$PROJECT_DIR/test" || -d "$PROJECT_DIR/__tests__" || -d "$PROJECT_DIR/spec" ]] && HAS_TESTS=true

# Python testing
if [[ " ${LANGUAGES[*]:-} " =~ " python " ]]; then
    grep -ql "pytest" "$PROJECT_DIR/pyproject.toml" "$PROJECT_DIR/requirements.txt" 2>/dev/null && TEST_FRAMEWORKS+=("pytest")
fi

# JS/TS testing
if [[ -f "$PROJECT_DIR/package.json" ]]; then
    grep -q '"vitest"' "$PROJECT_DIR/package.json" 2>/dev/null && TEST_FRAMEWORKS+=("vitest")
    grep -q '"jest"' "$PROJECT_DIR/package.json" 2>/dev/null && TEST_FRAMEWORKS+=("jest")
    grep -q '"playwright"' "$PROJECT_DIR/package.json" 2>/dev/null && TEST_FRAMEWORKS+=("playwright")
    [[ -f "$PROJECT_DIR/vitest.config.ts" || -f "$PROJECT_DIR/vitest.config.js" ]] && { [[ ! " ${TEST_FRAMEWORKS[*]:-} " =~ " vitest " ]] && TEST_FRAMEWORKS+=("vitest"); }
fi

# ---- Detect infra tools ----
INFRA_TOOLS=()
[[ -f "$PROJECT_DIR/Dockerfile" || -f "$PROJECT_DIR/docker-compose.yml" || -f "$PROJECT_DIR/docker-compose.yaml" || -f "$PROJECT_DIR/compose.yml" ]] && INFRA_TOOLS+=("docker")
[[ -d "$PROJECT_DIR/k8s" || -d "$PROJECT_DIR/kubernetes" || -d "$PROJECT_DIR/deploy" ]] && INFRA_TOOLS+=("kubernetes")
[[ -f "$PROJECT_DIR/terraform.tf" || -d "$PROJECT_DIR/infra" || -d "$PROJECT_DIR/terraform" ]] && INFRA_TOOLS+=("terraform")
find "$PROJECT_DIR" -maxdepth 2 -name "*.tf" -type f 2>/dev/null | head -1 | grep -q . && { [[ ! " ${INFRA_TOOLS[*]:-} " =~ " terraform " ]] && INFRA_TOOLS+=("terraform"); }

# ---- Detect features ----
HAS_CI=false
[[ -d "$PROJECT_DIR/.github/workflows" || -f "$PROJECT_DIR/.gitlab-ci.yml" || -f "$PROJECT_DIR/Jenkinsfile" || -d "$PROJECT_DIR/.circleci" ]] && HAS_CI=true

HAS_AGENTS_MD=false
[[ -f "$PROJECT_DIR/AGENTS.md" ]] && HAS_AGENTS_MD=true

HAS_SKILLS=false
[[ -d "$PROJECT_DIR/.agents/skills" ]] && HAS_SKILLS=true

# ---- Determine primary stack ----
# Helps agents choose the right skill (python-expert vs nodejs-expert)
PRIMARY_STACK=""
if [[ " ${LANGUAGES[*]:-} " =~ " python " ]] && [[ ! " ${LANGUAGES[*]:-} " =~ " typescript " ]] && [[ ! " ${LANGUAGES[*]:-} " =~ " javascript " ]]; then
    PRIMARY_STACK="python"
elif [[ " ${LANGUAGES[*]:-} " =~ " typescript " ]] || [[ " ${LANGUAGES[*]:-} " =~ " javascript " ]] && [[ ! " ${LANGUAGES[*]:-} " =~ " python " ]]; then
    PRIMARY_STACK="nodejs"
elif [[ " ${LANGUAGES[*]:-} " =~ " python " ]] && [[ " ${LANGUAGES[*]:-} " =~ " typescript " || " ${LANGUAGES[*]:-} " =~ " javascript " ]]; then
    PRIMARY_STACK="polyglot"
elif [[ " ${LANGUAGES[*]:-} " =~ " go " ]]; then
    PRIMARY_STACK="go"
elif [[ " ${LANGUAGES[*]:-} " =~ " rust " ]]; then
    PRIMARY_STACK="rust"
elif [[ " ${LANGUAGES[*]:-} " =~ " java " ]]; then
    PRIMARY_STACK="java"
fi

# ---- Git info ----
GIT_BRANCH=""
if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    GIT_BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo "")
fi

# ---- Directory structure ----
STRUCTURE=$(find "$PROJECT_DIR" -maxdepth "$DEPTH" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/__pycache__/*" \
    -not -path "*/venv/*" \
    -not -path "*/.venv/*" \
    -not -path "*/.next/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" \
    -not -name "*.pyc" \
    -type d 2>/dev/null | sort | head -50 | sed "s|$PROJECT_DIR|.|g")

# ---- Build JSON ----
to_json_array() {
    local arr=("$@")
    # Filter out empty strings (bash passes "" for unset arrays)
    local filtered=()
    for item in "${arr[@]}"; do
        [[ -n "$item" ]] && filtered+=("$item")
    done
    if [[ ${#filtered[@]} -eq 0 ]]; then
        echo "[]"
        return
    fi
    local result="["
    local first=true
    for item in "${filtered[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            result+=","
        fi
        result+="\"$item\""
    done
    result+="]"
    echo "$result"
}

cat <<EOF
{
  "project_dir": "$PROJECT_DIR",
  "primary_stack": "$PRIMARY_STACK",
  "languages": $(to_json_array "${LANGUAGES[@]:-}"),
  "frameworks": $(to_json_array "${FRAMEWORKS[@]:-}"),
  "package_managers": $(to_json_array "${PKG_MANAGERS[@]:-}"),
  "test_frameworks": $(to_json_array "${TEST_FRAMEWORKS[@]:-}"),
  "infra_tools": $(to_json_array "${INFRA_TOOLS[@]:-}"),
  "has_tests": $HAS_TESTS,
  "has_ci": $HAS_CI,
  "has_agents_md": $HAS_AGENTS_MD,
  "has_skills": $HAS_SKILLS,
  "git_branch": "$GIT_BRANCH"
}
EOF
