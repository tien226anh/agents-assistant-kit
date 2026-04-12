# AGENTS.md — Agent Skills Builder

This repository contains a curated framework of Agent Skills and AGENTS.md templates for IDE-native AI coding agents (GitHub Copilot, Claude Code, Codex, Cursor, etc.).

## Project Overview

A pure file-based framework of 27 Agent Skills and AGENTS.md templates that supercharge IDE coding agents. No runtime, no CLI — just files that agents discover and use natively.

## Command Safety

**Read-only commands only.** Agents must NEVER run commands that mutate state, delete data, modify infrastructure, or have destructive side-effects without explicit user approval.
- ✅ Allowed: `git status`, `git diff`, `cat`, `ls`, `find`, `grep`, test runners, linters, type checkers, read-only queries
- ❌ Forbidden: `rm -rf`, `git push --force`, `docker rm`, `kubectl delete`, database writes, deploy commands

## Project Structure

```
skills/                    → Agent Skills (SKILL.md spec compliant)
agents-md-templates/       → AGENTS.md templates for different tech stacks
project-template/          → Drop-in template for any project
scripts/                   → Shared helper scripts used by skills
install.sh                 → Installer for deploying skills
```

## Setup Commands

- No build step required — this is a pure file-based framework.
- To test the installer: `bash install.sh --help`
- To validate skills: `for f in skills/*/SKILL.md; do head -1 "$f" | grep -q "^---$" && echo "✓ $f" || echo "✗ $f"; done`
- To validate frontmatter names: `for f in skills/*/SKILL.md; do dir=$(basename $(dirname "$f")); name=$(grep "^name:" "$f" | sed 's/name: //'); [ "$dir" = "$name" ] && echo "✓ $dir" || echo "✗ $dir (name=$name)"; done`

## Code Style

- **SKILL.md files**: Must follow the [Agent Skills specification](https://agentskills.io/specification)
  - YAML frontmatter with `name` and `description` (required)
  - `name` must be lowercase, hyphenated, match the parent directory name
  - `description` must be third-person, start with "Use when...", include trigger keywords
  - Body content should be < 500 lines (use `references/` for details)
  - Use progressive disclosure: keep SKILL.md concise, put details in `references/`
- **Shell scripts**: POSIX-compatible where possible, bash when needed
  - Must support `--help` flag
  - Must use structured output (JSON preferred)
  - Must be non-interactive (no prompts)
  - Must include error handling with informative messages
- **Markdown**: Use ATX headers (`#`), one sentence per line in body text

## Testing Instructions

- Validate SKILL.md frontmatter: check `---` delimiters and required `name`/`description` fields
- Validate skill names match directory names
- Run shell scripts with `--help` to verify they're self-documenting
- Test install.sh in both `--project` and `--user` modes against a temp directory

## Gotchas

- Skill `name` in frontmatter MUST match the directory name exactly (lowercase, hyphenated)
- The `description` field is the primary trigger for skill activation — if a skill doesn't activate, improve the description first
- Skills with `references/` subdirectories use progressive disclosure — the main SKILL.md should link to reference files clearly
- The `project-template/` directory is what gets deployed to user projects — changes there affect all new installations

## Agent Skills

Check the `.agents/skills/` directory for specialized skills that provide detailed instructions for specific tasks.

**IMPORTANT: Transparency Rule**
Whenever you act upon a user's request, you MUST explicitly state which skill(s) from `.agents/skills/` you are utilizing at the very beginning of your response. (e.g., "🛠️ *Skill Activated: code-review*"). Wait to read the skill document before executing.

### Available Skills

| Skill | Activates When You Ask To... |
|-------|------------------------------|
| **architect-cloud** | Design multi-cloud architecture (AWS/GCP/Azure), IaC, serverless, cost optimization |
| **architect-onprem** | Design on-premise infrastructure, k8s, CI/CD, HA, DR, security |
| **brainstorming** | Explore design options, refine a rough idea, structured ideation before planning |
| **bug-analyzer** | Deep-dive triage of bugs, logs, stack traces, crash reports |
| **build-mcp-server** | Build MCP servers, add MCP tools/resources, configure MCP clients |
| **code-planner** | Create step-by-step implementation plans before writing code |
| **code-review** | Review code, check a PR, audit changes, find problems in diffs |
| **debug-assistant** | Debug a bug, investigate an error, fix unexpected behavior |
| **devops** | Docker, CI/CD, Kubernetes ops, GitOps, monitoring, deployment strategies |
| **doc-writer** | Write structured docs: specs, ADRs, proposals, RFCs, runbooks, API docs |
| **executing-plans** | Execute an implementation plan task-by-task with review checkpoints |
| **frontend-design** | Build distinctive, production-grade frontend interfaces and web UI |
| **git-workflow** | Work with git: branch, commit, merge, PR |
| **nodejs-expert** | Node.js/TypeScript development: setup, pnpm, vitest, ESLint, frameworks |
| **problem-solving** | Get unstuck, think creatively, find root causes when standard approaches fail |
| **python-expert** | Python development: setup, packaging, testing, typing, frameworks, async |
| **refactor** | Refactor, clean up, restructure, or improve existing code |
| **requirements-specifier** | Extract user intent into structured requirements, PRDs, user stories |
| **skill-creator** | Create, edit, and improve Agent Skills for this framework |
| **skill-orchestrator** | Orchestrate and route requests to the best installed Agent Skill |
| **systematic-debugging** | Debug hard bugs that resist normal troubleshooting, root cause tracing |
| **test-driven-development** | Enforce RED-GREEN-REFACTOR cycle, write tests before implementation |
| **test-writer** | Write tests, add coverage, create test cases |
| **troubleshoot-infra** | Infrastructure troubleshooting: networking, DNS, TLS, Docker, Kubernetes |
| **use-skill** | Discover, evaluate, and activate other installed Agent Skills |
| **webapp-testing** | Test web apps with Playwright: screenshots, E2E tests, browser automation |
| **writing-plans** | Create detailed implementation plans with bite-sized tasks |

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md`
2. Add YAML frontmatter with `name` (matching directory) and `description`
3. Write body instructions (step-by-step, actionable)
4. Add `scripts/`, `references/`, or `assets/` subdirectories as needed
5. Validate: `name` matches directory, `description` starts with "Use when..."
6. Test with an IDE agent to verify discovery and activation
7. Update the Available Skills table in this file
