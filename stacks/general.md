<!-- SECTION: Stack -->
## Stack

<!-- Define your stack below. Format: -->
<!-- **Core**: Language + Framework + Type System -->
<!-- **Data**: Database + ORM/Query Builder + Cache -->
<!-- **Testing**: Test Runner + Assertion Library + Coverage -->
<!-- **Tooling**: Package Manager + Linter + Formatter -->
<!--  -->
<!-- Example: -->
<!-- **Core**: TypeScript + Express + Zod -->
<!-- **Data**: PostgreSQL 16 + Prisma + Redis 7 -->
<!-- **Testing**: Vitest + supertest + c8 -->
<!-- **Tooling**: pnpm + ESLint + Prettier -->

Define your stack here.

<!-- SECTION: Behavioral Overrides -->
## Behavioral Overrides

7. Use your language's strictest type checking mode. Prefer immutable data.
10. Use your ecosystem's standard package manager. Pin dependency versions.

<!-- SECTION: Quality Overrides -->
## Quality Overrides

**Code**: Handle every state - loading, error (with retry), empty, data. Validate at system boundaries. Environment variables for secrets. No hardcoded values.
**Testing**: Test critical paths. Integration tests over unit tests where practical. Mock external services, not internal modules.
**Security**: Sanitize all inputs. Parameterized queries only. Rate limit public endpoints. No secrets in code or version control.

<!-- SECTION: Forbidden Patterns -->
## Forbidden Patterns

NEVER: secrets/credentials in source code | console.log/print in production code (use structured logging) | untested critical paths | silently ignoring errors | catch-all error handlers that swallow context | TODO/FIXME without linked issue | em dashes (use hyphens, colons, commas)

<!-- SECTION: File Structure -->
## File Structure

**Principles** (adapt to your framework):

```
project/
  src/                     # Application source code
    [entrypoint]           # Main entry point
    [routes/handlers]      # HTTP/API layer (thin - validate, delegate, respond)
    [services/domain]      # Business logic layer
    [data/repo]            # Data access layer
    [config]               # Configuration loading
    [utils/shared]         # Shared utilities
  tests/                   # Test files (mirror src/ structure or colocate)
  migrations/              # Database migrations (if applicable)
  [package manifest]       # package.json, pyproject.toml, go.mod, Cargo.toml
```

- Separate concerns: handlers, business logic, data access.
- Colocate related code. Tests near the code they test.
- Single responsibility per file. Split at ~400 lines.

<!-- SECTION: Conventions -->
## Conventions

- Validate all inputs at system boundaries. Trust nothing from outside.
- Handle every error explicitly. No silent failures.
- Test behavior, not implementation. Integration tests > unit tests.
- Structured logging with context (request ID, user ID, operation).
- Database migrations are append-only in production.
- Configuration from environment variables. `.env` for local dev only.
- Dependency injection over global state. Constructor injection preferred.
- One logical change per commit. Conventional commit messages.

<!-- SECTION: When Unsure -->
## When Unsure

- **Package choice**: check if your ecosystem/stdlib handles it first. Prefer well-maintained, focused libraries.
- **Architecture**: start simple. Add layers when complexity demands it, not before.
- **Database**: use your ORM/query builder. Raw SQL only for performance-critical queries.
- **State management**: server state and client state are different problems. Use different tools.
- **Technology choice**: choose boring technology. New and exciting = new and untested.
- **Build vs buy**: if a library does 1 thing you need + 50 you don't, write it yourself.
