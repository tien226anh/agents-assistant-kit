---
name: code-review
description: Use when reviewing code changes, auditing pull requests, or checking diffs for issues. Performs two-stage review (spec compliance then code quality) with structured feedback. Include keywords: review, PR, pull request, diff, audit, code quality, feedback.
---

# Code Review

## When to use
Use this skill when asked to review code, check a pull request, audit recent changes, or evaluate code quality.

## Workflow

1. **Gather the changes**
   ```bash
   # Unstaged changes
   git diff

   # Staged changes
   git diff --cached

   # Last commit
   git diff HEAD~1

   # Specific PR branch vs main
   git diff main..HEAD
   ```

2. **Understand the context**
   - Read the changed files in full to understand the surrounding code
   - Check related test files to understand expected behavior
   - Look at commit messages for intent

3. **Review systematically** — check each category in order:

   **🔒 Security**
   - SQL injection, XSS, command injection
   - Hardcoded secrets or credentials
   - Missing authentication/authorization checks
   - Unsanitized user input

   **🐛 Correctness**
   - Logic errors, off-by-one, null/undefined handling
   - Race conditions in concurrent code
   - Missing error handling or swallowed exceptions
   - Edge cases: empty inputs, boundary values, unicode

   **🏗️ Design**
   - Single responsibility — does each function do one thing?
   - Unnecessary coupling between modules
   - Code duplication that should be extracted
   - Public API surface — is it minimal and clear?

   **⚡ Performance**
   - N+1 queries in database operations
   - Missing indexes for filtered/sorted queries
   - Unnecessary allocations in hot paths
   - Missing pagination for large result sets

   **📖 Readability**
   - Unclear variable/function names
   - Missing or misleading comments
   - Overly complex expressions that should be broken up
   - Consistent formatting and conventions

4. **Provide structured feedback** using this format:

   ```markdown
   ## Code Review Summary

   **Files reviewed**: [list]
   **Overall**: [approve / request changes / needs discussion]

   ### Critical Issues
   - [file:line] Description of issue and suggested fix

   ### Suggestions
   - [file:line] Description of improvement

   ### Positive Notes
   - What was done well
   ```

## Two-Stage Review (for significant changes)

For PRs with 100+ lines changed or architectural impact, use a two-stage review:

### Stage 1: Spec Compliance Review

Before evaluating code quality, verify the implementation matches what was requested:

1. **Read the spec/requirements** — What was supposed to be built?
2. **Compare actual code to requirements** — Line by line
3. **Check for missing pieces** — Were all requirements implemented?
4. **Check for extra features** — Was anything added that wasn't requested?
5. **Report findings** — "Spec compliant ✅" or list deviations

See [references/spec-reviewer-prompt.md](references/spec-reviewer-prompt.md) for the full prompt template.

### Stage 2: Code Quality Review

After confirming spec compliance, evaluate code quality:

1. **Security** → **Correctness** → **Design** → **Performance** → **Readability**
2. **Categorize issues** — Critical (must fix), Important (should fix), Suggestions (nice to have)
3. **Provide actionable fixes** — Not just "this is wrong" but "here's how to fix it"

See [references/code-quality-reviewer-prompt.md](references/code-quality-reviewer-prompt.md) for the full prompt template.

## Gotchas
- Don't flag style issues that a linter/formatter should handle — focus on logic and design.
- When reviewing database migrations, check for both forward AND rollback safety.
- For API changes, check backward compatibility with existing clients.
- Always check if tests were updated to match the code changes.
- For large PRs, prioritize critical issues over minor suggestions.
- Never trust the implementer's self-report — verify independently.

For a detailed review checklist, see [references/checklist.md](references/checklist.md).

## Integration

- **Before this skill:** Use `writing-plans` or `code-planner` to plan the implementation
- **After this skill:** Use `executing-plans` to implement review feedback
- **Complementary skills:** `executing-plans`, `writing-plans`, `code-planner`
