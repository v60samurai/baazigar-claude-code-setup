#!/usr/bin/env bash
# Baazigar Claude Code Setup - iTerm2 Installer
# https://github.com/v60samurai/baazigar-claude-code-setup
#
# Installs and configures: iTerm2, Oh My Zsh, Powerlevel10k,
# MesloLGS NF fonts, color themes, and zsh plugins.

set -euo pipefail

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[info]${NC}  $*"; }
success() { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}  $*"; }
error()   { echo -e "${RED}[error]${NC} $*"; }
step()    { echo -e "\n${BOLD}${CYAN}==> $*${NC}"; }

# ---------- Resolve script directory ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------- macOS check ----------
if [[ "$(uname -s)" != "Darwin" ]]; then
  error "This installer only supports macOS. Exiting."
  exit 1
fi

# ---------- Detect architecture ----------
if [[ "$(uname -m)" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# ---------- 1. Homebrew ----------
step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  info "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
  success "Homebrew installed."
else
  success "Homebrew already installed."
fi

# ---------- 2. iTerm2 ----------
step "Checking iTerm2"
if ! brew list --cask iterm2 &>/dev/null; then
  info "Installing iTerm2..."
  brew install --cask iterm2
  success "iTerm2 installed."
else
  success "iTerm2 already installed."
fi

# ---------- 3. Nerd Font (cask) ----------
step "Installing Nerd Font (MesloLG)"
if ! brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
  brew install --cask font-meslo-lg-nerd-font
  success "font-meslo-lg-nerd-font installed via Homebrew."
else
  success "font-meslo-lg-nerd-font already installed."
fi

# ---------- 4. MesloLGS NF (Powerlevel10k-specific) ----------
step "Downloading MesloLGS NF fonts for Powerlevel10k"
FONT_DIR="$HOME/Library/Fonts"
FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
FONTS=(
  "MesloLGS%20NF%20Regular.ttf"
  "MesloLGS%20NF%20Bold.ttf"
  "MesloLGS%20NF%20Italic.ttf"
  "MesloLGS%20NF%20Bold%20Italic.ttf"
)

for font_file in "${FONTS[@]}"; do
  decoded="$(printf '%b' "${font_file//%/\\x}")"
  if [[ -f "${FONT_DIR}/${decoded}" ]]; then
    success "${decoded} already exists."
  else
    info "Downloading ${decoded}..."
    curl -fsSL -o "${FONT_DIR}/${decoded}" "${FONT_BASE_URL}/${font_file}" && \
      success "Downloaded ${decoded}." || \
      warn "Failed to download ${decoded}. You can install it manually."
  fi
done

# ---------- 5. Oh My Zsh ----------
step "Checking Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed."
else
  success "Oh My Zsh already installed."
fi

# ---------- 6. Powerlevel10k ----------
step "Checking Powerlevel10k"
if ! brew list powerlevel10k &>/dev/null; then
  info "Installing Powerlevel10k via Homebrew..."
  brew install powerlevel10k
  success "Powerlevel10k installed."
else
  success "Powerlevel10k already installed."
fi

# ---------- 7. Zsh plugins ----------
step "Installing zsh plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
  info "Cloning zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  success "zsh-autosuggestions installed."
else
  success "zsh-autosuggestions already installed."
fi

if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
  info "Cloning zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  success "zsh-syntax-highlighting installed."
else
  success "zsh-syntax-highlighting already installed."
fi

# ---------- 8. Theme selection ----------
step "iTerm2 color theme"
echo ""
echo -e "  ${BOLD}1)${NC} Light  - clean light background (#FAFAFA)"
echo -e "  ${BOLD}2)${NC} Dark   - Catppuccin Mocha (#1E1E2E)"
echo ""
while true; do
  read -rp "$(echo -e "${CYAN}Select theme [1/2]:${NC} ")" theme_choice
  case "$theme_choice" in
    1) THEME_FILE="themes/light.itermcolors"; THEME_NAME="Baazigar Light"; break ;;
    2) THEME_FILE="themes/dark.itermcolors"; THEME_NAME="Baazigar Dark"; break ;;
    *) warn "Please enter 1 or 2." ;;
  esac
done

THEME_PATH="${SCRIPT_DIR}/${THEME_FILE}"
if [[ -f "$THEME_PATH" ]]; then
  info "Importing ${THEME_NAME} into iTerm2..."
  open "$THEME_PATH"
  success "Theme imported. You may need to select it in iTerm2 Preferences > Profiles > Colors."
else
  error "Theme file not found at ${THEME_PATH}. Skipping."
fi

# ---------- 9. p10k style selection ----------
step "Powerlevel10k prompt style"
echo ""
echo -e "  ${BOLD}1)${NC} Lean    - minimal, no background colors, no powerline glyphs"
echo -e "  ${BOLD}2)${NC} Classic - powerline segments with background colors"
echo ""
while true; do
  read -rp "$(echo -e "${CYAN}Select style [1/2]:${NC} ")" p10k_choice
  case "$p10k_choice" in
    1) P10K_FILE="p10k-lean.zsh"; break ;;
    2) P10K_FILE="p10k-classic.zsh"; break ;;
    *) warn "Please enter 1 or 2." ;;
  esac
done

# Back up existing p10k config.
if [[ -f "$HOME/.p10k.zsh" ]]; then
  backup="$HOME/.p10k.zsh.bak.$(date +%Y%m%d%H%M%S)"
  info "Backing up existing ~/.p10k.zsh to ${backup}"
  cp "$HOME/.p10k.zsh" "$backup"
  success "Backup created."
fi

P10K_SRC="${SCRIPT_DIR}/${P10K_FILE}"
if [[ -f "$P10K_SRC" ]]; then
  cp "$P10K_SRC" "$HOME/.p10k.zsh"
  success "Installed ${P10K_FILE} as ~/.p10k.zsh"
else
  error "p10k config not found at ${P10K_SRC}. Skipping."
fi

# ---------- 10. Generate .zshrc ----------
step "Generating ~/.zshrc"

# Determine p10k source line based on architecture.
P10K_SOURCE_LINE="source ${BREW_PREFIX}/share/powerlevel10k/powerlevel10k.zsh-theme"

# Preserve user customizations from existing .zshrc.
USER_CUSTOMIZATIONS=""
MARKER="# === USER CUSTOMIZATIONS"
if [[ -f "$HOME/.zshrc" ]]; then
  # Back up existing .zshrc.
  zshrc_backup="$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
  info "Backing up existing ~/.zshrc to ${zshrc_backup}"
  cp "$HOME/.zshrc" "$zshrc_backup"
  success "Backup created."

  # Extract everything after the marker (including the marker line).
  if grep -qF "$MARKER" "$HOME/.zshrc"; then
    USER_CUSTOMIZATIONS="$(sed -n "/${MARKER}/,\$p" "$HOME/.zshrc")"
  fi
fi

# Read template and replace placeholder.
TEMPLATE="${SCRIPT_DIR}/zshrc.template"
if [[ ! -f "$TEMPLATE" ]]; then
  error "zshrc.template not found at ${TEMPLATE}. Skipping .zshrc generation."
else
  GENERATED="$(sed "s|{{P10K_SOURCE}}|${P10K_SOURCE_LINE}|g" "$TEMPLATE")"

  # If we have user customizations, replace the default marker block.
  if [[ -n "$USER_CUSTOMIZATIONS" ]]; then
    # Remove everything from the marker onward in the generated content,
    # then append the preserved customizations.
    GENERATED="$(echo "$GENERATED" | sed "/${MARKER}/,\$d")"
    GENERATED="${GENERATED}
${USER_CUSTOMIZATIONS}"
    info "Preserved user customizations from previous .zshrc."
  fi

  echo "$GENERATED" > "$HOME/.zshrc"
  success "Generated ~/.zshrc"
fi

# ---------- Summary ----------
echo ""
echo -e "${BOLD}${GREEN}=====================================${NC}"
echo -e "${BOLD}${GREEN}  iTerm2 Setup Complete${NC}"
echo -e "${BOLD}${GREEN}=====================================${NC}"
echo ""
echo -e "  ${BOLD}Installed:${NC}"
echo -e "    - Homebrew"
echo -e "    - iTerm2"
echo -e "    - MesloLGS NF fonts"
echo -e "    - Oh My Zsh"
echo -e "    - Powerlevel10k"
echo -e "    - zsh-autosuggestions"
echo -e "    - zsh-syntax-highlighting"
echo ""
echo -e "  ${BOLD}Configured:${NC}"
echo -e "    - Theme: ${THEME_NAME}"
echo -e "    - Prompt: ${P10K_FILE%.zsh}"
echo -e "    - Shell:  ~/.zshrc"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "    1. Open iTerm2 (or restart it if already open)"
echo -e "    2. Go to Preferences > Profiles > Text"
echo -e "       Set font to ${BOLD}MesloLGS NF${NC} (size 13+)"
echo -e "    3. Go to Preferences > Profiles > Colors"
echo -e "       Select ${BOLD}${THEME_NAME}${NC} from the Color Presets dropdown"
echo -e "    4. For further prompt customization, run: ${BOLD}p10k configure${NC}"
echo ""
