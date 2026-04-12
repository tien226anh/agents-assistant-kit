---
name: doc-writer
description: Use when writing structured documentation including technical specs, design docs, decision documents, proposals, RFCs, runbooks, and API documentation. Guides drafting, organizing, and polishing docs.
---

# Documentation Writer

## When to use
Use this skill when asked to write documentation — technical specs, design docs, decision documents, proposals, RFCs, runbooks, API docs, ADRs, or similar structured content.

## Workflow

### Stage 1: Context Gathering

Start by understanding the document:

1. **What type** of document? (spec, proposal, decision doc, runbook, API docs)
2. **Who reads it?** (engineers, managers, external users, future self)
3. **What impact** should it have? (get approval, share knowledge, guide implementation)
4. **Any template** to follow? (company standard, specific format)
5. **Any constraints?** (length, deadline, formality level)

Then ask the user to dump all context — background, decisions, alternatives considered, constraints. They can be messy — organization comes later.

### Stage 2: Structure + Draft

Based on the document type, propose a structure:

**Technical Spec / Design Doc:**
```markdown
# Title
## Context / Problem Statement
## Goals & Non-Goals
## Proposed Solution
## Alternatives Considered
## Technical Details
## Migration / Rollout Plan
## Open Questions
```

**Decision Doc / ADR:**
```markdown
# Decision: [Title]
## Status: [Proposed | Accepted | Deprecated]
## Context
## Decision
## Consequences
## Alternatives Considered
```

**Proposal / RFC:**
```markdown
# RFC: [Title]
## Summary
## Motivation
## Detailed Design
## Drawbacks
## Alternatives
## Unresolved Questions
```

**Runbook:**
```markdown
# [System/Process] Runbook
## Overview
## Prerequisites
## Common Operations
## Troubleshooting
## Escalation
```

**API Documentation:**
```markdown
# API: [Name]
## Authentication
## Endpoints
### GET /resource
### POST /resource
## Error Codes
## Rate Limits
## Examples
```

Draft each section iteratively:
1. Ask clarifying questions about the section
2. Draft the content
3. Get user feedback
4. Refine with surgical edits (don't rewrite the whole doc)

### Stage 3: Quality Check

After all sections are drafted:

```
- [ ] Every claim has supporting evidence or reasoning
- [ ] No jargon is used without explanation (for the target audience)
- [ ] Alternatives considered section exists (for decisions/proposals)
- [ ] No assumptions left unstated
- [ ] Consistent terminology throughout
- [ ] Diagrams or examples where helpful
- [ ] Action items or next steps are clear
```

## Writing Principles

1. **Lead with the conclusion.** Put the most important information first. Busy readers may only read the first section.
2. **Use concrete examples.** "This API returns user data" → "This API returns `{ id, name, email, created_at }`"
3. **Be specific about trade-offs.** Don't just list pros — explain what you're giving up.
4. **Cut ruthlessly.** If a sentence doesn't add information, remove it.
5. **Use formatting.** Tables for comparisons, code blocks for examples, callouts for warnings.
6. **One idea per paragraph.** Short paragraphs are easier to scan.

## Gotchas

- **Don't write the conclusion first.** Gather context → structure → draft → refine. Jumping to the conclusion leads to rationalization, not good analysis.
- **Audience matters more than completeness.** A doc for senior engineers can skip basics. A doc for new hires can't.
- **Living docs need owners.** Note who maintains the doc and when to update it.
- **Don't bury the lede.** If a design doc's key insight is on page 5, restructure.

## Integration

- **Before this skill:** requirements-specifier
- **After this skill:** code-review
- **Complementary skills:** brainstorming
