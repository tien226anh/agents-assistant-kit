---
name: test-writer
description: Use when writing tests, adding test coverage, or creating test cases for code. Covers unit tests, integration tests, mocking, assertions, and coverage across pytest, vitest, and jest.
---

# Test Writer

## When to use
Use this skill when asked to write tests, add test coverage, create test cases, or verify behavior of existing code.

## Workflow

### Step 1: Understand the code under test
```
- [ ] Read the source file to understand the function/module behavior
- [ ] Identify the public API (what should be tested)
- [ ] Identify dependencies (what needs to be mocked)
- [ ] Check for existing tests (don't duplicate)
```

```bash
# Find existing tests for a file
# Convention: test_*.py, *_test.go, *.spec.ts, *.test.js
find . -name "test_*" -o -name "*_test.*" -o -name "*.spec.*" -o -name "*.test.*" | head -20
```

### Step 2: Plan test cases
For every function/method under test, identify:

1. **Happy path** — normal input, expected output
2. **Edge cases** — empty input, zero, single element, max/min values
3. **Error cases** — invalid input, missing data, network failure
4. **Boundary cases** — off-by-one, type boundaries, Unicode

### Step 3: Write tests

Use the **Arrange → Act → Assert** pattern:

```python
# Python (pytest)
def test_create_user_with_valid_data():
    # Arrange
    user_data = {"name": "Alice", "email": "alice@example.com"}

    # Act
    result = create_user(user_data)

    # Assert
    assert result.name == "Alice"
    assert result.email == "alice@example.com"
    assert result.id is not None
```

```typescript
// TypeScript (vitest)
describe('createUser', () => {
  it('should create user with valid data', () => {
    // Arrange
    const userData = { name: 'Alice', email: 'alice@example.com' };

    // Act
    const result = createUser(userData);

    // Assert
    expect(result.name).toBe('Alice');
    expect(result.email).toBe('alice@example.com');
    expect(result.id).toBeDefined();
  });
});
```

### Step 4: Verify

```
- [ ] All tests pass
- [ ] Tests fail for the right reason when code is broken
- [ ] No tests depend on external state (DB, network, filesystem)
- [ ] Tests run in any order (no inter-test dependencies)
```

## Test naming convention

Use descriptive names that read as specifications:

```
test_<function>_<scenario>_<expected_result>

test_create_user_with_valid_data_returns_user
test_create_user_with_duplicate_email_raises_conflict
test_create_user_with_empty_name_raises_validation_error
```

## Mocking rules

- Mock **external dependencies** (database, HTTP, filesystem) — never the code under test
- Use the most specific mock possible (don't mock an entire module when you need one function)
- Verify mock interactions only when the *call itself* is the behavior you're testing
- Prefer fakes/stubs over mocks when the logic is simple

## Gotchas
- Don't test private/internal methods directly — test them through the public API.
- Don't assert on exact error messages (they change) — assert on error type/code.
- Don't use `sleep()` in tests — use proper synchronization or fake timers.
- Each test should test ONE behavior. If a test name has "and" in it, split it.
- Always clean up: reset mocks, close connections, remove temp files.

## Stack-Specific Testing

Detect the project stack first, then apply the right patterns:

| Stack signal | Test framework | Expert skill |
|-------------|---------------|-------------|
| `pyproject.toml`, `requirements.txt` | **pytest** + pytest-asyncio, pytest-cov | **python-expert** |
| `package.json` + `tsconfig.json` | **vitest** (preferred) or jest | **nodejs-expert** |
| `package.json` (JS only) | **vitest** or jest | **nodejs-expert** |

- **Python testing details**: See the **python-expert** skill for pytest fixtures, async testing, factory patterns, and coverage configuration.
- **Node.js/TypeScript testing details**: See the **nodejs-expert** skill for vitest mocking (`vi.fn`, `vi.mock`, `vi.spyOn`), MSW for HTTP mocking, and Playwright for E2E.

For detailed test patterns (fixtures, parameterized, async), see [references/test-patterns.md](references/test-patterns.md).

For common testing anti-patterns and how to fix them, see [references/testing-anti-patterns.md](references/testing-anti-patterns.md).

## Integration

- **Before this skill:** Use `test-driven-development` for the RED-GREEN-REFACTOR cycle
- **After this skill:** Use `code-review` to review the tests you wrote
- **Complementary skills:** `test-driven-development`, `code-review`, `debug-assistant`

