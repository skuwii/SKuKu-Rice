# S

### STR — skuwii

> _Arch Linux · Hyprland · Quickshell · JetBrainsMono_

---

## Stack

| Component     | Role                                                              |
| ------------- | ----------------------------------------------------------------- |
| Hyprland      | Window manager — gaps, borders, animations, keybinds             |
| Quickshell    | Top bar, left panel, notifications, app launcher, all popups     |
| Hyprlock      | Lock screen — S mark, clock, blur                                |
| Hypridle      | Auto-lock and dim timers                                         |
| Kitty         | Terminal — STR colors, JetBrainsMono, quake dropdown             |
| ZSH           | Shell — S❯ prompt, git branch, aliases                           |
| tmux          | Multiplexer — azure pill tabs, S mark status                     |
| Neovim        | Editor — AstroNvim + STR base16, LSPs via Mason                  |
| Yazi          | File manager — image/video/PDF previews                          |
| Fastfetch     | System info — custom layout                                      |
| Cava          | Audio visualizer → Quickshell bar renderer                       |
| wlogout       | Power menu — STR styled, Honda Red on shutdown                   |
| SDDM          | Login screen — QML theme                                         |
| GRUB          | Boot menu — minimal S mark theme                                 |
| Plymouth      | Boot splash — STR theme, azure spinner                           |
| GTK 3/4       | Dark theme for Thunar, file pickers                              |
| Rofi          | Legacy launcher (kept, superseded by Quickshell applauncher)     |
| eww           | Legacy panel (kept as rollback for LeftPanel)                    |
| Brave         | Browser — STR unpacked theme extension                           |
| Steam         | Gaming — Millennium STR skin                                     |
| MangoHud      | Game overlay — STR palette, `$mod+SHIFT+F12` toggle             |

## Quickshell Layout

```
Main.qml          — full-screen overlay host: notifications, popups
TopBar.qml        — identity, workspaces, music, clock, system tray, net speed, GitHub badge
LeftPanel.qml     — profile, clock, sys stats, fetch, media+cava
Floating.qml      — bottom sidebar: quick actions, system usage
```

Widgets under `quickshell/widgets/`: applauncher, audio mixer, battery, calendar, clipboard,
focustime, music, network/bluetooth, notifications, OSD, screenshot overlay, recording indicator,
settings, updater, volume, wallpaper.

IPC: `~/.config/hypr/scripts/qs_manager.sh toggle <widget>` writes to `/tmp/qs_widget_state`.

## Keybinds (selected)

| Bind | Action |
| ---- | ------ |
| `$mod+SPACE` | App launcher |
| `$mod+TAB` | Workspace overview (hyprexpo) |
| `$mod+grave` | Quake dropdown terminal |
| `$mod+7/8/9` | Scratchpad: music / notes / calc |
| `$mod+A` | Audio mixer |
| `$mod+B` | Clipboard history |
| `$mod+N` | Network / bluetooth |
| `$mod+SHIFT+G` | Game mode toggle |
| `$mod+SHIFT+T` | Palette toggle (STR ↔ wal) |
| `$mod+SHIFT+F12` | MangoHud overlay |

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
- `hyprexpo` — workspace overview (`$mod+TAB`, 3 cols)
- `hyprbars` — ultra-subtle transparent title bars, pywal-synced
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
yay -S hyprland hyprlock hypridle hyprpm

# Quickshell
yay -S quickshell inotify-tools

# Wallpaper + color sync
yay -S awww matugen python-pywal

# Terminal / Shell / Editor
yay -S kitty zsh oh-my-zsh-git zsh-autosuggestions zsh-syntax-highlighting tmux neovim yazi

# Bar / UI deps
yay -S wlogout rofi-wayland swappy wf-recorder

# Utilities
yay -S fastfetch cava eza bat brightnessctl grim grimblast slurp wl-clipboard cliphist jq playerctl gamemoded

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
yay -S sddm qt6-declarative plymouth

# Gaming
yay -S steam gamescope mangohud
```

## Manual Steps After Install

**1. Hyprland plugins**
```bash
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm add https://github.com/VirtCode/hypr-dynamic-cursors
hyprpm enable hyprexpo
hyprpm enable hyprbars
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

**4. Plymouth**
```bash
sudo cp -r ~/.dotfiles/plymouth/str-theme /usr/share/plymouth/themes/
sudo plymouth-set-default-theme str-theme -R
# Add 'plymouth' to HOOKS in /etc/mkinitcpio.conf, then:
sudo mkinitcpio -P
```

**5. Brave theme**

Open `brave://extensions` → enable Developer mode → Load unpacked → select `~/.dotfiles/brave/STR-theme/`

**6. Steam / Millennium**

Install [Millennium](https://steambrew.app), then symlink or copy `~/.dotfiles/steam/millennium/STR-Theme/` into `~/.local/share/Steam/millennium/themes/`.

**7. Wallpaper**

Place wallpaper at `~/media/wallpapers/` — awww picks it up. Default: `firewatch.jpg`.

**8. Cursor**
```bash
gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic
```
