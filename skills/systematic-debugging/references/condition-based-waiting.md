# Condition-Based Waiting

Replace arbitrary timeouts with condition checks for more reliable and faster tests and operations.

## The Problem with Arbitrary Timeouts

```python
# ❌ Bad: Arbitrary timeout — too short (flaky) or too long (slow)
import time
time.sleep(5)  # Hope the service is ready
response = client.get("/api/health")
```

Problems:
- **Too short:** Test fails intermittently (flaky)
- **Too long:** Test is always slow
- **No feedback:** You don't know why it failed

## The Solution: Condition-Based Waiting

```python
# ✅ Good: Wait for the condition, not for time
import time

def wait_for_condition(condition_fn, timeout=30, interval=0.5):
    """Wait for a condition to become true, with timeout."""
    start = time.time()
    last_error = None
    while time.time() - start < timeout:
        try:
            result = condition_fn()
            if result:
                return result
        except Exception as e:
            last_error = e
        time.sleep(interval)
    raise TimeoutError(
        f"Condition not met within {timeout}s. Last error: {last_error}"
    )

# Usage: Wait for service to be healthy
wait_for_condition(
    lambda: client.get("/api/health").status_code == 200,
    timeout=30,
    interval=0.5
)
```

## Common Patterns

### Wait for Service Health

```python
def wait_for_service(url, timeout=30):
    """Wait for a service to respond with 200."""
    def is_healthy():
        try:
            return requests.get(f"{url}/health").status_code == 200
        except requests.ConnectionError:
            return False
    wait_for_condition(is_healthy, timeout=timeout)
```

### Wait for Database Connection

```python
def wait_for_db(connection_string, timeout=30):
    """Wait for database to accept connections."""
    def db_ready():
        try:
            conn = psycopg2.connect(connection_string)
            conn.close()
            return True
        except psycopg2.OperationalError:
            return False
    wait_for_condition(db_ready, timeout=timeout)
```

### Wait for File Existence

```python
def wait_for_file(path, timeout=10):
    """Wait for a file to exist."""
    wait_for_condition(lambda: os.path.exists(path), timeout=timeout)
```

### Wait for Process Completion

```python
def wait_for_process(pid, timeout=30):
    """Wait for a process to exit."""
    def process_done():
        try:
            os.kill(pid, 0)  # Check if process exists
            return False
        except ProcessLookupError:
            return True
    wait_for_condition(process_done, timeout=timeout)
```

## Best Practices

1. **Always include a timeout** — Prevent infinite waits
2. **Use appropriate intervals** — 0.1-0.5s for most cases, 1-5s for slow operations
3. **Log the wait duration** — Helps identify performance issues
4. **Include the last error in timeout messages** — Makes debugging easier
5. **Clean up on timeout** — If you started a process, kill it on timeout

## When to Use

- **Integration tests** — Wait for services to be ready before testing
- **E2E tests** — Wait for UI elements to appear
- **CI/CD pipelines** — Wait for deployments to complete
- **Async operations** — Wait for background jobs to finish
- **Debugging intermittent issues** — Replace `sleep()` with condition checks