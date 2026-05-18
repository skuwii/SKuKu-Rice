#!/bin/bash
# Toggle between locked STR palette and pywal-generated palette.
# Default is STR. Wal mode is a party trick — run once to show off, again to restore.

FLAG="/tmp/qs_theme_mode"
QML="$HOME/.dotfiles/hypr/scripts/quickshell/MatugenColors.qml"
STR_BACKUP="$HOME/.dotfiles/hypr/scripts/quickshell/MatugenColors-str.qml"
WALLPAPER="$HOME/media/wallpapers/firewatch.jpg"

current=$(cat "$FLAG" 2>/dev/null || echo "str")

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
    r = int(r1 + (r2 - r1) * t)
    g = int(g1 + (g2 - g1) * t)
    b = int(b1 + (b2 - b1) * t)
    return f'#{r:02x}{g:02x}{b:02x}'

def alpha_hex(h, a):
    aa = int(a * 255)
    return f'#{aa:02x}{h.lstrip("#")}'

bg   = sp['background']
fg   = sp['foreground']
mid  = c['color8']   # bright-black — the natural midpoint wal picks

# Neutral scale: step from bg toward mid
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

# Accent scale from wal — warm tones kept as STR (semantic icons)
blue     = c['color4']
sapphire = c['color6']
teal     = c['color2']
mauve    = c['color5']
red      = c['color1']
maroon   = c['color9']
peach    = '#fab387'   # locked — sun / warm icons
yellow   = '#f9e2af'   # locked — moon / idle icons
pink     = '#ffb8c6'   # locked — hearts
green    = '#a6e3a1'   # locked — charging / success

crust_glass = alpha_hex(crust, 0.85)
base_glass  = alpha_hex(base,  0.85)

qml = f'''// WAL — pywal palette from firewatch.jpg
// Toggle back: run toggle-theme.sh again
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

    // Semantic warm tones — locked regardless of wallpaper
    property color peach:    "{peach}"
    property color yellow:   "{yellow}"
    property color pink:     "{pink}"
    property color green:    "{green}"

    property color crustGlass: "{crust_glass}"
    property color baseGlass:  "{base_glass}"

    property string rawJson: ""
}}
'''

with open(qml_path, 'w') as f:
    f.write(qml)

print(f"wal palette written → {qml_path}")
PYEOF

    echo "wal" > "$FLAG"
    notify-send -i ~/.config/hypr/scripts/quickshell/assets/icons/palette.png \
        "Theme" "Switched to pywal palette" 2>/dev/null || \
    notify-send "Theme" "Switched to pywal palette"
    restart_quickshell

else
    # ── Restore STR ────────────────────────────────────────────
    cp "$STR_BACKUP" "$QML"
    echo "str" > "$FLAG"
    notify-send "Theme" "STR palette restored"
    restart_quickshell
fi
