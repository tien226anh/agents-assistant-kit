---
name: test-driven-development
description: Use when writing code using the TDD discipline — write tests before implementation code. Triggers on phrases like "TDD", "test-driven", "red-green-refactor", "write the test first", or when the user wants to enforce a strict test-first development workflow.
---

# Test-Driven Development

Enforce the RED-GREEN-REFACTOR cycle: write a failing test, make it pass, then improve the code.

## When to Use

- User explicitly requests TDD workflow
- User says "write the test first" or "red-green-refactor"
- Implementing features where correctness is critical
- Fixing bugs using the "write a failing test first" approach

## ⚠️ Command Safety

Tests are read-only in terms of production code impact. However, running test suites may execute code — ensure test environments are isolated.

## The TDD Cycle

### RED — Write a Failing Test

1. **Identify the next smallest behavior** to implement
2. **Write a test that describes the desired behavior**
3. **Run the test — it MUST fail** (if it passes, the behavior already exists or the test is wrong)
4. **The test failure message should tell you what to implement**

```python
# RED: Write the test first
def test_user_cannot_have_empty_email():
    user = User(name="Alice", email="")
    with pytest.raises(ValidationError):
        user.validate()
```

### GREEN — Make It Pass (Minimal Code)

1. **Write the simplest code that makes the test pass**
2. **Don't add features the test doesn't require**
3. **Hardcode if needed** — you'll refactor later
4. **Run the test — it MUST pass**

```python
# GREEN: Minimal implementation
class User:
    def validate(self):
        if not self.email:
            raise ValidationError("Email cannot be empty")
```

### REFACTOR — Improve the Code

1. **Run ALL tests** — they must still pass
2. **Improve the code** — remove duplication, improve naming, simplify
3. **Run ALL tests again** — they must still pass
4. **Commit** — only after green + refactored

```python
# REFACTOR: Improve without changing behavior
class User:
    REQUIRED_FIELDS = ["email"]

    def validate(self):
        for field in self.REQUIRED_FIELDS:
            if not getattr(self, field):
                raise ValidationError(f"{field} cannot be empty")
```

## Gate Functions

Before writing any test, check these gates. If any gate fails, stop and fix the approach:

### Gate 1: Are You Testing Behavior, Not Implementation?

- ✅ "When I call `validate()` with empty email, it raises `ValidationError`"
- ❌ "When I call `validate()`, it calls `check_email_format()` internally"

If you're testing how something works internally, you're coupling tests to implementation. Test what, not how.

### Gate 2: Are You Mocking the Right Thing?

- ✅ Mock external dependencies (APIs, databases, file system)
- ❌ Mock internal collaborators that are part of the system under test

If you're adding methods to production code just to mock them, you're testing the mock, not the behavior.

### Gate 3: Is the Test Independent?

- ✅ Test can run in any order
- ✅ Test creates its own data
- ✅ Test cleans up after itself
- ❌ Test depends on data created by another test
- ❌ Test shares mutable state with other tests

### Gate 4: Is the Test Deterministic?

- ✅ Same input → same output, every time
- ❌ Test uses `random`, `Date.now()`, or depends on timing
- ❌ Test passes sometimes and fails sometimes (flaky)

## Anti-Patterns

See [references/testing-anti-patterns.md](references/testing-anti-patterns.md) for detailed examples.

**Quick reference — stop if you catch yourself doing any of these:**

- **Testing mock behavior** — If your test verifies that a mock was called, you're testing the mock
- **Adding test-only methods** — If you add a method to production code just to test it, refactor instead
- **Testing private methods** — Test the public interface; private methods are implementation details
- **Overspecifying** — If your test asserts on 20 things, it breaks when anything changes
- **Mystery guests** — If your test uses magic values without explaining why, future readers won't understand the intent

## Integration

- **Before this skill:** Use `writing-plans` to plan what to implement
- **During this skill:** Use `test-writer` for test patterns and stack-specific guidance
- **After this skill:** Use `code-review` to review the implementation
- **Complementary skills:** `test-writer` for test patterns, `debug-assistant` for failing tests