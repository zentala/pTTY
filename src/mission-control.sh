#!/bin/bash
# Mission Control - F11 panel for tmux session management
# Persistent Console v1.0.0

# Version info
VERSION="1.0.0"
HEADER="🖥️  PERSISTENT CONSOLE v${VERSION}"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

# Get current session for highlighting
CURRENT_SESSION="${TMUX_SESSION:-$(tmux display-message -p '#S' 2>/dev/null)}"

# Build session list with status and details
build_session_list() {
    local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

    if [ -z "$sessions" ]; then
        echo "No sessions found"
        return 1
    fi

    local idx=1
    while IFS= read -r session; do
        local status="○"  # inactive
        local windows=$(tmux list-windows -t "$session" 2>/dev/null | wc -l)
        local current_window=$(tmux list-windows -t "$session" -F "#{window_active} #{window_name} #{pane_current_command}" 2>/dev/null | grep "^1" | cut -d' ' -f2-)

        # Check if session has active processes
        if tmux list-panes -t "$session" -F "#{pane_pid}" &>/dev/null; then
            status="●"
        fi

        # Get F-key mapping
        local fkey=""
        case "$session" in
            console-1) fkey="[F1]" ;;
            console-2) fkey="[F2]" ;;
            console-3) fkey="[F3]" ;;
            console-4) fkey="[F4]" ;;
            console-5) fkey="[F5]" ;;
            console-6) fkey="[F6]" ;;
            console-7) fkey="[F7]" ;;
            console-8) fkey="[F8]" ;;
            console-9) fkey="[F9]" ;;
            console-10) fkey="[F10]" ;;
            *) fkey="    " ;;
        esac

        # Format window info
        local window_info="$current_window"
        [ -z "$window_info" ] && window_info="(empty)"

        # Mark current session
        local marker=" "
        [ "$session" = "$CURRENT_SESSION" ] && marker="→"

        # Output format: "marker status session fkey | window_info"
        printf "%s %s %-15s %s │ %s\n" "$marker" "$status" "$session" "$fkey" "$window_info"

        idx=$((idx + 1))
    done <<< "$sessions"
}

# Preview pane content for selected session
preview_session() {
    local line="$1"
    local session=$(echo "$line" | awk '{print $3}')

    if [ -z "$session" ]; then
        echo "Select a session to see preview"
        return
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Session: $session"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show session info
    tmux list-windows -t "$session" -F "Window #{window_index}: #{window_name} (#{window_panes} panes)" 2>/dev/null || echo "Session not found"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Current pane content:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Capture last 20 lines from current pane
    tmux capture-pane -t "$session" -p -S -20 2>/dev/null || echo "(no content)"
}

# Restart session
restart_session() {
    local session="$1"

    if [ -z "$session" ]; then
        echo "No session specified"
        return 1
    fi

    # Create temp script for background restart
    local temp_dir="${HOME}/.cache/tmux-console"
    mkdir -p "$temp_dir" && chmod 700 "$temp_dir"

    local restart_script=$(mktemp "$temp_dir/restart-XXXXXX.sh")
    local lock_file="$temp_dir/restart-${session}.lock"

    cat > "$restart_script" << 'RESTART_SCRIPT'
#!/bin/bash
session_name="$1"
temp_script="$2"
lock_file="$3"

touch "$lock_file" 2>/dev/null
sleep 0.5

if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux kill-session -t "$session_name" 2>/dev/null
fi

# Wait for session to terminate
for i in {1..50}; do
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        break
    fi
    sleep 0.1
done

sleep 0.2

# Create new session
tmux new-session -d -s "$session_name" -n "main" 2>/dev/null

rm -f "$temp_script" "$lock_file"
exit 0
RESTART_SCRIPT

    chmod 700 "$restart_script"
    nohup "$restart_script" "$session" "$restart_script" "$lock_file" > /dev/null 2>&1 &

    echo "✓ Session $session restarting..."
    sleep 1
}

# Main mission control interface
show_mission_control() {
    # Check if fzf is available
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required for Mission Control"
        echo "Install: sudo apt-get install fzf"
        sleep 2
        return 1
    fi

    # Build session list
    local session_list=$(build_session_list)

    if [ -z "$session_list" ]; then
        echo "No tmux sessions found"
        sleep 2
        return 1
    fi

    # Create inline preview script
    local preview_cmd='
        session=$(echo {} | awk "{print \$3}")
        if [ -n "$session" ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Session: $session"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            tmux list-windows -t "$session" -F "Window #{window_index}: #{window_name} (#{window_panes} panes)" 2>/dev/null
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Current pane:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            tmux capture-pane -t "$session" -p -S -15 2>/dev/null
        fi
    '

    # fzf with preview and keybindings (compatible with fzf 0.20+)
    local selected=$(echo "$session_list" | fzf \
        --height=100% \
        --border \
        --prompt="> " \
        --header="$HEADER | [ENTER] Switch  [Ctrl+R] Restart  [ESC] Close" \
        --preview="$preview_cmd" \
        --preview-window=right:60% \
        --reverse)

    # Extract session name from selection
    local session_name=$(echo "$selected" | awk '{print $3}')

    if [ -n "$session_name" ]; then
        # Ask what to do with selected session
        clear
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Session: $session_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "  [ENTER]  Switch to this session"
        echo "  [R]      Restart session (kill + recreate)"
        echo "  [ESC]    Cancel"
        echo ""
        echo -n "Choose action: "

        read -n 1 action
        echo ""

        case "$action" in
            r|R)
                echo ""
                echo "⚠  Restarting session '$session_name'..."
                restart_session "$session_name"
                echo ""
                echo "✓ Session restarted. Press any key to continue..."
                read -n 1
                ;;
            ""|$'\n')
                # Switch to selected session
                if [ -n "$TMUX" ]; then
                    tmux switch-client -t "$session_name" 2>/dev/null
                else
                    tmux attach-session -t "$session_name" 2>/dev/null
                fi
                ;;
            *)
                # Cancel - do nothing
                ;;
        esac
    fi
}

# Export for fzf callbacks
export -f build_session_list
export -f restart_session

# Run mission control
show_mission_control
