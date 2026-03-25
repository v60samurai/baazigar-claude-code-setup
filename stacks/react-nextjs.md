<!-- SECTION: Stack -->
## Stack

**Core**: React 19 + Next.js 15 App Router + TypeScript (strict) + Tailwind CSS 4
**UI**: shadcn/ui + Base UI. Icons: Lucide (default), Phosphor (duotone only).
**State**: Zustand (client) + Jotai (atomic) + TanStack Query (server)
**Forms**: React Hook Form + Zod
**Data**: Drizzle (queries) + Prisma (schema/migrations) + PostgreSQL 16 + Redis 7
**Backend**: Fastify or Hono + tRPC (internal), REST (external)
**Auth**: Lucia + Arctic + Oslo (session-based) or Clerk/next-auth (managed)
**Testing**: Vitest + Testing Library + Playwright + MSW
**Tooling**: pnpm (always) + Biome + Turborepo + Husky + lint-staged + commitlint
**Animation**: Framer Motion (component) + GSAP + ScrollTrigger (scroll) + React Three Fiber (3D) + React Spring (physics) + Lottie (handoff) + Magic UI / Aceternity UI (pre-built)

<!-- SECTION: Behavioral Overrides -->
## Behavioral Overrides

7. TypeScript strict. No `any`. Arrow functions. Server Components by default.
10. `pnpm` only. Never npm. Never yarn. Check if installed before `pnpm add`.

<!-- SECTION: Quality Overrides -->
## Quality Overrides

**UX**: Mobile-first. 44px touch targets. Confirm destructive actions. Toast feedback. <2s load. Dark mode.
**Code**: Server Components default. No console.logs. Handle every state: loading - error (with retry) - empty - data. Validate at boundaries. Env vars for secrets. Batch DB queries. `.maybeSingle()` not `.single()`.
**Security**: Sanitize inputs. Admin server-side only. Verify RLS after migrations. Rate limit auth + paid ops. Cross-user queries = admin client only.

<!-- SECTION: Forbidden Patterns -->
## Forbidden Patterns

NEVER: CSS-in-JS/styled-components/Emotion | Redux/MobX/Recoil/SWR | Webpack | class components | Ant Design/MUI/Chakra/Mantine/Radix directly | moment.js/date-fns (dayjs only) | barrel file imports (unless tree-shaking confirmed) | console.log in committed code (Pino for backend) | npm | yarn | em dashes (use hyphens, colons, commas)

<!-- SECTION: File Structure -->
## File Structure

```
src/
  app/                    # Routes (route groups: (auth), (dashboard))
    api/                  # API routes (BFF pattern: Promise.allSettled for N queries)
    layout.tsx            # Font loading, metadata, providers
    page.tsx
  components/
    ui/                   # shadcn/ui primitives
    [feature]/            # Feature-specific
  lib/
    db/                   # Drizzle schema + queries
    auth/                 # Auth config
    validators/           # Zod schemas (shared FE+BE)
    utils.ts              # cn(), helpers
    trpc/                 # tRPC router + client
  hooks/                  # Custom React hooks
  styles/globals.css      # Tailwind directives + CSS variables
  types/                  # TypeScript type definitions
```

<!-- SECTION: Conventions -->
## Conventions

- `interface` for objects, `type` for unions/intersections. `const` assertions + `satisfies` over explicit types.
- `"use client"` only when hooks/interactivity needed. Colocate server actions with forms.
- `Suspense` + `loading.tsx` for async. No manual loading booleans.
- `cn()` for conditional classes. CSS variables for theme tokens. Mobile-first breakpoints.
- Drizzle for queries, Prisma for migrations. Transactions for multi-table writes. Index WHERE/JOIN/ORDER columns.
- tRPC internal, REST external. Version external APIs from day one. Rate limit public endpoints.
- Test behavior, not implementation. Integration > unit. MSW for API mocks. Testcontainers for DB.
- Bug recurs = regression test before the fix.

<!-- SECTION: When Unsure -->
## When Unsure

- **UI component**: check shadcn/ui first.
- **Animation**: Framer Motion (component-level), GSAP (scroll-driven).
- **State**: API data = TanStack Query. Client-only = Zustand.
- **Data fetching**: Server Components `async`. Client = TanStack Query.
- **Package**: check if something in the stack handles it first.
- **Library does 1 thing you need + 50 you don't**: write it yourself.
