# Code Quality Reviewer Prompt Template

Use this template when performing a code quality review — evaluating the quality of the implementation after spec compliance is confirmed. This is Stage 2 of the two-stage review process.

## Purpose

Evaluate code quality: security, correctness, design, performance, and readability. This runs AFTER the spec compliance review confirms the implementation matches requirements.

## Review Categories

### 🔒 Security (Must Fix)

- SQL injection, XSS, command injection
- Hardcoded secrets or credentials
- Missing authentication/authorization checks
- Unsanitized user input
- Insecure dependencies

### 🐛 Correctness (Must Fix)

- Logic errors, off-by-one errors
- Null/undefined handling
- Race conditions in concurrent code
- Missing error handling or swallowed exceptions
- Edge cases: empty inputs, boundary values, unicode

### 🏗️ Design (Should Fix)

- Single responsibility violations
- Unnecessary coupling between modules
- Code duplication that should be extracted
- Overly broad public API surface
- Missing abstractions for complex logic

### ⚡ Performance (Should Fix)

- N+1 queries in database operations
- Missing indexes for filtered/sorted queries
- Unnecessary allocations in hot paths
- Missing pagination for large result sets
- Synchronous operations that should be async

### 📖 Readability (Nice to Have)

- Unclear variable/function names
- Missing or misleading comments
- Overly complex expressions
- Inconsistent formatting

## Report Format

```markdown
## Code Quality Review

### Strengths
- [What was done well — always acknowledge good work first]

### Critical Issues (Must Fix)
1. **[Issue title]**
   - File: [file:line]
   - Issue: [description]
   - Fix: [suggested fix]

### Important Issues (Should Fix)
1. **[Issue title]**
   - File: [file:line]
   - Issue: [description]
   - Fix: [suggested fix]

### Suggestions (Nice to Have)
1. **[Suggestion title]**
   - File: [file:line]
   - Suggestion: [description]

### Assessment
- **Ready to merge**: ✅ Yes / ❌ No
- **Required changes**: [number of critical + important issues]
```

## Key Principles

- **Always acknowledge what was done well first.** Reviews should be constructive, not just critical.
- **Categorize issues by severity.** Don't mix critical bugs with style suggestions.
- **Provide actionable fixes.** Not just "this is wrong" but "here's how to fix it."
- **Be specific.** Include file paths and line numbers.
- **Consider scalability.** Will this code work at 10x or 100x scale?
- **Check for missing tests.** Every behavior change should have a corresponding test.