#!/bin/bash
# ╔═══════════════════════════════════════╗
# ║         STR TERMINAL v3.0             ║
# ║         install.sh — skuwii           ║
# ╚═══════════════════════════════════════╝

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$HOME/.config"

echo ""
echo "  ███████╗"
echo "  ██╔════╝"
echo "  ███████╗  STR TERMINAL v3.0"
echo "  ╚════██║  installer"
echo "  ███████║"
echo "  ╚══════╝"
echo ""

# ── Dependencies ──
echo "[ PACKAGES ] Required packages:"
echo ""
echo "  Core:      hyprland hyprpaper hyprlock hypridle waybar eww-git dunst rofi-wayland kitty"
echo "  Shell:     zsh oh-my-zsh-git zsh-autosuggestions zsh-syntax-highlighting"
echo "  Util:      fastfetch cava eza bat brightnessctl grim slurp wl-clipboard cliphist jq"
echo "  Theme:     papirus-icon-theme bibata-cursor-theme-bin ttf-jetbrains-mono-nerd"
echo "  GTK:       nwg-look (for applying GTK theme)"
echo "  SDDM:      sddm qt5-quickcontrols2"
echo "  Audio:     pipewire pipewire-pulse pavucontrol"
echo ""
echo "  Install with: yay -S <packages>"
echo ""

read -p "Continue with symlinks? [y/N] " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "Aborted." && exit 0

# ── Backup existing configs ──
backup() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        echo "  backup: $1 → $1.bak"
        mv "$1" "$1.bak"
    fi
}

# ── Symlink helper ──
link() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    backup "$dst"
    ln -sf "$src" "$dst"
    echo "  link: $dst → $src"
}

echo ""
echo "[ LINKING ]"

# Hyprland
link "$DOTFILES/hypr/hyprland.conf"   "$CONFIG/hypr/hyprland.conf"
link "$DOTFILES/hypr/hyprlock.conf"   "$CONFIG/hypr/hyprlock.conf"
link "$DOTFILES/hypr/hypridle.conf"   "$CONFIG/hypr/hypridle.conf"
link "$DOTFILES/hypr/hyprpaper.conf"  "$CONFIG/hypr/hyprpaper.conf"

# Waybar
link "$DOTFILES/waybar/config.jsonc"  "$CONFIG/waybar/config.jsonc"
link "$DOTFILES/waybar/style.css"     "$CONFIG/waybar/style.css"

# eww
link "$DOTFILES/eww/eww.yuck"        "$CONFIG/eww/eww.yuck"
link "$DOTFILES/eww/eww.scss"        "$CONFIG/eww/eww.scss"
mkdir -p "$CONFIG/eww/scripts"
link "$DOTFILES/eww/scripts/cpu.sh"     "$CONFIG/eww/scripts/cpu.sh"
link "$DOTFILES/eww/scripts/network.sh" "$CONFIG/eww/scripts/network.sh"
chmod +x "$DOTFILES/eww/scripts/"*.sh

# Kitty
link "$DOTFILES/kitty/kitty.conf"     "$CONFIG/kitty/kitty.conf"

# Rofi
link "$DOTFILES/rofi/config.rasi"     "$CONFIG/rofi/config.rasi"

# Dunst
link "$DOTFILES/dunst/dunstrc"        "$CONFIG/dunst/dunstrc"

# tmux
link "$DOTFILES/tmux/tmux.conf"       "$CONFIG/tmux/tmux.conf"

# Fastfetch
link "$DOTFILES/fastfetch/config.jsonc" "$CONFIG/fastfetch/config.jsonc"

# Cava
link "$DOTFILES/cava/config"          "$CONFIG/cava/config"

# GTK
link "$DOTFILES/gtk-3.0/settings.ini" "$CONFIG/gtk-3.0/settings.ini"
link "$DOTFILES/gtk-4.0/gtk.css"      "$CONFIG/gtk-4.0/gtk.css"

# ZSH
link "$DOTFILES/zsh/.zshrc"           "$HOME/.zshrc"

# Pywal override
mkdir -p "$HOME/.config/wal"
link "$DOTFILES/wal/colors-str.json"  "$CONFIG/wal/colors-str.json"

echo ""
echo "[ MANUAL STEPS ]"
echo ""
echo "  1. SDDM theme:"
echo "     sudo cp -r $DOTFILES/sddm/str-theme /usr/share/sddm/themes/"
echo "     sudo nano /etc/sddm.conf → set Current=str-theme under [Theme]"
echo ""
echo "  2. GRUB theme:"
echo "     sudo cp -r $DOTFILES/grub/str-theme /boot/grub/themes/"
echo "     sudo nano /etc/default/grub → set GRUB_THEME=/boot/grub/themes/str-theme/theme.txt"
echo "     sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo ""
echo "  3. Cursor theme:"
echo "     Run nwg-look and select Bibata-Modern-Classic"
echo "     Or: gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic"
echo ""
echo "  4. Pywal:"
echo "     wal --theme $CONFIG/wal/colors-str.json"
echo "     Or generate from wallpaper: wal -i ~/wallpapers/current.jpg"
echo ""
echo "  5. Wallpaper:"
echo "     Place your wallpaper at ~/wallpapers/current.jpg"
echo "     Hyprpaper will load it automatically"
echo ""
echo "  6. Firefox:"
echo "     Install 'Dark Reader' extension"
echo "     In about:config set toolkit.legacyUserProfileCustomizations.stylesheets = true"
echo "     Create chrome/userChrome.css in your Firefox profile for deeper theming"
echo ""
echo "[ DONE ] STR v3.0 deployed. Log out and back in, or:"
echo "  hyprctl reload && killall waybar; waybar & eww-reload"
echo ""
