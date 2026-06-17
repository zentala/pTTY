#!/bin/bash
# ~/.tmux-persistent-console/setup.sh
# Create all persistent tmux sessions (console-1..10).

sessions=(
    "console-1" "console-2" "console-3" "console-4" "console-5"
    "console-6" "console-7" "console-8" "console-9" "console-10"
)

for session in "${sessions[@]}"; do
    if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session" -n "main"
        echo "Created session: $session"
    else
        echo "Session $session already exists"
    fi
done

echo "All 10 console sessions are ready. Use 'tmux ls' to list them."
