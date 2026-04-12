---
name: executing-plans
description: Use when executing an implementation plan task-by-task with review checkpoints. Triggers on phrases like "execute the plan", "implement the plan", "run through the tasks", or when a written plan exists and needs to be carried out step by step.
---

# Executing Plans

Execute implementation plans task-by-task with review checkpoints between batches.

## When to Use

- A written implementation plan exists (from `writing-plans` or `code-planner`)
- User asks to execute, implement, or carry out a plan
- You need to work through tasks sequentially with verification at each step

## ⚠️ Command Safety

This skill involves writing code and running commands. Always confirm before:
- Running destructive commands (`rm`, `DROP`, `force push`)
- Modifying production configuration
- Committing to protected branches

## Execution Process

### 1. Load the Plan

Read the plan document fully before starting. Understand:
- The goal and architecture
- Total number of tasks
- Dependencies between tasks
- Verification steps for each task

### 2. Execute Task by Task

For each task in order:

1. **Read the task** — Understand exactly what to do
2. **Execute the Do steps** — Make the specified changes
3. **Run the Verify steps** — Confirm the changes work
4. **Commit** — Use the commit message from the plan

If verification fails:
- Fix the issue
- Re-verify
- Only commit when verification passes

### 3. Review Checkpoints

After every 2-3 tasks (or at logical breakpoints):

- **Pause and review** — Are we on track? Does the current state match the plan?
- **Run full test suite** — Catch integration issues early
- **Check for drift** — Have we deviated from the plan? If so, document why

### 4. Handle Deviations

Plans are guides, not straitjackets. When reality differs from the plan:

- **Minor deviation** — Adjust and continue. Note the change in a comment.
- **Major deviation** — Stop. Discuss with the user. Update the plan before continuing.
- **Blocked** — Stop. Report what's blocking and suggest options.

### 5. Final Verification

After all tasks are complete:

- Run the full test suite
- Verify all acceptance criteria from the original requirements
- Check for linting and type errors
- Review the complete diff

## Task Execution Rules

- **One task at a time** — Don't skip ahead or combine tasks
- **Verify before committing** — Never commit broken code
- **Commit messages match the plan** — Use the exact commit message from the plan
- **If a task is unclear** — Re-read the plan. If still unclear, ask for clarification rather than guessing.
- **If a task is too large** — Split it into smaller steps, but keep the original task number (e.g., "Task 3a", "Task 3b")

## Anti-Patterns

- **Skipping verification** — "It should work" is not verification. Run the tests.
- **Batching commits** — Each task gets its own commit, not one giant commit at the end
- **Silent deviations** — If you deviate from the plan, document it
- **Skipping tasks** — If a task seems unnecessary, discuss with the user first
- **Rushing** — Speed comes from clarity, not from skipping steps

## Integration

- **Before this skill:** Use `writing-plans` to create the plan
- **After this skill:** Use `code-review` to review the completed implementation
- **REQUIRED SUB-SKILL:** `writing-plans` — you need a plan before you can execute one
- **Complementary skills:** `git-workflow` for branch management, `test-writer` for writing tests