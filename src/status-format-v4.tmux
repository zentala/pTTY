# Status Bar Format v4.0 - Session Tabs Edition
# Shows F1-F10 session tabs instead of windows
# Based on: SPEC.md (2025-10-11), src/theme-config.sh
# Goal: Static format using native tmux (NO external scripts, NO FLICKER)

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
# LEFT SIDE: [ 󰢩 pTTY ] [ 󰀉 user @ server ]
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status-left-length 300

# Icons from theme-config.sh:
# - App: 󰢩 (nf-md-console_network f08a9)
# - User: 󰀉 (nf-md-account_network f0011)
# - Server:  (generic server icon)

set -g status-left '\
#[fg=colour39]#[bg=colour236]#[bold] 󰢩 pTTY #[fg=colour236]#[bg=colour234]#[default] \
#[fg=colour244]#[bg=colour234] 󰀉 #{USER} @ #[default]\
#[fg=colour244]#[bg=colour234] #H #[default] \
'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CENTER: Hide window-status (we show sessions in status-right)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g window-status-format ''
set -g window-status-current-format ''
set -g window-status-separator ''

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RIGHT SIDE: Session tabs F1-F10 + F11 Manager + F12 Help
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status-right-length 300

# Icons from theme-config.sh:
# Console: 󰢩 (nf-md-console_network f08a9)
# Manager:  (nf-md-network_pos f1acb)
# Help:  (nf-md-help_network f06f5)

# Colors:
# Current: colour39 (cyan) with bg colour236
# Other: colour240 (dark gray)

# v0.2 uses 10 always-created sessions. The bar only distinguishes the current
# console from the other consoles; it does not show a suspended/on-demand state.

set -g status-right '#{?#{==:#{client_session},console-1},#[fg=colour39]#[bg=colour236] 󰢩 F1 #[default],#[fg=colour240] 󰢩 F1 #[default]} #{?#{==:#{client_session},console-2},#[fg=colour39]#[bg=colour236] 󰢩 F2 #[default],#[fg=colour240] 󰢩 F2 #[default]} #{?#{==:#{client_session},console-3},#[fg=colour39]#[bg=colour236] 󰢩 F3 #[default],#[fg=colour240] 󰢩 F3 #[default]} #{?#{==:#{client_session},console-4},#[fg=colour39]#[bg=colour236] 󰢩 F4 #[default],#[fg=colour240] 󰢩 F4 #[default]} #{?#{==:#{client_session},console-5},#[fg=colour39]#[bg=colour236] 󰢩 F5 #[default],#[fg=colour240] 󰢩 F5 #[default]} #{?#{==:#{client_session},console-6},#[fg=colour39]#[bg=colour236] 󰢩 F6 #[default],#[fg=colour240] 󰢩 F6 #[default]} #{?#{==:#{client_session},console-7},#[fg=colour39]#[bg=colour236] 󰢩 F7 #[default],#[fg=colour240] 󰢩 F7 #[default]} #{?#{==:#{client_session},console-8},#[fg=colour39]#[bg=colour236] 󰢩 F8 #[default],#[fg=colour240] 󰢩 F8 #[default]} #{?#{==:#{client_session},console-9},#[fg=colour39]#[bg=colour236] 󰢩 F9 #[default],#[fg=colour240] 󰢩 F9 #[default]} #{?#{==:#{client_session},console-10},#[fg=colour39]#[bg=colour236] 󰢩 F10 #[default],#[fg=colour240] 󰢩 F10 #[default]}  #[fg=colour255] 󱫋 F11 #[default] #[fg=colour255] 󰲊 F12 #[default]'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Window/Session Justification
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -g status-justify left

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VERIFICATION NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Expected result:
# [ 󰢩 pTTY ][ 󰀉 user@host ]   F1  F2 ... 󰢩 F5 ... F10   F11   F12
#                             (if on console-5, F5 is highlighted cyan with shadow)
#
# NO FLICKERING because:
# - status-interval 0 (no auto-refresh)
# - No external script calls '#()'
# - Pure tmux conditional format strings
# - Only updates on session switch
#
