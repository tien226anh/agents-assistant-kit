This project uses the Agent Skills framework.

## Agent Guidance
Please refer to the `AGENTS.md` file in the repository root for:
- Setup commands (install, build, test, lint)
- Code style conventions
- Testing instructions
- Architecture notes and gotchas

## Available Skills
Check the `.agents/skills/` directory for specialized skills that provide detailed instructions for specific tasks (code review, requirements specification, code planning, debugging, testing, git workflow, refactoring). Use these structured workflows when performing associated tasks.

**IMPORTANT: Transparency Rule**
Whenever you act upon a user's request, you MUST explicitly state which skill(s) from `.agents/skills/` you are utilizing at the very beginning of your response. (e.g., "🛠️ *Skill Activated: code-review*"). Wait to read the skill document before executing.
