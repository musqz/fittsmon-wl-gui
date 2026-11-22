#!/usr/bin/env bash
# Usage: lib/release.sh X.Y.Z   bump VERSION, man page, PKGBUILD (sha256 = SKIP), .SRCINFO
#        lib/release.sh --sha   after the tag is pushed: set the real tarball sha256
# Git steps (branch, PR, tag) stay manual.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

srcinfo() { (cd packaging && makepkg --printsrcinfo > .SRCINFO.tmp && mv .SRCINFO.tmp .SRCINFO); }

case "${1:-}" in
    --sha)
        ver=$(<VERSION)
        url="https://github.com/musqz/fittsmon-wl-gui/archive/refs/tags/v${ver}.tar.gz"
        tmp=$(mktemp)
        trap 'rm -f "$tmp"' EXIT
        curl -fsSL "$url" -o "$tmp"
        got=$(tar -xzOf "$tmp" "fittsmon-wl-gui-${ver}/VERSION")
        [[ "$got" == "$ver" ]] || { echo "tarball VERSION is '$got', expected '$ver'" >&2; exit 1; }
        sha=$(sha256sum "$tmp" | cut -d' ' -f1)
        sed -i "s/^sha256sums=.*/sha256sums=('$sha')/" packaging/PKGBUILD
        srcinfo
        echo "v$ver sha256 $sha"
        ;;
    *)
        [[ "${1:-}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "usage: $0 X.Y.Z | --sha" >&2; exit 1; }
        ver="$1"
        old=$(<VERSION)
        [[ "$ver" != "$old" ]] || { echo "VERSION is already $ver" >&2; exit 1; }
        echo "$ver" > VERSION
        sed -i "1s/fittsmon-wl-gui $old/fittsmon-wl-gui $ver/" fittsmon-wl-gui.1
        sed -i "s/^pkgver=.*/pkgver=$ver/; s/^pkgrel=.*/pkgrel=1/; s/^sha256sums=.*/sha256sums=('SKIP')/" packaging/PKGBUILD
        grep -q "fittsmon-wl-gui $ver" fittsmon-wl-gui.1 || { echo "man page version not updated" >&2; exit 1; }
        grep -q "^pkgver=$ver$" packaging/PKGBUILD || { echo "PKGBUILD pkgver not updated" >&2; exit 1; }
        srcinfo
        echo "bumped $old -> $ver"
        ;;
esac

git status --short
