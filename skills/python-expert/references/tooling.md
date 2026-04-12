# Python Tooling Ecosystem

Comprehensive reference for Python development tools. Organized by category.

## Package & Environment Management

| Tool | Purpose | Install | Key Commands |
|------|---------|---------|--------------|
| **uv** | Fast package manager + resolver | `curl -LsSf https://astral.sh/uv/install.sh \| sh` | `uv add`, `uv sync`, `uv run` |
| **pip** | Standard package installer | Built-in | `pip install`, `pip freeze` |
| **pipx** | Install CLI tools globally | `uv tool install pipx` | `pipx install ruff` |
| **pyenv** | Manage Python versions | System-specific | `pyenv install 3.12` |
| **venv** | Virtual environments (stdlib) | Built-in | `python -m venv .venv` |

### Recommended: uv for everything
```bash
uv init my-project          # Create project
uv add fastapi              # Add dep
uv add --dev pytest         # Add dev dep
uv sync                     # Install from lockfile
uv run pytest               # Run in project env
uv python install 3.12      # Install Python version
uv tool install ruff        # Install CLI tool globally
```

## Code Quality

| Tool | Purpose | Config |
|------|---------|--------|
| **ruff** | Linter + formatter (replaces flake8, isort, black, pyflakes, pycodestyle) | `pyproject.toml` → `[tool.ruff]` |
| **mypy** | Static type checker | `pyproject.toml` → `[tool.mypy]` |
| **pyright** | Type checker (Microsoft, faster) | `pyrightconfig.json` |
| **bandit** | Security linter | `pyproject.toml` → `[tool.bandit]` |

### Ruff configuration (recommended)
```toml
[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "F",    # pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "A",    # flake8-builtins
    "SIM",  # flake8-simplify
    "TCH",  # type-checking imports
    "RUF",  # ruff-specific rules
]
ignore = [
    "E501",  # line length (handled by formatter)
]

[tool.ruff.lint.isort]
known-first-party = ["app"]
```

### Mypy configuration (strict recommended)
```toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

# Per-module overrides
[[tool.mypy.overrides]]
module = ["tests.*"]
disallow_untyped_defs = false
```

## Testing

| Tool | Purpose |
|------|---------|
| **pytest** | Test runner (standard) |
| **pytest-asyncio** | Async test support |
| **pytest-cov** | Coverage reporting |
| **pytest-xdist** | Parallel test execution |
| **pytest-mock** | Mocker fixture |
| **factory_boy** | Test data factories |
| **responses** / **httpx-mock** | HTTP mocking |
| **freezegun** | Time mocking |
| **hypothesis** | Property-based testing |

### pytest configuration
```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
addopts = "-v --tb=short --strict-markers"
markers = [
    "slow: marks tests as slow",
    "integration: marks integration tests",
]
```

### Coverage configuration
```toml
[tool.coverage.run]
source = ["app"]
omit = ["tests/*", "*/__pycache__/*"]

[tool.coverage.report]
fail_under = 80
show_missing = true
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "if __name__",
]
```

## Web Frameworks

| Framework | Best For | Style |
|-----------|----------|-------|
| **FastAPI** | REST APIs, async, modern | Async, Pydantic, DI |
| **Django** | Full-stack web apps, admin | Batteries-included, ORM |
| **Flask** | Simple APIs, microservices | Minimal, sync |
| **Litestar** | FastAPI alternative | Async, opinionated |

## ORMs & Database

| Tool | Purpose |
|------|---------|
| **SQLAlchemy 2.0** | Full ORM + query builder |
| **Alembic** | Database migrations (for SQLAlchemy) |
| **asyncpg** | Fast async PostgreSQL driver |
| **psycopg** | PostgreSQL driver (sync/async) |

## Task Queues

| Tool | Purpose |
|------|---------|
| **Celery** | Distributed task queue (mature, feature-rich) |
| **Dramatiq** | Simple task queue (Celery alternative) |
| **ARQ** | Async task queue (lightweight, uses asyncio) |
| **Huey** | Simple task queue (SQLite/Redis) |

## HTTP Clients

| Tool | Purpose |
|------|---------|
| **httpx** | Async + sync HTTP (modern, recommended) |
| **requests** | Sync HTTP (legacy, widely used) |
| **aiohttp** | Async HTTP client + server |

## Data Validation & Serialization

| Tool | Purpose |
|------|---------|
| **Pydantic v2** | Data validation, settings, API schemas |
| **dataclasses** | Simple data containers (stdlib) |
| **attrs** | Advanced data classes |
| **msgspec** | Fast serialization (JSON, MessagePack) |

## CLI Tools

| Tool | Purpose |
|------|---------|
| **typer** | CLI framework (like click but with type hints) |
| **click** | CLI framework (mature) |
| **argparse** | CLI parsing (stdlib) |
| **rich** | Terminal formatting, progress bars, tables |

## Profiling & Performance

| Tool | Purpose | Command |
|------|---------|---------|
| **cProfile** | CPU profiling (stdlib) | `python -m cProfile script.py` |
| **py-spy** | Sampling profiler (no code change needed) | `py-spy top -- python script.py` |
| **memory_profiler** | Memory usage per line | `@profile` decorator |
| **scalene** | CPU + memory + GPU profiler | `scalene script.py` |
| **line_profiler** | Line-by-line CPU profiling | `@profile` decorator |

## Pre-commit

### `.pre-commit-config.yaml`
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.13.0
    hooks:
      - id: mypy
        additional_dependencies: [pydantic, sqlalchemy[mypy]]
```

```bash
# Install hooks
pre-commit install

# Run on all files
pre-commit run --all-files
```

## Docker

### Multi-stage Dockerfile (Python)
```dockerfile
FROM python:3.12-slim AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /app/.venv /app/.venv
COPY . .
ENV PATH="/app/.venv/bin:$PATH"
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## CI/CD (GitHub Actions)

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v4
      - run: uv sync --dev
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run mypy app/
      - run: uv run pytest tests/ --cov=app --cov-report=xml
```
