# Copilot Instructions

<!-- This file provides instructions for GitHub Copilot's agent mode. -->
<!-- It references the project's AGENTS.md for conventions and the .agents/skills/ directory for specialized skills. -->

## Agent Guidance

Refer to the project's `AGENTS.md` file in the repository root for:
- Setup commands (install, build, test, lint)
- Code style conventions
- Testing instructions
- Architecture notes and gotchas

## Available Skills

Check the `.agents/skills/` directory for specialized skills that provide detailed instructions for specific tasks (code review, debugging, testing, git workflow, refactoring).

**IMPORTANT: Transparency Rule**
Whenever you act upon a user's request, you MUST explicitly state which skill(s) from `.agents/skills/` you are utilizing at the very beginning of your response. (e.g., "🛠️ *Skill Activated: code-review*"). Wait to read the skill document before executing.
