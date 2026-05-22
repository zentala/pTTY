#!/bin/bash
# ~/.tmux-persistent-console/setup.sh - Create 7 persistent tmux sessions

sessions=("console-1" "console-2" "console-3" "console-4" "console-5" "console-6" "console-7")

for session in "${sessions[@]}"; do
    # Check if session exists
    tmux has-session -t "$session" 2>/dev/null
    if [ $? != 0 ]; then
        # Create new session in detached mode
        tmux new-session -d -s "$session" -n "main"
        echo "Created session: $session"
    else
        echo "Session $session already exists"
    fi
done

echo "All sessions created. Use 'tmux ls' to list them."