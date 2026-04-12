---
name: brainstorming
description: Use when starting a new feature, exploring design options, or refining a rough idea before implementation. Triggers on phrases like "I want to build", "how should we design", "let's brainstorm", or when requirements are vague and need structured exploration before planning.
---

# Brainstorming

Structured ideation and design refinement through Socratic exploration.

## When to Use

- User describes a feature with vague or incomplete requirements
- Starting a new project or major feature that needs design thinking
- Multiple possible approaches exist and the best path isn't clear
- Before jumping to `requirements-specifier` or `code-planner`

## ⚠️ Command Safety

Read-only exploration. No code changes during brainstorming.

## Process

### Phase 1: Explore (5-10 minutes)

Gather context and expand the solution space:

1. **Understand the goal** — What problem does this solve? Who uses it? What does success look like?
2. **Identify constraints** — Time, budget, tech stack, team skills, existing systems
3. **Enumerate approaches** — List at least 3 different ways to solve the problem
4. **Ask clarifying questions** — Use structured questions to fill gaps:
   - "What happens when [edge case]?"
   - "How does this interact with [existing system]?"
   - "What's the priority: speed, cost, or flexibility?"

### Phase 2: Narrow (5-10 minutes)

Converge on the best approach:

1. **Evaluate each approach** against constraints and goals
2. **Identify trade-offs** — Every approach has costs; make them explicit
3. **Rank approaches** — Score on: simplicity, maintainability, time-to-delivery, extensibility
4. **Select the leading approach** — State why it wins and what trade-offs you're accepting

### Phase 3: Validate (5 minutes)

Confirm the chosen direction before investing in detailed planning:

1. **Walk through a happy path** — Can the approach handle the core use case?
2. **Walk through an edge case** — Does it break under stress?
3. **Check for unknowns** — Are there technical risks that need spike/exploration?
4. **Get explicit confirmation** — Present the approach and ask: "Should I proceed with this direction?"

## Output Format

Save the brainstorming result as a design document:

```markdown
# [Feature Name] — Design Document

**Date:** [ISO date]
**Status:** Draft / Approved

## Problem
[1-2 sentences describing what we're solving]

## Approaches Considered
| # | Approach | Pros | Cons | Score |
|---|----------|------|------|-------|
| 1 | ... | ... | ... | ... |
| 2 | ... | ... | ... | ... |
| 3 | ... | ... | ... | ... |

## Selected Approach
[Which approach and why]

## Key Decisions
- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]

## Open Questions
- [ ] [Question 1]
- [ ] [Question 2]

## Next Steps
→ Use `requirements-specifier` to create detailed requirements
→ Use `code-planner` to create an implementation plan
```

## Anti-Patterns

- **Jumping to implementation** — If you haven't explored at least 3 approaches, you're skipping brainstorming
- **Analysis paralysis** — Set a timebox. Better to decide and adjust than deliberate forever
- **Confirming the first idea** — The first approach is rarely the best. Force yourself to consider alternatives
- **Skipping validation** — Always walk through at least one edge case before committing

## Integration

- **Before this skill:** User has a rough idea or vague requirement
- **After this skill:** Use `requirements-specifier` to formalize requirements, then `code-planner` to create an implementation plan
- **Complementary skills:** `requirements-specifier`, `code-planner`