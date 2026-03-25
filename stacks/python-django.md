<!-- SECTION: Stack -->
## Stack

**Core**: Python 3.12+ + Django 5 + Django REST Framework
**Data**: PostgreSQL 16 + Redis 7
**Async**: Celery (task queue)
**Optional**: django-ninja (fast API alternative to DRF)
**Testing**: pytest + pytest-django + Factory Boy + coverage
**Tooling**: uv (always) + ruff (lint + format) + pre-commit + mypy
**API**: DRF serializers + viewsets + routers. OpenAPI via drf-spectacular.

<!-- SECTION: Behavioral Overrides -->
## Behavioral Overrides

7. Type hints on all functions. Prefer dataclasses over dicts. f-strings over format().
10. `uv` only. Never pip install directly. pyproject.toml for dependencies.

<!-- SECTION: Quality Overrides -->
## Quality Overrides

**API**: API-first. OpenAPI docs auto-generated via drf-spectacular. 100% migration coverage.
**Code**: Type hints everywhere. Structured logging with python-json-logger. No raw SQL - use the ORM. Transactions for multi-model writes.
**Testing**: pytest with fixtures. Factory Boy for test data. 80%+ coverage minimum.
**Security**: CSRF protection on. Content-Security-Policy headers. django-axes for brute-force protection. Parameterized queries only.

<!-- SECTION: Forbidden Patterns -->
## Forbidden Patterns

NEVER: bare `except:` (always specify exception type) | `print()` in production (use `logging`) | raw SQL (use Django ORM) | `requirements.txt` (use pyproject.toml) | global mutable state | `from module import *` | `pip install` directly | class-based views without justification (prefer function views for simple cases) | em dashes (use hyphens, colons, commas)

<!-- SECTION: File Structure -->
## File Structure

```
project/
  apps/
    core/                 # Shared models, utils, mixins
    users/                # User model, auth, profiles
    [feature]/            # Feature-specific app
      models.py
      serializers.py
      views.py
      urls.py
      tasks.py            # Celery tasks
      tests/
        test_models.py
        test_views.py
        factories.py
  config/
    settings/
      base.py             # Shared settings
      local.py            # Dev overrides
      production.py       # Prod settings
    urls.py               # Root URL config
    celery.py             # Celery app config
    wsgi.py
  tests/                  # Integration/E2E tests
  manage.py
  pyproject.toml
```

<!-- SECTION: Conventions -->
## Conventions

- Fat models, thin views. Business logic lives in model methods or service layers, not views.
- DRF serializers for all input validation. Never trust request.data directly.
- Factory Boy for test data. Never use fixtures files - factories are composable and explicit.
- Celery for anything async: emails, webhooks, reports, cleanup jobs.
- Structured logging with `logging.getLogger(__name__)`. JSON format in production.
- Migrations are append-only in production. Squash in dev when needed.
- Custom user model from day one. Never use Django's default User.
- Signals sparingly - prefer explicit method calls. Signals hide control flow.

<!-- SECTION: When Unsure -->
## When Unsure

- **Admin interface**: Django admin for internal CRUD - customize before building custom UI.
- **Async work**: Celery for background tasks. Django channels only if WebSockets needed.
- **API**: DRF for REST APIs. django-ninja if you want FastAPI-like syntax.
- **Testing**: pytest fixtures over setUp/tearDown. Factory Boy over raw model creation.
- **Package**: check Django ecosystem first (django-* packages). Prefer well-maintained packages with Django integration.
