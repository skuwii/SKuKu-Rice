#!/bin/bash
# ╔═══════════════════════════════════════╗
# ║         STR TERMINAL — skuwii         ║
# ║         install.sh                    ║
# ╚═══════════════════════════════════════╝

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$HOME/.config"

echo ""
echo "  ███████╗"
echo "  ██╔════╝"
echo "  ███████╗  STR TERMINAL"
echo "  ╚════██║  installer"
echo "  ███████║"
echo "  ╚══════╝"
echo ""

# ── Symlink helper ──────────────────────────────────────────────────────────
backup() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        echo "  backup: $1 → $1.bak"
        mv "$1" "$1.bak"
    fi
}

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    backup "$dst"
    ln -sf "$src" "$dst"
    echo "  link: $(basename "$dst")"
}

link_dir() {
    local src="$1" dst="$2"
    backup "$dst"
    ln -sf "$src" "$dst"
    echo "  link dir: $(basename "$dst")"
}

# ── Configs ──────────────────────────────────────────────────────────────────
echo "[ LINKING ]"
echo ""

# Hyprland
link "$DOTFILES/hypr/hyprland.conf"        "$CONFIG/hypr/hyprland.conf"
link "$DOTFILES/hypr/hyprlock.conf"        "$CONFIG/hypr/hyprlock.conf"
link "$DOTFILES/hypr/hypridle.conf"        "$CONFIG/hypr/hypridle.conf"
link_dir "$DOTFILES/hypr/scripts"          "$CONFIG/hypr/scripts"

# Quickshell (lives inside hypr/scripts/quickshell — symlinked above via scripts dir)
# No separate link needed.

# Kitty
link "$DOTFILES/kitty/kitty.conf"          "$CONFIG/kitty/kitty.conf"

# ZSH
link "$DOTFILES/zsh/.zshrc"                "$HOME/.zshrc"

# tmux
link "$DOTFILES/tmux/tmux.conf"            "$HOME/.tmux.conf"

# Fastfetch
link "$DOTFILES/fastfetch/config.jsonc"    "$CONFIG/fastfetch/config.jsonc"

# Cava
link "$DOTFILES/cava/config"               "$CONFIG/cava/config"

# Rofi (legacy, kept)
link "$DOTFILES/rofi/config.rasi"          "$CONFIG/rofi/config.rasi"

# eww (legacy rollback)
link "$DOTFILES/eww/eww.yuck"             "$CONFIG/eww/eww.yuck"
link "$DOTFILES/eww/eww.scss"             "$CONFIG/eww/eww.scss"
link_dir "$DOTFILES/eww/scripts"          "$CONFIG/eww/scripts"

# wlogout
link "$DOTFILES/wlogout/layout"            "$CONFIG/wlogout/layout"
link "$DOTFILES/wlogout/style.css"         "$CONFIG/wlogout/style.css"

# GTK
link "$DOTFILES/gtk-3.0/settings.ini"     "$CONFIG/gtk-3.0/settings.ini"
link "$DOTFILES/gtk-4.0/gtk.css"          "$CONFIG/gtk-4.0/gtk.css"

# btop
link "$DOTFILES/btop/btop.conf"           "$CONFIG/btop/btop.conf"

# yazi
link_dir "$DOTFILES/yazi"                 "$CONFIG/yazi"

# zathura
link "$DOTFILES/zathura/zathurarc"        "$CONFIG/zathura/zathurarc"

# lazygit
link "$DOTFILES/lazygit/config.yml"       "$CONFIG/lazygit/config.yml"

echo ""
echo "[ MANUAL STEPS ]"
echo ""
echo "  1. Hyprland plugins:"
echo "     hyprpm add https://github.com/hyprwm/hyprland-plugins"
echo "     hyprpm add https://github.com/VirtCode/hypr-dynamic-cursors"
echo "     hyprpm enable hyprexpo"
echo "     hyprpm enable dynamic-cursors"
echo ""
echo "  2. SDDM theme:"
echo "     sudo cp -r $DOTFILES/sddm/str-theme /usr/share/sddm/themes/"
echo "     # Set Current=str-theme in /etc/sddm.conf"
echo ""
echo "  3. GRUB theme:"
echo "     sudo cp -r $DOTFILES/grub/str-theme /boot/grub/themes/"
echo "     # Set GRUB_THEME in /etc/default/grub, then:"
echo "     sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo ""
echo "  4. Brave theme:"
echo "     brave://extensions → Developer mode → Load unpacked → $DOTFILES/brave/STR-theme/"
echo ""
echo "  5. Wallpaper:"
echo "     Place images in ~/media/wallpapers/ (default: firewatch.jpg)"
echo ""
echo "  6. Cursor:"
echo "     gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic"
echo ""
echo "[ DONE ] Log out and back in to apply."
echo ""
