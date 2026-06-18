#!/bin/bash
# Check relative markdown links in release-facing documentation.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

check_doc() {
    local doc="$1"
    local abs_doc="$ROOT_DIR/$doc"
    local base_dir

    base_dir="$(dirname "$abs_doc")"

    while IFS= read -r target; do
        case "$target" in
            http://*|https://*|mailto:*|\#*|"") continue ;;
        esac

        target="${target%%#*}"
        target="${target%%[[:space:]]*}"

        if [ ! -e "$base_dir/$target" ]; then
            echo "$doc: broken link target: $target"
            status=1
        fi
    done < <(
        grep -Eo '\[[^]]+\]\(([^)]+)\)' "$abs_doc" |
            sed -E 's/^.*\(([^)]+)\)$/\1/'
    )
}

for doc in "$@"; do
    if [ ! -f "$ROOT_DIR/$doc" ]; then
        echo "missing markdown file: $doc"
        status=1
        continue
    fi

    check_doc "$doc"
done

exit "$status"
