# Agent Skills Builder: Project Overview

## Context / Purpose
The **Agent Skills Builder** is a file-based framework designed to supercharge IDE-native AI coding agents (e.g., GitHub Copilot, Claude Code, Cursor, Windsurf). It provides a curated set of structured **Agent Skills** and **AGENTS.md** templates. By dropping these files into a project, agents acquire advanced, specialized capabilities—from reviewing code and managing Git workflows to architecting complex cloud deployments—without requiring a runtime or additional CLI tool.

The framework adheres to the open [Agent Skills](https://agentskills.io/) and [AGENTS.md](https://agents.md/) standards.

## Project Structure
The repository handles skills content separately from templates and installation logic:
- `skills/`: The core database of capabilities. Each sub-folder contains a spec-compliant `SKILL.md` file.
- `agents-md-templates/`: Pre-constructed `AGENTS.md` files serving as project guidelines for various core tech stacks (e.g., general, Python/FastAPI, Node/TypeScript).
- `project-template/`: Drop-in boilerplate that makes embedding Agent Skills into new repositories easy.
- `scripts/`: Reusable, shared helper scripts (like `analyze-diff.sh` and `find-tests.sh`) leveraged by different skills when executing tasks.
- `install.sh`: A shell-based installer that maps and deploys skills for local (`--project`) or global (`--user`) use. It also provisions IDE compatibility mappings.

## Core Mechanisms

### Progressive Disclosure
To prevent overflowing an agent's context window, the system uses progressive disclosure. Upon IDE launch, the agent reads only the YAML frontmatter (`name` and `description`) of the skills. The complete markdown instructions located in `SKILL.md` are fetched into context solely when a user's prompt triggers the specific skill. 

### Supported Runtimes & Cross-IDE Tooling
This framework can be installed via POSIX bash (`install.sh`), NPM (`npx github:tien226anh/agents-assistant-kit`), or Python (`pipx`). 

During installation, IDE-specific profiles are established so the framework is natively recognized by different editors:
- `.agents/skills/` (Standard Agent Skills protocol)
- `.github/copilot-instructions.md` (GitHub Copilot Agent mode)
- `.cursor/rules.md` (Cursor IDE)
- `.vscode/mcp.json` and `.cursor/mcp.json` (MCP environment configuration mappings)

## Supported Skill Ecosystem
The framework spans a wide variety of development roles:
- **Architect & Expert Guidance:** `architect-cloud`, `architect-onprem`, `nodejs-expert`, `python-expert`, `frontend-design`.
- **Code & Refactor:** `code-planner`, `refactor`, `skill-creator`.
- **Testing & Review:** `code-review`, `test-writer`, `webapp-testing`.
- **Debugging & DevOps:** `bug-analyzer`, `debug-assistant`, `devops`, `troubleshoot-infra`.
- **Project Workflows:** `doc-writer`, `git-workflow`, `requirements-specifier`, `use-skill`.

## Customization & Extensibility
Developers can build proprietary skills by:
1. Creating a folder inside `skills/` (e.g., `skills/my-new-skill/`).
2. Providing a `SKILL.md` file wrapped with valid YAML frontmatter specifying the `name` and `description`.
3. Outlining concise instructions in the markdown body. Optional support directories like `scripts/` or `references/` can be incorporated for advanced workflows.
