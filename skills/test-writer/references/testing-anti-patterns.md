# Testing Anti-Patterns

Common testing anti-patterns that reduce test quality and how to fix them.

## 1. Testing Implementation Details

**Anti-pattern:** Testing how code works internally rather than what it does.

```python
# ❌ Bad: Testing private method directly
def test_internal_parse_method():
    result = parser._parse_tokens(["a", "b"])
    assert result == expected

# ✅ Good: Testing public behavior
def test_parser_produces_expected_output():
    result = parser.parse("a b")
    assert result == expected
```

**Why it's bad:** Internal details change frequently. Tests become brittle and break on refactors that don't change behavior.

**Fix:** Test through the public API. If you need to test internal logic, it might be a sign the logic should be extracted into its own testable unit.

## 2. Over-Mocking

**Anti-pattern:** Mocking everything, including the code under test.

```python
# ❌ Bad: Mocking the system under test
@mock.patch("module.UserService.create")
@mock.patch("module.UserService.validate")
@mock.patch("module.UserService.save")
def test_create_user(mock_save, mock_validate, mock_create):
    mock_create.return_value = User(id=1)
    result = create_user(data)
    mock_create.assert_called()

# ✅ Good: Mock only external dependencies
def test_create_user(db_session):
    result = create_user(data, db=db_session)
    assert result.id is not None
```

**Why it's bad:** Over-mocked tests verify that code calls mocks in a specific order — they test the mock, not the code. They pass even when the real implementation is broken.

**Fix:** Mock only external dependencies (database, HTTP, filesystem). Use real implementations for internal logic.

## 3. Mystery Guest

**Anti-pattern:** Tests that depend on data created elsewhere.

```python
# ❌ Bad: Depends on fixture data created in conftest.py
def test_get_user():
    result = get_user(user_id=1)  # Where does user_id=1 come from?
    assert result.name == "Alice"  # Why Alice?

# ✅ Good: Test creates its own data
def test_get_user(db):
    user = db.create(User(name="Alice"))
    result = get_user(user_id=user.id)
    assert result.name == "Alice"
```

**Why it's bad:** Tests fail mysteriously when fixture data changes. New developers can't understand what data the test expects.

**Fix:** Each test should set up its own data. Use factory functions to reduce boilerplate.

## 4. Flaky Tests

**Anti-pattern:** Tests that sometimes pass and sometimes fail.

```python
# ❌ Bad: Race condition
def test_async_processing():
    start_processing(data)
    time.sleep(1)  # Hope it's done
    assert get_result() is not None

# ✅ Good: Wait for condition
def test_async_processing():
    start_processing(data)
    result = wait_until(lambda: get_result(), timeout=5)
    assert result is not None
```

**Common causes:**
- Race conditions (use proper synchronization)
- Time-dependent logic (use fake clocks)
- External state (reset between tests)
- Random data (use fixed seeds)
- Order dependencies (tests must run independently)

**Fix:** Use deterministic test data, fake clocks, and proper synchronization instead of `sleep()`.

## 5. Test-Only Methods

**Anti-pattern:** Adding methods to production code just for testing.

```python
# ❌ Bad: Test-only method
class Cache:
    def get(self, key): ...
    def set(self, key, value): ...
    def _reset_for_testing(self):  # Only used in tests
        self._data.clear()

# ✅ Good: Use dependency injection
class Cache:
    def __init__(self, storage=None):
        self._storage = storage or RedisStorage()

# In tests:
cache = Cache(storage=InMemoryStorage())  # No production code changes
```

**Why it's bad:** Test-only methods add complexity to production code and can be misused.

**Fix:** Use dependency injection, interfaces, or factory patterns to make code testable without modifying production code.

## 6. Overspecified Assertions

**Anti-pattern:** Asserting on every field of a large object when only a few matter.

```python
# ❌ Bad: Asserting on entire object
def test_create_user():
    result = create_user(data)
    assert result == User(id=1, name="Alice", email="a@b.com",
                          created_at="2024-01-01", updated_at="2024-01-01",
                          status="active", role="user", ...)

# ✅ Good: Assert only what matters
def test_create_user():
    result = create_user(data)
    assert result.name == "Alice"
    assert result.id is not None
```

**Why it's bad:** Overspecified tests break when any field changes, even if the behavior you care about hasn't changed.

**Fix:** Assert only on the fields that matter for the behavior being tested. Use `assert result.id is not None` instead of `assert result.id == 42`.

## 7. Testing Private Methods

**Anti-pattern:** Testing private/internal methods directly.

```python
# ❌ Bad: Accessing private method
def test_validate_email():
    assert validator._validate_email("a@b.com")

# ✅ Good: Test through public API
def test_validate_user():
    result = validator.validate(User(email="a@b.com"))
    assert result.is_valid
```

**Why it's bad:** Private methods are implementation details. If you need to test them, they probably contain enough logic to extract into a public, testable unit.

**Fix:** Test private methods indirectly through the public API. If the logic is complex enough to need direct testing, extract it into its own module with a public API.