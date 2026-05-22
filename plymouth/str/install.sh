#!/bin/bash
set -e

THEME_DIR="/usr/share/plymouth/themes/str"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Generate assets
python3 "$SCRIPT_DIR/gen-assets.py"

# Install theme files
sudo mkdir -p "$THEME_DIR"
sudo cp "$SCRIPT_DIR/str.plymouth" "$THEME_DIR/"
sudo cp "$SCRIPT_DIR/str.script"   "$THEME_DIR/"
sudo cp "$SCRIPT_DIR/dot.png"      "$THEME_DIR/"

# Set as default
sudo plymouth-set-default-theme -R str

echo "STR Plymouth theme installed. Rebuild initramfs and update GRUB next."
