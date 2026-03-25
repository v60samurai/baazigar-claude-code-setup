#!/bin/bash
# Baazigar: Session Start Hook
# Fires when Claude Code starts a new conversation.

# Add local binaries to PATH
echo "export PATH=$HOME/.local/bin:$PATH" >> "$CLAUDE_ENV_FILE"

# Remind to load project context
echo "Session started. Load project knowledge (past mistakes, decisions, session journals) before building."
