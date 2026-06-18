#!/bin/bash
# Precise status bar position test - checks EXACT line where status bar appears
# Must be LAST visible line (height-1) or LAST line (height)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ -z "$TMUX" ]; then
    echo -e "${RED}❌ Must run inside tmux session${NC}"
    exit 1
fi

CURRENT_SESSION=$(tmux display-message -p '#S')

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🎯 Precise Status Bar Position Test${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

check_precise_position() {
    local session_name="$1"

    echo -e "${CYAN}Testing session: $session_name${NC}"

    # Get terminal dimensions
    local width=$(tmux display-message -p -t "$session_name" '#{pane_width}')
    local height=$(tmux display-message -p -t "$session_name" '#{pane_height}')

    echo "   Terminal: ${width}x${height}"

    # Capture pane with line numbers
    local numbered_content=$(tmux capture-pane -t "$session_name" -p -S - -E - | cat -n)

    # Find which line contains status bar
    local status_line=$(echo "$numbered_content" | grep "F1.*F10" | head -1)

    if [ -z "$status_line" ]; then
        echo -e "   ${RED}❌ FAIL: Status bar not found in pane${NC}"
        return 1
    fi

    # Extract line number
    local line_num=$(echo "$status_line" | awk '{print $1}')

    # Count total lines
    local total_lines=$(echo "$numbered_content" | wc -l)

    echo "   Status bar at line: $line_num / $total_lines"

    # Status bar should be at LAST line (total_lines) or LAST-1
    local expected_min=$((total_lines - 1))
    local expected_max=$total_lines

    if [ "$line_num" -lt "$expected_min" ] || [ "$line_num" -gt "$expected_max" ]; then
        echo -e "   ${RED}❌ FAIL: Status bar at wrong position${NC}"
        echo "      Expected: line $expected_min or $expected_max (bottom)"
        echo "      Got: line $line_num"
        echo ""
        echo -e "${YELLOW}   Last 5 lines of pane:${NC}"
        echo "$numbered_content" | tail -5
        return 1
    fi

    echo -e "   ${GREEN}✅ PASS: Status bar is at bottom (line $line_num/${total_lines})${NC}"

    # Check for duplicates
    local status_count=$(echo "$numbered_content" | grep -c "F1.*F10" || true)
    if [ "$status_count" -ne 1 ]; then
        echo -e "   ${RED}❌ FAIL: Found $status_count status bars (expected 1)${NC}"
        return 1
    fi

    echo -e "   ${GREEN}✅ PASS: Only one status bar present${NC}"

    # Verify tmux status-position setting
    local status_pos=$(tmux show-options -g status-position | awk '{print $2}')
    if [ "$status_pos" != "bottom" ]; then
        echo -e "   ${YELLOW}⚠️  WARNING: status-position is '$status_pos' (expected 'bottom')${NC}"
    else
        echo -e "   ${GREEN}✅ PASS: tmux status-position = bottom${NC}"
    fi

    echo ""
    return 0
}

# Test current session
check_precise_position "$CURRENT_SESSION"
result=$?

# Test all console sessions
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Testing all console sessions...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

total_errors=$result

for i in {1..10}; do
    session="console-$i"

    if ! tmux has-session -t "$session" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Session $session doesn't exist, skipping${NC}"
        echo ""
        continue
    fi

    # Switch to session
    tmux switch-client -t "$session"
    sleep 0.2

    check_precise_position "$session"
    session_result=$?
    ((total_errors += session_result))
done

# Return to original
tmux switch-client -t "$CURRENT_SESSION"

# Summary
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $total_errors -eq 0 ]; then
    echo -e "${GREEN}✅ ALL POSITION TESTS PASSED${NC}"
    echo -e "${GREEN}   Status bar is always at the bottom!${NC}"
    exit 0
else
    echo -e "${RED}❌ POSITION TESTS FAILED${NC}"
    echo -e "${RED}   Status bar position is incorrect${NC}"
    echo ""
    echo -e "${YELLOW}Debugging tips:${NC}"
    echo "   1. Check tmux.conf: grep 'status-position' ~/.vps/sessions/src/tmux.conf"
    echo "   2. Check status-format: tmux show-options -g | grep status-format"
    echo "   3. Reload config: tmux source-file ~/.vps/sessions/src/tmux.conf"
    exit 1
fi
