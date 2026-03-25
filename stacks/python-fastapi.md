<!-- SECTION: Stack -->
## Stack

**Core**: Python 3.12+ + FastAPI + Pydantic v2 + Uvicorn
**ORM**: SQLAlchemy 2.0 (async) + Alembic (migrations)
**Data**: PostgreSQL 16 + Redis 7
**Testing**: pytest + pytest-asyncio + httpx + coverage
**Tooling**: uv (always) + ruff (lint + format) + pre-commit + mypy
**HTTP Client**: httpx (async)
**Background**: Celery or ARQ for task queues

<!-- SECTION: Behavioral Overrides -->
## Behavioral Overrides

7. Type hints everywhere. Pydantic models for all I/O. Async by default.
10. `uv` only. pyproject.toml for all dependencies.

<!-- SECTION: Quality Overrides -->
## Quality Overrides

**API**: API-first. Auto OpenAPI docs. < 100ms p99 latency target.
**Code**: Async by default. Pydantic for all request/response models. Dependency injection via `Depends()`. Structured logging with structlog.
**Testing**: httpx.AsyncClient for API tests. pytest-asyncio for async tests. Test against real DB with Testcontainers.
**Security**: Rate limiting with slowapi. CORS configured explicitly. JWT or session auth - never roll your own crypto.

<!-- SECTION: Forbidden Patterns -->
## Forbidden Patterns

NEVER: sync DB calls in async routes | `Any` type annotations | `requirements.txt` (use pyproject.toml) | bare `except:` | `print()` in production (use structlog/logging) | raw SQL without parameterization | `pip install` directly | global mutable state for request-scoped data | em dashes (use hyphens, colons, commas)

<!-- SECTION: File Structure -->
## File Structure

```
src/
  api/
    routes/               # Route handlers grouped by domain
      users.py
      [feature].py
    dependencies.py       # Shared Depends() functions
    middleware.py          # Custom middleware
  domain/
    models/               # Domain/business models
    services/             # Business logic layer
    schemas/              # Pydantic models (request/response)
  infra/
    db/
      models.py           # SQLAlchemy models
      session.py          # DB session factory
      repositories/       # Repository pattern implementations
    cache.py              # Redis client
    external/             # Third-party API clients
  core/
    config.py             # Settings via pydantic-settings
    security.py           # Auth utilities
    exceptions.py         # Custom exceptions + handlers
  tests/
    api/                  # API integration tests
    domain/               # Unit tests for business logic
    conftest.py           # Shared fixtures
  main.py                 # FastAPI app factory
  pyproject.toml
  alembic/                # Migration scripts
    versions/
    env.py
```

<!-- SECTION: Conventions -->
## Conventions

- Dependency injection via `Depends()` for everything: DB sessions, auth, services.
- Repository pattern for database access. Never call SQLAlchemy directly from routes.
- Pydantic models for all input validation and response serialization. Separate request/response schemas.
- httpx for all HTTP client calls. Always async. Always with timeouts.
- Alembic for migrations. Auto-generate from SQLAlchemy models. Review before applying.
- pydantic-settings for configuration. Environment variables for secrets. `.env` for local dev only.
- Structured logging with structlog. Correlation IDs for request tracing.
- Background tasks: `BackgroundTasks` for fire-and-forget. Celery/ARQ for reliable job processing.

<!-- SECTION: When Unsure -->
## When Unsure

- **Validation**: Pydantic models - never validate manually.
- **ORM**: SQLAlchemy 2.0 with async session. Use `select()` style, not legacy Query API.
- **HTTP client**: httpx (async). Never requests in async code.
- **Background tasks**: `BackgroundTasks` for simple. Celery/ARQ for reliable/retryable.
- **Auth**: FastAPI security utilities + python-jose for JWT. Never roll your own.
- **Package**: check FastAPI ecosystem first. Prefer packages with async support.
