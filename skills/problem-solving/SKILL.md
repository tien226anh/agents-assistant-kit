---
name: problem-solving
description: Use when stuck on a difficult problem, facing a creative block, or when standard approaches have failed. Triggers on phrases like "I'm stuck", "can't figure out", "nothing works", "need a different approach", or when debugging has not resolved the issue after multiple attempts.
---

# Problem-Solving

Creative and structured techniques for when you're stuck and standard approaches aren't working.

## When to Use

- Standard debugging hasn't resolved the issue after multiple attempts
- You're facing a design problem with no obvious solution
- You need to think creatively about an architecture or approach
- The user says they're stuck or blocked

## ⚠️ Command Safety

Read-only analysis. No code changes during problem-solving — only after a solution is chosen.

## Technique Selection

When stuck, pick the technique that matches your situation:

| Situation | Technique | Why |
|-----------|-----------|-----|
| Assumptions might be wrong | Inversion Exercise | Flip assumptions to reveal hidden constraints |
| Problem feels overwhelming | Simplification Cascades | Find the insight that eliminates multiple problems |
| Need creative breakthrough | Collision Zone Thinking | Force unrelated concepts together for emergent insights |
| Solution seems obvious but might be wrong | Scale Game | Test at extremes to expose fundamental truths |
| Seeing patterns across problems | Meta-Pattern Recognition | Spot universal principles across domains |
| Not sure which technique to use | When Stuck | Decision flowchart to dispatch to the right technique |

## Techniques

### Inversion Exercise

Flip your assumptions to reveal hidden constraints.

1. **List assumptions** — Write down everything you're assuming about the problem
2. **Invert each** — What if the opposite were true?
3. **Explore implications** — What would that mean for the solution?
4. **Extract insights** — Which inversions reveal something useful?

**Example:** "The database is slow" → Inversion: "What if the database is fast but we're querying it wrong?" → Leads to checking query patterns instead of adding indexes.

### Simplification Cascades

Find the insight that eliminates multiple problems at once.

1. **List all problems** — Every symptom, error, and pain point
2. **Find the root** — Which single problem, if solved, would make others disappear?
3. **Validate** — Does solving this one thing actually cascade?
4. **Implement the cascade** — Fix the root cause first

**Example:** "Tests are slow, CI is flaky, deployments are risky" → Root cause: "No separation between unit and integration tests" → Fix: Restructure test suite → All three problems resolve.

### Collision Zone Thinking

Force unrelated concepts together for emergent insights.

1. **Identify the domain** — What field is this problem in?
2. **Pick an unrelated domain** — What completely different field faces similar structural challenges?
3. **Map the analogy** — How does the other domain solve this type of problem?
4. **Extract the principle** — What's the transferable insight?
5. **Apply to your problem** — How does this principle change your approach?

**Example:** "Queue processing is unreliable" → Unrelated domain: "How do post offices handle mail surges?" → Principle: "Batch + route at intake, not at processing" → Apply: Pre-sort and batch messages before queue submission.

### Scale Game

Test at extremes to expose fundamental truths.

1. **Scale up 100x** — What breaks if this runs 100x more?
2. **Scale down to 0** — What's the minimum viable version?
3. **Scale to 1** — What's the simplest version that works for one user/case?
4. **Compare** — What do the extremes reveal about the core requirements?

**Example:** "Design a notification system" → 100x: "Billion notifications/day requires queue + workers" → 0: "One notification is just an email" → 1: "Send email, but with a queue abstraction for future scale" → Core truth: Queue abstraction is essential even at small scale.

### Meta-Pattern Recognition

Spot universal principles across domains.

1. **List similar problems** you've solved before
2. **Identify the common pattern** — What's the same about all of them?
3. **Extract the principle** — Name the underlying rule
4. **Apply the principle** — How does it guide the current solution?

**Example:** "This auth bug" + "that caching bug" + "the config bug" → Pattern: "All involve stale state not being invalidated" → Principle: "Always invalidate on write, not on read" → Apply: Check all write paths for proper cache invalidation.

## When Stuck: Decision Flowchart

```
Am I making assumptions?
├─ Yes → Inversion Exercise
└─ No → Am I overwhelmed by multiple problems?
    ├─ Yes → Simplification Cascades
    └─ No → Do I need a creative breakthrough?
        ├─ Yes → Collision Zone Thinking
        └─ No → Is the "obvious" solution possibly wrong?
            ├─ Yes → Scale Game
            └─ No → Have I seen this pattern before?
                ├─ Yes → Meta-Pattern Recognition
                └─ No → Start with Inversion Exercise (it's the most broadly applicable)
```

## Anti-Patterns

- **Trying all techniques at once** — Pick one, go deep, then try another if needed
- **Skipping the "validate" step** — Every technique requires checking if the insight actually holds
- **Confusing symptoms with root causes** — Simplification Cascades specifically addresses this
- **Giving up after one technique** — If inversion doesn't work, try collision zone thinking

## Integration

- **Before this skill:** Use `debug-assistant` for straightforward bugs, `systematic-debugging` for hard bugs
- **After this skill:** Use `code-planner` to plan the implementation of the chosen solution
- **Complementary skills:** `brainstorming` for exploring multiple approaches, `debug-assistant` for simple bugs