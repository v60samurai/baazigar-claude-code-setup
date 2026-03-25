#!/usr/bin/env bash
set -euo pipefail

# Baazigar Claude Code Setup - Uninstaller
# Reads the installation manifest and reverses file operations

MANIFEST="$HOME/.claude/.baazigar-manifest.json"
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

echo ""
echo -e "${BOLD}Baazigar Claude Code Setup - Uninstaller${RESET}"
echo "========================================="
echo ""

# ─── Step 1: Read manifest ───────────────────────────────────────────────────

if [[ ! -f "$MANIFEST" ]]; then
  echo "No installation found. Nothing to uninstall."
  echo ""
  echo -e "${DIM}If you installed manually, you can remove files from ~/.claude/ yourself.${RESET}"
  exit 0
fi

# ─── Step 2: Parse manifest with python3 ─────────────────────────────────────

if ! command -v python3 &>/dev/null; then
  echo -e "${RED}Error: python3 is required to parse the manifest.${RESET}"
  exit 1
fi

# Extract data from manifest
BACKUP_COUNT=$(python3 -c "
import json, sys
with open('$MANIFEST') as f:
    m = json.load(f)
print(len(m.get('backups', [])))
")

COPIED_COUNT=$(python3 -c "
import json, sys
with open('$MANIFEST') as f:
    m = json.load(f)
print(len(m.get('copiedFiles', [])))
")

INSTALLED_AT=$(python3 -c "
import json, sys
with open('$MANIFEST') as f:
    m = json.load(f)
print(m.get('installedAt', 'unknown'))
")

STACK=$(python3 -c "
import json, sys
with open('$MANIFEST') as f:
    m = json.load(f)
print(m.get('stack', 'unknown'))
")

# ─── Step 3: Show summary ────────────────────────────────────────────────────

echo -e "${BOLD}Installation found:${RESET}"
echo "  Installed at: $INSTALLED_AT"
echo "  Stack:        $STACK"
echo "  Backups:      $BACKUP_COUNT file(s) to restore"
echo "  Copied files: $COPIED_COUNT file(s) to remove"
echo ""

# Show backup details
if [[ "$BACKUP_COUNT" -gt 0 ]]; then
  echo -e "${BOLD}Files to restore from backup:${RESET}"
  python3 -c "
import json
with open('$MANIFEST') as f:
    m = json.load(f)
for b in m.get('backups', []):
    print(f\"  {b['backup']} -> {b['original']}\")
"
  echo ""
fi

# Show copied file details
if [[ "$COPIED_COUNT" -gt 0 ]]; then
  echo -e "${BOLD}Files to remove:${RESET}"
  python3 -c "
import json
with open('$MANIFEST') as f:
    m = json.load(f)
for f_path in m.get('copiedFiles', []):
    print(f'  {f_path}')
"
  echo ""
fi

echo -e "${YELLOW}Will NOT touch:${RESET}"
echo "  - Installed plugins (claude plugin list to see them)"
echo "  - iTerm2 profile/settings"
echo "  - Oh My Zsh installation"
echo "  - Homebrew packages"
echo "  - Marketplace sources"
echo ""

# ─── Step 4: Ask for confirmation ────────────────────────────────────────────

read -rp "Proceed with uninstall? (y/N) " confirm
if [[ "${confirm,,}" != "y" ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""

# ─── Step 5: Restore backed-up files ─────────────────────────────────────────

RESTORED=0
RESTORE_FAILED=0

if [[ "$BACKUP_COUNT" -gt 0 ]]; then
  echo -e "${BOLD}Restoring backups...${RESET}"

  python3 -c "
import json
with open('$MANIFEST') as f:
    m = json.load(f)
for b in m.get('backups', []):
    print(b['backup'] + '|||' + b['original'])
" | while IFS='|||' read -r backup_path original_path; do
    if [[ -f "$backup_path" ]]; then
      mv "$backup_path" "$original_path"
      echo -e "  ${GREEN}Restored${RESET}: $original_path"
      RESTORED=$((RESTORED + 1))
    else
      echo -e "  ${RED}Backup not found${RESET}: $backup_path (skipped)"
      RESTORE_FAILED=$((RESTORE_FAILED + 1))
    fi
  done
fi

# ─── Step 6: Remove copied files ─────────────────────────────────────────────

REMOVED=0
REMOVE_SKIPPED=0

if [[ "$COPIED_COUNT" -gt 0 ]]; then
  echo -e "${BOLD}Removing copied files...${RESET}"

  python3 -c "
import json
with open('$MANIFEST') as f:
    m = json.load(f)
for f_path in m.get('copiedFiles', []):
    print(f_path)
" | while IFS= read -r file_path; do
    if [[ -f "$file_path" ]]; then
      rm "$file_path"
      echo -e "  ${GREEN}Removed${RESET}: $file_path"
      REMOVED=$((REMOVED + 1))
    else
      echo -e "  ${DIM}Already gone${RESET}: $file_path"
      REMOVE_SKIPPED=$((REMOVE_SKIPPED + 1))
    fi
  done

  # Clean up empty directories left behind (only within ~/.claude/)
  find "$HOME/.claude/commands" "$HOME/.claude/agents" "$HOME/.claude/templates" "$HOME/.claude/hooks" \
    -type d -empty -delete 2>/dev/null || true
fi

# ─── Step 7: Remove the manifest ─────────────────────────────────────────────

rm "$MANIFEST"
echo ""
echo -e "${GREEN}Manifest removed.${RESET}"

# ─── Step 8: Summary ─────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Uninstall complete.${RESET}"
echo ""
echo "What was done:"
echo "  - Backed-up files restored to their original locations"
echo "  - Copied files (commands, agents, hooks, templates, settings) removed"
echo "  - Installation manifest deleted"
echo ""
echo "What was left intentionally:"
echo "  - Plugins: run 'claude plugin list' and 'claude plugin remove <name>' manually"
echo "  - iTerm2 profile and settings"
echo "  - Oh My Zsh and its plugins"
echo "  - Homebrew-installed packages (jq, python3, etc.)"
echo "  - Marketplace sources in claude settings"
echo "  - Any files you created or modified after installation"
echo ""
echo -e "${DIM}To fully remove Claude Code itself, see: https://docs.anthropic.com/en/docs/claude-code${RESET}"
