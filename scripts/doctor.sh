#!/bin/bash
# scripts/doctor.sh — one-shot install health check for tmux-persistent-console.
# Prints a colored report and exits 0 if everything is healthy, 1 if any
# critical check failed, 2 if only warnings.
#
# Run with:  bash scripts/doctor.sh

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="$HOME/.tmux-persistent-console"
SERVICE_PATH="$HOME/.config/systemd/user/tmux-console.service"
CONTAINER_CI=0

if [ -f /.dockerenv ] || [ -n "${CI:-}" ] || [ -n "${CONTAINER:-}" ]; then
    CONTAINER_CI=1
fi

errors=0
warnings=0

ok()   { echo -e " ${GREEN}✓${NC} $*"; }
warn() { echo -e " ${YELLOW}⚠${NC} $*"; warnings=$((warnings+1)); }
err()  { echo -e " ${RED}✗${NC} $*"; errors=$((errors+1)); }

section() { echo; echo -e "${BLUE}── $* ──${NC}"; }

section "Binaries"
for bin in tmux ssh systemctl loginctl; do
    if [ "$CONTAINER_CI" -eq 1 ] && { [ "$bin" = "systemctl" ] || [ "$bin" = "loginctl" ]; }; then
        ok "$bin skipped in container/CI mode"
        continue
    fi

    if command -v "$bin" &> /dev/null; then
        ok "$bin: $(command -v "$bin")"
    else
        if [ "$bin" = "systemctl" ] || [ "$bin" = "loginctl" ]; then
            warn "$bin not found — autostart on boot will not work"
        else
            err "$bin not found"
        fi
    fi
done

section "Install directory"
if [ -d "$INSTALL_DIR" ]; then
    ok "$INSTALL_DIR exists"
    for f in setup.sh tmux.conf status-format-v4.tmux; do
        if [ -f "$INSTALL_DIR/$f" ]; then
            ok "  $f present"
        else
            err "  $f missing in $INSTALL_DIR"
        fi
    done
else
    err "$INSTALL_DIR does not exist — run install.sh"
fi

section "tmux.conf"
if [ -f "$HOME/.tmux.conf" ]; then
    if grep -q "^# tmux-persistent-console config" "$HOME/.tmux.conf" 2>/dev/null; then
        ok "~/.tmux.conf installed by tmux-persistent-console"
    else
        warn "~/.tmux.conf exists but doesn't look like ours (no marker comment)"
    fi
    # Check for stale .vps/sessions references — the pre-v0.1.3 bug
    if grep -q "\.vps/sessions" "$HOME/.tmux.conf" 2>/dev/null; then
        err "~/.tmux.conf still references the stale ~/.vps/sessions/ path"
        err "  Reinstall with:  cd $INSTALL_DIR && bash install.sh"
    else
        ok "no stale ~/.vps/sessions/ references"
    fi
else
    err "~/.tmux.conf missing"
fi

if [ -d "$HOME/.vps/sessions" ]; then
    warn "legacy ~/.vps/sessions directory still present — safe to remove"
fi

section "systemd user service"
if [ "$CONTAINER_CI" -eq 1 ]; then
    ok "systemd service checks skipped in container/CI mode"
elif command -v systemctl &> /dev/null; then
    if [ -f "$SERVICE_PATH" ]; then
        ok "service file installed at $SERVICE_PATH"
    else
        err "service file missing — sessions will NOT auto-recreate on reboot"
    fi

    if systemctl --user is-enabled tmux-console.service &> /dev/null; then
        ok "service enabled"
    else
        err "service not enabled — run:  systemctl --user enable --now tmux-console.service"
    fi

    if systemctl --user is-active --quiet tmux-console.service; then
        ok "service active"
    else
        err "service not active — run:  systemctl --user status tmux-console.service"
    fi
else
    warn "no systemctl — skipping service checks"
fi

section "User lingering"
if [ "$CONTAINER_CI" -eq 1 ]; then
    ok "user lingering checks skipped in container/CI mode"
elif command -v loginctl &> /dev/null; then
    if loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
        ok "Linger=yes (service will run when nobody is logged in)"
    else
        err "Linger=no — service will NOT start on boot until anyone logs in"
        err "  Fix:  sudo loginctl enable-linger $USER"
    fi
else
    warn "no loginctl — cannot check lingering"
fi

section "tmux sessions"
if command -v tmux &> /dev/null; then
    if tmux ls 2>/dev/null | grep -q "^console-1:"; then
        n=$(tmux ls 2>/dev/null | grep -c "^console-")
        ok "$n console-* sessions running"
        tmux ls 2>/dev/null | grep "^console-" | sed 's/^/    /'
    else
        err "no console-* sessions found — service may have started but setup.sh failed"
    fi
else
    err "tmux missing"
fi

echo
if [ "$errors" -gt 0 ]; then
    echo -e "${RED}✗ $errors error(s), $warnings warning(s)${NC}"
    exit 1
elif [ "$warnings" -gt 0 ]; then
    echo -e "${YELLOW}⚠ $warnings warning(s) — non-blocking${NC}"
    exit 2
else
    echo -e "${GREEN}✓ all checks passed${NC}"
    exit 0
fi
