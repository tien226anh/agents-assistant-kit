# AGENTS.md

## Project Overview
Python web API built with FastAPI.

## Command Safety
**Read-only commands only.** Agents must NEVER run commands that mutate state, delete data, modify infrastructure, or have destructive side-effects.

- ✅ **Allowed**: `git status`, `git diff`, `uv run pytest`, `uv run ruff check`, `uv run mypy`, `alembic current`, `alembic history`, `curl` (GET), `psql` (SELECT), `docker ps`, `kubectl get`
- ❌ **Forbidden**: `rm`, `git push`, `git commit`, `alembic upgrade/downgrade`, `docker rm`, `kubectl delete`, `DROP/ALTER/INSERT/UPDATE/DELETE` queries, any deploy command
- When the user explicitly asks to run a mutating command, confirm with the user before executing.

## Setup Commands
- Install dependencies: `uv sync`
- Run dev server: `uv run uvicorn app.main:app --reload --port 8000`
- Run tests: `uv run pytest tests/ -v`
- Lint: `uv run ruff check .`
- Format: `uv run ruff format .`
- Type check: `uv run mypy app/`
- Database migration (create): `uv run alembic revision --autogenerate -m "<description>"`
- Database migration (apply): `uv run alembic upgrade head`
- Database migration (rollback): `uv run alembic downgrade -1`

## Code Style
- Python 3.11+ features are OK (match statements, ExceptionGroup, etc.)
- Use `async def` for all endpoint handlers
- Use type hints everywhere — `mypy --strict` must pass
- Prefer `Annotated[type, Depends(...)]` over `= Depends(...)` for dependency injection
- Use Pydantic v2 `model_validator` over `validator` (v1 deprecated)
- Imports: stdlib → third-party → local, separated by blank lines
- Use `from __future__ import annotations` in all files

## Testing Instructions
- Run all tests: `uv run pytest tests/ -v`
- Run specific test: `uv run pytest tests/test_auth.py::test_login -v`
- Run with coverage: `uv run pytest --cov=app tests/`
- Use `httpx.AsyncClient` for API tests (not `TestClient` for async endpoints)
- Use `pytest-asyncio` with `@pytest.mark.asyncio` for async tests
- Database tests use transactions that roll back after each test

## Architecture Notes
- **Framework**: FastAPI with async SQLAlchemy
- **Database**: PostgreSQL with Alembic migrations
- **Auth**: JWT access + refresh tokens, stored in httponly cookies
- **Background tasks**: Celery with Redis broker
- **File structure**:
  ```
  app/
  ├── main.py          # FastAPI app factory
  ├── api/             # Route handlers (grouped by domain)
  ├── models/          # SQLAlchemy models
  ├── schemas/         # Pydantic request/response schemas
  ├── services/        # Business logic
  ├── repositories/    # Database access layer
  └── core/            # Config, deps, middleware
  ```

## Gotchas
- Use `async with get_session() as session:` — never create sessions manually
- Alembic migrations must be backward-compatible (support rolling deploys)
- Environment variables are loaded via `pydantic-settings`, not `os.environ`
- `created_at` and `updated_at` are set by the database, not by Python
- API pagination uses cursor-based pagination, not offset-based
- All datetimes are UTC. Never use `datetime.now()` — use `datetime.now(UTC)`

## PR Conventions
- Branch: `feature/`, `fix/`, `chore/`, `refactor/`
- Commits: Conventional Commits (`feat(auth): add refresh token rotation`)
- PRs must pass: `ruff check`, `ruff format --check`, `mypy`, `pytest`
- Include migration in PR if schema changes
