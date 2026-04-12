# CSO: Claude Search Optimization Best Practices

Optimizing skill descriptions for maximum discoverability by AI agents.

## Why CSO Matters

When an agent has 20+ skills available, it uses the `description` field to decide which skill to activate. The description is the **primary discovery mechanism** — if it doesn't match the user's request, the skill won't fire.

Think of CSO like SEO for skills: you want your skill to appear for the right queries.

## The Description Formula

Every description should follow this pattern:

```
Use when [triggering conditions]. Include keywords: [adjacent terms].
```

### Breaking it down:

1. **"Use when"** — Signals this is a trigger condition, not a summary
2. **[Triggering conditions]** — Specific situations where this skill applies
3. **[Adjacent terms]** — Alternative words users might use

## Before and After Examples

### Example 1: Debug Skill

❌ **Bad:** "Helps with debugging"
- Too vague
- No specific triggers
- No adjacent terms

✅ **Good:** "Use when the user reports a bug, encounters an error, sees unexpected output, or needs help troubleshooting an issue. Include keywords: debug, error, bug, crash, fix, investigate, trace, stack trace, exception."

### Example 2: Code Review Skill

❌ **Bad:** "Code review skill for reviewing code"
- Redundant
- No alternative terms
- No specific contexts

✅ **Good:** "Use when the user asks to review code, check a PR, audit changes, look at a diff, or find problems in modified files. Include keywords: review, PR, pull request, diff, audit, code quality, feedback."

### Example 3: Python Skill

❌ **Bad:** "Python development assistance"
- Doesn't say when to trigger
- No specific contexts

✅ **Good:** "Use when the user is working on a Python project, setting up Python tooling, writing Python code, or asking about Python best practices. Include keywords: Python, pip, pytest, FastAPI, Django, Flask, virtualenv, venv, requirements.txt, pyproject.toml."

## Keyword Strategy

### Include These Types of Keywords:

1. **Direct terms** — The exact words users will say
   - "debug", "test", "review", "deploy"

2. **Synonyms** — Alternative words for the same concept
   - "bug" ↔ "error" ↔ "issue" ↔ "problem"

3. **Tool names** — Specific tools the skill covers
   - "pytest", "vitest", "Docker", "Kubernetes"

4. **File names** — Files users might mention
   - "Dockerfile", "pyproject.toml", "package.json"

5. **Error patterns** — Symptoms users describe
   - "stack trace", "unexpected output", "not working"

### Don't Include:

- **Workflow descriptions** — "This skill walks you through 5 steps..." (belongs in the body)
- **Internal jargon** — Terms only the skill author would use
- **Marketing language** — "The ultimate debugging solution"

## Description Length

- **Target:** Under 500 characters
- **Maximum:** 1024 characters (spec limit)
- **Sweet spot:** 200-400 characters — enough for triggers and keywords, short enough to scan quickly

## Testing Your Description

After writing a description, test it against these scenarios:

1. **Direct match:** User says "debug this error" → Does your description contain "debug" or "error"?
2. **Synonym match:** User says "investigate this crash" → Does your description contain "investigate" or "crash"?
3. **Context match:** User says "my Python tests are failing" → Does your description contain "Python" and "test"?
4. **No false positives:** User says "deploy to production" → Does your debugging skill NOT activate?

## Common Mistakes

| Mistake | Why It Fails | Fix |
|---------|-------------|-----|
| "I can help with..." | First person breaks discovery | Use "Use when..." |
| "This skill does X, Y, Z" | Summarizes workflow, not triggers | Describe when to use, not what it does |
| "Python help" | Too vague, no triggers | Add specific contexts and keywords |
| 800+ character description | Too long, dilutes key terms | Trim to 200-400 characters |
| No adjacent terms | Misses users who use different words | Add synonyms and tool names |
| Summarizing the process | Description is for discovery, not instruction | Move workflow to SKILL.md body |