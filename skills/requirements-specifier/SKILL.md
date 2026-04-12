---
name: requirements-specifier
description: Use when extracting user intent into structured requirements, PRDs (Product Requirements Docs), user stories, and acceptance criteria. Clarifies ambiguities before writing code.
---

# Requirements Specifier Workflow

## When to use
Use this skill when the user provides a high-level idea, "I want to build X," or asks you to help specify a new feature, epic, or project. Focus entirely on extraction, edge cases, and documentation before any implementation details.

## Specification Process

### 1. Intent Extraction
When the user proposes a feature, do not start writing code or database schemas. Instead, ask probing questions to define the boundaries:
- **Scope:** What are the exact use cases? What is explicitly out of scope?
- **Users:** Who interacts with this? (Admins, anonymous users, external APIs?)
- **Constraints:** Are there performance, security, or platform-specific limitations?

### 2. Edge Case Identification
Proactively suggest edge cases the user might missed:
- "What happens if the network disconnects halfway through?"
- "How do we handle duplicate submissions?"
- "What if the user has no historical data?"

### 3. Draft the Specification
Once the boundaries are clear, draft a structured specification document (often saved as an artifact or `requirements.md`):

```markdown
# [Feature Name] Requirements

## 1. Overview
(1-2 sentence summary of the feature's value proposition)

## 2. In Scope
- (Feature 1)
- (Feature 2)

## 3. Out of Scope
- (Explicitly excluded features to prevent scope creep)

## 4. User Stories & Acceptance Criteria
**As a** [user type], **I want to** [action], **so that** [value].
- [ ] Scenario 1: Given [context], When [action], Then [measurable outcome]
- [ ] Scenario 2: (Error handling)

## 5. Non-Functional Requirements
- Security (e.g., rate limiting)
- Performance (e.g., latency < 200ms)
- Data retention
```

## Anti-Patterns
- **Do not design the database or architecture:** Focus strictly on *what* the system should do, not *how* it should be built. Leave the *how* to the `code-planner` or `architect` skills.
- **Do not assume defaults:** Always clarify standard behaviors (like pagination limits or timezone handling) with the user.

## Integration

- **Before this skill:** brainstorming
- **After this skill:** writing-plans, code-planner
- **Complementary skills:** doc-writer
