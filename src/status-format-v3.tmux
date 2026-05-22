# Status Bar Format v3.0 - No Flicker Edition
# Based on: ICONS.md, TODO.md, PLAN-FIX-FLICKERING.md
# Goal: Static format using native tmux (NO external scripts)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CRITICAL: Disable auto-refresh to prevent flickering
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status-interval 0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Status Bar: ENABLED and PINNED to bottom
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status on
set -g status-position bottom
set -g status-bg colour234
set -g status-fg colour255

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LEFT SIDE: [ pTTY ] [ user@host ]
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status-left-length 300

# Icons from ICONS.md
# - App:  (nf-md-console_network_outline f0c60)
# - User:  (nf-md-account_network_outline f0be6)
# - Server:  (nf-md-server_network f048d)

# Format: [ pTTY ] [ user @ host ]
set -g status-left '\
#[fg=colour39,bg=colour236,bold]  pTTY #[fg=colour236,bg=colour234]#[default] \
#[fg=colour244,bg=colour234]  #{USER} @ #[default]\
#[fg=colour244,bg=colour234] #H #[default] \
'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CENTER: Console tabs F1-F7 (using window-status)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Terminal icon:  (nf-md-console_network_outline f0c60)
# Active icon:  (nf-md-play_network f088b)
# Idle icon:  (nf-md-network_outline f0c9d)

# Inactive window/tab (gray)
set -g window-status-format '\
#[fg=colour244,bg=colour234]  #{window_index} #[default]\
'

# Active window/tab (cyan with shadow effect)
set -g window-status-current-format '\
#[fg=colour236,bg=colour234]#[default]\
#[fg=colour39,bg=colour236,bold]  #{window_index} #[default]\
#[fg=colour236,bg=colour234]#[default]\
'

set -g window-status-separator ''

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RIGHT SIDE: F8-F10 (suspended) | F11 Manager | F12 Help
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status-right-length 100

# Icons from ICONS.md:
# - Suspended/off:  (nf-md-close_network_outline f0c5f)
# - Manager: 󰒓 (nf-md-table_network f13c9) or  (nf-md-network_pos f1acb)
# - Help:  (nf-md-help_network_outline f0c8a)

set -g status-right '\
#[fg=colour240,bg=colour234]  F8-10 #[default] \
#[fg=colour244,bg=colour234] 󰒓 F11 Manager #[default] \
#[fg=colour244,bg=colour234]  F12 Help #[default]\
'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Window/Session Justification
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status-justify left

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Remove old status-format entries (cleanup)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status-format[1] ''

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VERIFICATION NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Expected result:
# [ pTTY ] [ user@host ]   1  2  3  4  5  6  7   F8-10  󰒓 F11 Manager   F12 Help
#
# NO FLICKERING because:
# - status-interval 0 (no auto-refresh)
# - No external script calls '#()'
# - Pure tmux format strings with variables
# - Variables only update on actual changes (session switch, resize)
#
# Test with:
# ~/.tmux-persistent-console/tests/test-no-flicker.sh 30
#
# Should see: "✅ PERFECT: Status bar completely stable"
