#!/bin/bash
# Ctrl+R - Restart current console with confirmation
# Uses gum for beautiful confirmation dialog

# Get current session
CURRENT_SESSION=$(tmux display-message -p '#S' 2>/dev/null)

# Don't allow restarting special sessions
if [ "$CURRENT_SESSION" = "help" ] || [ "$CURRENT_SESSION" = "manager" ]; then
    if command -v gum &>/dev/null; then
        gum style \
            --border rounded \
            --border-foreground 196 \
            --padding "1 2" \
            "⚠️  Cannot restart special session

Session '$CURRENT_SESSION' is a system window.
Use F1-F7 to switch to a console first."
        sleep 2
    else
        echo "⚠️  Cannot restart special session '$CURRENT_SESSION'"
        echo "Use F1-F7 to switch to a console first."
        sleep 2
    fi
    exit 1
fi

# Check if gum is available
if command -v gum &>/dev/null; then
    # Beautiful gum choice menu (works in popup, unlike confirm)
    clear
    echo ""
    gum style \
        --foreground 226 \
        --bold \
        "⚠️  Restart $CURRENT_SESSION?"
    echo ""
    echo "This will kill current session and create a new one."
    echo "You will lose unsaved work."
    echo ""

    choice=$(gum choose "Yes, restart now" "No, cancel" --cursor.foreground="212")

    if [ "$choice" = "Yes, restart now" ]; then
        # User confirmed - restart session
        echo ""
        gum style --foreground 226 "⚙️  Restarting $CURRENT_SESSION..."

        # Call restart logic
        ~/.tmux-persistent-console/restart-session.sh "$CURRENT_SESSION"

        gum style --foreground 46 "✓ Session restarted successfully"
        sleep 1
    else
        # User cancelled
        gum style --foreground 244 "Cancelled - session not restarted"
        sleep 1
    fi
else
    # Fallback without gum
    echo ""
    echo "⚠️  Restart $CURRENT_SESSION?"
    echo ""
    echo "This will:"
    echo "  • Kill current session"
    echo "  • Create new clean session"
    echo "  • Lose unsaved work"
    echo ""
    echo -n "Continue? [y/N]: "
    read -n 1 answer
    echo ""

    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        echo "⚙️  Restarting $CURRENT_SESSION..."
        ~/.tmux-persistent-console/restart-session.sh "$CURRENT_SESSION"
        echo "✓ Session restarted"
        sleep 1
    else
        echo "Cancelled"
        sleep 1
    fi
fi
