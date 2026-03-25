<!-- SECTION: Stack -->
## Stack

**Core**: Go 1.22+ + stdlib `net/http` (or Chi/Echo for routing)
**Data**: sqlc (type-safe SQL) + goose (migrations) + PostgreSQL 16
**Logging**: slog (structured, stdlib)
**Testing**: testify + go test + testcontainers-go
**Tooling**: go mod + golangci-lint + goreleaser (releases)
**HTTP**: stdlib net/http or Chi/Echo. No heavy frameworks.

<!-- SECTION: Behavioral Overrides -->
## Behavioral Overrides

7. Idiomatic Go. Accept interfaces, return structs. Error wrapping with `fmt.Errorf("%w", err)`.
10. `go mod` only. Minimal dependencies. Prefer stdlib.

<!-- SECTION: Quality Overrides -->
## Quality Overrides

**API**: API-first. Structured logging with slog. Graceful shutdown with `signal.NotifyContext`.
**Code**: Error handling is not optional - every error checked. Context propagation through all layers. No goroutine leaks - always cancel contexts.
**Testing**: Table-driven tests. Testcontainers for integration tests. Race detector in CI (`-race`).
**Security**: No secrets in code. Rate limiting on public endpoints. Input validation at handler level. SQL injection impossible with sqlc.

<!-- SECTION: Forbidden Patterns -->
## Forbidden Patterns

NEVER: `init()` functions (explicit initialization only) | package-level mutable variables (except sentinel errors) | `panic()` for recoverable errors | global state for dependency injection | interface pollution (accept interfaces, return structs) | `fmt.Println` in production (use slog) | ignoring errors with `_` | naked goroutines without lifecycle management | em dashes (use hyphens, colons, commas)

<!-- SECTION: File Structure -->
## File Structure

```
cmd/
  server/
    main.go               # Entry point, wiring, graceful shutdown
internal/
  handler/                 # HTTP handlers (thin - validate, delegate, respond)
    users.go
    [feature].go
  service/                 # Business logic layer
    users.go
  repo/                    # Database access (sqlc-generated + custom)
    queries/               # SQL files for sqlc
    users.go
  middleware/              # HTTP middleware (auth, logging, recovery)
  config/                  # Configuration loading
    config.go
pkg/                       # Reusable packages (only if truly generic)
migrations/                # goose migration files
  001_initial.sql
sqlc.yaml                  # sqlc configuration
go.mod
go.sum
Makefile                   # Build, test, lint, migrate commands
```

<!-- SECTION: Conventions -->
## Conventions

- Table-driven tests for all functions with multiple cases. Subtests with `t.Run()`.
- Context propagation: every function that does I/O takes `context.Context` as first param.
- Graceful shutdown: `signal.NotifyContext` + `server.Shutdown(ctx)`. Clean up connections.
- Error wrapping: `fmt.Errorf("operation failed: %w", err)`. Sentinel errors with `errors.Is()`.
- Minimal interfaces: define interfaces where they're consumed, not where they're implemented.
- sqlc for database: write SQL, generate Go. Type-safe, no ORM magic.
- Dependency injection via struct constructors. No framework needed - just `New*` functions.
- Makefile for common commands: `make build`, `make test`, `make lint`, `make migrate`.

<!-- SECTION: When Unsure -->
## When Unsure

- **HTTP routing**: stdlib `net/http` with Go 1.22 routing first. Chi only if you need middleware chaining.
- **Database**: sqlc for type-safe SQL. No ORMs - write the SQL you want to run.
- **Testing**: testify for assertions. Testcontainers for integration tests against real DB.
- **Logging**: slog (stdlib). No third-party loggers needed.
- **Config**: envconfig or viper for env vars. Keep it simple.
- **Package choice**: stdlib first. Only add a dependency if it saves significant complexity.
