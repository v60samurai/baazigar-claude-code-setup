# Customization Guide

Step-by-step guides for making this setup your own.

---

## Editing Your Identity

Open `~/.claude/CLAUDE.md` and find the Identity section near the top:

```markdown
## Identity

Developer: Baazigar (Harshit Badiger). PM building full-stack products. Bengaluru, India.
Claude is my CTO. I decide **what**. Claude decides **how** and holds the bar.
```

Replace this with your own details:
- Your name and role
- Your location (for timezone context)
- How you want Claude to interact with you (CTO, pair programmer, mentor, etc.)
- Your working style preferences

The Identity section shapes every interaction. Be specific about what you value.

---

## Changing Your Stack

### Option 1: Re-run the installer

```bash
cd /path/to/baazigar-claude-code-setup
./install.sh
```

Select a different stack when prompted. The installer backs up your current CLAUDE.md before overwriting.

### Option 2: Use a different preset

Available presets in the `stacks/` directory:

| File | Stack |
|------|-------|
| `react-nextjs.md` | React 19 + Next.js 15 + TypeScript + Tailwind |
| `python-fastapi.md` | Python + FastAPI + SQLAlchemy + Pydantic |
| `python-django.md` | Python + Django + DRF + Celery |
| `go.md` | Go + Chi/Gin + sqlc + PostgreSQL |
| `rust.md` | Rust + Axum/Actix + SQLx + PostgreSQL |
| `general.md` | Language-agnostic best practices |

### Option 3: Manual edit

Open `~/.claude/CLAUDE.md` and edit the stack-specific sections directly. Look for these markers:
- `## Stack` - your technology choices
- `## File Structure` - directory layout
- `## Conventions` - language-specific patterns
- `## When Unsure` - decision trees

---

## Adding Custom Commands

Commands are markdown files that Claude executes when you type the slash command.

### 1. Create the file

```bash
touch ~/.claude/commands/my-command.md
```

### 2. Write the command

```markdown
Review the following code for accessibility issues.

Focus on:
- ARIA attributes
- Keyboard navigation
- Screen reader compatibility
- Color contrast

Files to review: $ARGUMENTS
```

`$ARGUMENTS` is replaced with whatever the user types after the command.

### 3. Use it

```
/my-command src/components/Modal.tsx
```

### Tips
- Keep commands focused on one task
- Include specific criteria so Claude knows what "done" looks like
- Use `$ARGUMENTS` for the variable part (file paths, descriptions, etc.)

---

## Creating Custom Agents

Agents are specialized Claude instances with their own model, tools, and instructions.

### 1. Create the file

```bash
touch ~/.claude/agents/my-agent.md
```

### 2. Write the agent definition

```markdown
---
name: "performance-auditor"
description: "Analyzes code for performance bottlenecks and optimization opportunities"
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - WebSearch
model: "opus"
---

You are a performance auditor. Your job is to find performance bottlenecks in code.

## Process

1. Map the hot paths (most frequently executed code)
2. Identify N+1 queries, unnecessary re-renders, unoptimized loops
3. Check bundle size impact of imports
4. Look for missing memoization, indexes, or caching
5. Rank issues by impact (high/medium/low)

## Output

For each issue:
- File and line number
- What the problem is
- Why it matters (quantify if possible)
- Recommended fix with code example
```

### 3. Frontmatter fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Display name for the agent |
| `description` | Yes | One-line description of what it does |
| `tools` | Yes | List of tools the agent can use |
| `model` | No | `sonnet` (default) or `opus` |

---

## Writing Hooks

Hooks are scripts that run automatically at specific points in a Claude Code session.

### 1. Create the script

```bash
touch ~/.claude/hooks/my-hook.sh
chmod +x ~/.claude/hooks/my-hook.sh
```

```bash
#!/usr/bin/env bash
# Example: Log session start time
echo "Session started at $(date)" >> ~/.claude/session-log.txt
```

### 2. Register in settings.json

Edit `~/.claude/settings.json` and add to the `hooks` section:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/my-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### 3. Available events

| Event | When it fires |
|-------|--------------|
| `SessionStart` | When a Claude Code session begins |
| `PreToolUse` | Before Claude uses any tool (Read, Write, Bash, etc.) |
| `PostToolUse` | After Claude uses a tool |
| `Stop` | When a session ends or Claude stops responding |

The `matcher` field filters which tool invocations trigger the hook (for PreToolUse/PostToolUse). Leave empty to match all.

---

## Building a Local Plugin

The brand-guide plugin included in this setup is a working example. Here is how it is structured:

### 1. Directory structure

```
~/.claude/plugins/brand-guide/
  skills/
    manage-brand/
      SKILL.md           # Skill definition
    view-brand/
      SKILL.md
```

### 2. SKILL.md format

Each skill needs a `SKILL.md` file that defines:

```markdown
---
name: "manage-brand"
description: "Interactive wizard to define brand voice, tone, and style"
---

# Manage Brand

When the user runs /manage-brand, walk them through these questions:

1. What is your brand name?
2. What is your tagline?
3. Describe your brand voice in 3 adjectives
...

Save the results to ~/.claude/brand-guide.json
```

### 3. How local plugins are activated

Local plugins are registered in `~/.claude/settings.json` under the `plugins` key:

```json
{
  "plugins": {
    "brand-guide": {
      "enabled": true,
      "path": "~/.claude/plugins/brand-guide"
    }
  }
}
```

The installer handles this registration automatically.

---

## Setting Up Your Brand Guide

### 1. Run the wizard

```
/manage-brand
```

### 2. Answer the questions

The wizard asks about:
- Brand name and tagline
- Voice attributes (e.g., confident but not arrogant)
- Tone on a formal-to-casual spectrum
- Words to always use and words to avoid
- Target audience

### 3. View your guide

```
/view-brand
```

Displays the saved brand guidelines in a readable format.

### 4. Automatic injection

Once saved, the brand guide auto-injects into context whenever Claude is:
- Writing marketing copy
- Drafting documentation
- Creating user-facing text
- Composing emails or announcements

No extra commands needed - it activates based on the task.

---

## Adding Integration Plugins

Install any integration with the `claude plugin install` command:

```bash
# Deployment and hosting
claude plugin install vercel
claude plugin install firebase
claude plugin install supabase

# Code and project management
claude plugin install github
claude plugin install gitlab
claude plugin install linear
claude plugin install atlassian

# Communication
claude plugin install slack

# Payments
claude plugin install stripe

# Monitoring
claude plugin install sentry

# AI/ML
claude plugin install pinecone
claude plugin install huggingface-skills
```

Each plugin will prompt for any required API keys or authentication during installation.

---

## Contributing a Stack Preset

### 1. Copy the template

```bash
cp stacks/general.md stacks/my-stack.md
```

### 2. Fill in all 7 sections

Each stack preset uses section markers that the installer reads:

```markdown
<!-- SECTION: stack -->
**Core**: Your framework + language + key libraries
**UI**: Component library + styling approach
**State**: State management choices
**Data**: ORM + database + caching
**Backend**: API framework + protocols
**Auth**: Authentication approach
**Testing**: Test runner + utilities
**Tooling**: Package manager + linter + build tools

<!-- SECTION: file-structure -->
Your recommended directory layout

<!-- SECTION: conventions -->
Language and framework-specific patterns

<!-- SECTION: when-unsure -->
Decision trees for common questions

<!-- SECTION: behavioral-rules -->
Stack-specific rules (optional, supplements universal rules)

<!-- SECTION: quality-bar -->
Stack-specific quality criteria (optional)

<!-- SECTION: forbidden-patterns -->
Stack-specific anti-patterns (optional)
```

### 3. Submit a PR

- Branch from `main`
- Add your stack file to `stacks/`
- Update the README if needed
- Include a brief description of the stack and who it is for
