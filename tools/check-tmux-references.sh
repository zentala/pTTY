#!/bin/bash
# Validate script/config references used by the shipped tmux config.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMUX_CONF="$ROOT_DIR/src/tmux.conf"
INSTALLER="$ROOT_DIR/install.sh"
INSTALL_PREFIX="~/.tmux-persistent-console/"
missing=0

check_file() {
    local rel_path="$1"
    local source_path="$ROOT_DIR/src/$rel_path"

    if [ ! -f "$source_path" ]; then
        echo "missing source file referenced by tmux.conf: src/$rel_path"
        missing=1
        return
    fi

    if ! grep -q "$rel_path" "$INSTALLER"; then
        echo "installer does not download referenced file: src/$rel_path"
        missing=1
    fi
}

while IFS= read -r ref; do
    rel_path="${ref#"$INSTALL_PREFIX"}"
    check_file "$rel_path"
done < <(
    grep -Eo "${INSTALL_PREFIX}[A-Za-z0-9_./-]+" "$TMUX_CONF" |
        sed "s/[\"';].*$//" |
        sort -u
)

if grep -q "manager-menu.sh" "$TMUX_CONF"; then
    echo "tmux.conf still references removed manager-menu.sh"
    missing=1
fi

exit "$missing"
