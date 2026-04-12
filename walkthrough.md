# Walkthrough — Agent Skills Builder

## What Was Built

An IDE-native **Agent Skills framework** — a collection of files that supercharge AI coding agents (Google Antigravity, GitHub Copilot, Claude Code, Codex, Cursor, Cline, OpenCode) without any custom runtime. Drop the files into your project, and your IDE agent gains structured expertise across 19 different domains.

## Project Structure

```
agents_skills_builder/
├── AGENTS.md                                  # Meta: guidance for agents on THIS repo
├── README.md                                  # Human documentation
├── install.sh                                 # Local installer (--project / --user modes)
├── setup.sh                                   # Remote CLI installer (curl | bash wrapper)
├── package.json                               # Node.js NPM configuration 
├── pyproject.toml                             # Python package configuration 
│
├── skills/                                    # 19 built-in Agent Skills
│   ├── code-review/                           # Structured review workflow & security checks
│   ├── git-workflow/                          # Branch naming, conventional commits, PR flow
│   ├── debug-assistant/                       # Reproduce→Isolate→Hypothesize→Fix→Verify
│   ├── test-writer/                           # Arrange-Act-Assert, naming, stack-aware mocks
│   ├── refactor/                              # Plan→Validate→Execute→Verify code smells
│   ├── build-mcp-server/                      # MCP server creation and client config
│   ├── python-expert/                         # FastApi, pytest, ruff, uv, async, SQLAlchemy
│   ├── nodejs-expert/                         # TypeScript, vitest, pnpm, Next.js/Express, Zod
│   ├── architect-onprem/                      # Proxmox, k3s, HAProxy, Patroni, Vault
│   ├── architect-cloud/                       # AWS/GCP/Azure, Terraform, cost, compliance
│   ├── troubleshoot-infra/                    # Networking, DNS, Docker/K8s triage, DB locks
│   ├── devops/                                # CI/CD workflows, GitOps (ArgoCD), metrics
│   ├── skill-creator/                         # Guide for writing and improving Agent Skills
│   ├── frontend-design/                       # UI aesthetics, CSS patterns, design thinking
│   ├── webapp-testing/                        # Playwright E2E testing, browser inspection
│   ├── doc-writer/                            # Structured docs (specs, ADRs, RFCs, runbooks)
│   ├── bug-analyzer/                          # Deep-dive log triage & root cause analysis
│   ├── requirements-specifier/                # Structuring PRDs and acceptance criteria
│   └── code-planner/                          # Phased implementation planning without coding
│
├── agents-md-templates/                       # AGENTS.md templates
│   ├── general.md                             # Generic project template
│   ├── python-fastapi.md                      # Python/FastAPI template
│   └── node-typescript.md                     # Node/TS template
│
├── project-template/                          # IDE compatibility files
│   ├── AGENTS.md                              # Minimal drop-in template
│   ├── .github/copilot-instructions.md        # GitHub Copilot compatibility
│   ├── .cursor/rules.md                       # Cursor compatibility
│   ├── .clinerules                            # Cline compatibility
│   ├── CLAUDE.md                              # Claude Code compatibility
│   └── GEMINI.md                              # Google Antigravity compatibility
└── scripts/                                   # Shared helper scripts
    ├── analyze-diff.sh                        # Git diff → structured JSON
    ├── find-tests.sh                          # Source file → related test files
    └── project-context.sh                     # Detect language, framework, pkg manager
```

## Key Design Decisions

1. **No runtime / CLI** — The framework IS the files. IDE agents discover and use them natively via the open Agent Skills and AGENTS.md standards.

2. **Progressive disclosure** — Skills load in 3 tiers: name+description (discovery), SKILL.md body (activation), references/scripts (on-demand). This keeps agent context lightweight.

3. **Spec-compliant** — All 19 skills follow the [Agent Skills specification](https://agentskills.io/specification) exactly: YAML frontmatter with `name` + `description`, optional `scripts/`, `references/`, `assets/` directories.

4. **Command Safety Built-in** — Top-level templates and operations skills enforce a strict read-only policy for shell commands, preventing autonomous mutating/destructive actions without explicit user approval.

5. **Stack-aware routing** — Scripts output structured JSON. For example, `project-context.sh` detects if the user is in a Python vs JS project, allowing the agent to dynamically route to `python-expert` or `nodejs-expert` and use the right tests.

6. **Cross-IDE** — The installer creates compatibility files for Copilot (`.github/copilot-instructions.md`), Cursor (`.cursor/rules.md`), Claude Code (`CLAUDE.md`), Cline (`.clinerules`), and Google Antigravity (`GEMINI.md`). The core `.agents/skills/` format naturally works with standard agents like OpenCode.

## How to Use

### One-Line Remote Installation (Recommended)
You can directly stream the setup script from GitHub. This fetches the repository securely into `/tmp`, passes your arguments into `install.sh`, and cleans up without leaving extraneous files behind.

```bash
# Install globally
curl -fsSL https://raw.githubusercontent.com/anhnt/agents_skills_builder/main/setup.sh | bash -s -- --user
```

### Local Checkout Installation
```bash
# Install into a project
./install.sh --project ~/your-project --template python-fastapi

# Install globally
./install.sh --user

# Preview without changes
./install.sh --project ~/your-project --dry-run
```

## Verification Results

## Verification Results

- ✅ All 19 SKILL.md files have valid YAML frontmatter matching their directory names
- ✅ Comprehensive Command Safety rules added to templates and operational skills
- ✅ Helper scripts output structured JSON and are non-interactive
- ✅ Installer supports `.vscode/mcp.json` and `.cursor/mcp.json` configs
- ✅ `project-context.sh` detects 12+ framework/tool patterns (FastAPI, NextJS, Terraform, pytest, etc.)
- ✅ 100% compliant with standard Agent Skills framework specification
