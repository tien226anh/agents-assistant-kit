# AGENTS.md

<!-- This is a template — customize the sections below for your project. -->
<!-- Delete these HTML comments when you're done. -->

## Project Overview
<!-- Describe your project in 1-2 sentences -->

## Command Safety
**Read-only commands only.** Agents must NEVER run commands that mutate state, delete data, modify infrastructure, or have destructive side-effects without explicit user approval.
- ✅ Allowed: `git status`, `git diff`, `cat`, `ls`, `find`, `grep`, test runners, linters, type checkers, read-only queries
- ❌ Forbidden: `rm`, `git push`, `git commit`, `docker rm`, `kubectl delete`, database writes, deploy commands

## Setup Commands
<!-- Add the commands your project uses -->

## Code Style
<!-- Add style guidelines not covered by linters/formatters -->

## Testing Instructions
<!-- How to run tests -->

## Gotchas
<!-- Non-obvious things that would trip up an agent -->
