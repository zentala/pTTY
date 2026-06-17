#!/bin/bash
# Interactive testing script for tmux-persistent-console

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🎮 Interactive tmux-persistent-console Testing${NC}"
echo "=============================================="

# Check if connection info exists
if [ ! -f "$SCRIPT_DIR/connection-info.txt" ]; then
    echo -e "${RED}❌ No connection info found.${NC}"
    echo "   Please deploy infrastructure first with: ./deploy.sh"
    exit 1
fi

# Extract connection info
PUBLIC_IP=$(grep "Public IP:" "$SCRIPT_DIR/connection-info.txt" | cut -d' ' -f3)
SSH_COMMAND=$(grep "SSH Command:" "$SCRIPT_DIR/connection-info.txt" | cut -d' ' -f3-)

echo -e "${CYAN}🖥️  Test Server: $PUBLIC_IP${NC}"
echo ""

# Interactive menu
while true; do
    echo -e "${BLUE}🎯 Select test scenario:${NC}"
    echo ""
    echo -e "${YELLOW}Basic Tests:${NC}"
    echo "  1) 🔗 Connect to main console menu"
    echo "  2) 🤖 Connect directly to console-1 (Claude Code console)"
    echo "  3) 🎪 Connect directly to console-2 (Copilot console)"
    echo "  4) 💻 Connect directly to console-3 (Development console)"
    echo ""
    echo -e "${YELLOW}Advanced Tests:${NC}"
    echo "  5) 🧪 Run automated test suite"
    echo "  6) 🔄 Test session switching (manual Ctrl+F keys)"
    echo "  7) 📊 Monitor all sessions status"
    echo ""
    echo -e "${YELLOW}Stress Tests:${NC}"
    echo "  8) 💥 Test crash resistance (kill SSH, reconnect)"
    echo "  9) 🔁 Test rapid session switching"
    echo " 10) 🏗️  Test installation from scratch"
    echo ""
    echo -e "${YELLOW}Management:${NC}"
    echo " 11) 📝 Show server logs"
    echo " 12) 🔧 Debug connection issues"
    echo " 13) 🗑️  Destroy test infrastructure"
    echo ""
    echo -e "${CYAN} 0) Exit${NC}"
    echo ""
    echo -n "Choose option (0-13): "

    read -r choice

    case $choice in
        1)
            echo -e "${GREEN}🔗 Connecting to console menu...${NC}"
            ssh -t ubuntu@"$PUBLIC_IP" "connect-console"
            ;;
        2)
            echo -e "${GREEN}🤖 Connecting to console-1 (Claude Code)...${NC}"
            echo -e "${YELLOW}💡 Try: Ctrl+F2 to switch to console-2${NC}"
            ssh -t ubuntu@"$PUBLIC_IP" "tmux attach -t console-1"
            ;;
        3)
            echo -e "${GREEN}🎪 Connecting to console-2 (Copilot)...${NC}"
            echo -e "${YELLOW}💡 Try: Ctrl+F1 to switch to console-1${NC}"
            ssh -t ubuntu@"$PUBLIC_IP" "tmux attach -t console-2"
            ;;
        4)
            echo -e "${GREEN}💻 Connecting to console-3 (Development)...${NC}"
            echo -e "${YELLOW}💡 Try: Ctrl+F4 to switch to console-4${NC}"
            ssh -t ubuntu@"$PUBLIC_IP" "tmux attach -t console-3"
            ;;
        5)
            echo -e "${GREEN}🧪 Running automated test suite...${NC}"
            ssh ubuntu@"$PUBLIC_IP" "./test-tmux-console.sh"
            ;;
        6)
            echo -e "${GREEN}🔄 Manual session switching test...${NC}"
            echo ""
            echo -e "${YELLOW}Instructions:${NC}"
            echo "1. You'll connect to console-1"
            echo "2. Try these function keys:"
            echo "   - Ctrl+F2: Switch to console-2"
            echo "   - Ctrl+F3: Switch to console-3"
            echo "   - Ctrl+F12: Show all sessions"
            echo "   - Ctrl+F8: Disconnect"
            echo "3. Test if switching is instant!"
            echo ""
            echo -n "Press Enter to continue..."
            read -r
            ssh -t ubuntu@"$PUBLIC_IP" "tmux attach -t console-1"
            ;;
        7)
            echo -e "${GREEN}📊 Monitoring all sessions...${NC}"
            ssh ubuntu@"$PUBLIC_IP" "tmux ls && echo && echo 'Active processes in each session:' && for i in {1..7}; do echo '=== Console-$i ==='; tmux capture-pane -t console-$i -p | tail -5; done"
            ;;
        8)
            echo -e "${GREEN}💥 Testing crash resistance...${NC}"
            echo ""
            echo -e "${YELLOW}Test procedure:${NC}"
            echo "1. Connect to console-1"
            echo "2. Start a long-running command (e.g., 'top' or 'watch date')"
            echo "3. Kill your terminal/SSH connection"
            echo "4. Reconnect and verify session continues"
            echo ""
            echo -n "Press Enter to start test..."
            read -r

            echo -e "${CYAN}Step 1: Starting session...${NC}"
            ssh -t ubuntu@"$PUBLIC_IP" "tmux attach -t console-1"

            echo ""
            echo -e "${CYAN}Step 2: Reconnecting to verify persistence...${NC}"
            ssh -t ubuntu@"$PUBLIC_IP" "tmux attach -t console-1"
            ;;
        9)
            echo -e "${GREEN}🔁 Rapid session switching test...${NC}"
            ssh -t ubuntu@"$PUBLIC_IP" "
                echo 'Testing rapid session switching...'
                for i in {1..7}; do
                    echo \"Switching to console-\$i\"
                    tmux switch-client -t console-\$i
                    sleep 1
                done
                echo 'Rapid switching test complete!'
                tmux attach -t console-1
            "
            ;;
        10)
            echo -e "${GREEN}🏗️  Testing fresh installation...${NC}"
            ssh -t ubuntu@"$PUBLIC_IP" "
                echo 'Removing existing installation...'
                uninstall-console || true
                echo 'Installing fresh copy...'
                curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | bash
                echo 'Testing fresh installation...'
                ./test-tmux-console.sh
            "
            ;;
        11)
            echo -e "${GREEN}📝 Showing server logs...${NC}"
            ssh ubuntu@"$PUBLIC_IP" "
                echo '=== Cloud-init status ==='
                sudo cloud-init status --long
                echo
                echo '=== Cloud-init logs (last 20 lines) ==='
                sudo tail -20 /var/log/cloud-init-output.log
                echo
                echo '=== System status ==='
                uptime
                df -h
                free -h
            "
            ;;
        12)
            echo -e "${GREEN}🔧 Debugging connection...${NC}"
            echo ""
            echo -e "${CYAN}Connection diagnostics:${NC}"
            echo "Public IP: $PUBLIC_IP"
            echo "SSH Command: $SSH_COMMAND"
            echo ""

            echo -e "${YELLOW}Testing connectivity...${NC}"
            if ping -c 3 "$PUBLIC_IP" > /dev/null 2>&1; then
                echo -e "${GREEN}✅ Ping successful${NC}"
            else
                echo -e "${RED}❌ Ping failed${NC}"
            fi

            echo -e "${YELLOW}Testing SSH port...${NC}"
            if nc -z "$PUBLIC_IP" 22 2>/dev/null; then
                echo -e "${GREEN}✅ SSH port 22 is open${NC}"
            else
                echo -e "${RED}❌ SSH port 22 is not accessible${NC}"
            fi

            echo -e "${YELLOW}Testing SSH connection...${NC}"
            if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" "echo 'SSH works'" 2>/dev/null; then
                echo -e "${GREEN}✅ SSH connection successful${NC}"
            else
                echo -e "${RED}❌ SSH connection failed${NC}"
            fi
            ;;
        13)
            echo -e "${RED}🗑️  Destroying infrastructure...${NC}"
            echo -e "${YELLOW}⚠️  This will permanently delete the test server!${NC}"
            echo -n "Are you sure? (y/N): "
            read -r confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                "$SCRIPT_DIR/destroy.sh"
                exit 0
            else
                echo "Cancelled."
            fi
            ;;
        0)
            echo -e "${GREEN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option. Please choose 0-13.${NC}"
            ;;
    esac

    echo ""
    echo -e "${CYAN}Press Enter to return to menu...${NC}"
    read -r
    echo ""
done
