# Python Frameworks Reference

Detailed patterns for common Python frameworks. Load when working with a specific framework.

## FastAPI

### Project structure
```
app/
├── main.py              # App factory, lifespan
├── api/                 # Route handlers
│   ├── __init__.py
│   ├── deps.py          # Shared dependencies (get_db, get_user)
│   ├── users.py
│   └── auth.py
├── models/              # SQLAlchemy models
├── schemas/             # Pydantic request/response schemas
├── services/            # Business logic
├── repositories/        # Database access (CRUD)
├── core/
│   ├── config.py        # Settings (pydantic-settings)
│   ├── security.py      # JWT, hashing
│   └── database.py      # Engine, session factory
└── middleware/
```

### App factory pattern
```python
from contextlib import asynccontextmanager
from fastapi import FastAPI

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await init_db()
    yield
    # Shutdown
    await close_db()

def create_app() -> FastAPI:
    app = FastAPI(title="My API", lifespan=lifespan)
    app.include_router(users_router, prefix="/api/v1")
    app.include_router(auth_router, prefix="/api/v1")
    return app

app = create_app()
```

### Dependency injection
```python
from typing import Annotated
from fastapi import Depends

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        yield session

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    user = await verify_token(token, db)
    if not user:
        raise HTTPException(status_code=401)
    return user

# Use in endpoint
@router.get("/me")
async def get_me(
    user: Annotated[User, Depends(get_current_user)],
) -> UserResponse:
    return UserResponse.model_validate(user)
```

### Background tasks
```python
from fastapi import BackgroundTasks

@router.post("/users")
async def create_user(
    data: UserCreate,
    background_tasks: BackgroundTasks,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    user = await create_user_in_db(db, data)
    background_tasks.add_task(send_welcome_email, user.email)
    return user
```

### Settings with pydantic-settings
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    redis_url: str = "redis://localhost:6379"
    jwt_secret: str
    debug: bool = False

    model_config = {"env_file": ".env"}

settings = Settings()
```

---

## SQLAlchemy 2.0 (Async)

### Model definition
```python
from sqlalchemy import String, ForeignKey
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from datetime import datetime, UTC

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(100))
    created_at: Mapped[datetime] = mapped_column(default=lambda: datetime.now(UTC))
    is_active: Mapped[bool] = mapped_column(default=True)

    # Relationships
    posts: Mapped[list["Post"]] = relationship(back_populates="author")

class Post(Base):
    __tablename__ = "posts"

    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"))

    author: Mapped["User"] = relationship(back_populates="posts")
```

### Async engine and session
```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

engine = create_async_engine(
    "postgresql+asyncpg://user:pass@localhost:5432/db",
    echo=False,
    pool_size=20,
    max_overflow=10,
)

async_session = async_sessionmaker(engine, expire_on_commit=False)
```

### Repository pattern
```python
from sqlalchemy import select

class UserRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, user_id: int) -> User | None:
        result = await self.session.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> User | None:
        result = await self.session.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()

    async def create(self, data: UserCreate) -> User:
        user = User(**data.model_dump())
        self.session.add(user)
        await self.session.flush()
        return user
```

---

## Alembic (Database Migrations)

```bash
# Initialize
alembic init alembic

# Create migration
alembic revision --autogenerate -m "add users table"

# Apply
alembic upgrade head

# Rollback
alembic downgrade -1

# Show current
alembic current

# Show history
alembic history --verbose
```

### env.py setup for async
```python
# In alembic/env.py
from app.core.database import Base, engine

target_metadata = Base.metadata

async def run_async_migrations():
    async with engine.connect() as connection:
        await connection.run_sync(do_run_migrations)

def do_run_migrations(connection):
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()
```

---

## Celery (Background Tasks)

### Setup
```python
from celery import Celery

celery_app = Celery(
    "worker",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/1",
)

celery_app.conf.update(
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    timezone="UTC",
    task_track_started=True,
    task_acks_late=True,
    worker_prefetch_multiplier=1,
)
```

### Task definition
```python
@celery_app.task(bind=True, max_retries=3)
def process_upload(self, file_id: int) -> dict:
    try:
        result = do_processing(file_id)
        return {"status": "success", "file_id": file_id}
    except TransientError as e:
        self.retry(exc=e, countdown=60)
```

### Calling tasks (decoupled — use send_task)
```python
# Preferred: decoupled (no import of worker code in API)
celery_app.send_task("tasks.process_upload", args=[file_id])

# Direct (only if in same codebase)
process_upload.delay(file_id)
```

---

## Pydantic v2

### Model patterns
```python
from pydantic import BaseModel, Field, model_validator

class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: str
    password: str = Field(min_length=8)

class UserResponse(BaseModel):
    id: int
    name: str
    email: str

    model_config = {"from_attributes": True}  # enables ORM mode

class PaginatedResponse[T](BaseModel):
    items: list[T]
    total: int
    page: int
    page_size: int
```

### Validation
```python
class DateRange(BaseModel):
    start: date
    end: date

    @model_validator(mode="after")
    def validate_range(self) -> Self:
        if self.end < self.start:
            raise ValueError("end must be after start")
        return self
```
