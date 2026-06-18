#!/bin/bash
# Tmux Persistent Console - One-line installer
# curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | bash

set -e

PTPC_VERSION="0.1.3"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse flags
DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=1 ;;
        --version|-V) echo "tmux-persistent-console v$PTPC_VERSION"; exit 0 ;;
        --help|-h)
            cat <<EOF
Usage: install.sh [--dry-run] [--version] [--help]

  --dry-run   Show what would happen without changing anything
  --version   Print version and exit
  --help      This help

One-liner install:
  curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | bash
EOF
            exit 0
            ;;
    esac
done

# Configuration
INSTALL_DIR="$HOME/.tmux-persistent-console"
BIN_DIR="$HOME/bin"

echo -e "${BLUE}==================================="
echo -e "  TMUX PERSISTENT CONSOLE INSTALLER v$PTPC_VERSION"
echo -e "===================================${NC}"
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "${YELLOW}DRY-RUN MODE — would perform:${NC}"
    echo "  1. Install missing deps:           tmux, fzf, gum (via apt/yum/pacman/brew)"
    echo "  2. Create directories:             $INSTALL_DIR, $BIN_DIR"
    echo "  3. Copy scripts:                   src/* → $INSTALL_DIR/"
    echo "  4. Install tmux.conf:              $INSTALL_DIR/tmux.conf → ~/.tmux.conf (backup made)"
    echo "  5. Add PATH + safe-exit hooks to:  ~/.bashrc, ~/.zshrc"
    echo "  6. Install systemd user service:   ~/.config/systemd/user/tmux-console.service"
    echo "  7. Enable user lingering:          loginctl enable-linger \$USER"
    echo "  8. Enable + start service:         systemctl --user enable --now tmux-console.service"
    echo "  9. Verify service is active and console-1..console-10 exist"
    echo ""
    echo "To actually install, re-run without --dry-run."
    exit 0
fi

# Warn if a legacy install layout is still around
if [ -d "$HOME/.vps/sessions" ]; then
    echo -e "${YELLOW}⚠️  Legacy install detected at ~/.vps/sessions${NC}"
    echo -e "${YELLOW}   You can safely remove it after this install finishes:${NC}"
    echo -e "${YELLOW}     rm -rf ~/.vps/sessions${NC}"
    echo ""
fi

# Detect container / CI environments.
CONTAINER_CI=0
SKIP_TUI_DEPS=0
if [ -f /.dockerenv ] || [ -n "${CI:-}" ] || [ -n "${CONTAINER:-}" ]; then
    CONTAINER_CI=1
    SKIP_TUI_DEPS=1
    echo -e "${YELLOW}📦 Container/CI environment detected — skipping optional TUI deps (gum, fzf)${NC}"
    echo -e "${YELLOW}   Set SKIP_TUI_DEPS=0 to force install them.${NC}"
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}📦 Installing tmux...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y tmux
        elif command -v yum &> /dev/null; then
            sudo yum install -y tmux
        elif command -v pacman &> /dev/null; then
            sudo pacman -S tmux
        else
            echo -e "${RED}❌ Cannot install tmux automatically. Please install tmux manually.${NC}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install tmux
        else
            echo -e "${RED}❌ Please install tmux using Homebrew: brew install tmux${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}✅ Tmux installed successfully${NC}"
fi

# Install TUI tools (gum, fzf)
echo -e "${YELLOW}🎨 Installing TUI enhancements...${NC}"

if [ "$SKIP_TUI_DEPS" -eq 1 ]; then
    echo -e "${YELLOW}  ⏭️  Skipping TUI deps (container/CI mode)${NC}"
else

# Install fzf (fuzzy finder)
if ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}  Installing fzf...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fzf
        elif command -v yum &> /dev/null; then
            sudo yum install -y fzf
        elif command -v pacman &> /dev/null; then
            sudo pacman -S fzf
        else
            echo -e "${YELLOW}  ⚠️  fzf not available in package manager, trying git install...${NC}"
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --bin
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install fzf
        fi
    fi
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    echo -e "${GREEN}  ✅ fzf installed${NC}"
else
    echo -e "${GREEN}  ✅ fzf already installed${NC}"
fi

# Install gum (modern TUI)
if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}  Installing gum...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Try snap first (most modern systems)
        if command -v snap &> /dev/null; then
            sudo snap install gum 2>/dev/null || {
                # Fallback to manual install
                echo -e "${YELLOW}  ⚠️  snap failed, trying manual install...${NC}"
                wget -q https://github.com/charmbracelet/gum/releases/download/v0.14.0/gum_0.14.0_linux_amd64.tar.gz -O /tmp/gum.tar.gz
                tar -xzf /tmp/gum.tar.gz -C /tmp
                sudo mv /tmp/gum /usr/local/bin/
                rm /tmp/gum.tar.gz
            }
        elif command -v apt-get &> /dev/null; then
            # Debian/Ubuntu - manual install
            wget -q https://github.com/charmbracelet/gum/releases/download/v0.14.0/gum_0.14.0_linux_amd64.tar.gz -O /tmp/gum.tar.gz
            tar -xzf /tmp/gum.tar.gz -C /tmp
            sudo mv /tmp/gum /usr/local/bin/
            rm /tmp/gum.tar.gz
        else
            echo -e "${YELLOW}  ⚠️  gum installation not available, will use fallback TUI${NC}"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install gum
        fi
    fi

    if command -v gum &> /dev/null; then
        echo -e "${GREEN}  ✅ gum installed${NC}"
    else
        echo -e "${YELLOW}  ⚠️  gum not installed, TUI will fallback to fzf/whiptail${NC}"
    fi
else
    echo -e "${GREEN}  ✅ gum already installed${NC}"
fi
fi # end SKIP_TUI_DEPS block

# Create directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Resolve source location: if we are running from inside a cloned repo with src/,
# treat THAT as the source. If $PWD already IS $INSTALL_DIR (common: user cloned to
# ~/.tmux-persistent-console then ran ./install.sh), skip the copy step entirely —
# copying src/* over the repo root just creates phantom "modified" duplicates.
REPO_ROOT="$(pwd)"

if [ -d "$REPO_ROOT/src" ]; then
    if [ "$REPO_ROOT" = "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}📋 Running from install dir — using src/ in place (no copy)${NC}"
    else
        echo -e "${YELLOW}📋 Copying local files from $REPO_ROOT/src to $INSTALL_DIR${NC}"
        cp -r "$REPO_ROOT/src/"* "$INSTALL_DIR/"
        if [ -d "$REPO_ROOT/src/tui" ]; then
            mkdir -p "$INSTALL_DIR/tui"
            cp -r "$REPO_ROOT/src/tui/"* "$INSTALL_DIR/tui/"
        fi
    fi
else
    # Remote installation (curl-piped install with no local checkout)
    REPO_URL_BASE="https://raw.githubusercontent.com/zentala/pTTY/main"
    echo -e "${YELLOW}⬇️  Downloading files from ${REPO_URL_BASE}${NC}"
    for f in \
        setup.sh connect.sh tmux.conf tmux-console.service uninstall.sh \
        safe-exit.sh console-help.sh help-console.sh help-reference.sh \
        status-format-v4.tmux status-format-v3.tmux status-bar-legacy.sh \
        theme-config.sh mission-control.sh shortcuts-popup.sh \
        click-session.sh restart-confirm.sh restart-session.sh; do
        if ! curl -fsSL "$REPO_URL_BASE/src/$f" -o "$INSTALL_DIR/$f"; then
            echo -e "${RED}❌ Failed to download $f from $REPO_URL_BASE/src/$f${NC}"
            exit 1
        fi
    done

    mkdir -p "$INSTALL_DIR/tui"
    for f in tui-core.sh tui-menu.sh tui-dialogs.sh tui-list.sh tui-status.sh; do
        if ! curl -fsSL "$REPO_URL_BASE/src/tui/$f" -o "$INSTALL_DIR/tui/$f"; then
            echo -e "${RED}❌ Failed to download tui/$f${NC}"
            exit 1
        fi
    done
fi

# Source location used by the rest of the installer (systemd service etc.)
SRC_DIR="$INSTALL_DIR"
if [ "$REPO_ROOT" != "$INSTALL_DIR" ] && [ -d "$REPO_ROOT/src" ]; then
    SRC_DIR="$INSTALL_DIR"   # already copied above
fi

# Make scripts executable
chmod +x "$INSTALL_DIR"/*.sh

# Backup existing tmux config
if [ -f "$HOME/.tmux.conf" ]; then
    echo -e "${YELLOW}💾 Backing up existing tmux config...${NC}"
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Install tmux configuration
echo -e "${YELLOW}⚙️  Installing tmux configuration...${NC}"
echo "# tmux-persistent-console config" > "$HOME/.tmux.conf"
cat "$INSTALL_DIR/tmux.conf" >> "$HOME/.tmux.conf"

# Create convenient commands
echo -e "${YELLOW}🔗 Creating command aliases...${NC}"

# Create setup command
cat > "$BIN_DIR/setup-console-sessions" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/setup.sh "$@"
EOF

# Create connect command
cat > "$BIN_DIR/connect-console" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/connect.sh "$@"
EOF

# Create console help command
cat > "$BIN_DIR/console-help" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/console-help.sh "$@"
EOF

# Create uninstall command
cat > "$BIN_DIR/uninstall-console" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/uninstall.sh "$@"
EOF

chmod +x "$BIN_DIR"/*

# Add to PATH and safe-exit if needed
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${YELLOW}🛤️  Adding $BIN_DIR to PATH...${NC}"

    # Add to bashrc
    if [ -f "$HOME/.bashrc" ]; then
        echo "" >> "$HOME/.bashrc"
        echo "# tmux-persistent-console" >> "$HOME/.bashrc"
        echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
        echo "" >> "$HOME/.bashrc"
        echo "# Safe exit wrapper for tmux sessions" >> "$HOME/.bashrc"
        echo "[ -f ~/.tmux-persistent-console/safe-exit.sh ] && source ~/.tmux-persistent-console/safe-exit.sh" >> "$HOME/.bashrc"
    fi

    # Add to zshrc
    if [ -f "$HOME/.zshrc" ]; then
        echo "" >> "$HOME/.zshrc"
        echo "# tmux-persistent-console" >> "$HOME/.zshrc"
        echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$HOME/.zshrc"
        echo "" >> "$HOME/.zshrc"
        echo "# Safe exit wrapper for tmux sessions" >> "$HOME/.zshrc"
        echo "[ -f ~/.tmux-persistent-console/safe-exit.sh ] && source ~/.tmux-persistent-console/safe-exit.sh" >> "$HOME/.zshrc"
    fi

    # Add to current session
    export PATH="$BIN_DIR:$PATH"
fi

# Install systemd user service so empty sessions are recreated after boot.
if [ "$CONTAINER_CI" -eq 1 ]; then
    echo -e "${YELLOW}📦 Container/CI mode — skipping systemd user service setup${NC}"
    echo -e "${YELLOW}   Creating console sessions directly for verification.${NC}"
    bash "$INSTALL_DIR/setup.sh"

    if ! tmux ls 2>/dev/null | grep -q "^console-1:"; then
        echo -e "${RED}❌ setup.sh completed but no console-* sessions found${NC}"
        echo -e "${RED}   Check setup.sh:  bash -x $INSTALL_DIR/setup.sh${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Container/CI sessions verified${NC}"
elif ! command -v systemctl &> /dev/null; then
    echo -e "${YELLOW}⚠️  systemctl not found — skipping autostart setup${NC}"
    echo -e "${YELLOW}   You will need to start sessions manually with: bash $INSTALL_DIR/setup.sh${NC}"
else
    echo -e "${YELLOW}🔧 Installing systemd autostart service...${NC}"

    # Prefer src/ as canonical source, fall back to INSTALL_DIR
    SERVICE_SRC="$INSTALL_DIR/tmux-console.service"
    if [ -f "$REPO_ROOT/src/tmux-console.service" ]; then
        SERVICE_SRC="$REPO_ROOT/src/tmux-console.service"
    fi
    if [ ! -f "$SERVICE_SRC" ]; then
        echo -e "${RED}❌ Missing tmux-console.service — cannot install autostart${NC}"
        exit 1
    fi

    mkdir -p "$HOME/.config/systemd/user"
    cp "$SERVICE_SRC" "$HOME/.config/systemd/user/tmux-console.service"
    systemctl --user daemon-reload

    # Enable lingering so user services run without an active login after boot.
    if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
        echo -e "${YELLOW}   Enabling user lingering...${NC}"
        if loginctl enable-linger "$USER" 2>/dev/null; then
            echo -e "${GREEN}   ✓ Lingering enabled${NC}"
        elif sudo loginctl enable-linger "$USER" 2>/dev/null; then
            echo -e "${GREEN}   ✓ Lingering enabled (via sudo)${NC}"
        else
            echo -e "${YELLOW}   ⚠ Could not enable lingering — empty sessions will not auto-create after boot until you run:${NC}"
            echo -e "${YELLOW}     sudo loginctl enable-linger $USER${NC}"
        fi
    fi

    # Enable + start the service
    if ! systemctl --user enable --now tmux-console.service 2>&1; then
        echo -e "${RED}❌ systemctl enable --now failed${NC}"
        systemctl --user status tmux-console.service --no-pager || true
        exit 1
    fi

    # Verify the service actually came up — don't trust enable's return code alone
    sleep 1
    if ! systemctl --user is-active --quiet tmux-console.service; then
        echo -e "${RED}❌ tmux-console.service is not active after start${NC}"
        echo -e "${RED}   Run:  systemctl --user status tmux-console.service${NC}"
        echo -e "${RED}   And:  journalctl --user -u tmux-console.service -n 30${NC}"
        exit 1
    fi

    # And verify the sessions it claims to manage actually exist
    if ! tmux ls 2>/dev/null | grep -q "^console-1:"; then
        echo -e "${RED}❌ Service active but no console-* sessions found${NC}"
        echo -e "${RED}   Check setup.sh:  bash -x $INSTALL_DIR/setup.sh${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Service active, sessions verified${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo -e "   ${YELLOW}connect-console${NC}           # Interactive session menu"
echo -e "   ${YELLOW}tmux attach -t console-1${NC}  # Direct to console-1"
echo ""
echo -e "${BLUE}🔥 Function Keys (from within tmux):${NC}"
echo -e "   ${YELLOW}Ctrl+F1-F10${NC} Jump to console 1-10"
echo -e "   ${YELLOW}Ctrl+F11${NC}    Open manager menu"
echo -e "   ${YELLOW}Ctrl+F12${NC}    Show keyboard help"
echo ""
echo -e "${BLUE}🌐 Remote SSH Access:${NC}"
echo -e "   ${YELLOW}ssh user@server -t \"tmux attach -t console-1\"${NC}"
echo ""
echo -e "${BLUE}🗑️  Uninstall:${NC}"
echo -e "   ${YELLOW}uninstall-console${NC}"
echo ""
echo -e "${GREEN}🎉 Your sessions are protected from SSH/client disconnects. Enjoy coding with AI CLI tools!${NC}"
echo ""
