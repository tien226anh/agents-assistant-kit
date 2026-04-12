---
name: git-workflow
description: Use when managing git operations including branching, commits, merges, pull requests, worktrees, and conflict resolution. Covers conventional commits, branch naming, and PR preparation.
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

## Git Worktrees (Isolated Workspaces)

Use git worktrees when you need to work on multiple branches simultaneously without stashing or cloning.

### When to use worktrees
- Switching between features without losing uncommitted work
- Running long tests on one branch while working on another
- Reviewing a PR while keeping your current work intact
- Hotfix production while mid-feature

### Quick reference
```bash
# Create a worktree for a new branch
git worktree add ../feature-auth feature/auth

# Create a worktree for an existing branch
git worktree add ../hotfix-login hotfix/login

# List all worktrees
git worktree list

# Remove a worktree when done
git worktree remove ../feature-auth

# Prune deleted worktree references
git worktree prune
```

See [references/worktrees.md](references/worktrees.md) for detailed patterns and best practices.

## Branch Finishing Workflow

When finishing work on a branch, follow this checklist:

1. **Run all tests** — Ensure nothing is broken
2. **Rebase on main** — Keep history clean
3. **Squash related commits** — Combine WIP commits into meaningful units
4. **Write final commit message** — Follow conventional commits format
5. **Push and create PR** — Include description of changes
6. **Clean up** — Delete the branch after merge

```bash
# 1. Run tests
npm test  # or: pytest, go test, etc.

# 2. Rebase on main
git fetch origin
git rebase origin/main

# 3. Interactive rebase to squash (optional)
git rebase -i origin/main

# 4. Push
git push origin feature/my-feature --force-with-lease

# 5. After PR is merged, clean up
git checkout main
git pull origin main
git branch -d feature/my-feature
git push origin --delete feature/my-feature  # remote cleanup
```

## Integration

- **Before this skill:** Use `writing-plans` to plan the work before branching
- **After this skill:** Use `code-review` to review changes before merging
- **Complementary skills:** `code-review`, `executing-plans`, `writing-plans`
