# Testing Anti-Patterns

Common testing mistakes and how to avoid them. Use this reference when writing tests to ensure you're testing behavior, not implementation.

## Anti-Pattern 1: Testing Mock Behavior

**The Problem:** Your test verifies that a mock was called, not that the system produces the correct output.

```python
# ❌ Bad: Testing that the mock was called
def test_send_welcome_email():
    mailer = Mock()
    user = User(name="Alice", email="alice@example.com")
    user.send_welcome(mailer)
    mailer.send.assert_called_once_with("alice@example.com", "Welcome!")
```

**The Fix:** Test the observable behavior, not the interaction.

```python
# ✅ Good: Test the outcome
def test_user_receives_welcome_email():
    inbox = FakeInbox()
    user = User(name="Alice", email="alice@example.com")
    user.send_welcome(inbox)
    assert inbox.contains(to="alice@example.com", subject="Welcome!")
```

**Why:** If you refactor `send_welcome` to use a different mailer, the mock test breaks even though the behavior is correct. The good test still passes.

## Anti-Pattern 2: Adding Test-Only Methods to Production Code

**The Problem:** You add methods to production classes just so tests can access internal state.

```python
# ❌ Bad: Test-only method added to production code
class Order:
    def __init__(self):
        self._items = []

    def add_item(self, item):
        self._items.append(item)

    # This method exists only for testing!
    def get_items_for_testing(self):
        return self._items
```

**The Fix:** Test through the public interface, or refactor to make the state observable.

```python
# ✅ Good: Test through public interface
class Order:
    def __init__(self):
        self._items = []

    def add_item(self, item):
        self._items.append(item)

    def total(self):
        return sum(item.price for item in self._items)

    def item_count(self):
        return len(self._items)

# Test through public interface
def test_order_total_includes_all_items():
    order = Order()
    order.add_item(Item(price=10))
    order.add_item(Item(price=20))
    assert order.total() == 30
```

## Anti-Pattern 3: Testing Private Methods

**The Problem:** You test private/internal methods directly, coupling tests to implementation.

```python
# ❌ Bad: Testing a private method
def test_validate_email_format():
    user = User()
    assert user._validate_email("test@example.com") == True
```

**The Fix:** Test private methods indirectly through the public interface.

```python
# ✅ Good: Test through public interface
def test_user_with_valid_email_is_accepted():
    user = User(email="test@example.com")
    assert user.is_valid()  # _validate_email is tested implicitly

def test_user_with_invalid_email_is_rejected():
    user = User(email="not-an-email")
    assert not user.is_valid()
```

## Anti-Pattern 4: Overspecifying

**The Problem:** Your test asserts on too many details, making it brittle.

```python
# ❌ Bad: Overspecified test
def test_get_users():
    response = client.get("/api/users")
    assert response.status_code == 200
    assert response.headers["Content-Type"] == "application/json"
    assert response.headers["X-Request-Id"] is not None
    data = response.json()
    assert len(data) == 5
    assert data[0]["id"] == 1
    assert data[0]["name"] == "Alice"
    assert data[0]["email"] == "alice@example.com"
    assert data[0]["role"] == "admin"
    # ... 20 more assertions
```

**The Fix:** Assert only on what matters for the behavior being tested.

```python
# ✅ Good: Assert on what matters
def test_get_users_returns_list_of_users():
    response = client.get("/api/users")
    assert response.status_code == 200
    users = response.json()
    assert len(users) > 0
    assert "id" in users[0]
    assert "name" in users[0]
```

## Anti-Pattern 5: Mystery Guests

**The Problem:** Test uses magic values without explaining why.

```python
# ❌ Bad: Mystery values
def test_calculate_discount():
    result = calculate_discount(100, 0.15)
    assert result == 85  # Why 85? What's the relationship?
```

**The Fix:** Make the relationship explicit.

```python
# ✅ Good: Clear relationship
def test_calculate_discount():
    original_price = 100
    discount_rate = 0.15
    expected_discount = original_price * discount_rate  # 15
    expected_price = original_price - expected_discount  # 85

    result = calculate_discount(original_price, discount_rate)
    assert result == expected_price
```

## Anti-Pattern 6: Flaky Tests

**The Problem:** Tests that pass sometimes and fail other times.

**Common causes:**
- Depending on execution order (shared mutable state)
- Using `sleep()` instead of condition-based waiting
- Depending on current time (`Date.now()`, `datetime.now()`)
- Depending on random values
- Race conditions in async code

**The Fix:**
- Make tests independent — each test creates and cleans up its own data
- Use condition-based waiting instead of `sleep()` (see `systematic-debugging` skill)
- Inject time as a dependency — use a clock interface instead of system time
- Use deterministic test data — fixed seeds for random, fixed dates for time
- Use proper synchronization for async tests

## Anti-Pattern 7: Testing Implementation Details

**The Problem:** Your test knows about the internal structure of the code.

```python
# ❌ Bad: Test knows about internal structure
def test_user_repository_saves_to_database():
    repo = UserRepository()
    repo.save(User(name="Alice"))
    assert repo._database.query("SELECT * FROM users")  # Knows about _database
```

**The Fix:** Test through the public interface.

```python
# ✅ Good: Test through public interface
def test_user_repository_saves_and_retrieves_user():
    repo = UserRepository()
    repo.save(User(name="Alice"))
    retrieved = repo.find_by_name("Alice")
    assert retrieved.name == "Alice"
```

## Quick Reference: Gate Function Checklist

Before writing any test, verify:

- [ ] Am I testing **behavior**, not implementation?
- [ ] Am I mocking **external dependencies**, not internal collaborators?
- [ ] Is this test **independent** of other tests?
- [ ] Is this test **deterministic** (same input → same output, always)?
- [ ] Does this test have a **clear purpose** (one behavior per test)?
- [ ] Are my assertions **minimal but sufficient**?
- [ ] Are my test values **meaningful** (no mystery guests)?