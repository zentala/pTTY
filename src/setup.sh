#!/bin/bash
# ~/.tmux-persistent-console/setup.sh
# Create the 5 "active" persistent tmux sessions (console-1..5).
# Sessions 6-10 are "on-demand" — bind keys exist in tmux.conf but the
# sessions aren't pre-created (per project design: active vs suspended slots).

sessions=("console-1" "console-2" "console-3" "console-4" "console-5")

for session in "${sessions[@]}"; do
    if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session" -n "main"
        echo "Created session: $session"
    else
        echo "Session $session already exists"
    fi
done

echo "All sessions created. Use 'tmux ls' to list them."
