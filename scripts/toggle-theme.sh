#!/bin/bash
# Toggle between locked STR palette and pywal-generated palette.
# Affects: Quickshell, kitty, all terminals, tmux, rofi, btop, zathura, dunst, wlogout.
# SUPER+SHIFT+T to trigger. Toggle again to restore STR.

FLAG="/tmp/qs_theme_mode"
QML="$HOME/.dotfiles/hypr/scripts/quickshell/MatugenColors.qml"
STR_BACKUP="$HOME/.dotfiles/hypr/scripts/quickshell/MatugenColors-str.qml"
KITTY_ACTIVE="$HOME/.config/kitty/colors-active.conf"
WALLPAPER=$(awww query 2>/dev/null | grep -oP 'image: \K\S+' | head -1)
[ -z "$WALLPAPER" ] && WALLPAPER="$HOME/media/wallpapers/firewatch.jpg"

current=$(cat "$FLAG" 2>/dev/null || echo "str")

apply_all() {
    # Terminals — escape sequences hit all open windows instantly
    cat ~/.cache/wal/sequences 2>/dev/null
    # kitty — persist across new windows
    cp ~/.cache/wal/colors-kitty.conf "$KITTY_ACTIVE"
    kill -SIGUSR1 $(pidof kitty) 2>/dev/null
    # tmux — reload all sessions
    tmux list-sessions -F '#S' 2>/dev/null | while read session; do
        tmux source-file ~/.cache/wal/colors-tmux.conf -t "$session" 2>/dev/null
    done
    # btop — write active theme
    cp ~/.cache/wal/colors-btop.theme ~/.config/btop/themes/wal-active.theme
    # dunst — patch colors into a temp config and restart
    python3 - <<'DUNST_EOF'
import json, re

with open('/home/yousef/.cache/wal/colors.json') as f:
    wal = json.load(f)
c, sp = wal['colors'], wal['special']

with open('/home/yousef/.dotfiles/dunst/dunstrc') as f:
    src = f.read()

patches = {
    # global frame
    r'(\[global\].*?frame_color\s*=\s*")[^"]*(")',
    # urgency_low
    r'(\[urgency_low\].*?background\s*=\s*")[^"]*(")',
}

replacements = [
    (r'(frame_color\s*=\s*")[^"]*(")',         f'\\g<1>{c["color0"]}\\2'),
    (r'(separator_color\s*=\s*")[^"]*(")',      f'\\g<1>{c["color0"]}\\2'),
    (r'(\[urgency_low\][^\[]*background\s*=\s*")[^"]*(")',   f'\\g<1>{c["color0"]}\\2'),
    (r'(\[urgency_low\][^\[]*foreground\s*=\s*")[^"]*(")',   f'\\g<1>{c["color8"]}\\2'),
    (r'(\[urgency_normal\][^\[]*background\s*=\s*")[^"]*(")',f'\\g<1>{c["color0"]}\\2'),
    (r'(\[urgency_normal\][^\[]*foreground\s*=\s*")[^"]*(")',f'\\g<1>{sp["foreground"]}\\2'),
    (r'(\[urgency_normal\][^\[]*frame_color\s*=\s*")[^"]*(")',f'\\g<1>{c["color4"]}\\2'),
    (r'(\[urgency_normal\][^\[]*highlight\s*=\s*")[^"]*(")', f'\\g<1>{c["color4"]}\\2'),
    (r'(\[urgency_critical\][^\[]*background\s*=\s*")[^"]*(")',f'\\g<1>{c["color0"]}\\2'),
    (r'(\[urgency_critical\][^\[]*foreground\s*=\s*")[^"]*(")',f'\\g<1>{sp["foreground"]}\\2'),
    (r'(\[urgency_critical\][^\[]*frame_color\s*=\s*")[^"]*(")',f'\\g<1>{c["color1"]}\\2'),
    (r'(\[urgency_critical\][^\[]*highlight\s*=\s*")[^"]*(")', f'\\g<1>{c["color1"]}\\2'),
]

out = src
for pattern, repl in replacements:
    out = re.sub(pattern, repl, out, flags=re.DOTALL)

with open('/tmp/dunstrc-active', 'w') as f:
    f.write(out)
DUNST_EOF
    pkill dunst 2>/dev/null
    sleep 0.1
    dunst -conf /tmp/dunstrc-active &
    # rofi reads ~/.cache/wal/colors-rofi.rasi at runtime — nothing to do
    # zathura reads ~/.cache/wal/colors-zathura at open time — nothing to do
}

restart_quickshell() {
    pkill -f "quickshell" 2>/dev/null
    sleep 0.4
    quickshell -p ~/.config/hypr/scripts/quickshell/Main.qml &
    quickshell -p ~/.config/hypr/scripts/quickshell/TopBar.qml &
    quickshell -p ~/.config/hypr/scripts/quickshell/Floating.qml &
    quickshell -p ~/.config/hypr/scripts/quickshell/LeftPanel.qml &
}

if [ "$current" = "str" ]; then
    # ── Switch to wal ──────────────────────────────────────────
    wal -i "$WALLPAPER" -n -q
    python3 - "$QML" <<'PYEOF'
import json, sys

qml_path = sys.argv[1]

with open('/home/yousef/.cache/wal/colors.json') as f:
    wal = json.load(f)

c  = wal['colors']
sp = wal['special']

def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def lerp_hex(h1, h2, t):
    r1, g1, b1 = hex_to_rgb(h1)
    r2, g2, b2 = hex_to_rgb(h2)
    return '#{:02x}{:02x}{:02x}'.format(
        int(r1 + (r2 - r1) * t),
        int(g1 + (g2 - g1) * t),
        int(b1 + (b2 - b1) * t)
    )

def alpha_hex(h, a):
    return '#{:02x}{}'.format(int(a * 255), h.lstrip('#'))

bg  = sp['background']
fg  = sp['foreground']
mid = c['color8']

crust    = bg
mantle   = lerp_hex(bg, mid, 0.12)
base     = lerp_hex(bg, mid, 0.22)
surface0 = lerp_hex(bg, mid, 0.34)
surface1 = lerp_hex(bg, mid, 0.46)
surface2 = lerp_hex(bg, mid, 0.58)
overlay0 = lerp_hex(mid, fg, 0.10)
overlay1 = lerp_hex(mid, fg, 0.35)
overlay2 = lerp_hex(mid, fg, 0.60)
subtext0 = lerp_hex(mid, fg, 0.78)
subtext1 = lerp_hex(mid, fg, 0.90)
text     = fg

blue     = c['color4']
sapphire = c['color6']
teal     = c['color2']
mauve    = c['color5']
red      = c['color1']
maroon   = c['color9']
peach    = '#fab387'
yellow   = '#f9e2af'
pink     = '#ffb8c6'
green    = '#a6e3a1'

with open(qml_path, 'w') as f:
    f.write(f'''// WAL — pywal palette (toggle back with SUPER+SHIFT+T)
import QtQuick

Item {{
    id: root

    property color crust:    "{crust}"
    property color mantle:   "{mantle}"
    property color base:     "{base}"
    property color surface0: "{surface0}"
    property color surface1: "{surface1}"
    property color surface2: "{surface2}"

    property color overlay0: "{overlay0}"
    property color overlay1: "{overlay1}"
    property color overlay2: "{overlay2}"

    property color subtext0: "{subtext0}"
    property color subtext1: "{subtext1}"
    property color text:     "{text}"

    property color blue:     "{blue}"
    property color sapphire: "{sapphire}"
    property color teal:     "{teal}"
    property color mauve:    "{mauve}"

    property color red:      "{red}"
    property color maroon:   "{maroon}"

    property color peach:    "{peach}"
    property color yellow:   "{yellow}"
    property color pink:     "{pink}"
    property color green:    "{green}"

    property color crustGlass: "{alpha_hex(crust, 0.85)}"
    property color baseGlass:  "{alpha_hex(base,  0.85)}"

    property string rawJson: ""
}}
''')
PYEOF

    apply_all
    echo "wal" > "$FLAG"
    notify-send "Theme" "pywal palette active"
    restart_quickshell

else
    # ── Restore STR ────────────────────────────────────────────
    wal --theme "$HOME/.dotfiles/wal/colors-str.json" -n -q
    cp "$STR_BACKUP" "$QML"
    apply_all
    # dunst — restart from original STR config
    pkill dunst 2>/dev/null; sleep 0.1
    dunst -conf ~/.dotfiles/dunst/dunstrc &
    echo "str" > "$FLAG"
    notify-send "Theme" "STR palette restored"
    restart_quickshell
fi
