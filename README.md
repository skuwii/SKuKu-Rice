# S

### STR TERMINAL — skuwii ·

> _Arch Linux · Hyprland · Quickshell · JetBrainsMono_

---

## Stack

| Component     | Role                                                          |
| ------------- | ------------------------------------------------------------- |
| Hyprland      | Window manager — gaps, borders, animations, keybinds         |
| Quickshell    | Top bar, left panel, notifications, app launcher, popups      |
| Hyprlock      | Lock screen — S mark, clock, blur                            |
| Hypridle      | Auto-lock and dim timers                                      |
| Kitty         | Terminal — STR colors, JetBrainsMono                         |
| ZSH           | Shell — S❯ prompt, git branch, aliases                       |
| tmux          | Multiplexer — azure pill tabs, S mark status                 |
| Fastfetch     | System info — custom layout                                  |
| Cava          | Audio visualizer → Quickshell real bar renderer              |
| wlogout       | Power menu — STR styled, Honda Red on shutdown               |
| SDDM          | Login screen — QML theme                                     |
| GRUB          | Boot menu — minimal S mark theme                             |
| GTK 3/4       | Dark theme for Thunar, file pickers                          |
| Rofi          | Legacy launcher (kept, superseded by Quickshell applauncher) |
| eww           | Legacy panel (kept as rollback for LeftPanel)                |
| Brave         | Browser — STR unpacked theme extension                       |

## Quickshell Layout

```
Main.qml          — full-screen overlay host: notifications, popups
TopBar.qml        — top bar: identity, workspaces, music, clock, system tray
LeftPanel.qml     — left panel: profile, clock, sys stats, fetch, media+cava, love counter
Floating.qml      — bottom sidebar: quick actions, system usage
Lock.qml          — lock surface (hyprlock used as primary)
```

Widgets under `quickshell/widgets/`: applauncher, battery, calendar, clipboard,
focustime, music, network, notifications, settings, updater, volume, wallpaper.

IPC: `~/.config/hypr/scripts/qs_manager.sh toggle <widget>` writes to `/tmp/qs_widget_state`.

## Palette

```
#0e0f11   bg / crust       (background)
#1c1e21   surface          (cards, panels)
#25272a   surface0         (hover)
#2e3136   surface1         (borders)
#4f5258   mute             (inactive text)
#8a8d92   dim              (secondary text)
#d6d8dc   text             (primary text)
#2980d4   azure            (primary accent)
#c0392b   Honda Red        (power button, critical alerts only)

Semantic warm (icon-level only):
#fab387   peach            (sun / warm states)
#f9e2af   yellow           (moon / idle)
#ffb8c6   pink             (love counter)
#a6e3a1   green            (charging / online)
```

Font: `JetBrainsMono Nerd Font`

## Hyprland Plugins

Managed via `hyprpm`:
- `hyprexpo` — workspace overview (`SUPER+TAB`, 3 cols)
- `hypr-dynamic-cursors` — tilt + shake-to-find cursor effect

## Install

```bash
git clone https://github.com/skuwii/SKuKu-Rice.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

### Required packages

```bash
# Core WM
yay -S hyprland hyprlock hypridle

# Quickshell (official extra repo)
yay -S quickshell inotify-tools

# Wallpaper
yay -S awww

# Terminal / Shell
yay -S kitty zsh oh-my-zsh-git zsh-autosuggestions zsh-syntax-highlighting tmux

# Bar / UI deps
yay -S wlogout rofi-wayland

# Utilities
yay -S fastfetch cava eza bat brightnessctl grim grimblast slurp wl-clipboard cliphist jq playerctl

# Audio
yay -S pipewire pipewire-pulse easyeffects

# Bluetooth
yay -S bluez bluez-utils blueman

# Fonts / Icons / Cursor
yay -S ttf-jetbrains-mono-nerd papirus-icon-theme bibata-cursor-theme-bin

# Network
yay -S networkmanager

# GTK theming
yay -S nwg-look

# Login / Boot
yay -S sddm qt6-declarative
```

## Manual Steps After Install

**1. Hyprland plugins**
```bash
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm add https://github.com/VirtCode/hypr-dynamic-cursors
hyprpm enable hyprexpo
hyprpm enable dynamic-cursors
```

**2. SDDM theme**
```bash
sudo cp -r ~/.dotfiles/sddm/str-theme /usr/share/sddm/themes/
# Set Current=str-theme in /etc/sddm.conf
```

**3. GRUB theme**
```bash
sudo cp -r ~/.dotfiles/grub/str-theme /boot/grub/themes/
# Set GRUB_THEME in /etc/default/grub, then:
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**4. Brave theme**

Open `brave://extensions` → enable Developer mode → Load unpacked → select `~/.dotfiles/brave/STR-theme/`

**5. Wallpaper**

Place wallpaper at `~/media/wallpapers/` — awww picks it up. Default: `firewatch.jpg`.

**6. Cursor**
```bash
gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic
```
