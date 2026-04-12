# Test Patterns Reference

Detailed patterns for the test-writer skill. Load when you need guidance on specific testing techniques.

## Parameterized Tests

Run the same test logic with multiple inputs:

```python
# Python (pytest)
import pytest

@pytest.mark.parametrize("input_val,expected", [
    ("hello", 5),
    ("", 0),
    ("café", 4),
    ("🎉", 1),
])
def test_string_length(input_val, expected):
    assert len(input_val) == expected
```

```typescript
// TypeScript (vitest)
it.each([
  ['hello', 5],
  ['', 0],
  ['café', 4],
])('length of "%s" should be %d', (input, expected) => {
  expect(input.length).toBe(expected);
});
```

## Fixtures / Setup-Teardown

```python
# Python (pytest)
@pytest.fixture
def db_session():
    session = create_test_session()
    yield session
    session.rollback()
    session.close()

def test_create_user(db_session):
    user = create_user(db_session, name="Alice")
    assert user.id is not None
```

```typescript
// TypeScript (vitest)
let db: TestDatabase;

beforeEach(async () => {
  db = await createTestDatabase();
});

afterEach(async () => {
  await db.cleanup();
});
```

## Mocking HTTP Requests

```python
# Python (pytest + responses or httpx-mock)
import responses

@responses.activate
def test_fetch_user_profile():
    responses.add(
        responses.GET,
        "https://api.example.com/users/1",
        json={"id": 1, "name": "Alice"},
        status=200,
    )
    profile = fetch_user_profile(1)
    assert profile.name == "Alice"
```

```typescript
// TypeScript (vitest + msw)
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.get('https://api.example.com/users/1', () => {
    return HttpResponse.json({ id: 1, name: 'Alice' });
  }),
);

beforeAll(() => server.listen());
afterAll(() => server.close());
```

## Testing Async Code

```python
# Python (pytest-asyncio)
import pytest

@pytest.mark.asyncio
async def test_async_fetch():
    result = await fetch_data("key")
    assert result is not None
```

```typescript
// TypeScript (vitest)
it('should fetch data', async () => {
  const result = await fetchData('key');
  expect(result).toBeDefined();
});
```

## Testing Exceptions / Errors

```python
# Python
def test_division_by_zero():
    with pytest.raises(ZeroDivisionError):
        divide(1, 0)

def test_invalid_email_validation():
    with pytest.raises(ValidationError, match="email"):
        validate_user({"email": "not-an-email"})
```

```typescript
// TypeScript
it('should throw on division by zero', () => {
  expect(() => divide(1, 0)).toThrow(ZeroDivisionError);
});

it('should reject invalid email', async () => {
  await expect(validateUser({ email: 'bad' })).rejects.toThrow('email');
});
```

## Snapshot Testing

Use for complex output that's expensive to assert field-by-field:

```typescript
// TypeScript (vitest)
it('should render user profile', () => {
  const html = renderProfile({ name: 'Alice', role: 'admin' });
  expect(html).toMatchSnapshot();
});
```

**When to use**: HTML rendering, serialized data structures, CLI output.
**When NOT to use**: Frequently changing output, data with timestamps/IDs.

## Testing Database Operations

```python
# Use transactions that roll back after each test
@pytest.fixture
def db(engine):
    connection = engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection)
    yield session
    transaction.rollback()
    connection.close()
```

Key rules:
- Each test gets a fresh transaction that rolls back
- Never share state between tests
- Use factories (not fixtures with hardcoded data) for test data
