---
name: code-planner
description: Generate step-by-step implementation plans before writing code. Use when the user asks how to implement a complex feature, needs a refactoring strategy, or wants a phased execution plan across multiple files.
---

# Code Planner Workflow

## When to use
Use this skill to bridge the gap between requirements and execution. When faced with a multi-file feature, a large refactor, or complex integration, generate a phased `implementation_plan.md` instead of generating chaotic, immediate code changes.

## ⚠️ Command Safety
You are in planning mode. **Do not run formatting, linting, or modification scripts.** You may use code search (`grep_search`) and read tools to analyze the repository, but you must not alter the source code during the planning phase.

## Planning Process

### 1. Repository Context Gathering
- Identify the existing architecture (e.g., is this an MVC app, a serverless architecture, a CLI tool?).
- Locate the files that will be affected by the proposed changes.
- Check for existing utility functions or established patterns that should be reused instead of reinvented.

### 2. Phase Breakdown
Break the implementation down into logical, testable phases. Commits should ideally be made after each phase. The structure should generally follow:
1. **Data Layer** (Schema, models, migrations)
2. **Core Logic** (Services, controllers, business logic)
3. **API / Routing** (Endpoints, middleware)
4. **Presentation** (UI components, CLI prompts)
5. **Testing** (Unit/Integration tests)

### 3. Draft the Implementation Plan
Draft the plan formatted specifically for the user to review.

```markdown
# Implementation Plan: [Feature Name]

## Overview
(Brief explanation of the technical approach)

## Phase 1: [Name] (e.g., Data Layer)
- **`[MODIFY]` file/path.ext**: (What exactly changes here?)
- **`[NEW]` file/path.ext**: (Purpose of the new file)

## Phase 2: [Name]
- ...

## Open Questions / Risks
- Highlight areas where the existing codebase might conflict with the plan.
- Warn about potential breaking changes.

## Verification
- How will we know this works? (Tests to write, manual QA steps).
```

## Anti-Patterns
- **Do not write the actual code in the plan:** The plan should contain instructions (e.g., "Add a `validate_email` function"), not the 50 lines of Python code for it.
- **Do not create giant monolithic phases:** If a phase touches more than 5 files, it is too large. Break it down.
