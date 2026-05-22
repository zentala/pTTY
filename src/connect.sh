#!/bin/bash
# ~/.tmux-persistent-console/connect.sh - Easy console connection

echo "==================================="
echo "    PERSISTENT CONSOLE MANAGER     "
echo "==================================="
echo ""
echo "Available consoles:"
echo ""

# List sessions with status
tmux ls 2>/dev/null | nl -w2 -s') '

echo ""
echo "Enter console number (1-7) or 'q' to quit: "
read -r choice

case $choice in
    1) tmux attach-session -t console-1 ;;
    2) tmux attach-session -t console-2 ;;
    3) tmux attach-session -t console-3 ;;
    4) tmux attach-session -t console-4 ;;
    5) tmux attach-session -t console-5 ;;
    6) tmux attach-session -t console-6 ;;
    7) tmux attach-session -t console-7 ;;
    q) exit 0 ;;
    *) echo "Invalid choice"; exit 1 ;;
esac