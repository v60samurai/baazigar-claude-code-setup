<!-- SECTION: Stack -->
## Stack

**Core**: Rust stable + tokio (async runtime)
**Web**: Axum (or Actix-web) + tower (middleware)
**Data**: SQLx (compile-time checked SQL) + PostgreSQL 16
**Serialization**: serde + serde_json
**Error Handling**: thiserror (libraries) + anyhow (applications)
**Testing**: cargo test + testcontainers + rstest
**Tooling**: cargo + clippy + rustfmt + cargo-watch + cargo-nextest

<!-- SECTION: Behavioral Overrides -->
## Behavioral Overrides

7. Ownership-first design. `Result<T, E>` for all fallible ops. Minimize `.unwrap()`.
10. `cargo` only. Workspace for multi-crate projects.

<!-- SECTION: Quality Overrides -->
## Quality Overrides

**API**: API-first. Compile-time guarantees over runtime checks. Zero `unsafe` in application code.
**Code**: All errors handled with `Result<T, E>`. Custom error types with thiserror. Clone only when necessary - prefer borrowing. Zero-cost abstractions.
**Testing**: Integration tests in `tests/`. Property-based testing with proptest for serialization. Benchmark critical paths with criterion.
**Security**: No unsafe without justification. Validate all external input. Use `secrecy` crate for sensitive values.

<!-- SECTION: Forbidden Patterns -->
## Forbidden Patterns

NEVER: `.unwrap()` in library/application code (use `?` or explicit handling) | `unsafe` without justification and safety comment | `Box<dyn Any>` (use concrete types or proper trait objects) | `panic!` in production paths | `.unwrap_or_default()` hiding real errors | `println!` in production (use tracing) | `clone()` to satisfy the borrow checker without understanding why | `String` where `&str` suffices | em dashes (use hyphens, colons, commas)

<!-- SECTION: File Structure -->
## File Structure

```
Cargo.toml                 # Workspace definition
crates/
  api/
    src/
      lib.rs               # Route definitions, app state
      handlers/            # Request handlers
      middleware/          # Tower middleware layers
      extractors/          # Custom Axum extractors
  domain/
    src/
      lib.rs
      models/              # Domain types + business logic
      services/            # Business logic orchestration
      errors.rs            # Domain error types (thiserror)
  infra/
    src/
      lib.rs
      db/                  # SQLx queries + migrations
      external/            # Third-party API clients
      config.rs            # Configuration (from env)
tests/                     # Integration tests
  api_tests.rs
benches/                   # Criterion benchmarks
migrations/                # SQLx migrations
  001_initial.sql
```

<!-- SECTION: Conventions -->
## Conventions

- Derive macros for serde: `#[derive(Serialize, Deserialize)]`. Use `#[serde(rename_all = "camelCase")]` for JSON APIs.
- Builder pattern for complex struct construction. Use `typed-builder` or manual impl.
- thiserror for library/domain error types. anyhow for application-level error propagation.
- Trait objects at abstraction boundaries (e.g., repository traits). Concrete types within crates.
- SQLx with compile-time query checking. Run `cargo sqlx prepare` for offline mode in CI.
- Tower middleware for cross-cutting concerns: tracing, auth, rate limiting.
- tracing crate for structured logging. `#[instrument]` on async functions.
- Prefer `From`/`Into` implementations for type conversions over manual mapping.

<!-- SECTION: When Unsure -->
## When Unsure

- **Async runtime**: tokio. No other choice needed.
- **Serialization**: serde. Always.
- **Error handling**: thiserror for defining error types. anyhow for propagating in binaries.
- **Database**: SQLx for compile-time checked queries. Diesel if you want a full ORM.
- **Middleware**: tower - composable, reusable across frameworks.
- **HTTP framework**: Axum (tower-native, extractors). Actix-web if you need maximum throughput.
- **Package choice**: check crates.io. Prefer crates with recent activity and no unsafe.
