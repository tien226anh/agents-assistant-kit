---
name: git-workflow
description: Manage git operations including branching, commits, merges, and pull requests. Use when the user asks about git commands, branch strategy, commit messages, resolving conflicts, or preparing a PR.
---

# Git Workflow

## When to use
Use this skill when asked about git operations, branching strategy, writing commit messages, resolving merge conflicts, or preparing pull requests.

## Branch Naming Convention

```
<type>/<ticket-or-short-description>
```

| Type | When |
|------|------|
| `feature/` | New feature or enhancement |
| `fix/` | Bug fix |
| `hotfix/` | Urgent production fix |
| `refactor/` | Code restructuring without behavior change |
| `chore/` | Tooling, deps, config changes |
| `docs/` | Documentation only |

Examples: `feature/user-auth`, `fix/login-timeout`, `chore/upgrade-deps`

## Commit Message Format (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **type**: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `ci`, `style`
- **scope**: Optional, the module/component affected
- **subject**: Imperative mood, lowercase, no period. Max 72 chars.
- **body**: Optional. Explain *what* and *why*, not *how*.
- **footer**: Optional. `BREAKING CHANGE:` or issue references.

**Examples:**
```
feat(auth): add JWT refresh token rotation

Tokens now rotate on each refresh to prevent replay attacks.
The old token is invalidated immediately after a new one is issued.

Closes #142
```

```
fix(api): handle null user_id in session lookup

Previously returned 500 when user_id was null.
Now returns 401 with a clear error message.
```

Use `scripts/commit-msg-lint.sh` to validate commit messages:
```bash
bash scripts/commit-msg-lint.sh "feat(auth): add login endpoint"
```

## Workflow

### Starting work
```bash
# Make sure you're up to date
git checkout main
git pull origin main

# Create a feature branch
git checkout -b feature/my-feature
```

### Committing
```bash
# Stage specific files (preferred over git add .)
git add src/auth/login.py tests/test_login.py

# Commit with conventional message
git commit -m "feat(auth): add login endpoint"
```

### Preparing a PR
```bash
# Rebase on latest main to avoid merge conflicts
git fetch origin
git rebase origin/main

# If conflicts arise during rebase:
# 1. Resolve conflicts in each file
# 2. git add <resolved-files>
# 3. git rebase --continue

# Push (force-push after rebase is expected)
git push origin feature/my-feature --force-with-lease
```

### Merging
- Default: **squash merge** to keep main history clean
- Use **merge commit** for large features with meaningful individual commits
- **Never** force-push to `main` or shared branches

## Gotchas
- Always use `--force-with-lease` instead of `--force` to avoid overwriting others' work.
- Before rebasing, check if anyone else is working on the same branch.
- Don't amend commits that have already been pushed to a shared branch.
- When resolving conflicts, run tests after EVERY conflict resolution, not just at the end.
