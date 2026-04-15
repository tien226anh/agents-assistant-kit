# AGENTS.md

<!-- This is a template — customize the sections below for your project. -->
<!-- Delete these HTML comments when you're done. -->

## Project Overview
<!-- Describe your project in 1-2 sentences -->

## Command Safety
**Read-only commands only.** Agents must NEVER run commands that mutate state, delete data, modify infrastructure, or have destructive side-effects without explicit user approval.
- ✅ Allowed: `git status`, `git diff`, `cat`, `ls`, `find`, `grep`, test runners, linters, type checkers, read-only queries
- ❌ Forbidden: `rm -rf`, `git push --force`, `docker rm`, `kubectl delete`, database writes, deploy commands

## Setup Commands
<!-- Add the commands your project uses -->

## Code Style
<!-- Add style guidelines not covered by linters/formatters -->

## Testing Instructions
<!-- How to run tests -->

## Gotchas
<!-- Non-obvious things that would trip up an agent -->

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

## Custom Agents

Custom agents are specialized AI personas defined in `.github/agents/`. They provide structured workflows for complex tasks. In GitHub Copilot Chat, type `@` to see and select available agents.

### Available Custom Agents

| Agent | Type | Activates When You Ask To... |
|-------|------|------------------------------|
| **Brainstorming Agent** | Primary | Brainstorm, ideate, explore design options, refine a rough idea |
| **Requirements Specifier** | Primary | Specify requirements, write PRD, define user stories, acceptance criteria |
| **Code Planner** | Primary | Plan implementation, create step-by-step plans, break down tasks |
| **Context Researcher** | Sub-agent | Gather codebase context, web research, competitor analysis |
| **Approach Evaluator** | Sub-agent | Evaluate approaches, compare options, score alternatives |
| **Design Validator** | Sub-agent | Validate design, walk through edge cases, stress test approach |

### Agent Workflow

1. **Start with Brainstorming** → Explore approaches and validate designs
2. **Move to Requirements** → Formalize user stories and acceptance criteria
3. **Plan with Code Planner** → Break down into bite-sized implementation tasks
4. **Start Implementation** → Hand off to the default coding agent
