---
name: code-review
description: Review code changes, audit pull requests, and check diffs for issues. Use when the user asks to review code, check a PR, audit changes, look at a diff, or find problems in modified files.
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

## Gotchas
- Don't flag style issues that a linter/formatter should handle — focus on logic and design.
- When reviewing database migrations, check for both forward AND rollback safety.
- For API changes, check backward compatibility with existing clients.
- Always check if tests were updated to match the code changes.

For a detailed review checklist, see [references/checklist.md](references/checklist.md).
