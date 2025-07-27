#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/fzusers.sh"
DST="/usr/local/bin/fzusers"

echo "Installing fzusers to $DST (requires sudo)..."
sudo install -m 755 "$SRC" "$DST"
echo "fzusers installed!"

if ! command -v fzf >/dev/null 2>&1; then
  echo "WARNING: fzf is not installed. Please install fzf to use fzusers."
fi

echo "You can now run 'fzusers' from