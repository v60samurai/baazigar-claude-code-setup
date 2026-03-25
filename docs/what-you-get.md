# What You Get

Everything included in the Baazigar Claude Code Setup, organized by category.

---

## Commands (8)

Slash commands you can run inside any Claude Code session.

| Command | What it does | Example |
|---------|-------------|---------|
| `/commit` | Reviews staged changes, writes a conventional commit message, commits | `/commit` after staging files |
| `/debug` | Root-cause debugging: reproduce the bug, trace the cause, fix it, verify | `/debug TypeError: Cannot read property 'id' of undefined` |
| `/explore` | Codebase onboarding: maps architecture, key files, data flows | `/explore` in a new project |
| `/plan` | Creates an implementation plan before writing any code | `/plan add Stripe subscription billing` |
| `/refactor` | Zero-behavior-change refactoring with before/after verification | `/refactor src/lib/auth.ts - extract session logic` |
| `/review` | Two-pass code review: security/logic first, then style/improvements | `/review src/app/api/checkout/route.ts` |
| `/ship` | Pre-ship checklist: runs tests, lint, type-check, checks for common issues | `/ship` before merging |
| `/test` | Writes behavior-focused tests for a module or feature | `/test src/components/DataTable.tsx` |

---

## Agents (3)

Specialized agents with dedicated models and toolsets.

| Agent | Model | What it does |
|-------|-------|-------------|
| `researcher` | Sonnet | Deep research via web search and documentation. Finds answers, compares options, summarizes findings. |
| `reviewer` | Opus | Code review focused on bugs, security vulnerabilities, and architectural issues. Two-pass: critical then informational. |
| `simplifier` | Opus | Reduces complexity without changing behavior. Finds abstractions to remove, code to inline, files to merge. |

**Usage**: Agents are invoked automatically when Claude Code determines the task matches their specialty, or you can reference them directly.

---

## Hooks (2)

Automated scripts that run at session boundaries.

### session-start.sh
Runs when you start a Claude Code session. Reminds you to:
- Load the project's CLAUDE.md
- Check for existing session journals and past mistakes
- Resume where you left off

### session-end.sh
Runs when a session ends. Prompts you to save learnings:
- Write a session journal (what was built, decisions made, bugs found)
- Record past mistakes (abstracted to the class of error, not the instance)
- Log decision records (architectural choices with tradeoffs)

---

## Knowledge System Templates (3)

Templates stored in `~/.claude/templates/` for maintaining project memory across sessions.

### session-journal.md
End-of-session documentation template. Fields:
- Date and project
- Goal for the session
- What was built
- Decisions made (and why)
- Bugs encountered and fixes
- Learnings
- Next session TODOs

### past-mistakes.md
Bug pattern documentation. For each entry:
- What happened (the specific bug)
- The class of error it represents
- Rule to prevent this class of error in the future

The key insight: abstract the pattern, not the instance. "Always validate response shape before destructuring" prevents an entire class of bugs, not just one.

### decision-record.md
Architecture Decision Record (ADR) template. Fields:
- Title and date
- Status (proposed, accepted, deprecated, superseded)
- Context (why this decision was needed)
- Options considered (with tradeoffs for each)
- Decision and rationale
- Consequences (what changes, what risks remain)

---

## Brand Guide Plugin

A local plugin for maintaining consistent brand voice across all writing.

### /manage-brand
Interactive wizard that walks you through defining:
- Brand name and tagline
- Voice attributes (e.g., confident, approachable, technical)
- Tone guidelines (formal vs casual, humor level, jargon tolerance)
- Writing style rules (sentence length, active voice, specific words to use/avoid)
- Audience description

### /view-brand
Displays the current brand guidelines in a readable format. Use this to verify your brand guide before writing copy.

The brand guide auto-injects into context when Claude is writing marketing copy, documentation, or user-facing text.

---

## CLAUDE.md

The installer creates `~/.claude/CLAUDE.md` from a template system:

### Universal Sections (always included)
- **Identity**: Who you are, how Claude should work with you
- **Think-Build-Prove**: The cognitive framework for approaching tasks
- **Model Routing**: When to use Sonnet vs Opus, when to enable thinking
- **Behavioral Rules**: Code quality standards and working principles
- **Quality Bar**: Checklists for code, UX, security, and architecture
- **Forbidden Patterns**: Libraries, patterns, and practices to avoid
- **Knowledge System**: How session journals, past mistakes, and decisions work

### Stack-Specific Sections (based on your choice)
- **Stack**: Your exact technology choices (framework, ORM, state management, etc.)
- **File Structure**: Directory layout conventions
- **Conventions**: Language-specific patterns and best practices
- **When Unsure**: Decision tree for common "which tool should I use?" questions

Available stack presets: `react-nextjs`, `python-fastapi`, `python-django`, `go`, `rust`, `general`

---

## Settings

The installer configures `~/.claude/settings.json` with:

### Permissions
Pre-approves common safe operations so Claude doesn't ask for confirmation on every file read or shell command. Includes: `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `WebFetch`, `WebSearch`, `mcp__*`, and specific shell commands (`npm`, `pnpm`, `git`, `node`, etc.).

### Hooks
- `SessionStart` event triggers the session-start reminder
- `Stop` event triggers the session-end prompt

### Plugin Marketplaces
Adds the Anthropic marketplace and the superpowers community marketplace so you can install plugins with `claude plugin install`.

### Plugin Settings
Enables installed plugins (brand-guide, etc.) with their required permissions.
