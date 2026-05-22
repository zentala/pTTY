#!/bin/bash
# ~/.tmux-persistent-console/safe-exit.sh - Safe exit wrapper for tmux sessions
# Prevents accidental session termination

safe_exit() {
    # ANSI color codes
    local GRAY_BG='\033[48;5;240m'   # Gray background
    local WHITE_TEXT='\033[97m'       # White text
    local BLACK_TEXT='\033[30m'       # Black text for brackets
    local RESET='\033[0m'             # Reset colors
    local BOLD='\033[1m'              # Bold text

    # Key button style with visible brackets
    local BRACKET="${GRAY_BG}${BLACK_TEXT}${BOLD}"
    local KEY_TEXT="${GRAY_BG}${WHITE_TEXT}${BOLD}"
    local KEY_END="${RESET}"

    # Cleanup function - always executed on exit
    _safe_exit_cleanup() {
        trap - INT EXIT TERM
    }

    # Check if we're inside a tmux session
    if [ -n "$TMUX" ]; then
        # Ensure cleanup always runs
        trap '_safe_exit_cleanup' EXIT INT TERM

        # Get current session name for restart
        local session_name=$(tmux display-message -p '#S')

        while true; do
            echo ""
            echo "⚠  WARNING: You are in a persistent tmux session!"
            echo ""
            echo "What do you want to do?"
            echo -e "  ${BRACKET}[${KEY_TEXT} ENTER ${BRACKET}]${KEY_END}                   - Detach safely (recommended)"
            echo -e "  ${BRACKET}[${KEY_TEXT} SHIFT ${BRACKET}]${KEY_END} + ${BRACKET}[${KEY_TEXT} Y ${BRACKET}]${KEY_END}          - Restart session (console will be reset)"
            echo -e "  ${BRACKET}[${KEY_TEXT} ESC ${BRACKET}]${KEY_END}                     - Stay in session"
            echo ""
            printf "Your choice: "

            # Read single character (works in both bash and zsh)
            # Ctrl+C handling via main trap (EXIT INT TERM)
            if [ -n "$ZSH_VERSION" ]; then
                # In zsh, read -k 1 reads one character including newline
                read -k 1 choice 2>/dev/null || {
                    # Ctrl+C pressed during read
                    echo ""
                    echo "[OK] Staying in session. You can continue working."
                    return 0
                }
                # If it's a newline, convert to empty string
                if [[ "$choice" == $'\n' ]]; then
                    choice=""
                fi
            else
                # In bash, read -n 1 works as expected
                read -n 1 choice 2>/dev/null || {
                    # Ctrl+C pressed during read
                    echo ""
                    echo "[OK] Staying in session. You can continue working."
                    return 0
                }
            fi

            # Show what was pressed (visual feedback)
            case "$choice" in
                Y)
                    echo "SHIFT+Y"
                    ;;
                y)
                    echo "y"
                    ;;
                $'\e')
                    echo "ESC"
                    ;;
                "")
                    echo "ENTER"
                    ;;
                *)
                    echo "'$choice'"
                    ;;
            esac
            echo ""

            case "$choice" in
                Y)
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "🔄 Restarting persistent tmux session '$session_name'..."
                    echo ""
                    echo "Session will be restarted safely (max 5s)."
                    echo "Reconnect with: tmux attach -t $session_name"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo ""

                    # Create secure temp directory if it doesn't exist
                    local temp_dir="${HOME}/.cache/tmux-console"
                    if ! mkdir -p "$temp_dir" 2>/dev/null; then
                        echo "[ERROR] Failed to create temp directory"
                        sleep 2
                        continue  # Back to menu
                    fi
                    chmod 700 "$temp_dir"

                    # Create secure temp file with mktemp
                    umask 077  # Only owner can read/write
                    local restart_script=$(mktemp "$temp_dir/restart-XXXXXX.sh")
                    if [ ! -f "$restart_script" ]; then
                        echo "[ERROR] Failed to create restart script"
                        sleep 2
                        continue  # Back to menu
                    fi

                    # Write restart script with lock file and polling
                    cat > "$restart_script" << 'RESTART_SCRIPT'
#!/bin/bash
session_name="$1"
temp_script="$2"
lock_file="$3"

# Create lock file to signal restart in progress
touch "$lock_file" 2>/dev/null

# Initial delay
sleep 1

# Kill old session if it still exists
if tmux has-session -t "$session_name" 2>/dev/null; then
    if ! tmux kill-session -t "$session_name" 2>/dev/null; then
        echo "[ERROR] Failed to kill old session '$session_name'" >&2
        rm -f "$temp_script" "$lock_file"
        exit 1
    fi
fi

# Poll until session is completely gone (max 5 seconds)
for i in {1..50}; do
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        break  # Session is gone, safe to proceed
    fi
    sleep 0.1
done

# Final check - if session still exists after 5s, fail
if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "[ERROR] Old session '$session_name' did not terminate in time" >&2
    rm -f "$temp_script" "$lock_file"
    exit 1
fi

# Additional safety delay
sleep 0.2

# Create new session
if ! tmux new-session -d -s "$session_name" -n "main" 2>/dev/null; then
    echo "[ERROR] Failed to create new session '$session_name'" >&2
    rm -f "$temp_script" "$lock_file"
    exit 1
fi

# Success - cleanup lock file and temp script
rm -f "$temp_script" "$lock_file"
exit 0
RESTART_SCRIPT
                    chmod 700 "$restart_script"

                    # Define lock file path
                    local lock_file="$temp_dir/restart-${session_name}.lock"

                    # Run restart script in background with parameters (session_name, script_path, lock_file)
                    nohup "$restart_script" "$session_name" "$restart_script" "$lock_file" > /dev/null 2>&1 &

                    sleep 1
                    builtin exit
                    ;;
                $'\e')
                    echo "[OK] Staying in session. You can continue working."
                    return 0
                    ;;
                "")
                    echo "✓ Detached from persistent tmux session '$session_name'"
                    sleep 0.8
                    if ! tmux detach-client 2>/dev/null; then
                        echo "[ERROR] Failed to detach from tmux session"
                        echo "You may need to close the terminal manually"
                        sleep 2
                        return 1
                    fi
                    return 0
                    ;;
                y)
                    echo -e "[!] You pressed ${BRACKET}[${KEY_TEXT} y ${BRACKET}]${KEY_END} (lowercase). You need ${BRACKET}[${KEY_TEXT} SHIFT ${BRACKET}]${KEY_END} + ${BRACKET}[${KEY_TEXT} Y ${BRACKET}]${KEY_END} to restart session."
                    sleep 2
                    # Loop continues, showing menu again
                    ;;
                *)
                    echo -e "[!] Invalid choice. Please press ${BRACKET}[${KEY_TEXT} ENTER ${BRACKET}]${KEY_END}, ${BRACKET}[${KEY_TEXT} SHIFT ${BRACKET}]${KEY_END} + ${BRACKET}[${KEY_TEXT} Y ${BRACKET}]${KEY_END}, or ${BRACKET}[${KEY_TEXT} ESC ${BRACKET}]${KEY_END}"
                    sleep 1
                    # Loop continues, showing menu again
                    ;;
            esac
        done
    else
        # Not in tmux, just exit normally
        builtin exit
    fi
}

# Override the exit command
alias exit='safe_exit'

# Inform user about Ctrl+D alternative
if [ -n "$TMUX" ]; then
    # Trap Ctrl+D to also use safe exit
    trap 'safe_exit' SIGINT
fi
