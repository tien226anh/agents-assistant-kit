# Problem-Solving Techniques Reference

Detailed descriptions of each technique for deeper study.

## Inversion Exercise

**Best for:** Problems where hidden assumptions might be blocking progress.

**The pattern:**
1. Write down every assumption you're making
2. Negate each one
3. Explore what would be true if the negation held
4. Look for useful insights from the inversions

**Common assumptions to invert:**
- "The data is correct" → What if the data is corrupted?
- "The API is working" → What if the API is returning errors we're ignoring?
- "The config is loaded" → What if the config is using defaults?
- "This is a new bug" → What if this has always been broken?
- "More code will fix it" → What if removing code fixes it?

**When it works:** Almost always produces at least one useful insight, even if it doesn't solve the problem directly.

---

## Simplification Cascades

**Best for:** Problems with multiple symptoms where you suspect a common root cause.

**The pattern:**
1. List every symptom and problem
2. For each pair, ask: "If I solved A, would B still exist?"
3. Find the problem that, when solved, makes the most other problems disappear
4. Validate by checking: "Does solving this actually cascade?"

**Cascade examples:**
- Slow tests + flaky CI + risky deployments → Root: No test separation → Fix: Split unit/integration tests
- Memory leaks + slow startup + high CPU → Root: Singleton caching everything → Fix: Proper cache eviction
- API errors + timeout + data inconsistency → Root: Missing retry logic → Fix: Add exponential backoff

**When it works:** Best when there are 3+ seemingly unrelated problems that might share a root cause.

---

## Collision Zone Thinking

**Best for:** Creative blocks where conventional approaches in your domain have failed.

**The pattern:**
1. Name your domain (e.g., "distributed systems")
2. Pick a completely unrelated domain (e.g., "urban planning", "biology", "music")
3. Find the structural similarity (not surface similarity)
4. Map how the other domain solves this type of problem
5. Extract the transferable principle
6. Apply it to your problem

**Domain collision examples:**
| Your Domain | Unrelated Domain | Structural Similarity | Transferable Principle |
|-------------|-----------------|----------------------|----------------------|
| Queue processing | Post office | Sorting surges | Batch + route at intake |
| API rate limiting | Traffic lights | Controlling flow | Token bucket = green light cycles |
| Cache invalidation | Library checkout | Tracking what's out | Event-driven returns |
| Microservice discovery | City navigation | Finding services | Service registry = map + GPS |

**When it works:** Best when you've exhausted domain-specific solutions and need a fresh perspective.

---

## Scale Game

**Best for:** Problems where the "obvious" solution might be wrong, or where you need to find the essential core.

**The pattern:**
1. Scale up 100x — What breaks at massive scale?
2. Scale down to 0 — What's the absolute minimum?
3. Scale to 1 — What's the simplest version that works?
4. Compare extremes — What do they reveal about the core?

**Scale examples:**
| Problem | 100x | 0 | 1 | Core Truth |
|---------|------|---|---|------------|
| Notifications | Billion/day → need queue + workers | One → just send email | Send email with queue abstraction | Queue abstraction is essential |
| Auth | Million concurrent → need token rotation | No users → no auth needed | Simple token with refresh mechanism | Refresh mechanism is the core |
| Search | Billion docs → need Elasticsearch | No docs → no search needed | Simple LIKE query with index | Index is the core, ES is scale |

**When it works:** Best for architecture and design decisions where you need to separate essential complexity from accidental complexity.

---

## Meta-Pattern Recognition

**Best for:** Experienced developers who have solved similar problems before but aren't seeing the connection.

**The pattern:**
1. List problems you've solved that feel similar
2. For each, write down what the actual solution was (not the surface-level fix)
3. Find the common principle across all of them
4. Name the principle
5. Apply it to the current problem

**Common meta-patterns:**
- **Stale state pattern:** Problems caused by data that should have been invalidated but wasn't
- **Abstraction inversion pattern:** Low-level details leaking into high-level code
- **Hidden coupling pattern:** Components that depend on each other's implementation details
- **Premature optimization pattern:** Complexity added for scale that hasn't arrived
- **Missing error path pattern:** Happy path works, error handling is missing or broken

**When it works:** Best when you have a feeling of "I've seen this before" but can't quite place it.