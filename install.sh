#!/usr/bin/env bash
# Usage: ./install.sh [--uninstall]
# Env:   PREFIX (default ~/.local), SUDO (e.g. SUDO=sudo with PREFIX=/usr/local)
set -euo pipefail

TARGET=fittsmon-wl-gui
PREFIX="${PREFIX:-$HOME/.local}"
SUDO="${SUDO:-}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN="$PREFIX/bin/$TARGET"
MAN="$PREFIX/share/man/man1/$TARGET.1.gz"
DESKTOP="$PREFIX/share/applications/$TARGET.desktop"
ICON="$PREFIX/share/icons/hicolor/scalable/apps/$TARGET.svg"
LICENSE="$PREFIX/share/licenses/$TARGET/LICENSE"

if [[ "${1:-}" == "--uninstall" ]]; then
    for f in "$BIN" "$MAN" "$DESKTOP" "$ICON" "$LICENSE"; do
        if [[ -e "$f" ]]; then
            $SUDO rm -f "$f"
            echo "removed $f"
        fi
    done
    $SUDO rmdir --ignore-fail-on-non-empty "$(dirname "$LICENSE")" 2>/dev/null || true
    exit 0
fi

[[ $# -eq 0 ]] || { echo "usage: $0 [--uninstall]" >&2; exit 1; }

$SUDO install -Dm755 "$SRC/fittsmon-wl-gui.py" "$BIN"
$SUDO install -Dm644 "$SRC/fittsmon-wl-gui.1" "${MAN%.gz}"
$SUDO gzip -nf "${MAN%.gz}"
$SUDO install -Dm644 "$SRC/fittsmon-wl-gui.desktop" "$DESKTOP"
$SUDO install -Dm644 "$SRC/icons/scalable/apps/$TARGET.svg" "$ICON"
$SUDO install -Dm644 "$SRC/LICENSE" "$LICENSE"

echo "installed:"
printf '  %s\n' "$BIN" "$MAN" "$DESKTOP" "$ICON" "$LICENSE"

[[ -x "$BIN" ]] || { echo "install failed: $BIN not executable" >&2; exit 1; }
command -v "$TARGET" >/dev/null || echo "note: $PREFIX/bin is not in PATH"
