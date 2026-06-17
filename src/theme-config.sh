#!/bin/bash
# pTTY Theme Configuration
# Icons and colors for status bar and UI elements
#
# Version: 1.0
# Date: 2025-10-11
#
# Usage:
#   source ~/.tmux-persistent-console/theme-config.sh
#   echo "$ICON_PTTY_LOGO"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ICONS - Nerd Fonts Mode (NF)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# All icons from: docs/ICONS-NETWORK-SET.md (network theme)

# Application Identity
export ICON_PTTY_LOGO="󰢩"          # nf-md-console_network (f08a9)
export ICON_USER=""              # nf-md-account_network (f0011)
export ICON_SERVER=""             # Custom - not in network set (fallback to generic)

# Terminal Session States
export ICON_SESSION_ACTIVE="󰢩"    # nf-md-console_network (f08a9) - currently active
export ICON_SESSION_AVAILABLE="󰱠"  # nf-md-console_network_outline (f0c60) - created, idle
export ICON_SESSION_OTHER="󰢩"      # nf-md-console_network (f08a9) - non-current console
export ICON_SESSION_CRASHED="󰱟"    # nf-md-close_network_outline (f0c5f) - killed/crashed

# Special Functions
export ICON_MANAGER="󱫋"            # nf-md-network_pos (f1acb) - F11 Manager
export ICON_HELP="󰲊"               # nf-md-help_network_outline (f0c8a) - F12 Help

# Additional UI Elements (future use)
export ICON_DOWNLOAD=""           # nf-md-download_network (f06f4)
export ICON_UPLOAD=""             # nf-md-upload_network_outline (f0cd8)
export ICON_FOLDER=""             # nf-md-folder_network (f0870)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ICONS - Fallback Mode (Non-NF)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ASCII/Unicode fallback for terminals without Nerd Fonts

export ICON_PTTY_LOGO_FALLBACK="⚡"
export ICON_USER_FALLBACK="@"
export ICON_SERVER_FALLBACK=""    # null - no icon

export ICON_SESSION_ACTIVE_FALLBACK="▶"
export ICON_SESSION_AVAILABLE_FALLBACK="○"
export ICON_SESSION_OTHER_FALLBACK="○"
export ICON_SESSION_CRASHED_FALLBACK="✖"

export ICON_MANAGER_FALLBACK="☰"
export ICON_HELP_FALLBACK="?"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COLORS - Status Bar Theme
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Color codes for tmux (colour0-colour255)

# Background Colors
export COLOR_BG_STATUS_BAR="colour234"      # Status bar background (lighter than session)
export COLOR_BG_SESSION="colour235"         # Session/terminal background (darker)
export COLOR_BG_ACTIVE_TAB="colour236"      # Active session tab background

# Foreground Colors - Session States
export COLOR_SESSION_ACTIVE="colour39"      # Cyan - active session (NO BOLD)
export COLOR_SESSION_AVAILABLE="colour255"  # White - available/created session
export COLOR_SESSION_OTHER="colour240"      # Dark gray - non-current console
export COLOR_SESSION_CRASHED="colour196"    # Red - crashed/killed

# Foreground Colors - Special Elements
export COLOR_MANAGER="colour255"            # White - F11 Manager (same as available)
export COLOR_HELP="colour255"               # White - F12 Help (same as available)
export COLOR_PTTY_LOGO="colour39"           # Cyan - pTTY branding
export COLOR_USER_HOST="colour244"          # Light gray - user@host info

# Shadow/Separator Colors
export COLOR_SHADOW="colour236"             # Shadow effect for active tab
export COLOR_SEPARATOR="colour238"          # Separator between elements

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HELPER FUNCTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Get icon with fallback support
# Usage: get_icon "SESSION_ACTIVE"
get_icon() {
    local icon_name="$1"
    local nf_mode="${PTTY_NF_MODE:-true}"  # Default: NF enabled

    if [[ "$nf_mode" == "true" ]]; then
        eval echo "\$ICON_${icon_name}"
    else
        eval echo "\$ICON_${icon_name}_FALLBACK"
    fi
}

# Get color for tmux format string
# Usage: get_color "SESSION_ACTIVE"
get_color() {
    local color_name="$1"
    eval echo "\$COLOR_${color_name}"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Validate Nerd Fonts availability (optional)
validate_nerd_fonts() {
    if ! echo -e "\uf0c60" | grep -q ""; then
        echo "⚠️  WARNING: Nerd Fonts not detected. Falling back to ASCII icons."
        export PTTY_NF_MODE="false"
        return 1
    fi
    export PTTY_NF_MODE="true"
    return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEBUG INFO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Print theme configuration (for debugging)
show_theme_config() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "pTTY Theme Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "NF Mode: ${PTTY_NF_MODE:-true}"
    echo ""
    echo "Icons (NF):"
    echo "  Logo:      $ICON_PTTY_LOGO"
    echo "  Active:    $ICON_SESSION_ACTIVE"
    echo "  Available: $ICON_SESSION_AVAILABLE"
    echo "  Other:     $ICON_SESSION_OTHER"
    echo "  Crashed:   $ICON_SESSION_CRASHED"
    echo "  Manager:   $ICON_MANAGER"
    echo "  Help:      $ICON_HELP"
    echo ""
    echo "Colors:"
    echo "  Active:    $COLOR_SESSION_ACTIVE"
    echo "  Available: $COLOR_SESSION_AVAILABLE"
    echo "  Other:     $COLOR_SESSION_OTHER"
    echo "  Crashed:   $COLOR_SESSION_CRASHED"
    echo ""
}

# Auto-run validation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_nerd_fonts
    show_theme_config
fi
