# Testing Skills

How to verify that your skills activate correctly and produce the right behavior.

## Why Test Skills

A skill that doesn't activate when it should is invisible. A skill that activates when it shouldn't is annoying. Testing ensures your skills fire in the right situations.

## Validation Checklist

After creating or modifying a skill, verify each item:

### 1. Frontmatter Validation

```bash
# Check frontmatter delimiters
head -1 skills/my-skill/SKILL.md | grep -q "^---$" && echo "✓ valid" || echo "✗ invalid"

# Check name matches directory
dir_name=$(basename skills/my-skill)
skill_name=$(head -5 skills/my-skill/SKILL.md | grep "^name:" | sed 's/name: //')
[ "$dir_name" = "$skill_name" ] && echo "✓ name matches" || echo "✗ mismatch"

# Check description exists and starts with "Use when"
desc=$(head -10 skills/my-skill/SKILL.md | grep "^description:" | sed 's/description: //')
echo "$desc" | grep -q "^Use when" && echo "✓ description format" || echo "✗ should start with 'Use when'"
```

### 2. Description Quality

- [ ] Description starts with "Use when..."
- [ ] Description is in third person (no "I can" or "You should")
- [ ] Description includes specific triggering conditions
- [ ] Description includes adjacent terms and keywords
- [ ] Description is under 500 characters
- [ ] Description does NOT summarize the skill's workflow

### 3. Body Structure

- [ ] Has a "When to use" section
- [ ] Has clear workflow steps (not just prose)
- [ ] Includes "Gotchas" or "Anti-patterns" section
- [ ] Under 500 lines (move details to references/)
- [ ] Uses imperative form ("Run the linter" not "The linter should be run")

### 4. Progressive Disclosure

- [ ] SKILL.md is concise (under 500 lines)
- [ ] Reference files are organized by domain
- [ ] SKILL.md links to reference files with "when to read" guidance
- [ ] No content is duplicated between SKILL.md and references

## Activation Testing

### Direct Trigger Test

Ask the agent a question that should directly trigger the skill:

- **Test:** "Review the changes in my last commit"
- **Expected:** `code-review` skill activates
- **Fail:** Agent doesn't mention the skill or uses a different one

### Synonym Trigger Test

Ask the same thing using different words:

- **Test:** "Look at my diff and find problems"
- **Expected:** `code-review` skill activates (synonym: "diff", "find problems")
- **Fail:** Agent doesn't recognize the synonyms

### Context Trigger Test

Describe a situation that implies the skill should be used:

- **Test:** "I'm getting a 500 error when I call the API"
- **Expected:** `debug-assistant` skill activates (context: error, API)
- **Fail:** Agent suggests a different approach without using the skill

### Negative Test

Ask something that should NOT trigger the skill:

- **Test:** "Deploy my app to production"
- **Expected:** `debug-assistant` does NOT activate
- **Fail:** Debugging skill activates for a deployment request

## Common Testing Scenarios

| Skill Type | Test With | Should Activate |
|-----------|-----------|----------------|
| Debug | "I'm getting an error" | ✅ |
| Debug | "How do I write a test?" | ❌ |
| Test Writer | "Write tests for auth module" | ✅ |
| Test Writer | "My tests are failing" | ❌ (that's debug) |
| Code Review | "Check my PR for issues" | ✅ |
| Code Review | "How do I review someone else's PR?" | ✅ (still relevant) |
| Code Review | "Write a function that validates email" | ❌ |

## Iterative Improvement

If a skill doesn't activate when it should:

1. **Check the description** — Does it include the words the user used?
2. **Add synonyms** — Add the user's exact words to the description
3. **Add context** — Add situations where the skill applies
4. **Shorten** — If the description is too long, key terms get diluted
5. **Re-test** — Verify the change works