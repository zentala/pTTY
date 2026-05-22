#!/bin/bash
# tmux-persistent-console uninstaller

echo "==================================="
echo "  TMUX PERSISTENT CONSOLE REMOVAL  "
echo "==================================="
echo ""

# Stop + remove systemd autostart so sessions don't get re-created on next boot
if command -v systemctl &> /dev/null; then
    if [ -f "$HOME/.config/systemd/user/tmux-console.service" ]; then
        echo "🛑 Disabling systemd autostart..."
        systemctl --user disable --now tmux-console.service 2>/dev/null || true
        rm -f "$HOME/.config/systemd/user/tmux-console.service"
        systemctl --user daemon-reload 2>/dev/null || true
        echo "   ✓ Removed tmux-console.service"
    fi

    # Drop linger only if no other user services rely on it.
    if loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
        other_user_units=$(systemctl --user list-unit-files --state=enabled --no-legend 2>/dev/null | wc -l)
        if [ "$other_user_units" -eq 0 ]; then
            echo "🧹 Disabling user lingering (no other user services need it)..."
            loginctl disable-linger "$USER" 2>/dev/null || sudo loginctl disable-linger "$USER" 2>/dev/null || \
                echo "   ⚠ Could not disable lingering — run manually: sudo loginctl disable-linger $USER"
        else
            echo "ℹ️  Keeping linger=yes ($other_user_units other user services still enabled)"
        fi
    fi
fi

# Kill all console sessions (1..10 — covers both active and on-demand slots)
echo "🔄 Stopping console sessions..."
for i in {1..10}; do
    if tmux has-session -t "console-$i" 2>/dev/null; then
        tmux kill-session -t "console-$i"
        echo "   ✓ Stopped console-$i"
    fi
done

# Remove tmux config if it was installed by us
if [ -f ~/.tmux.conf ] && grep -q "# tmux-persistent-console config" ~/.tmux.conf 2>/dev/null; then
    echo "🗑️  Removing tmux configuration..."
    rm ~/.tmux.conf
    echo "   ✓ Removed ~/.tmux.conf"
fi

# Remove any aliases or shortcuts
if [ -f ~/.bashrc ] && grep -q "connect-console" ~/.bashrc; then
    echo "🗑️  Removing bash aliases..."
    sed -i '/connect-console/d' ~/.bashrc
    echo "   ✓ Removed aliases from ~/.bashrc"
fi

if [ -f ~/.zshrc ] && grep -q "connect-console" ~/.zshrc; then
    echo "🗑️  Removing zsh aliases..."
    sed -i '/connect-console/d' ~/.zshrc
    echo "   ✓ Removed aliases from ~/.zshrc"
fi

echo ""
echo "✅ Tmux Persistent Console has been removed!"
echo "   Sessions stopped, config cleaned up."
echo ""
echo "💡 Tip: You can reinstall anytime with:"
echo "   curl -sSL https://raw.githubusercontent.com/zentala/tmux-persistent-console/main/install.sh | bash"
echo ""