---
name: python-expert
description: Expert guidance for Python software development including project setup, packaging, virtual environments, testing, linting, type checking, debugging, profiling, async programming, and framework-specific patterns. Use when the user is working on a Python project, setting up Python tooling, writing Python code, or asking about Python best practices.
---

# Python Expert

## When to use
Use this skill when working on any Python project — setting up environments, writing code, debugging, testing, packaging, or following Python best practices.

## Project Setup

### Modern project initialization (uv — recommended)
```bash
# Create a new project
uv init my-project
cd my-project

# Create with a specific Python version
uv init my-project --python 3.12

# Create a library (vs application)
uv init my-lib --lib
```

### pyproject.toml (the single source of truth)
Every Python project should have a `pyproject.toml`. Never use `setup.py` or `setup.cfg` for new projects.

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "Project description"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115",
    "sqlalchemy>=2.0",
    "pydantic>=2.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-asyncio>=0.24",
    "pytest-cov>=6.0",
    "ruff>=0.8",
    "mypy>=1.13",
]

[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "A", "SIM", "TCH"]

[tool.mypy]
python_version = "3.11"
strict = true

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
```

## Package Managers

| Tool | When to use | Commands |
|------|-------------|----------|
| **uv** | New projects (fastest, recommended) | `uv add`, `uv run`, `uv sync` |
| **pip** | Simple scripts, legacy projects | `pip install`, `pip freeze` |
| **poetry** | Existing poetry projects | `poetry add`, `poetry run` |
| **pipx** | CLI tools (install globally) | `pipx install ruff` |

### uv cheat sheet
```bash
uv add requests              # Add dependency
uv add --dev pytest          # Add dev dependency
uv remove requests           # Remove dependency
uv sync                      # Install all deps from lockfile
uv run pytest                # Run command in project env
uv run python script.py      # Run script
uv lock                      # Update lockfile
uv pip install -e .          # Editable install
uv python install 3.12       # Install a Python version
uv python pin 3.12           # Pin project Python version
```

## Virtual Environments

Always use a virtual environment. Never install packages globally.

```bash
# uv (automatic — creates .venv on first use)
uv sync

# Manual
python -m venv .venv
source .venv/bin/activate    # Linux/macOS
.venv\Scripts\activate       # Windows
```

## Code Quality Tools

### Ruff (linter + formatter — replaces flake8, isort, black)
```bash
ruff check .                 # Lint
ruff check --fix .           # Lint + auto-fix
ruff format .                # Format (like black)
ruff format --check .        # Check formatting
```

### Mypy (type checking)
```bash
mypy app/                    # Check types
mypy app/ --strict           # Strict mode (recommended)
```

### Common type annotation patterns
```python
from __future__ import annotations
from typing import Any
from collections.abc import Sequence, Mapping

# Function signatures
def process(items: list[str], count: int = 10) -> dict[str, int]: ...

# Optional values
def find(name: str) -> User | None: ...

# Generics
def first(items: Sequence[T]) -> T: ...

# Callable
from collections.abc import Callable
def retry(fn: Callable[..., T], times: int = 3) -> T: ...

# TypedDict for structured dicts
from typing import TypedDict
class Config(TypedDict):
    host: str
    port: int
    debug: bool
```

## Testing (pytest)

```bash
# Run all tests
uv run pytest tests/ -v

# Run specific file/test
uv run pytest tests/test_auth.py -v
uv run pytest tests/test_auth.py::test_login -v

# Run with coverage
uv run pytest --cov=app --cov-report=term-missing tests/

# Run only marked tests
uv run pytest -m "not slow" tests/

# Run tests matching a pattern
uv run pytest -k "test_login" tests/
```

### pytest fixtures
```python
import pytest
from unittest.mock import AsyncMock, patch

@pytest.fixture
def db_session():
    session = create_test_session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def mock_redis():
    with patch("app.cache.redis_client") as mock:
        mock.get = AsyncMock(return_value=None)
        yield mock
```

### Async testing
```python
import pytest

@pytest.mark.asyncio
async def test_fetch_user():
    user = await fetch_user(1)
    assert user.name == "Alice"
```

## Debugging

### pdb / breakpoint()
```python
# Insert breakpoint (Python 3.7+)
breakpoint()

# Or explicitly
import pdb; pdb.set_trace()
```

**pdb commands**: `n` (next), `s` (step into), `c` (continue), `p expr` (print), `l` (list code), `w` (where/stack), `q` (quit)

### Rich debugging (better tracebacks)
```python
from rich import traceback
traceback.install(show_locals=True)
```

### Logging (prefer over print)
```python
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

logger.debug("Processing %d items", len(items))
logger.info("User %s logged in", user.email)
logger.warning("Retry %d/%d", attempt, max_retries)
logger.error("Failed to connect", exc_info=True)
```

## Async Programming

### asyncio patterns
```python
import asyncio

# Run concurrent tasks
results = await asyncio.gather(
    fetch_users(),
    fetch_orders(),
    fetch_products(),
)

# With timeout
try:
    result = await asyncio.wait_for(slow_operation(), timeout=5.0)
except asyncio.TimeoutError:
    logger.error("Operation timed out")

# Task group (Python 3.11+, preferred over gather)
async with asyncio.TaskGroup() as tg:
    task1 = tg.create_task(fetch_users())
    task2 = tg.create_task(fetch_orders())
# All tasks are done here; exceptions propagate
```

### httpx (async HTTP client — preferred over requests)
```python
import httpx

async with httpx.AsyncClient() as client:
    response = await client.get("https://api.example.com/users")
    response.raise_for_status()
    data = response.json()
```

## Common Patterns

### Context managers
```python
from contextlib import contextmanager, asynccontextmanager

@contextmanager
def managed_connection(url: str):
    conn = connect(url)
    try:
        yield conn
    finally:
        conn.close()

@asynccontextmanager
async def managed_session():
    session = await create_session()
    try:
        yield session
    finally:
        await session.close()
```

### Dataclasses and Pydantic
```python
# Dataclass (stdlib — for internal data)
from dataclasses import dataclass, field

@dataclass
class Config:
    host: str
    port: int = 8000
    tags: list[str] = field(default_factory=list)

# Pydantic (for validation, serialization, API schemas)
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: str = Field(pattern=r"^[\w.-]+@[\w.-]+\.\w+$")
    age: int = Field(ge=0, le=150)
```

### Error handling
```python
# Custom exceptions
class AppError(Exception):
    """Base error for the application."""

class NotFoundError(AppError):
    """Resource not found."""

class ValidationError(AppError):
    """Input validation failed."""

# Structured error handling
try:
    user = await get_user(user_id)
except NotFoundError:
    raise HTTPException(status_code=404, detail="User not found")
except ValidationError as e:
    raise HTTPException(status_code=422, detail=str(e))
```

## Gotchas

- **Mutable default arguments**: Never use `def f(items=[])`. Use `def f(items: list | None = None)`.
- **`datetime.now()`**: Always use `datetime.now(UTC)` or `datetime.now(timezone.utc)`. Never naive datetimes.
- **String formatting**: Use f-strings for readability. Use `%s` format in logging (lazy evaluation).
- **`import *`**: Never use wildcard imports. Always import explicitly.
- **Circular imports**: Move imports inside functions or use `TYPE_CHECKING` guard.
- **`is` vs `==`**: Use `is` only for `None`, `True`, `False`. Use `==` for value comparison.
- **Global state**: Avoid module-level mutable state. Use dependency injection.

For framework-specific patterns (FastAPI, SQLAlchemy, Celery), see [references/frameworks.md](references/frameworks.md).
For Python tooling ecosystem overview, see [references/tooling.md](references/tooling.md).
