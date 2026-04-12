# AGENTS.md — Agent Skills Builder

This repository contains a curated framework of Agent Skills and AGENTS.md templates for IDE-native AI coding agents (GitHub Copilot, Claude Code, Codex, Cursor, etc.).

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

## Code Style

- **SKILL.md files**: Must follow the [Agent Skills specification](https://agentskills.io/specification)
  - YAML frontmatter with `name` and `description` (required)
  - `name` must be lowercase, hyphenated, match the parent directory name
  - Body content should be < 5000 tokens
  - Use progressive disclosure: keep SKILL.md concise, put details in `references/`
- **Shell scripts**: POSIX-compatible where possible, bash when needed
  - Must support `--help` flag
  - Must use structured output (JSON preferred)
  - Must be non-interactive (no prompts)
  - Must include error handling with informative messages
- **Markdown**: Use ATX headers (`#`), one sentence per line in body text

## Testing Instructions

- Validate SKILL.md frontmatter: check `---` delimiters and required `name`/`description` fields
- Run shell scripts with `--help` to verify they're self-documenting
- Test install.sh in both `--project` and `--user` modes against a temp directory

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md`
2. Add YAML frontmatter with `name` (matching directory) and `description`
3. Write body instructions (step-by-step, actionable)
4. Add `scripts/`, `references/`, or `assets/` subdirectories as needed
5. Test with an IDE agent to verify discovery and activation
