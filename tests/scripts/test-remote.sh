#!/bin/bash
# Remote testing script for tmux-persistent-console

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🧪 Testing tmux-persistent-console remotely${NC}"
echo "============================================"

# Check if connection info exists
if [ ! -f "$SCRIPT_DIR/connection-info.txt" ]; then
    echo -e "${RED}❌ No connection info found.${NC}"
    echo "   Please deploy infrastructure first with: ./deploy.sh"
    exit 1
fi

# Extract connection info
PUBLIC_IP=$(grep "Public IP:" "$SCRIPT_DIR/connection-info.txt" | cut -d' ' -f3)
SSH_COMMAND=$(grep "SSH Command:" "$SCRIPT_DIR/connection-info.txt" | cut -d' ' -f3-)

if [ -z "$PUBLIC_IP" ]; then
    echo -e "${RED}❌ Could not extract connection info.${NC}"
    exit 1
fi

echo -e "${BLUE}📡 Connecting to test server: $PUBLIC_IP${NC}"

# Function to run remote command with proper error handling
run_remote() {
    local cmd="$1"
    local description="$2"

    echo -e "${YELLOW}🔧 $description${NC}"
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" "$cmd"; then
        echo -e "${GREEN}✅ $description - PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ $description - FAILED${NC}"
        return 1
    fi
}

# Wait for server to be ready
echo -e "${YELLOW}⏳ Waiting for server to be ready...${NC}"
for i in {1..30}; do
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@"$PUBLIC_IP" "echo 'ready'" &>/dev/null; then
        echo -e "${GREEN}✅ Server is ready!${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Server did not become ready in time${NC}"
        exit 1
    fi
    echo -n "."
    sleep 10
done

echo ""
echo -e "${BLUE}🧪 Running comprehensive tests...${NC}"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_TOTAL=0

# Test 1: Basic tmux installation
((TESTS_TOTAL++))
if run_remote "tmux -V" "Test 1: Tmux installation"; then
    ((TESTS_PASSED++))
fi

# Test 2: Console sessions exist
((TESTS_TOTAL++))
if run_remote "tmux ls | grep -E 'console-(10|[1-9])'" "Test 2: Console sessions created"; then
    ((TESTS_PASSED++))
fi

# Test 3: All 10 sessions exist
((TESTS_TOTAL++))
if run_remote "[ \$(tmux ls | grep -c 'console-') -eq 10 ]" "Test 3: All 10 console sessions exist"; then
    ((TESTS_PASSED++))
fi

# Test 4: Connect script exists and is executable
((TESTS_TOTAL++))
if run_remote "which connect-console" "Test 4: Connect script availability"; then
    ((TESTS_PASSED++))
fi

# Test 5: Setup script exists
((TESTS_TOTAL++))
if run_remote "which setup-console-sessions" "Test 5: Setup script availability"; then
    ((TESTS_PASSED++))
fi

# Test 6: Tmux configuration loaded
((TESTS_TOTAL++))
if run_remote "tmux show-options -g | grep -q 'mouse on'" "Test 6: Tmux configuration (mouse support)"; then
    ((TESTS_PASSED++))
fi

# Test 7: Function key bindings configured
((TESTS_TOTAL++))
if run_remote "tmux list-keys | grep -q 'C-F1'" "Test 7: Function key bindings (Ctrl+F1)"; then
    ((TESTS_PASSED++))
fi

# Test 8: Session switching works
((TESTS_TOTAL++))
if run_remote "tmux switch-client -t console-2 2>/dev/null || tmux new-session -d -s test-switch && tmux switch-client -t console-1 && tmux kill-session -t test-switch" "Test 8: Session switching functionality"; then
    ((TESTS_PASSED++))
fi

# Test 9: Installation persistence (survives logout)
((TESTS_TOTAL++))
if run_remote "tmux has-session -t console-1" "Test 9: Session persistence"; then
    ((TESTS_PASSED++))
fi

# Test 10: Custom test script execution
((TESTS_TOTAL++))
if run_remote "cd ~ && ./test-tmux-console.sh" "Test 10: Custom test script execution"; then
    ((TESTS_PASSED++))
fi

echo ""
echo -e "${BLUE}📊 Test Results Summary${NC}"
echo "======================"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}/$TESTS_TOTAL"

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo ""
    echo -e "${BLUE}🚀 Interactive Testing Available:${NC}"
    echo "   Connect manually: $SSH_COMMAND"
    echo "   Test Ctrl+F1-F10 switching"
    echo "   Try: connect-console"
    echo ""
    RESULT=0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    echo ""
    echo -e "${YELLOW}💡 Debugging suggestions:${NC}"
    echo "   1. Connect manually: $SSH_COMMAND"
    echo "   2. Check cloud-init logs: sudo cloud-init status --long"
    echo "   3. Verify installation: ./test-tmux-console.sh"
    echo ""
    RESULT=1
fi

# Additional connection info
echo -e "${BLUE}🔗 Connection Information:${NC}"
echo "   Public IP: $PUBLIC_IP"
echo "   SSH: $SSH_COMMAND"
echo "   Test console directly: $SSH_COMMAND -t 'tmux attach -t console-1'"
echo ""

exit $RESULT
