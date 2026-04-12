---
name: skill-creator
description: Use when creating, editing, or improving Agent Skills for this framework. Covers SKILL.md authoring, CSO description optimization, testing skill quality, and progressive disclosure patterns.
---

# Skill Creator

## When to use
Use this skill when asked to create a new Agent Skill, improve an existing one, or learn best practices for writing effective skills.

## Anatomy of a Skill

```
skill-name/
├── SKILL.md              # Required — instructions for the agent
├── references/           # Optional — detailed docs loaded on demand
├── scripts/              # Optional — executable helper scripts
└── assets/               # Optional — templates, configs, examples
```

## Step 1: Capture Intent

Before writing, answer these questions:

1. **What** should this skill enable the agent to do?
2. **When** should this skill trigger? (user phrases, contexts)
3. **What output** does the user expect? (code, config, analysis, commands)
4. **What tools/data** does the skill need? (filesystem, APIs, scripts)
5. **What should the agent AVOID doing?** (destructive actions, wrong patterns)

## Step 2: Write the SKILL.md

### Frontmatter (required)
```yaml
---
name: my-skill
description: Clear description of what the skill does AND when to trigger it. Include specific keywords and phrases that should activate this skill. Be slightly "pushy" — include contexts where the skill is useful even if the user doesn't explicitly name it.
---
```

**Description tips:**
- Include BOTH what the skill does AND trigger contexts
- Add common user phrases: "when the user asks to...", "use when..."
- Be slightly broad — undertriggering is more common than overtriggering
- Include adjacent terms users might use

**Good**: `"Expert guidance for Python software development including project setup, packaging, virtual environments, testing, linting, type checking, debugging, profiling, async programming, and framework-specific patterns. Use when the user is working on a Python project, setting up Python tooling, writing Python code, or asking about Python best practices."`

**Bad**: `"Python help"` (too vague, won't trigger reliably)

### Body structure
```markdown
# Skill Name

## When to use
One paragraph describing activation conditions.

## ⚠️ Command Safety
(Include if skill involves running commands)
Read-only commands only. Never run mutating commands without user approval.

## Workflow / Instructions
Step-by-step guide with code examples.

## Gotchas
Common mistakes and how to avoid them.

## Cross-references
Links to related skills and reference files.
```

## Step 3: Writing Principles

1. **Explain the WHY, not just the WHAT.** Today's LLMs are smart — when they understand reasoning, they generalize better than when given rigid rules.

2. **Use imperative form.** "Run the linter" not "The linter should be run."

3. **Include examples.** Show input → output for key patterns.

4. **Keep SKILL.md under 500 lines.** If approaching this limit, move details to `references/` and add clear pointers about when to read them.

5. **Prefer explanation over MUST/NEVER.** Heavy-handed rules make skills brittle. Explain the reasoning so the agent can adapt to edge cases.

6. **Add cross-references.** When skills complement each other (e.g., test-writer → python-expert), include a cross-reference so the agent can chain skills.

7. **Include Command Safety** for any skill that involves running commands. Follow the pattern:
   ```markdown
   ## ⚠️ Command Safety
   Read-only commands only. Never run [specific destructive commands] without explicit user approval.
   ```

## Step 4: Progressive Disclosure

Skills load in three tiers:

| Tier | What loads | Size target |
|------|-----------|-------------|
| **1. Metadata** | `name` + `description` in frontmatter | ~100 words |
| **2. Body** | SKILL.md content (loads when skill triggers) | <500 lines |
| **3. References** | Files in `references/`, `scripts/` (loaded on demand) | Unlimited |

**Key pattern:** Keep SKILL.md focused. Put domain-specific details in reference files organized by variant:

```
architect-cloud/
├── SKILL.md (workflow + decision framework)
└── references/
    ├── cloud-services.md    # Loaded when discussing specific services
    └── terraform-patterns.md # Loaded when working with IaC
```

## Step 5: Organize Reference Files

### When to use references/
- Detailed tool configs (>50 lines of examples)
- Framework-specific patterns
- Checklists and catalogs
- Large code templates

### When NOT to use references/
- Core workflow steps (keep in SKILL.md)
- Short examples (<20 lines)
- One-liner commands

### Reference file format
- Add a table of contents for files >300 lines
- Include "when to read this" guidance in SKILL.md
- One file per domain/framework (e.g., `aws.md`, `gcp.md`)

## Step 6: Validate

After creating a skill, verify:

```bash
# Check frontmatter is valid
head -1 skills/my-skill/SKILL.md | grep -q "^---$" && echo "✓ valid" || echo "✗ invalid"

# Check name matches directory
dir_name=$(basename skills/my-skill)
skill_name=$(grep "^name:" skills/my-skill/SKILL.md | sed 's/name: //')
[ "$dir_name" = "$skill_name" ] && echo "✓ name matches" || echo "✗ mismatch"
```

## Template

Use this template for new skills:

```markdown
---
name: skill-name-here
description: Clear description. Use when the user asks to... Include keywords that should trigger this skill.
---

# Skill Name

## When to use
Use this skill when...

## ⚠️ Command Safety
(If applicable) Read-only commands only.

## Workflow

### Step 1: ...
### Step 2: ...
### Step 3: ...

## Gotchas
- Watch out for...
- Never...

For detailed patterns, see [references/details.md](references/details.md).
```

## CSO: Description Optimization

The `description` field is the **single most important factor** in whether a skill gets activated. Agents use it to decide which skill to load from potentially 20+ options.

### Description Rules

1. **Write in third person.** The description is injected into the system prompt — inconsistent point-of-view causes discovery problems.
   - ✅ "Processes Excel files and generates reports"
   - ❌ "I can help you process Excel files"
   - ❌ "You can use this to process Excel files"

2. **Start with "Use when..."** to focus on triggering conditions, not workflow.
   - ✅ "Use when the user asks to debug a persistent bug, trace root causes, or when standard debugging hasn't resolved the issue"
   - ❌ "This skill walks through 5 debugging steps: reproduce, isolate, hypothesize, fix, verify"

3. **Include specific symptoms and contexts.** These are the keywords agents search for.
   - ✅ "Use when the user reports a bug, encounters an error, sees unexpected output, or needs help troubleshooting an issue"
   - ❌ "Use for debugging"

4. **Include adjacent terms.** Users may not use the exact skill name.
   - ✅ "Use when the user asks to review code, check a PR, audit changes, look at a diff, or find problems in modified files"
   - ❌ "Use for code review"

5. **Keep under 500 characters if possible.** The max is 1024 characters, but shorter descriptions are more effective.

6. **NEVER summarize the skill's process or workflow.** The description is for discovery, not instruction. The SKILL.md body provides the workflow.

### Description Template

```yaml
description: Use when [specific triggering conditions and symptoms]. Include keywords: [comma-separated list of terms users might use].
```

For detailed optimization techniques, see [references/cso-best-practices.md](references/cso-best-practices.md).

## Testing Skills

After creating a skill, test that it activates correctly. See [references/testing-skills.md](references/testing-skills.md) for the full methodology.

**Quick validation:**
1. **Name check:** `name` must match directory name exactly (lowercase, hyphenated)
2. **Frontmatter check:** Must have `---` delimiters and both `name` and `description` fields
3. **Description check:** Starts with "Use when...", includes specific triggers, is third-person
4. **Body check:** Under 500 lines, has "When to use" section, includes workflow steps

```bash
# Validate all skills
for f in skills/*/SKILL.md; do
  dir=$(basename $(dirname "$f"))
  name=$(head -5 "$f" | grep "^name:" | sed 's/name: //')
  [ "$dir" = "$name" ] && echo "✓ $dir" || echo "✗ $dir (name=$name)"
done
```

## Gotchas

- **Name must match directory name.** `skills/my-skill/` → `name: my-skill`
- **Name must be lowercase, hyphenated.** `my-skill` not `MySkill` or `my_skill`
- **Description is the primary trigger.** If the skill doesn't activate, improve the description first.
- **Don't duplicate other skills.** Cross-reference instead. Use "See the X skill for Y" patterns.
- **Description is for discovery, not instruction.** Never summarize the workflow in the description — that's what the body is for.
- **Third person only in descriptions.** "Use when..." not "I can help with..." or "You should use this when..."
- **Test with real prompts.** Write 2-3 realistic user requests and verify the agent would use this skill.

## Integration

- **After this skill:** code-review
- **Complementary skills:** skill-orchestrator, use-skill
