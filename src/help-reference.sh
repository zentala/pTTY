#!/bin/bash
# F12 - Static Help Reference Window
# Simple, clean documentation without decorative borders

VERSION="1.0.0"

# Clear screen and show help
clear

cat << 'EOF'

  🖥️  PERSISTENT CONSOLE v1.0.0 - Quick Reference


  KEYBOARD SHORTCUTS

    Direct Jump:
      Ctrl+F1-F10    Jump to console 1-10

    Navigation:
      Ctrl+←         Previous console
      Ctrl+→         Next console

    Management:
      Ctrl+F11       Console Manager (interactive menu)
      Ctrl+R         Restart current console (with confirmation)
      Ctrl+D         Disconnect safely (detach)
      Ctrl+?         Show keyboard shortcuts popup


  MOUSE SUPPORT

    Click tab      Switch to console
    Scroll wheel   Navigate within console


  STATUS BAR

    Console tabs show:
      Icon     Active session (has processes)
      Icon     Empty/idle session
      Number   Console number (1-10)
      Name     Current window name

    Active tab highlighted in cyan with shadow effect


  SESSIONS

    • All sessions are persistent (survive disconnects)
    • Consoles 1-10 start automatically
    • Type 'exit' to safely detach (won't kill session)
    • Sessions survive SSH disconnects and client reboots
    • Server reboots recreate empty sessions, not in-memory context


  HELP & SUPPORT

    Documentation:  github.com/zentala/pTTY
    Report Bug:     github.com/zentala/pTTY/issues
    Author:         Zentala


  Press Ctrl+F1-F10 or click a tab to switch consoles


EOF

# Keep window open (static display, no input)
echo ""
echo "  This is a read-only reference window."
echo "  Switch to another console using Ctrl+F1-F10 or close this tab."
echo ""

# Sleep forever (keep window visible)
sleep infinity
