#!/bin/bash
# pTTY uninstaller

echo "==================================="
echo "          pTTY REMOVAL             "
echo "==================================="
echo ""

# Kill all console sessions
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

rm -f ~/bin/setup-console-sessions ~/bin/connect-console ~/bin/console-help ~/bin/ptty-doctor ~/bin/uninstall-console

echo ""
echo "✅ pTTY has been removed!"
echo "   Sessions stopped, config cleaned up."
echo ""
echo "💡 Tip: You can reinstall anytime with:"
echo "   curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | bash"
echo ""
