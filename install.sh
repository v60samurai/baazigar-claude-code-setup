#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Baazigar Claude Code Setup - One-command installer
# https://github.com/baazigar/baazigar-claude-code-setup
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
MANIFEST_FILE="$CLAUDE_DIR/.baazigar-manifest.json"
BACKUP_LOG=$(mktemp)
COPIED_FILES_LOG=$(mktemp)
PLUGINS_LOG=$(mktemp)

# --- Colors and output -----------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

info()    { printf "${BLUE}[info]${RESET}  %s\n" "$*"; }
success() { printf "${GREEN}[ok]${RESET}    %s\n" "$*"; }
warn()    { printf "${YELLOW}[warn]${RESET}  %s\n" "$*"; }
error()   { printf "${RED}[err]${RESET}   %s\n" "$*" >&2; }

prompt_yn() {
    local prompt="$1" default="${2:-Y}"
    local yn_hint="[Y/n]"
    [[ "$default" == "N" || "$default" == "n" ]] && yn_hint="[y/N]"

    printf "${BOLD}%s${RESET} %s " "$prompt" "$yn_hint"
    read -r answer
    answer="${answer:-$default}"
    [[ "$answer" =~ ^[Yy] ]]
}

# --- Welcome banner --------------------------------------------------------

welcome_banner() {
    printf "\n"
    printf "${BOLD}${BLUE}"
    cat << 'BANNER'
  ____                  _
 | __ )  __ _  __ _ ___(_) __ _  __ _ _ __
 |  _ \ / _` |/ _` |_  / |/ _` |/ _` | '__|
 | |_) | (_| | (_| |/ /| | (_| | (_| | |
 |____/ \__,_|\__,_/___|_|\__, |\__,_|_|
                           |___/
BANNER
    printf "${RESET}"
    printf "${BOLD}  Claude Code Setup${RESET}\n"
    printf "${DIM}  One-command installer for CLAUDE.md, commands, agents, hooks, and plugins.${RESET}\n"
    printf "\n"
}

# --- Prerequisites ----------------------------------------------------------

install_homebrew() {
    if command -v brew &>/dev/null; then
        success "Homebrew already installed."
        return 0
    fi

    printf "\n"
    info "Homebrew is a package manager for macOS (like apt for Linux)."
    info "It lets you install developer tools with simple commands."
    printf "\n"

    if prompt_yn "Install Homebrew now?" Y; then
        info "Installing Homebrew (this may take a few minutes)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to PATH for this session (Apple Silicon vs Intel)
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if command -v brew &>/dev/null; then
            success "Homebrew installed."
        else
            error "Homebrew installation failed. Try manually:"
            printf "  ${BOLD}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${RESET}\n"
            printf "  Then re-run this installer.\n"
            return 1
        fi
    else
        warn "Skipping Homebrew. Some prerequisites may need manual installation."
        return 1
    fi
}

install_git() {
    if command -v git &>/dev/null; then
        success "git $(git --version | awk '{print $3}') found."
        return 0
    fi

    printf "\n"
    printf "${BOLD}Git is not installed.${RESET}\n"
    info "Git is version control software - it tracks changes to your code."
    info "You already used it to clone this repo, so it's likely installed."
    printf "\n"

    if [[ "$(uname)" == "Darwin" ]]; then
        info "On macOS, the easiest way to install git:"
        printf "\n"
        printf "  ${BOLD}Option 1 (recommended):${RESET} Install Xcode Command Line Tools:\n"
        printf "    ${DIM}xcode-select --install${RESET}\n"
        printf "    This opens a popup - click 'Install' and wait ~5 minutes.\n"
        printf "\n"
        printf "  ${BOLD}Option 2:${RESET} Install via Homebrew:\n"
        printf "    ${DIM}brew install git${RESET}\n"
        printf "\n"

        if prompt_yn "Try installing via Xcode Command Line Tools now?" Y; then
            xcode-select --install 2>/dev/null || true
            printf "\n"
            warn "A popup may have appeared. Click 'Install' and wait for it to finish."
            printf "${BOLD}Press Enter when the installation is complete...${RESET}"
            read -r

            if command -v git &>/dev/null; then
                success "git installed."
                return 0
            else
                error "git still not found. Install manually and re-run."
                return 1
            fi
        fi
    else
        info "On Linux, install git with your package manager:"
        printf "\n"
        printf "  ${BOLD}Ubuntu/Debian:${RESET}  sudo apt install git\n"
        printf "  ${BOLD}Fedora:${RESET}         sudo dnf install git\n"
        printf "  ${BOLD}Arch:${RESET}           sudo pacman -S git\n"
        printf "\n"
    fi

    error "Please install git and re-run this installer."
    return 1
}

install_node() {
    if command -v node &>/dev/null; then
        local node_major
        node_major=$(node -v | sed 's/v//' | cut -d. -f1)
        if (( node_major >= 18 )); then
            success "Node.js $(node -v) found."
            return 0
        else
            warn "Node.js $(node -v) found, but version 18 or higher is required."
        fi
    fi

    printf "\n"
    printf "${BOLD}Node.js is not installed (or too old).${RESET}\n"
    info "Node.js is a JavaScript runtime. Claude Code is built with it."
    info "You need version 18 or higher."
    printf "\n"

    if [[ "$(uname)" == "Darwin" ]]; then
        info "Recommended install methods for macOS:"
        printf "\n"
        printf "  ${BOLD}Option 1 (recommended):${RESET} Install via Homebrew:\n"
        printf "    ${DIM}brew install node${RESET}\n"
        printf "    This installs the latest LTS version.\n"
        printf "\n"
        printf "  ${BOLD}Option 2:${RESET} Download from nodejs.org:\n"
        printf "    ${DIM}https://nodejs.org${RESET}\n"
        printf "    Download the LTS version and run the installer.\n"
        printf "\n"
        printf "  ${BOLD}Option 3:${RESET} Use a version manager (nvm):\n"
        printf "    ${DIM}curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash${RESET}\n"
        printf "    ${DIM}nvm install --lts${RESET}\n"
        printf "\n"

        if command -v brew &>/dev/null; then
            if prompt_yn "Install Node.js via Homebrew now?" Y; then
                info "Installing Node.js..."
                brew install node

                if command -v node &>/dev/null; then
                    success "Node.js $(node -v) installed."
                    return 0
                fi
            fi
        else
            info "Install Homebrew first (we'll ask about it next), then use 'brew install node'."
        fi
    else
        info "Recommended install methods for Linux:"
        printf "\n"
        printf "  ${BOLD}Option 1 (recommended):${RESET} Use NodeSource:\n"
        printf "    ${DIM}curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -${RESET}\n"
        printf "    ${DIM}sudo apt install -y nodejs${RESET}\n"
        printf "\n"
        printf "  ${BOLD}Option 2:${RESET} Use nvm (version manager):\n"
        printf "    ${DIM}curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash${RESET}\n"
        printf "    ${DIM}source ~/.bashrc && nvm install --lts${RESET}\n"
        printf "\n"
    fi

    if ! command -v node &>/dev/null; then
        error "Node.js not found. Please install it and re-run."
        return 1
    fi
}

install_claude_cli() {
    if command -v claude &>/dev/null; then
        success "Claude Code CLI found."
        return 0
    fi

    printf "\n"
    printf "${BOLD}Claude Code CLI is not installed.${RESET}\n"
    info "Claude Code is Anthropic's AI coding assistant for the terminal."
    info "It's what this entire setup configures."
    printf "\n"
    info "Requirements before installing Claude Code:"
    printf "  - Node.js 18+ (we'll check this first)\n"
    printf "  - An Anthropic account (free to create at anthropic.com)\n"
    printf "\n"

    if ! command -v node &>/dev/null; then
        error "Node.js must be installed first. Install Node.js, then re-run."
        return 1
    fi

    printf "  ${BOLD}Install command:${RESET}\n"
    printf "    ${DIM}npm install -g @anthropic-ai/claude-code${RESET}\n"
    printf "\n"

    if prompt_yn "Install Claude Code CLI now?" Y; then
        info "Installing Claude Code CLI (this may take a minute)..."

        # Use npm even if pnpm is preferred - global installs are fine with npm
        if npm install -g @anthropic-ai/claude-code 2>/dev/null; then
            if command -v claude &>/dev/null; then
                success "Claude Code CLI installed."
                printf "\n"
                info "First-time setup: Run 'claude' in your terminal to log in with your Anthropic account."
                info "You can do this after the installer finishes."
                return 0
            fi
        fi

        error "Installation failed. Try manually:"
        printf "    ${DIM}npm install -g @anthropic-ai/claude-code${RESET}\n"
        printf "\n"
        info "If you get a permission error, try:"
        printf "    ${DIM}sudo npm install -g @anthropic-ai/claude-code${RESET}\n"
        printf "\n"
        info "Or fix npm permissions (recommended):"
        printf "    ${DIM}https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally${RESET}\n"
        return 1
    else
        error "Claude Code CLI is required. Install it and re-run."
        return 1
    fi
}

check_prereqs() {
    printf "\n${BOLD}--- Checking Prerequisites ---${RESET}\n\n"

    local all_ok=true

    # On macOS, offer Homebrew first (other installs depend on it)
    if [[ "$(uname)" == "Darwin" ]]; then
        install_homebrew || all_ok=false
    fi

    # Check/install in dependency order: git -> node -> claude
    install_git || all_ok=false
    install_node || all_ok=false
    install_claude_cli || all_ok=false

    if ! $all_ok; then
        printf "\n"
        error "Some prerequisites could not be installed."
        info "Install the missing tools listed above, then re-run:"
        printf "    ${BOLD}bash install.sh${RESET}\n"
        exit 1
    fi

    printf "\n"
    success "All prerequisites OK."
}

# --- Existing install check -------------------------------------------------

IS_UPDATE=false
EXISTING_NAME=""
EXISTING_HANDLE=""
EXISTING_ROLE=""
EXISTING_LOCATION=""
EXISTING_WORKING_STYLE=""

check_existing_install() {
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        return
    fi

    local installed_at stack
    installed_at=$(python3 -c "import json; m=json.load(open('$MANIFEST_FILE')); print(m.get('installedAt','unknown'))" 2>/dev/null || echo "unknown")
    stack=$(python3 -c "import json; m=json.load(open('$MANIFEST_FILE')); print(m.get('stack','unknown'))" 2>/dev/null || echo "unknown")

    printf "\n"
    warn "Existing Baazigar install detected."
    info "  Installed: $installed_at"
    info "  Stack:     $stack"
    printf "\n"

    if prompt_yn "Update existing install (keeps identity, refreshes files)?" Y; then
        IS_UPDATE=true
        EXISTING_NAME=$(python3 -c "import json; m=json.load(open('$MANIFEST_FILE')); print(m.get('identity',{}).get('name',''))" 2>/dev/null || echo "")
        EXISTING_HANDLE=$(python3 -c "import json; m=json.load(open('$MANIFEST_FILE')); print(m.get('identity',{}).get('handle',''))" 2>/dev/null || echo "")
        EXISTING_ROLE=$(python3 -c "import json; m=json.load(open('$MANIFEST_FILE')); print(m.get('identity',{}).get('role',''))" 2>/dev/null || echo "")
        EXISTING_LOCATION=$(python3 -c "import json; m=json.load(open('$MANIFEST_FILE')); print(m.get('identity',{}).get('location',''))" 2>/dev/null || echo "")
        EXISTING_WORKING_STYLE=$(python3 -c "import json; m=json.load(open('$MANIFEST_FILE')); print(m.get('identity',{}).get('workingStyle',''))" 2>/dev/null || echo "")
    else
        info "Starting fresh install."
    fi
}

# --- Identity prompts -------------------------------------------------------

USER_NAME=""
USER_HANDLE=""
USER_ROLE=""
USER_LOCATION=""
USER_WORKING_STYLE=""

prompt_identity() {
    if $IS_UPDATE && [[ -n "$EXISTING_NAME" ]]; then
        USER_NAME="$EXISTING_NAME"
        USER_HANDLE="$EXISTING_HANDLE"
        USER_ROLE="$EXISTING_ROLE"
        USER_LOCATION="$EXISTING_LOCATION"
        USER_WORKING_STYLE="$EXISTING_WORKING_STYLE"
        info "Using saved identity: $USER_NAME ($USER_HANDLE)"
        return
    fi

    printf "\n${BOLD}--- Identity ---${RESET}\n\n"

    while [[ -z "$USER_NAME" ]]; do
        printf "${BOLD}Your name:${RESET} "
        read -r USER_NAME
        [[ -z "$USER_NAME" ]] && warn "Name is required."
    done

    while [[ -z "$USER_HANDLE" ]]; do
        printf "${BOLD}GitHub username or alias:${RESET} "
        read -r USER_HANDLE
        [[ -z "$USER_HANDLE" ]] && warn "Handle is required."
    done

    while [[ -z "$USER_ROLE" ]]; do
        printf "${BOLD}Your role (e.g., 'Full-stack developer', 'PM building products'):${RESET} "
        read -r USER_ROLE
        [[ -z "$USER_ROLE" ]] && warn "Role is required."
    done

    printf "${BOLD}City, Country ${DIM}(optional, press Enter to skip):${RESET} "
    read -r USER_LOCATION

    printf "${BOLD}How should Claude work with you?${RESET}\n"
    printf "${DIM}  Default: Push back with data, not opinion. One issue per question - lead with recommendation + tradeoffs.${RESET}\n"
    printf "${BOLD}  Custom ${DIM}(optional, press Enter for default):${RESET} "
    read -r USER_WORKING_STYLE
    USER_WORKING_STYLE="${USER_WORKING_STYLE:-Push back with data, not opinion. One issue per question - lead with recommendation + tradeoffs.}"
}

# --- Stack prompt -----------------------------------------------------------

STACK_CHOICE=""
STACK_FILE=""

prompt_stack() {
    printf "\n${BOLD}--- Stack ---${RESET}\n\n"
    printf "  ${BOLD}1)${RESET} React / Next.js ${DIM}(TypeScript, Tailwind, shadcn/ui, pnpm)${RESET}\n"
    printf "  ${BOLD}2)${RESET} Python / Django ${DIM}(DRF, PostgreSQL, pytest, uv)${RESET}\n"
    printf "  ${BOLD}3)${RESET} Python / FastAPI ${DIM}(Pydantic, SQLAlchemy, pytest, uv)${RESET}\n"
    printf "  ${BOLD}4)${RESET} Go ${DIM}(stdlib/Chi, sqlc, testify, golangci-lint)${RESET}\n"
    printf "  ${BOLD}5)${RESET} Rust ${DIM}(Axum, SQLx, tokio, cargo)${RESET}\n"
    printf "  ${BOLD}6)${RESET} General ${DIM}(no stack opinion - customize later)${RESET}\n"
    printf "\n"

    local choice
    while true; do
        printf "${BOLD}Pick your primary stack [1-6]:${RESET} "
        read -r choice
        case "$choice" in
            1) STACK_CHOICE="react-nextjs"; STACK_FILE="react-nextjs.md"; break ;;
            2) STACK_CHOICE="python-django"; STACK_FILE="python-django.md"; break ;;
            3) STACK_CHOICE="python-fastapi"; STACK_FILE="python-fastapi.md"; break ;;
            4) STACK_CHOICE="go"; STACK_FILE="go.md"; break ;;
            5) STACK_CHOICE="rust"; STACK_FILE="rust.md"; break ;;
            6) STACK_CHOICE="general"; STACK_FILE="general.md"; break ;;
            *) warn "Enter a number 1-6." ;;
        esac
    done

    success "Stack: $STACK_CHOICE"
}

# --- Bundle prompts ---------------------------------------------------------

BUNDLE_DEV=false
BUNDLE_PM=false
INTEGRATIONS=()

INTEGRATION_NAMES=(
    "Vercel"
    "GitHub"
    "Slack"
    "Sentry"
    "Firebase"
    "Supabase"
    "Stripe"
    "Pinecone"
    "Atlassian"
    "Linear"
    "GitLab"
    "HuggingFace"
)

INTEGRATION_SLUGS=(
    "vercel"
    "github"
    "slack"
    "sentry"
    "firebase"
    "supabase"
    "stripe"
    "pinecone"
    "atlassian"
    "linear"
    "gitlab"
    "huggingface"
)

prompt_bundles() {
    printf "\n${BOLD}--- Bundles ---${RESET}\n\n"

    info "Core bundle: always installed (CLAUDE.md, commands, agents, hooks, templates)"

    prompt_yn "Install developer power-ups? (130+ coding skills, PR review, browser testing)" Y && BUNDLE_DEV=true
    prompt_yn "Install PM skills? (40+ product management skills)" N && BUNDLE_PM=true

    printf "\n${BOLD}Integrations ${DIM}(enter comma-separated numbers, or 'none'):${RESET}\n"
    for i in "${!INTEGRATION_NAMES[@]}"; do
        printf "  ${BOLD}%2d)${RESET} %s\n" "$((i + 1))" "${INTEGRATION_NAMES[$i]}"
    done
    printf "\n"

    printf "${BOLD}Your picks (e.g., 1,2,5):${RESET} "
    read -r picks

    if [[ "$picks" != "none" && -n "$picks" ]]; then
        IFS=',' read -ra pick_arr <<< "$picks"
        for p in "${pick_arr[@]}"; do
            p=$(echo "$p" | tr -d ' ')
            if [[ "$p" =~ ^[0-9]+$ ]] && (( p >= 1 && p <= ${#INTEGRATION_NAMES[@]} )); then
                INTEGRATIONS+=("${INTEGRATION_SLUGS[$((p - 1))]}")
            fi
        done
    fi

    if (( ${#INTEGRATIONS[@]} > 0 )); then
        success "Integrations: ${INTEGRATIONS[*]}"
    else
        info "No integrations selected."
    fi
}

# --- Backup helper ----------------------------------------------------------

backup_file() {
    local filepath="$1"
    if [[ -f "$filepath" ]]; then
        local backup_path="${filepath}.backup.$(date +%s)"
        cp "$filepath" "$backup_path"
        printf "%s|%s\n" "$filepath" "$backup_path" >> "$BACKUP_LOG"
        info "Backed up: $filepath -> $backup_path"
    fi
}

# --- Generate CLAUDE.md -----------------------------------------------------

generate_claude_md() {
    info "Generating CLAUDE.md..."

    local template_file="$SCRIPT_DIR/claude/CLAUDE.md.template"
    local stack_file="$SCRIPT_DIR/stacks/$STACK_FILE"
    local output_file="$CLAUDE_DIR/CLAUDE.md"

    backup_file "$output_file"

    # Handle optional location
    local identity_location="${USER_LOCATION}"

    # Use python3 for all template processing (cross-platform, handles multi-line safely)
    python3 << 'PYEOF' - "$template_file" "$stack_file" "$output_file" "$USER_NAME" "$USER_HANDLE" "$USER_ROLE" "$identity_location" "$USER_WORKING_STYLE"
import sys, re

template_file = sys.argv[1]
stack_file = sys.argv[2]
output_file = sys.argv[3]
user_name = sys.argv[4]
user_handle = sys.argv[5]
user_role = sys.argv[6]
user_location = sys.argv[7]
user_working_style = sys.argv[8]

with open(template_file, "r") as f:
    template = f.read()

with open(stack_file, "r") as f:
    stack_content = f.read()

def extract_section(content, section_name):
    """Extract content between SECTION markers."""
    pattern = rf'<!-- SECTION: {re.escape(section_name)} -->\n(.*?)(?=<!-- SECTION:|$)'
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        return ""
    text = match.group(1).strip()
    # Remove the ## header line if present
    lines = text.split("\n")
    if lines and lines[0].startswith("## "):
        lines = lines[1:]
    return "\n".join(lines).strip()

stack_section = extract_section(stack_content, "Stack")
behavioral_overrides = extract_section(stack_content, "Behavioral Overrides")
quality_overrides = extract_section(stack_content, "Quality Overrides")
forbidden_patterns = extract_section(stack_content, "Forbidden Patterns")
file_structure = extract_section(stack_content, "File Structure")
conventions = extract_section(stack_content, "Conventions")
when_unsure = extract_section(stack_content, "When Unsure")

# Extract behavioral rules 7 and 10
rule_7 = "Follow language-idiomatic style strictly."
rule_10 = "Use the project's package manager. Check before adding dependencies."
for line in behavioral_overrides.split("\n"):
    stripped = line.strip()
    if stripped.startswith("7."):
        rule_7 = stripped
    elif stripped.startswith("10."):
        rule_10 = stripped

# Apply replacements
output = template
output = output.replace("{{NAME}}", user_name)
output = output.replace("{{HANDLE}}", user_handle)
output = output.replace("{{ROLE}}", user_role)
output = output.replace("{{LOCATION}}", user_location)
output = output.replace("{{WORKING_STYLE}}", user_working_style)
output = output.replace("{{STACK_SECTION}}", stack_section)
output = output.replace("{{BEHAVIORAL_RULE_7}}", rule_7)
output = output.replace("{{BEHAVIORAL_RULE_10}}", rule_10)
output = output.replace("{{QUALITY_OVERRIDES}}", quality_overrides + "\n" if quality_overrides else "")
output = output.replace("{{FORBIDDEN_PATTERNS}}", forbidden_patterns)
output = output.replace("{{FILE_STRUCTURE}}", file_structure)
output = output.replace("{{CONVENTIONS}}", conventions)
output = output.replace("{{WHEN_UNSURE}}", when_unsure)

with open(output_file, "w") as f:
    f.write(output)
PYEOF

    echo "$output_file" >> "$COPIED_FILES_LOG"
    success "Generated: $output_file"
}

# --- Copy universal files ---------------------------------------------------

copy_universal_files() {
    info "Copying commands, agents, hooks, templates, and plugins..."

    local dirs=("commands" "agents" "hooks" "templates")
    for dir in "${dirs[@]}"; do
        local src="$SCRIPT_DIR/claude/$dir"
        local dest="$CLAUDE_DIR/$dir"

        if [[ ! -d "$src" ]]; then
            warn "Source directory not found: $src"
            continue
        fi

        mkdir -p "$dest"

        for file in "$src"/*; do
            [[ -f "$file" ]] || continue
            local basename
            basename=$(basename "$file")
            backup_file "$dest/$basename"
            cp "$file" "$dest/$basename"
            echo "$dest/$basename" >> "$COPIED_FILES_LOG"
        done
    done

    # Make hooks executable
    if [[ -d "$CLAUDE_DIR/hooks" ]]; then
        chmod +x "$CLAUDE_DIR/hooks"/*.sh 2>/dev/null || true
    fi

    # Copy brand-guide plugin
    local plugin_src="$SCRIPT_DIR/claude/plugins/brand-guide"
    local plugin_dest="$CLAUDE_DIR/plugins/brand-guide"
    if [[ -d "$plugin_src" ]]; then
        mkdir -p "$plugin_dest"
        cp -R "$plugin_src/"* "$plugin_dest/" 2>/dev/null || true
        echo "$plugin_dest" >> "$COPIED_FILES_LOG"
    fi

    success "Copied universal files."
}

# --- Merge settings ---------------------------------------------------------

merge_settings() {
    info "Merging settings.json..."

    local existing_settings="$CLAUDE_DIR/settings.json"
    local base_settings="$SCRIPT_DIR/claude/settings.json.template"

    backup_file "$existing_settings"

    python3 << PYEOF
import json, os, sys

base_path = "$base_settings"
existing_path = "$existing_settings"
output_path = existing_path
stack = "$STACK_CHOICE"
bundle_dev = "$BUNDLE_DEV" == "true"
bundle_pm = "$BUNDLE_PM" == "true"

# Integrations
integrations_str = "${INTEGRATIONS[*]:-}"
integrations = integrations_str.split() if integrations_str.strip() else []

# Load base settings
with open(base_path) as f:
    settings = json.load(f)

# Load existing settings if present
existing = {}
if os.path.exists(existing_path):
    try:
        with open(existing_path) as f:
            existing = json.load(f)
    except (json.JSONDecodeError, IOError):
        pass

# Stack-specific allow permissions
stack_allow = {
    "react-nextjs": ["Bash(pnpm *)", "Bash(biome *)", "Bash(turbo *)", "Bash(playwright *)"],
    "python-django": ["Bash(python *)", "Bash(pip *)", "Bash(uv *)", "Bash(pytest *)", "Bash(ruff *)"],
    "python-fastapi": ["Bash(python *)", "Bash(pip *)", "Bash(uv *)", "Bash(pytest *)", "Bash(ruff *)"],
    "go": ["Bash(go *)", "Bash(golangci-lint *)"],
    "rust": ["Bash(cargo *)", "Bash(rustup *)"],
    "general": [],
}

# Stack-specific deny permissions
stack_deny = {
    "react-nextjs": ["Bash(npm *)", "Bash(yarn *)"],
}

# Add stack permissions
allow_list = settings.get("permissions", {}).get("allow", [])
for perm in stack_allow.get(stack, []):
    if perm not in allow_list:
        allow_list.append(perm)
settings["permissions"]["allow"] = allow_list

deny_list = settings.get("permissions", {}).get("deny", [])
for perm in stack_deny.get(stack, []):
    if perm not in deny_list:
        deny_list.append(perm)
settings["permissions"]["deny"] = deny_list

# Build enabledPlugins with correct plugin names from the spec
enabled_plugins = {}

# Core bundle (always)
core_plugins = [
    "superpowers@claude-plugins-official",
    "episodic-memory@superpowers-marketplace",
    "context7@claude-plugins-official",
    "code-review@claude-plugins-official",
    "code-simplifier@claude-plugins-official",
    "feature-dev@claude-plugins-official",
    "elements-of-style@superpowers-marketplace",
    "plugin-dev@claude-plugins-official",
    "claude-mem@thedotmack",
]
for p in core_plugins:
    enabled_plugins[p] = True

# Dev bundle
if bundle_dev:
    dev_plugins = [
        "everything-claude-code@everything-claude-code",
        "pr-review-toolkit@claude-plugins-official",
        "superpowers-chrome@superpowers-marketplace",
        "agent-sdk-dev@claude-plugins-official",
        "superpowers-lab@superpowers-marketplace",
        "superpowers-developing-for-claude-code@superpowers-marketplace",
        "claude-session-driver@superpowers-marketplace",
        "security-guidance@claude-plugins-official",
        "playwright@claude-plugins-official",
    ]
    # Add frontend-design for frontend stacks
    if stack in ("react-nextjs",):
        dev_plugins.append("frontend-design@claude-plugins-official")
    for p in dev_plugins:
        enabled_plugins[p] = True

# PM bundle
if bundle_pm:
    pm_plugins = [
        "pm-toolkit@pm-skills",
        "pm-product-strategy@pm-skills",
        "pm-product-discovery@pm-skills",
        "pm-market-research@pm-skills",
        "pm-data-analytics@pm-skills",
        "pm-marketing-growth@pm-skills",
        "pm-go-to-market@pm-skills",
        "pm-execution@pm-skills",
        "resume-helper@MadeByTokens-marketplace",
    ]
    for p in pm_plugins:
        enabled_plugins[p] = True

# Integration plugins
integration_plugin_map = {
    "vercel": "vercel@claude-plugins-official",
    "github": "github@claude-plugins-official",
    "slack": "slack@claude-plugins-official",
    "sentry": "sentry@claude-plugins-official",
    "firebase": "firebase@claude-plugins-official",
    "supabase": "supabase@claude-plugins-official",
    "stripe": "stripe@claude-plugins-official",
    "pinecone": "pinecone@claude-plugins-official",
    "atlassian": "atlassian@claude-plugins-official",
    "linear": "linear@claude-plugins-official",
    "gitlab": "gitlab@claude-plugins-official",
    "huggingface": "huggingface-skills@claude-plugins-official",
}
for integration in integrations:
    plugin_name = integration_plugin_map.get(integration)
    if plugin_name:
        enabled_plugins[plugin_name] = True

# Stack-specific LSPs
stack_lsp = {
    "react-nextjs": "typescript-lsp@claude-plugins-official",
    "python-django": "pyright-lsp@claude-plugins-official",
    "python-fastapi": "pyright-lsp@claude-plugins-official",
    "go": "gopls-lsp@claude-plugins-official",
    "rust": "rust-analyzer-lsp@claude-plugins-official",
}
lsp = stack_lsp.get(stack)
if lsp:
    enabled_plugins[lsp] = True

# Always install output styles
enabled_plugins["learning-output-style@claude-plugins-official"] = True
enabled_plugins["explanatory-output-style@claude-plugins-official"] = True

settings["enabledPlugins"] = enabled_plugins

# Preserve unknown keys from existing settings
for key, val in existing.items():
    if key not in settings:
        settings[key] = val

with open(output_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
PYEOF

    echo "$existing_settings" >> "$COPIED_FILES_LOG"
    success "Merged: $existing_settings"
}

# --- Register marketplaces --------------------------------------------------

register_marketplaces() {
    info "Registering plugin marketplaces..."

    local marketplaces=(
        "anthropics/claude-plugins-official"
        "obra/superpowers-marketplace"
        "phuryn/pm-skills"
        "affaan-m/everything-claude-code"
        "MadeByTokens/claude-code-plugins-madebytokens"
        "thedotmack/claude-mem"
    )

    for repo in "${marketplaces[@]}"; do
        local name
        name=$(echo "$repo" | cut -d/ -f2)
        # Check if already registered
        if claude plugin marketplace list 2>&1 | grep -q "$repo"; then
            printf "  ${BOLD}%s${RESET}... ${GREEN}already registered${RESET}\n" "$name"
        else
            printf "  ${BOLD}%s${RESET}..." "$name"
            if claude plugin marketplace add "github:$repo" 2>&1 >/dev/null; then
                printf " ${GREEN}ok${RESET}\n"
            else
                printf " ${YELLOW}skipped${RESET}\n"
            fi
        fi
    done

    # Update all marketplaces to fetch latest plugin lists
    info "Updating marketplace indexes..."
    claude plugin marketplace update 2>&1 >/dev/null || true
    success "Marketplaces ready."
}

# --- Install plugins --------------------------------------------------------

install_plugins() {
    info "Installing plugins (this may take a few minutes)..."

    # Check if claude plugin command exists
    if ! command -v claude &>/dev/null; then
        warn "Claude CLI not found. Plugins configured in settings.json but not installed."
        warn "Run 'claude plugin install <name>' manually for each plugin after installing Claude CLI."
        return
    fi

    # Collect all plugin names from settings
    local plugins
    plugins=$(python3 -c "
import json
with open('$CLAUDE_DIR/settings.json') as f:
    s = json.load(f)
for p in s.get('enabledPlugins', {}):
    print(p)
")

    local installed=0 failed=0

    while IFS= read -r plugin; do
        [[ -z "$plugin" ]] && continue
        echo "$plugin" >> "$PLUGINS_LOG"

        # Show progress
        printf "  Installing ${BOLD}%s${RESET}..." "$plugin"

        # Try install, capture output for error diagnosis
        local output
        if output=$(claude plugin install "$plugin" 2>&1); then
            printf " ${GREEN}ok${RESET}\n"
            ((installed++))
        else
            # Check if already installed
            if echo "$output" | grep -qi "already installed"; then
                printf " ${GREEN}already installed${RESET}\n"
                ((installed++))
            else
                printf " ${YELLOW}skipped${RESET}\n"
                ((failed++))
            fi
        fi
    done <<< "$plugins"

    if (( installed > 0 )); then
        success "Installed $installed plugins."
    fi
    if (( failed > 0 )); then
        warn "$failed plugins could not be installed automatically."
        info "They're configured in settings.json. Claude Code will prompt to install them on next launch."
    fi
}

# --- Write manifest ---------------------------------------------------------

write_manifest() {
    info "Writing manifest..."

    local git_sha="unknown"
    if [[ -d "$SCRIPT_DIR/.git" ]]; then
        git_sha=$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
    fi

    # Read backup log into JSON array
    local backups_json plugins_json copied_json integrations_json

    python3 << PYEOF
import json, datetime

backup_log = "$BACKUP_LOG"
copied_log = "$COPIED_FILES_LOG"
plugins_log = "$PLUGINS_LOG"

# Parse backups
backups = []
try:
    with open(backup_log) as f:
        for line in f:
            line = line.strip()
            if "|" in line:
                orig, bak = line.split("|", 1)
                backups.append({"original": orig, "backup": bak})
except FileNotFoundError:
    pass

# Parse copied files
copied = []
try:
    with open(copied_log) as f:
        copied = [l.strip() for l in f if l.strip()]
except FileNotFoundError:
    pass

# Parse plugins
plugins = []
try:
    with open(plugins_log) as f:
        plugins = [l.strip() for l in f if l.strip()]
except FileNotFoundError:
    pass

# Integrations
integrations_str = "${INTEGRATIONS[*]:-}"
integrations = integrations_str.split() if integrations_str.strip() else []

manifest = {
    "installedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "version": "$git_sha",
    "stack": "$STACK_CHOICE",
    "bundles": {
        "core": True,
        "dev": $( $BUNDLE_DEV && echo "True" || echo "False" ),
        "pm": $( $BUNDLE_PM && echo "True" || echo "False" ),
    },
    "integrations": integrations,
    "identity": {
        "name": """${USER_NAME}""",
        "handle": """${USER_HANDLE}""",
        "role": """${USER_ROLE}""",
        "location": """${USER_LOCATION}""",
        "workingStyle": """${USER_WORKING_STYLE}""",
    },
    "backups": backups,
    "copiedFiles": copied,
    "plugins": plugins,
}

with open("$MANIFEST_FILE", "w") as f:
    json.dump(manifest, f, indent=2)
    f.write("\n")
PYEOF

    success "Manifest written: $MANIFEST_FILE"
}

# --- Summary ----------------------------------------------------------------

print_summary() {
    local cmd_count agent_count hook_count template_count plugin_count

    cmd_count=$(find "$CLAUDE_DIR/commands" -type f 2>/dev/null | wc -l | tr -d ' ')
    agent_count=$(find "$CLAUDE_DIR/agents" -type f 2>/dev/null | wc -l | tr -d ' ')
    hook_count=$(find "$CLAUDE_DIR/hooks" -type f 2>/dev/null | wc -l | tr -d ' ')
    template_count=$(find "$CLAUDE_DIR/templates" -type f 2>/dev/null | wc -l | tr -d ' ')
    plugin_count=$(wc -l < "$PLUGINS_LOG" 2>/dev/null | tr -d ' ' || echo "0")

    printf "\n"
    printf "${GREEN}${BOLD}============================================${RESET}\n"
    printf "${GREEN}${BOLD}  Baazigar Claude Code Setup - Complete!${RESET}\n"
    printf "${GREEN}${BOLD}============================================${RESET}\n"
    printf "\n"
    printf "  ${BOLD}CLAUDE.md${RESET}    generated for ${BOLD}%s${RESET}\n" "$USER_NAME"
    printf "  ${BOLD}Stack${RESET}        %s\n" "$STACK_CHOICE"
    printf "  ${BOLD}Commands${RESET}     %s slash commands\n" "$cmd_count"
    printf "  ${BOLD}Agents${RESET}       %s agents\n" "$agent_count"
    printf "  ${BOLD}Hooks${RESET}        %s hooks\n" "$hook_count"
    printf "  ${BOLD}Templates${RESET}    %s templates\n" "$template_count"
    printf "  ${BOLD}Plugins${RESET}      %s plugins configured\n" "$plugin_count"

    if (( ${#INTEGRATIONS[@]} > 0 )); then
        printf "  ${BOLD}Integrations${RESET} %s\n" "${INTEGRATIONS[*]}"
    fi

    printf "\n"
    printf "${BOLD}Next steps:${RESET}\n"
    printf "  - Run ${BOLD}/manage-brand${RESET} to set up your brand guide\n"
    printf "  - Edit ${BOLD}~/.claude/CLAUDE.md${RESET} to customize further\n"
    printf "  - Run ${BOLD}/explore${RESET} in any project to get started\n"
    printf "\n"

    # Cleanup temp files
    rm -f "$BACKUP_LOG" "$COPIED_FILES_LOG" "$PLUGINS_LOG" 2>/dev/null || true
}

# --- Main -------------------------------------------------------------------

main() {
    welcome_banner
    check_prereqs
    check_existing_install

    local INSTALL_CLAUDE=false
    local INSTALL_ITERM=false

    prompt_yn "Install Claude Code setup?" Y && INSTALL_CLAUDE=true

    # Only show iTerm2 option on macOS
    if [[ "$(uname)" == "Darwin" ]]; then
        prompt_yn "Install iTerm2 + terminal setup?" Y && INSTALL_ITERM=true
    fi

    if $INSTALL_CLAUDE; then
        # Ensure ~/.claude exists
        mkdir -p "$CLAUDE_DIR"

        prompt_identity
        prompt_stack
        prompt_bundles

        printf "\n"
        info "Installing Claude Code setup..."
        generate_claude_md
        copy_universal_files
        merge_settings
        register_marketplaces
        install_plugins
        write_manifest
    fi

    if $INSTALL_ITERM; then
        if [[ -f "$SCRIPT_DIR/iterm2/install-iterm2.sh" ]]; then
            info "Launching iTerm2 installer..."
            bash "$SCRIPT_DIR/iterm2/install-iterm2.sh"
        else
            warn "iTerm2 installer not found at $SCRIPT_DIR/iterm2/install-iterm2.sh"
        fi
    fi

    if $INSTALL_CLAUDE; then
        print_summary
    fi
}

main "$@"
