#!/bin/bash
# Create persistent tmux sessions (console-1 .. console-5) — empty shells
# auto-recreated on boot via tmux-console.service.

sessions=("console-1" "console-2" "console-3" "console-4" "console-5")

for session in "${sessions[@]}"; do
    if ! tmux has-session -t "$session" 2>/dev/null; then
        tmux new-session -d -s "$session" -n "main"
        echo "Created session: $session"
    else
        echo "Session $session already exists"
    fi
done

echo 'Use tmux ls to list sessions.'
