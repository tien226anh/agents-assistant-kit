# AGENTS.md

## Project Overview
<!-- Describe your project in 1-2 sentences -->

## Command Safety
**Read-only commands only.** Agents must NEVER run commands that mutate state, delete data, modify infrastructure, or have destructive side-effects.

- ✅ **Allowed**: `git status`, `git log`, `git diff`, `cat`, `ls`, `find`, `grep`, test runners, linters, type checkers, `curl` (GET), `kubectl get`, `docker ps`, `terraform plan`
- ❌ **Forbidden**: `rm`, `git push`, `git commit`, `docker rm`, `kubectl delete`, `terraform apply`, `DROP TABLE`, database writes, `curl -X POST/PUT/DELETE`, any deploy or migration command
- When the user explicitly asks to run a mutating command, confirm with the user before executing.

## Setup Commands
<!-- Commands agents should know to build and run your project -->
- Install dependencies: `<your install command>`
- Run dev server: `<your dev command>`
- Run tests: `<your test command>`
- Lint/format: `<your lint command>`

## Code Style
<!-- Conventions that aren't enforced by linters -->
- Use descriptive variable names over abbreviations
- Prefer early returns over deeply nested conditions
- One exported function/class per file when practical
- Keep functions under 30 lines when possible

## Testing Instructions
- Run all tests: `<your test command>`
- Run a single test: `<your single test command>`
- Tests must pass before any PR is merged
- New code should have corresponding tests

## Architecture Notes
<!-- Key decisions that agents should know about -->
<!--
- Database: PostgreSQL with SQLAlchemy ORM
- API: REST with FastAPI
- Auth: JWT-based with refresh tokens
- Background tasks: Celery + Redis
-->

## Gotchas
<!-- Things that are non-obvious and would trip up an agent -->
<!--
- The `users` table uses soft deletes — always filter `deleted_at IS NULL`
- Config is loaded from environment variables, not config files
- The `/health` endpoint doesn't check database connectivity — use `/ready`
-->

## PR Conventions
- Branch naming: `<type>/<description>` (e.g., `feature/add-auth`)
- Commit messages: Conventional Commits format
- Always run lints and tests before committing

## Agent Skills
Check the `.agents/skills/` directory for specialized skills that provide detailed instructions for specific tasks. 

**IMPORTANT: Transparency Rule**
Whenever you act upon a user's request, you MUST explicitly state which skill(s) from `.agents/skills/` you are utilizing at the very beginning of your response. (e.g., "🛠️ *Skill Activated: code-review*"). Wait to read the skill document before executing.
