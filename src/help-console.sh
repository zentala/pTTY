#!/bin/bash
# Minimalna konsola pomocy - bez ładowania profili
# Używana przez F12 w tmux
# Refactored to use TUI library

# Wyłącz wszystkie profile i rc files
export BASH_ENV=""
export ENV=""

# Load TUI library
TUI_DIR="$(dirname "${BASH_SOURCE[0]}")/tui"
source "$TUI_DIR/tui-core.sh"
source "$TUI_DIR/tui-status.sh"

# Display help content
show_help_content() {
    clear

    tui_header "🖥️  pTTY - Quick Help Reference"
    echo ""

    cat << 'EOF'
🚀 CONSOLE SWITCHING:
   Ctrl+F1  📟 Console-1 (Claude Code)
   Ctrl+F2  🤖 Console-2 (Copilot CLI)
   Ctrl+F3  💻 Console-3 (Development)
   Ctrl+F4  🧪 Console-4 (Testing)
   Ctrl+F5  📊 Console-5 (Monitoring)
   Ctrl+F6  🌐 Console-6 (Git/Deploy)
   Ctrl+F7  🔧 Console-7 (System Admin)
   Ctrl+F8  📟 Console-8
   Ctrl+F9  📟 Console-9
   Ctrl+F10 📟 Console-10

⚡ SYSTEM CONTROLS:
   Ctrl+F11  🎛️  Manager menu
   Ctrl+F12  📋 This help window

🛠️  COMMANDS:
   connect-console      Interactive session menu
   console-help        Full management menu
   Ctrl+Alt+R          Reset current terminal

💡 TIPS:
• Sessions survive SSH disconnects and client reboots
• Server reboots recreate empty sessions, not in-memory context
• Use Ctrl+b,d to detach without menu
• This help window stays open - switch with Ctrl+F1-F10
• Type 'exit' or close window when done

EOF

    tui_separator
    echo ""

    tui_status_line "Help Console" "Ready" "green"
    tui_status_line "Available" "console-help, connect-console, exit" "cyan"
    echo ""
}

# Show initial help
show_help_content

# Prosty shell loop - minimalistyczny
while true; do
    echo -n "help> "
    read -r cmd

    case "$cmd" in
        "exit"|"quit"|"q")
            exit 0
            ;;
        "console-help")
            console-help
            ;;
        "connect-console")
            connect-console
            ;;
        "help"|"")
            echo "Available: console-help, connect-console, exit"
            ;;
        "clear")
            show_help_content
            ;;
        *)
            echo "Unknown command: $cmd"
            echo "Try: console-help, connect-console, clear, exit"
            ;;
    esac
done
