#!/bin/bash
# ╔═══════════════════════════════════════╗
# ║         STR         ║
# ║         install.sh                    ║
# ╚═══════════════════════════════════════╝

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$HOME/.config"

echo ""
echo "  ███████╗"
echo "  ██╔════╝"
echo "  ███████╗  STR"
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

# Neovim
link_dir "$DOTFILES/nvim"                  "$CONFIG/nvim"

# ZSH
link "$DOTFILES/zsh/.zshrc"                "$HOME/.zshrc"

# tmux
link "$DOTFILES/tmux/tmux.conf"            "$CONFIG/tmux/tmux.conf"

# Fastfetch
link "$DOTFILES/fastfetch/config.jsonc"    "$CONFIG/fastfetch/config.jsonc"

# Cava
link "$DOTFILES/cava/config"               "$CONFIG/cava/config"

# Rofi (only used for the sudo askpass prompt — scripts/rofi-askpass.sh)
link "$DOTFILES/rofi/config.rasi"          "$CONFIG/rofi/config.rasi"

# wlogout
link "$DOTFILES/wlogout/layout"            "$CONFIG/wlogout/layout"
link "$DOTFILES/wlogout/style.css"         "$CONFIG/wlogout/style.css"

# GTK
link "$DOTFILES/gtk-3.0/settings.ini"     "$CONFIG/gtk-3.0/settings.ini"
link "$DOTFILES/gtk-4.0/gtk.css"          "$CONFIG/gtk-4.0/gtk.css"
link "$DOTFILES/gtk-4.0/settings.ini"     "$CONFIG/gtk-4.0/settings.ini"

# fontconfig (pins every generic family to JetBrainsMono Nerd Font)
link "$DOTFILES/fontconfig/fonts.conf"    "$CONFIG/fontconfig/fonts.conf"

# btop (dir link — pywal writes themes/wal-active.theme here)
link_dir "$DOTFILES/btop"                 "$CONFIG/btop"

# yazi
link "$DOTFILES/yazi/yazi.toml"           "$CONFIG/yazi/yazi.toml"
link "$DOTFILES/yazi/theme.toml"          "$CONFIG/yazi/theme.toml"

# pywal — STR colorscheme + templates for tmux, btop, rofi, zathura
link "$DOTFILES/wal/colors-str.json"      "$CONFIG/wal/colors-str.json"
link_dir "$DOTFILES/wal/templates"        "$CONFIG/wal/templates"

# zathura
link "$DOTFILES/zathura/zathurarc"        "$CONFIG/zathura/zathurarc"

# lazygit
link "$DOTFILES/lazygit/config.yml"       "$CONFIG/lazygit/config.yml"

echo ""
echo "[ FONTS ]"
echo ""
# GTK/libadwaita apps name their font through gsettings and ignore the
# fontconfig generics, so settings.ini alone isn't enough — without this they
# fall back to Adwaita Sans and end up as the only non-JetBrains UI on screen.
for key in font-name document-font-name monospace-font-name; do
    gsettings set org.gnome.desktop.interface "$key" "JetBrainsMono Nerd Font 10"
    echo "  set  org.gnome.desktop.interface $key"
done

echo ""
echo "[ MANUAL STEPS ]"
echo ""
echo "  1. Hyprland plugins (hyprpm is a separate package as of 0.56):"
echo "     sudo pacman -S hyprpm"
echo "     hyprpm update"
echo "     hyprpm add https://github.com/hyprwm/hyprland-plugins"
echo "     hyprpm add https://github.com/VirtCode/hypr-dynamic-cursors"
echo "     hyprpm enable hyprbars"
echo "     hyprpm enable dynamic-cursors"
echo ""
echo "  2. SDDM theme (sddm-astronaut-theme + STR variant):"
echo "     sudo git clone https://github.com/Keyitdev/sddm-astronaut-theme /usr/share/sddm/themes/sddm-astronaut-theme"
echo "     sudo cp $DOTFILES/sddm/astronaut/str.conf /usr/share/sddm/themes/sddm-astronaut-theme/Themes/"
echo "     sudo cp ~/media/wallpapers/firewatch.jpg /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/str.jpg"
echo "     # /etc/sddm.conf: Current=sddm-astronaut-theme"
echo "     # theme metadata.desktop: ConfigFile=Themes/str.conf"
echo ""
echo "  3. GRUB theme:"
echo "     sudo cp -r $DOTFILES/grub/str-theme /boot/grub/themes/"
echo "     # Set GRUB_THEME in /etc/default/grub, then:"
echo "     sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo ""
echo "  4. Plymouth boot splash:"
echo "     bash $DOTFILES/plymouth/str/install.sh"
echo "     # Add 'plymouth' to HOOKS in /etc/mkinitcpio.conf, then: sudo mkinitcpio -P"
echo ""
echo "  5. Brave theme:"
echo "     brave://extensions → Developer mode → Load unpacked → $DOTFILES/brave/STR-theme/"
echo ""
echo "  6. Wallpaper:"
echo "     Place images in ~/media/wallpapers/ (default: firewatch.jpg)"
echo ""
echo "  7. Cursor:"
echo "     gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic"
echo ""
echo "[ DONE ] Log out and back in to apply."
echo ""
