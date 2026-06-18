#!/bin/bash
# Ctrl+? - Quick keyboard shortcuts popup overlay
# Non-intrusive, gum-styled popup

# Check if gum is available
if ! command -v gum &>/dev/null; then
    # Fallback to simple display
    clear
    cat << 'EOF'

  ⌨️  KEYBOARD SHORTCUTS

  F1-F10      Jump to console
  Ctrl+←→     Prev/Next
  Ctrl+R      Restart (confirm)
  F11         Manager Menu
  F12         Full Help
  Ctrl+?      This popup

  Press any key to close

EOF
    read -n 1
    exit 0
fi

# Gum styled popup (beautiful overlay)
gum style \
    --border rounded \
    --border-foreground 212 \
    --padding "1 2" \
    --margin "1" \
    --align left \
    "  ⌨️  KEYBOARD SHORTCUTS

  F1-F10      Jump to console
  Ctrl+←→     Prev/Next console
  Ctrl+R      Restart current (confirm)
  F11         Manager Menu
  F12         Full Help Reference
  Ctrl+?      This popup

  Press any key to close"

# Wait for any key
read -n 1 -s
