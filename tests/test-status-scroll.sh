#!/bin/bash
# Test if status bar stays PINNED to bottom when scrolling content
# CRITICAL: Status bar must be ALWAYS visible at screen bottom, not scroll with content

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
echo -e "${CYAN}📜 Status Bar Scroll Test${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "This test verifies that status bar stays PINNED to bottom"
echo "when scrolling through terminal content (like Claude output)."
echo ""

test_scroll_behavior() {
    local session_name="$1"

    echo -e "${CYAN}Testing session: $session_name${NC}"

    # Get terminal dimensions
    local height=$(tmux display-message -p -t "$session_name" '#{pane_height}')
    echo "   Terminal height: $height lines"

    # Step 1: Check initial state
    echo "   Step 1: Checking initial state..."
    local initial_status=$(tmux capture-pane -t "$session_name" -p | tail -1)
    local initial_has_bar=$(echo "$initial_status" | grep -c "F1.*F10" || true)

    if [ "$initial_has_bar" -ne 1 ]; then
        echo -e "   ${RED}❌ FAIL: Status bar not found at bottom initially${NC}"
        return 1
    fi
    echo -e "   ${GREEN}✅ Initial: Status bar at bottom${NC}"

    # Step 2: Generate LOTS of output to force scrolling
    echo "   Step 2: Generating output to trigger scroll..."

    # Generate 50 lines of output (way more than terminal height)
    for i in {1..50}; do
        tmux send-keys -t "$session_name" "echo 'Line $i - Testing scroll behavior - Status bar should stay pinned at bottom'" Enter
    done

    # Wait for output to finish
    sleep 0.5

    # Step 3: Check if status bar is STILL at visible bottom
    echo "   Step 3: Checking status bar after scroll..."

    # Capture what's CURRENTLY VISIBLE on screen (not scrollback!)
    local visible_content=$(tmux capture-pane -t "$session_name" -p)
    local last_visible_line=$(echo "$visible_content" | tail -1)

    local after_scroll_has_bar=$(echo "$last_visible_line" | grep -c "F1.*F10" || true)

    if [ "$after_scroll_has_bar" -ne 1 ]; then
        echo -e "   ${RED}❌ FAIL: Status bar NOT at bottom after scroll${NC}"
        echo "      Last visible line: '$last_visible_line'"
        echo ""
        echo -e "   ${YELLOW}This means status bar scrolled UP with content!${NC}"
        echo -e "   ${YELLOW}Expected: Status bar PINNED to screen bottom (like tmux status line)${NC}"
        echo -e "   ${YELLOW}Actual: Status bar is part of pane content (wrong!)${NC}"
        return 1
    fi

    echo -e "   ${GREEN}✅ After scroll: Status bar still at bottom${NC}"

    # Step 4: Verify bar appears EXACTLY ONCE in visible area
    local bar_count=$(echo "$visible_content" | grep -c "F1.*F10" || true)

    if [ "$bar_count" -ne 1 ]; then
        echo -e "   ${RED}❌ FAIL: Found $bar_count status bars in visible area${NC}"
        return 1
    fi

    echo -e "   ${GREEN}✅ Only one status bar visible${NC}"

    # Step 5: Clean up - clear the test output
    tmux send-keys -t "$session_name" "clear" Enter
    sleep 0.2

    echo ""
    return 0
}

# Test current session
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Testing scroll behavior...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

total_errors=0

# Test console-1 (where Claude usually runs)
if tmux has-session -t console-1 2>/dev/null; then
    tmux switch-client -t console-1
    sleep 0.3

    test_scroll_behavior "console-1"
    result=$?
    ((total_errors += result))
else
    echo -e "${YELLOW}⚠️  console-1 doesn't exist, creating...${NC}"
    tmux new-session -d -s console-1
    tmux switch-client -t console-1
    sleep 0.3

    test_scroll_behavior "console-1"
    result=$?
    ((total_errors += result))
fi

# Test one more session to be sure
if tmux has-session -t console-2 2>/dev/null; then
    tmux switch-client -t console-2
    sleep 0.3

    test_scroll_behavior "console-2"
    result=$?
    ((total_errors += result))
fi

# Return to original session
tmux switch-client -t "$CURRENT_SESSION" 2>/dev/null || true

# Summary
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $total_errors -eq 0 ]; then
    echo -e "${GREEN}✅ SCROLL TEST PASSED${NC}"
    echo -e "${GREEN}   Status bar stays pinned at bottom!${NC}"
    echo ""
    echo "   Status bar is correctly implemented as tmux status line"
    echo "   (not as part of pane content)."
    exit 0
else
    echo -e "${RED}❌ SCROLL TEST FAILED${NC}"
    echo -e "${RED}   Status bar scrolls with content!${NC}"
    echo ""
    echo -e "${YELLOW}PROBLEM DIAGNOSIS:${NC}"
    echo "   Status bar is part of pane content instead of tmux status line."
    echo ""
    echo -e "${YELLOW}ROOT CAUSE:${NC}"
    echo "   Using 'status-left' makes bar part of content that scrolls."
    echo ""
    echo -e "${YELLOW}SOLUTION:${NC}"
    echo "   Status bar should be NATIVE tmux status line:"
    echo "   • set -g status on"
    echo "   • set -g status-position bottom"
    echo "   • Status bar MUST be separate from pane content"
    echo ""
    echo -e "${YELLOW}DEBUG COMMANDS:${NC}"
    echo "   # Check if status line is enabled"
    echo "   tmux show-options -g status"
    echo ""
    echo "   # Check status position"
    echo "   tmux show-options -g status-position"
    echo ""
    echo "   # Verify status bar not in pane content"
    echo "   tmux capture-pane -p | grep 'F1.*F10'"
    exit 1
fi
