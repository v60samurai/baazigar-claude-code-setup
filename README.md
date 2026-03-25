# Baazigar Claude Code Setup

Production-ready Claude Code + iTerm2 setup. 60+ plugins, 8 commands, 3 agents, knowledge system, 6 stack presets. One command to install.

## What You Get

| Category | Count | Highlights |
|----------|-------|-----------|
| **Commands** | 8 | /commit, /debug, /explore, /plan, /refactor, /review, /ship, /test |
| **Agents** | 3 | researcher (web search), reviewer (code review), simplifier (reduce complexity) |
| **Hooks** | 2 | Session start (load context), session end (save learnings) |
| **Knowledge Templates** | 3 | Session journals, past mistakes log, decision records |
| **Plugin Bundles** | 60+ | Core workflow, dev tools, PM skills, integrations |
| **Stack Presets** | 6 | React/Next.js, Python/Django, Python/FastAPI, Go, Rust, General |
| **CLAUDE.md** | 1 | Battle-tested system prompt with your identity + stack injected |
| **Brand Guide Plugin** | 1 | Define your brand voice, tone, and style rules |
| **iTerm2 Setup** | Full | Oh My Zsh + Powerlevel10k + fonts + themes (macOS) |

## Quick Start

```bash
git clone https://github.com/v60samurai/baazigar-claude-code-setup.git
cd baazigar-claude-code-setup
bash install.sh
```

The installer walks you through everything interactively:
1. Your identity (name, role, working style)
2. Your stack (React, Python, Go, Rust, or General)
3. Plugin bundles (Core, Dev, PM, Integrations)
4. iTerm2 theme and prompt style (macOS only)

**Prerequisites:** The installer checks for and helps you install everything you need. If you're starting from scratch, it will guide you through installing Homebrew, git, Node.js, and Claude Code CLI step by step.

<details>
<summary>Manual prerequisite install (if you prefer doing it yourself)</summary>

**1. Homebrew (macOS only)**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2. Git**
```bash
# macOS (via Xcode tools)
xcode-select --install

# Ubuntu/Debian
sudo apt install git
```

**3. Node.js 18+**
```bash
# macOS
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

**4. Claude Code CLI**
```bash
npm install -g @anthropic-ai/claude-code
```
Then run `claude` once to log in with your Anthropic account.

</details>

## Plugin Bundles

### Core (always installed)
The workflow backbone. Brainstorming, planning, debugging, TDD, verification, cross-session memory, live docs lookup, code review.

**9 plugins** including: superpowers, episodic-memory, context7, code-review, code-simplifier, feature-dev, elements-of-style, plugin-dev, claude-mem

### Dev Power-Ups (opt-in)
130+ coding skills that auto-activate per language. PR review, browser testing, security scanning, agent development.

**10 plugins** including: everything-claude-code, pr-review-toolkit, superpowers-chrome, playwright, security-guidance

### PM Pack (opt-in)
40+ product management skills. PRDs, user stories, competitive analysis, sprint planning, A/B test analysis, pricing strategy.

**9 plugins** including: pm-execution, pm-product-strategy, pm-product-discovery, pm-market-research, pm-data-analytics

### Integrations (pick what you use)
Vercel, GitHub, Slack, Sentry, Firebase, Supabase, Stripe, Pinecone, Atlassian, Linear, GitLab, HuggingFace

[Full plugin details](docs/plugin-tiers.md)

## Stack Presets

Each preset configures your CLAUDE.md with stack-specific rules, forbidden patterns, file structure, conventions, and decision trees.

| Preset | Stack |
|--------|-------|
| **React / Next.js** | React 19, Next.js 15, TypeScript, Tailwind, shadcn/ui, pnpm, Biome |
| **Python / Django** | Django 5, DRF, PostgreSQL, pytest, ruff, uv, Celery |
| **Python / FastAPI** | FastAPI, Pydantic v2, SQLAlchemy 2.0, pytest, ruff, uv |
| **Go** | Go 1.22+, stdlib/Chi, sqlc, testify, golangci-lint |
| **Rust** | Axum, SQLx, tokio, serde, cargo |
| **General** | No stack opinion - universal rules only, customize later |

## The CLAUDE.md

The generated CLAUDE.md includes:

**Universal sections (every stack):**
- **BOOT** - Loads project knowledge before starting work
- **Think-Build-Prove** - Cognitive gears (Scope Expand / Hold / Reduce), priority order (Correct > Simple > Maintainable > Fast > Elegant), tripwires
- **Model Routing** - When to use Sonnet vs Opus, when to enable thinking
- **Behavioral Rules** - No TODOs, no scaffolds, 10 lines > 50 lines, validate everything
- **Quality Bar** - Security review, ship check, error state craft
- **Knowledge System** - Session journals, past mistakes, decision records

**Stack-specific sections:**
- Stack tools and libraries
- Forbidden patterns (what NEVER to use)
- File structure conventions
- Coding patterns and conventions
- Decision tree for common "which tool?" questions

## iTerm2 Setup (macOS)

The terminal setup is independent - you can install it without the Claude setup.

Includes:
- **iTerm2** via Homebrew
- **Oh My Zsh** with plugins (autosuggestions, syntax-highlighting, git, z)
- **Powerlevel10k** prompt with two presets (lean minimal or classic powerline)
- **MesloLGS NF** fonts (required by Powerlevel10k)
- **Two themes**: Light (#FAFAFA) and Dark (Catppuccin Mocha)

Run standalone: `bash iterm2/install-iterm2.sh`

## Customization

After installation, everything is yours to customize:

- **Edit CLAUDE.md** directly at `~/.claude/CLAUDE.md`
- **Add commands** - create `.md` files in `~/.claude/commands/`
- **Add agents** - create `.md` files in `~/.claude/agents/`
- **Add hooks** - create scripts in `~/.claude/hooks/`, register in settings.json
- **Build plugins** - the brand-guide plugin shows the pattern
- **Set up brand voice** - run `/manage-brand` in Claude Code

[Full customization guide](docs/customization.md)

## Uninstall

```bash
bash uninstall.sh
```

Restores all backed-up files. Does not remove plugins, iTerm2, or Oh My Zsh.

## Philosophy

This setup is built on the **Think-Build-Prove** methodology:

1. **Load context** - What was tried before? What failed?
2. **Challenge the ask** - Right problem? Right solution? Right time?
3. **Map the system** - Boundaries, data flows, failure modes
4. **Plan** - 3+ steps = plan mode
5. **Build in stages** - Verify each step
6. **Prove** - Run end-to-end, not just units

**Priority order:** Correct > Simple > Maintainable > Fast > Elegant

The knowledge system (session journals, past mistakes, decision records) ensures you learn from every session and never repeat the same class of error twice.

## Platform Support

| Platform | Claude Setup | iTerm2 Setup |
|----------|-------------|-------------|
| macOS | Full | Full |
| Linux / WSL | Full | Not available |
| Windows | Via WSL | Not available |

## Contributing

**Add a stack preset:**
1. Copy `stacks/general.md` as a template
2. Fill in all 7 sections with `<!-- SECTION: -->` markers
3. Submit a PR

**Suggest a plugin:** Open an issue with the plugin name, marketplace, and why it should be in a specific bundle.

## Credits

This setup curates plugins from these authors and communities:

- [Anthropic](https://github.com/anthropics/claude-plugins-official) - Official Claude Code plugins
- [obra/superpowers](https://github.com/obra/superpowers-marketplace) - Superpowers workflow plugins
- [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) - 130+ coding skills
- [phuryn/pm-skills](https://github.com/phuryn/pm-skills) - Product management skills
- [MadeByTokens](https://github.com/MadeByTokens/claude-code-plugins-madebytokens) - Resume helper and more
- [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) - Persistent memory system
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Dark theme color palette
- [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh prompt theme

## License

MIT
