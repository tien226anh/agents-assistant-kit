# Git Worktrees — Patterns and Best Practices

## What Are Worktrees?

Git worktrees allow you to have multiple working directories for the same repository, each on a different branch. This lets you work on multiple things simultaneously without stashing or cloning.

## Common Patterns

### Pattern 1: Feature Branch Worktree

Create an isolated workspace for a new feature while keeping main available:

```bash
# From the main repo directory
git worktree add ../feature-auth feature/auth

# Now you have two directories:
# ./ (main branch)
# ../feature-auth (feature/auth branch)

# Work in the feature worktree
cd ../feature-auth
# ... make changes, commit ...

# Return to main when needed
cd ../my-project
```

### Pattern 2: Hotfix Worktree

When you need to fix production while mid-feature:

```bash
# Create a hotfix worktree from main
git worktree add ../hotfix-login -b hotfix/login origin/main

# Fix the issue
cd ../hotfix-login
# ... fix, commit, push ...

# After merge, clean up
cd ../my-project
git worktree remove ../hotfix-login
```

### Pattern 3: PR Review Worktree

Review a PR without disturbing your current work:

```bash
# Fetch the PR branch
git fetch origin pull/42/head:pr-42

# Create a worktree for review
git worktree add ../review-pr-42 pr-42

# Review, test, comment
cd ../review-pr-42
# ... review ...

# Clean up
cd ../my-project
git worktree remove ../review-pr-42
git branch -d pr-42
```

### Pattern 4: Long-Running Test Worktree

Run long tests on one branch while continuing work on another:

```bash
# Create a worktree for testing
git worktree add ../test-branch feature/my-feature

# Run tests in the background
cd ../test-branch
npm test &

# Continue working in main worktree
cd ../my-project
# ... keep coding ...
```

## Best Practices

1. **Use consistent naming** — Place worktrees in a predictable location (e.g., `../worktrees/feature-name`)
2. **Clean up after yourself** — Remove worktrees when the branch is merged
3. **Don't share worktrees** — Each worktree is for one person
4. **Keep worktrees on the same filesystem** — Avoid network drives for performance
5. **Use `git worktree list`** to track what's active

## Worktree Management Script

```bash
#!/bin/bash
# wt.sh — Quick worktree manager

WORKTREE_DIR="../worktrees"

case "$1" in
  add)
    BRANCH="${2:-$(git branch --show-current)}"
    DIR="$WORKTREE_DIR/$(basename "$BRANCH")"
    mkdir -p "$WORKTREE_DIR"
    git worktree add "$DIR" "$BRANCH"
    echo "Worktree created at $DIR"
    ;;
  list)
    git worktree list
    ;;
  remove)
    DIR="$WORKTREE_DIR/${2}"
    git worktree remove "$DIR"
    echo "Worktree removed at $DIR"
    ;;
  prune)
    git worktree prune
    echo "Pruned stale worktree references"
    ;;
  *)
    echo "Usage: wt.sh {add|list|remove|prune} [branch-name]"
    ;;
esac
```

## Gotchas

- **Cannot have the same branch checked out in multiple worktrees.** Git enforces this.
- **Worktrees share the same `.git` directory.** Changes to refs (branches, tags) are visible everywhere.
- **Untracked files are NOT shared.** Each worktree has its own working directory.
- **Be careful with `git clean`** — it only affects the current worktree.
- **Some IDEs** may not handle worktrees well. Consider opening a new window for each worktree.