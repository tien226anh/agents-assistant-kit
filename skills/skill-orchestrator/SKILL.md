---
name: skill-orchestrator
description: Orchestrate and route user requests to the best installed Agent Skill. Use when the user asks to manage, select, activate, or coordinate other skills and when a meta-level skill choice is required.
---

# Skill Orchestrator

## When to use
Use this skill when the user asks you to:
- choose the right installed skill for a task
- orchestrate multiple skills or hand off a request
- discover whether the workspace already contains a skill for their need
- act as a meta-skill manager for skill activation

This skill is a routing layer, not a domain expert. It should only be used when the user requests skill selection, coordination, or when you need to explain which skill is best.

## ⚠️ Command Safety
Read-only commands only. Do not modify files or run destructive commands without explicit user approval.

## Workflow

### Step 1: Discover installed skills
Look at the local `skills/` directory and load the `SKILL.md` frontmatter for each installed skill.
Do not invent skills or rely on memory from outside the workspace.

### Step 2: Evaluate frontmatter
Read each `description` block to understand what the skill is meant to do.
Use the description and name to match the user's request to the best available capability.

### Step 3: Choose the best skill
If a dedicated skill exists:
- start your response with `🛠️ *Skill Activated: <skill-name>*`
- then execute the selected skill's instructions
If no dedicated skill exists:
- clearly say that there is no exact skill installed
- offer to solve the task directly or to create a new skill with `skill-creator`

### Step 4: Coordinate multi-skill workflows
If the request requires multiple capabilities, propose a short plan that uses specific skills in sequence.
For example:
- use `code-review` to audit code changes
- then use `test-writer` to add coverage
- then use `debug-assistant` if failures remain

### Step 5: Keep the user informed
Explain why you selected the chosen skill and how it matches their request.
If the choice is ambiguous, present 2-3 relevant skills and ask which one they prefer.

## Gotchas
- Never recommend a skill that does not exist in `skills/`.
- Do not ignore the user's request for a specific skill. If they ask to use a named skill, activate it directly.
- Avoid using this skill for normal domain work; prefer domain-specific skills unless the user explicitly requests orchestration.

## Example prompts
- "Pick the best skill for adding tests to this repo."
- "Which skill should I use for writing a new Agent Skill?"
- "Orchestrate a workflow to review and improve this plugin."
- "Find and activate the appropriate skill for debugging this error."
