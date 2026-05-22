#!/bin/bash
# Tmux Persistent Console - One-line installer
# curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.tmux-persistent-console"
BIN_DIR="$HOME/bin"

echo -e "${BLUE}==================================="
echo -e "  TMUX PERSISTENT CONSOLE INSTALLER"
echo -e "===================================${NC}"
echo ""

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

# Create directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Download or copy source files
if [ -d "./src" ]; then
    # Local installation
    echo -e "${YELLOW}📋 Copying local files...${NC}"
    cp -r src/* "$INSTALL_DIR/"
    # Ensure TUI library is copied
    if [ -d "./src/tui" ]; then
        mkdir -p "$INSTALL_DIR/tui"
        cp -r src/tui/* "$INSTALL_DIR/tui/"
    fi
else
    # Remote installation
    echo -e "${YELLOW}⬇️  Downloading files...${NC}"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/setup.sh" -o "$INSTALL_DIR/setup.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/connect.sh" -o "$INSTALL_DIR/connect.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/tmux.conf" -o "$INSTALL_DIR/tmux.conf"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/uninstall.sh" -o "$INSTALL_DIR/uninstall.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/safe-exit.sh" -o "$INSTALL_DIR/safe-exit.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/console-help.sh" -o "$INSTALL_DIR/console-help.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/help-console.sh" -o "$INSTALL_DIR/help-console.sh"

    # Download TUI library
    mkdir -p "$INSTALL_DIR/tui"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/tui/tui-core.sh" -o "$INSTALL_DIR/tui/tui-core.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/tui/tui-menu.sh" -o "$INSTALL_DIR/tui/tui-menu.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/tui/tui-dialogs.sh" -o "$INSTALL_DIR/tui/tui-dialogs.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/tui/tui-list.sh" -o "$INSTALL_DIR/tui/tui-list.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/tui/tui-status.sh" -o "$INSTALL_DIR/tui/tui-status.sh"
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

# Install systemd user service so sessions survive reboot
echo -e "${YELLOW}🔧 Installing systemd autostart service...${NC}"

if [ ! -f "$INSTALL_DIR/tmux-console.service" ]; then
    echo -e "${RED}❌ Missing $INSTALL_DIR/tmux-console.service — cannot install autostart${NC}"
    exit 1
fi

mkdir -p "$HOME/.config/systemd/user"
cp "$INSTALL_DIR/tmux-console.service" "$HOME/.config/systemd/user/tmux-console.service"
systemctl --user daemon-reload

# Enable lingering so user services run without an active login (survives reboot)
if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
    echo -e "${YELLOW}   Enabling user lingering (needs sudo)...${NC}"
    if loginctl enable-linger "$USER" 2>/dev/null; then
        echo -e "${GREEN}   ✓ Lingering enabled${NC}"
    elif sudo loginctl enable-linger "$USER" 2>/dev/null; then
        echo -e "${GREEN}   ✓ Lingering enabled (via sudo)${NC}"
    else
        echo -e "${YELLOW}   ⚠ Could not enable lingering — sessions will NOT survive reboot until you run:${NC}"
        echo -e "${YELLOW}     sudo loginctl enable-linger $USER${NC}"
    fi
fi

# Enable + start the service (creates console-1..7 immediately)
systemctl --user enable --now tmux-console.service
echo -e "${GREEN}✅ Service enabled — sessions will auto-start on boot${NC}"

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo -e "   ${YELLOW}connect-console${NC}           # Interactive session menu"
echo -e "   ${YELLOW}tmux attach -t console-1${NC}  # Direct to console-1"
echo ""
echo -e "${BLUE}🔥 Function Keys (from within tmux):${NC}"
echo -e "   ${YELLOW}Ctrl+F1-F7${NC}  Jump to console 1-7"
echo -e "   ${YELLOW}Ctrl+F8${NC}     Disconnect"
echo -e "   ${YELLOW}Ctrl+F12${NC}    Show all sessions"
echo ""
echo -e "${BLUE}🌐 Remote SSH Access:${NC}"
echo -e "   ${YELLOW}ssh user@server -t \"tmux attach -t console-1\"${NC}"
echo ""
echo -e "${BLUE}🗑️  Uninstall:${NC}"
echo -e "   ${YELLOW}uninstall-console${NC}"
echo ""
echo -e "${GREEN}🎉 Your work is now crash-resistant! Enjoy coding with AI CLI tools!${NC}"
echo ""