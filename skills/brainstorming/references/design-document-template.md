# Design Document Template

Use this template when saving brainstorming results. Adapt sections as needed for your project.

---

```markdown
# [Feature Name] — Design Document

**Date:** YYYY-MM-DD
**Author:** [Name or "AI-assisted"]
**Status:** Draft | Under Review | Approved

## Problem

[1-2 sentences describing the problem this feature solves. Be specific about user pain points.]

## Context

- **Tech stack:** [Key technologies]
- **Timeline:** [Deadline or timebox]
- **Team:** [Who's involved]
- **Existing systems:** [What this must integrate with]

## Approaches Considered

### Approach 1: [Name]
**Description:** [Brief explanation]
**Pros:**
- ...
**Cons:**
- ...
**Effort:** [Small/Medium/Large]

### Approach 2: [Name]
**Description:** [Brief explanation]
**Pros:**
- ...
**Cons:**
- ...
**Effort:** [Small/Medium/Large]

### Approach 3: [Name]
**Description:** [Brief explanation]
**Pros:**
- ...
**Cons:**
- ...
**Effort:** [Small/Medium/Large]

## Decision Matrix

| Criterion | Approach 1 | Approach 2 | Approach 3 |
|-----------|-----------|-----------|-----------|
| Simplicity | ★★★ | ★★ | ★ |
| Maintainability | ★★ | ★★★ | ★★ |
| Time-to-delivery | ★★★ | ★ | ★★ |
| Extensibility | ★ | ★★ | ★★★ |

## Selected Approach

**[Approach N]** — [One sentence rationale]

### Key Decisions
- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]

### Accepted Trade-offs
- [Trade-off 1]: [Why it's acceptable]

## Open Questions
- [ ] [Question 1 — needs investigation]
- [ ] [Question 2 — needs stakeholder input]

## Next Steps
1. Use `requirements-specifier` to create detailed requirements
2. Use `code-planner` to create an implementation plan
3. [Spike/POC if needed for unknowns]
```

## Tips

- Keep the problem statement short — 1-2 sentences max
- Be honest about trade-offs — every approach has downsides
- The decision matrix helps stakeholders see why you chose the approach
- Open questions are valuable — they highlight risks early
- Don't over-document — this is a decision document, not a novel