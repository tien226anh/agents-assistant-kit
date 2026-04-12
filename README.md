# 🛠️ Agent Skills Builder

A curated framework of **Agent Skills** and **AGENTS.md** templates that supercharge your IDE's AI coding agent. Works with GitHub Copilot, Claude Code, Codex, Cursor, Windsurf, Zed, and any agent that supports the open [Agent Skills](https://agentskills.io/) and [AGENTS.md](https://agents.md/) standards.

**No runtime. No CLI. Just files.** Drop them into your project and your IDE agent becomes a better coding assistant.

---

## ✨ What's Included

### Built-in Skills (`.agents/skills/`)

| Skill | Activates When You Ask To... |
|-------|------------------------------|
| **code-review** | Review code, check a PR, audit changes |
| **git-workflow** | Work with git: branch, commit, merge, PR |
| **debug-assistant** | Debug a bug, investigate an error, fix unexpected behavior |
| **test-writer** | Write tests, add coverage, create test cases |
| **refactor** | Refactor, clean up, restructure, or improve code |
| **build-mcp-server** | Build MCP servers, add MCP tools/resources, configure MCP clients |
| **python-expert** | Python development: setup, packaging, testing, typing, frameworks, async, debugging |
| **architect-onprem** | On-premise architecture: servers, networking, storage, k8s, CI/CD, HA, DR, security |
| **architect-cloud** | Multi-cloud architecture (AWS/GCP/Azure): compute, IaC, serverless, cost, security |
| **nodejs-expert** | Node.js/TypeScript development: setup, pnpm, vitest, ESLint, frameworks, async, debugging |
| **troubleshoot-infra** | Infrastructure troubleshooting: networking, DNS, TLS, Docker, Kubernetes, databases |
| **devops** | DevOps: Docker, CI/CD (GitHub Actions/GitLab), Kubernetes ops, GitOps, monitoring |
| **skill-creator** | Create, edit, and improve Agent Skills for this framework |
| **frontend-design** | Build distinctive, production-grade frontend interfaces and web UI |
| **webapp-testing** | Test web applications with Playwright: screenshots, E2E tests, browser automation |
| **doc-writer** | Write structured documentation: specs, ADRs, proposals, RFCs, runbooks, API docs |
| **use-skill** | Discover, evaluate, and activate other installed Agent Skills |
| **skill-orchestrator** | Orchestrate and route requests to the best installed Agent Skill |

### AGENTS.md Templates

Pre-built project guidance files for different tech stacks:
- **General** — works for any project
- **Python / FastAPI** — uv, pytest, ruff, mypy, alembic
- **Node / TypeScript** — pnpm, vitest, eslint, strict TS

### Cross-IDE Compatibility

The installer creates compatibility files for IDE-specific formats:
- `.agents/skills/` — Standard Agent Skills directory
- `.github/copilot-instructions.md` — GitHub Copilot
- `.cursor/rules.md` — Cursor
- `.vscode/mcp.json` — VS Code MCP server config
- `.cursor/mcp.json` — Cursor MCP server config

---

## 🚀 Quick Start

### NPM / Node.js
If you have `npx` installed, you can execute the installer directly from GitHub. This proxies the arguments directly.
```bash
# General setup
npx github:tien226anh/agents-assistant-kit --project ./my-project

# Target a specific IDE to avoid generating extra configs
npx github:tien226anh/agents-assistant-kit --project ./my-project --agent cursor,windsurf

# Force overwrite of all IDE configuration profiles in a repository
npx github:tien226anh/agents-assistant-kit --project ./my-project --reinstall
```

### Python / Pipx
If you use `pipx`, you can run the CLI mapping securely from GitHub.
```bash
pipx run git+https://github.com/tien226anh/agents-assistant-kit.git --project ./my-project
```

### One-Line Remote Installation (cURL)
You can securely download and run the installer directly from GitHub without cloning the repo:

```bash
# Global user install (Available to all your projects)
curl -fsSL https://raw.githubusercontent.com/tien226anh/agents-assistant-kit/main/setup.sh | bash -s -- --user
```

### Clone & Install

If you prefer to clone the repository first:

```bash
git clone https://github.com/tien226anh/agents-assistant-kit.git
cd agents-assistant-kit

# Install skills + AGENTS.md template into your project
./install.sh --project ~/my-project

# Or install with a specific AGENTS.md template
./install.sh --project ~/my-project --template python-fastapi
```

### Install globally (all projects)

```bash
# Install skills to ~/.agents/skills/ (available everywhere)
./install.sh --user
```

### Manual installation

If you don't want to run scripts, you can just manually copy the raw files:

```bash
# Copy skills into your project
cp -r skills/ ~/my-project/.agents/skills/

# Copy an AGENTS.md template
cp agents-md-templates/general.md ~/my-project/AGENTS.md
```

---

## 📖 How It Works

```
1. You install skills into your project (or globally to ~/.agents/skills/)

2. You open your project in VS Code, Cursor, or any supported IDE

3. The IDE agent scans .agents/skills/ and discovers available skills
   (It reads only the name + description — lightweight)

4. You ask: "Review the changes in my last commit"
   → Agent matches your request to the code-review skill
   → Agent loads the full SKILL.md instructions
   → Agent follows the structured review process
   → You get a thorough, consistent code review

5. You ask: "Write tests for the auth module"
   → Agent matches → test-writer skill activates
   → Agent reads your source code and test patterns
   → Agent creates well-structured tests
```

This is **progressive disclosure** — skills start cheap (just a name + description in memory) and only load full instructions when activated.

---

## 🔧 Creating Custom Skills

Create a new directory under `skills/` with a `SKILL.md` file:

```
skills/my-skill/
├── SKILL.md              # Required
├── scripts/              # Optional: executable code
├── references/           # Optional: detailed docs
└── assets/               # Optional: templates, resources
```

**SKILL.md format:**

```markdown
---
name: my-skill
description: A clear description of what this skill does and when to use it. Include keywords that help the agent match user requests.
---

# My Skill

## When to use
Use this skill when...

## Instructions
1. Step one...
2. Step two...

## Gotchas
- Watch out for...
```

See the [Agent Skills Specification](https://agentskills.io/specification) for the full format reference.

---

## 🔌 MCP Support

This framework includes full [Model Context Protocol](https://modelcontextprotocol.io/) support:

- **`build-mcp-server` skill** — Teaches your agent how to create MCP servers (Python/TypeScript), expose tools/resources/prompts, and configure clients
- **MCP config templates** — Pre-built `.vscode/mcp.json` and `.cursor/mcp.json` templates installed by the installer
- **Server catalog** — Curated list of useful MCP servers (filesystem, GitHub, PostgreSQL, etc.) with ready-to-use config snippets

MCP complements Agent Skills: **Skills provide instructions** (how to do things), while **MCP provides live tools** (access to APIs, databases, filesystems).

---

## 🤝 Compatibility

| IDE / Agent | AGENTS.md | Agent Skills | MCP | Status |
|-------------|-----------|-------------|-----|--------|
| GitHub Copilot (Agent mode) | ✅ | ✅ | ✅ | Full support |
| Claude Code | ✅ | ✅ | ✅ | Full support |
| Claude Desktop | — | — | ✅ | MCP only |
| ChatGPT | — | — | ✅ | MCP only |
| OpenAI Codex | ✅ | — | — | AGENTS.md only |
| Cursor | ✅ | ✅ | ✅ | Full support |
| Windsurf | ✅ | ✅ | ✅ | Full support |
| Zed | ✅ | — | — | AGENTS.md only |
| Warp | ✅ | — | — | AGENTS.md only |
| Aider | ✅ | — | — | AGENTS.md only |

---

## 📚 References

- [Agent Skills Specification](https://agentskills.io/specification)
- [AGENTS.md Standard](https://agents.md/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Agent Skills Best Practices](https://agentskills.io/skill-creation/best-practices)
- [MCP Server Registry](https://modelcontextprotocol.io/registry/about)

---

## License

MIT
