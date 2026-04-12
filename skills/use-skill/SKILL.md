---
name: use-skill
description: Use when discovering, evaluating, and activating other Agent Skills available in the workspace. Routes to the best skill when the user asks what skills are available, needs help finding a skill, or wants to orchestrate another skill dynamically.
---

# Use Skill

## When to use
Use this skill when the user asks you to:
- "Find a skill for X"
- "List all available skills"
- "What can you do?"
- "Do you have a skill to help me with Y?"

This is a meta-skill designed to help you (the Agent) navigate your own capabilities and explicitly communicate your routing logic to the user.

## Workflow

1. **Discover Available Skills**
   Scan the local `.agents/skills/` directory to discover what is installed.
   *Do not guess skill names. Only work with the directories that physically exist in `.agents/skills/`.*

2. **Evaluate Frontmatter**
   Read the `description` block inside the YAML frontmatter of the various `SKILL.md` files. This will give you the precise trigger parameters and intended use-cases for each capability.

3. **Respond Structure**
   When the user asks you what skills are available or what you can do, format your response cleanly:
   - Provide a bulleted list of 3-5 of the most contextually relevant skills (do not overwhelm them with 20 options unless they ask for all of them).
   - Briefly summarize in 1 sentence what the skill does based on its frontmatter.
   - Present the user with a clear command they can copy/paste to hand-off the task to that skill.

4. **Activation Hand-off**
   If the user asks you to *use* a specific skill, you MUST obey the **Transparency Rule** defined in your system prompt. 
   Immediately begin your response with: `🛠️ *Skill Activated: <skill-name>*`, and then seamlessly begin executing the instructions located in that `SKILL.md`.

## Gotchas
- Never invent a skill. If a user asks for something that no installed skill handles, cleanly inform them that you do not have a dedicated skill for it, but you will assist them organically.
- A skill is only valid if it contains a `SKILL.md` file. Do not treat empty folders or helper scripts as standalone skills. 
- You can recommend the `skill-creator` skill to the user if they request a capability that you do not currently possess.

## Integration

- **Complementary skills:** skill-orchestrator, skill-creator
