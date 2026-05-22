#!/bin/bash
# Per-workspace wallpaper daemon — listens to Hyprland workspace events.
# Config: ~/.config/hypr/workspace-wallpapers.json
# Format: { "1": "/path/wallpaper.jpg", "default": "/path/fallback.jpg" }
# If /tmp/qs_theme_mode = "wal", also regenerates pywal palette on each switch.

CONFIG="$HOME/.config/hypr/workspace-wallpapers.json"
FLAG="/tmp/qs_theme_mode"
QML="$HOME/.dotfiles/hypr/scripts/quickshell/MatugenColors.qml"
KITTY_ACTIVE="$HOME/.config/kitty/colors-active.conf"

[ ! -f "$CONFIG" ] && echo '{}' > "$CONFIG"

LAST_WALLPAPER=""

wal_sync() {
    local wallpaper="$1"
    local ws="$2"
    local CACHE_DIR="$HOME/.cache/wal/workspaces"
    local cached="$CACHE_DIR/ws-$ws.json"

    if [ -f "$cached" ]; then
        # Fast path — use pre-computed palette
        cp "$cached" ~/.cache/wal/colors.json
        wal --theme ~/.cache/wal/colors.json -n -q 2>/dev/null
    else
        # Slow path — analyze image on the fly
        wal -i "$wallpaper" -n -q 2>/dev/null || return
    fi

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

    # Apply to terminals, kitty, tmux, btop
    cat ~/.cache/wal/sequences 2>/dev/null
    cp ~/.cache/wal/colors-kitty.conf "$KITTY_ACTIVE"
    kill -SIGUSR1 $(pidof kitty) 2>/dev/null
    tmux list-sessions -F '#S' 2>/dev/null | while read session; do
        tmux source-file ~/.cache/wal/colors-tmux.conf -t "$session" 2>/dev/null
    done
    cp ~/.cache/wal/colors-btop.theme ~/.config/btop/themes/wal-active.theme 2>/dev/null

    # Restart Quickshell to pick up new MatugenColors.qml
    pkill -f "quickshell" 2>/dev/null
    sleep 0.4
    quickshell -p ~/.config/hypr/scripts/quickshell/Main.qml &
    quickshell -p ~/.config/hypr/scripts/quickshell/TopBar.qml &
    quickshell -p ~/.config/hypr/scripts/quickshell/Floating.qml &
    quickshell -p ~/.config/hypr/scripts/quickshell/LeftPanel.qml &
    quickshell -p ~/.dotfiles/hypr/scripts/quickshell/OSD.qml &
    quickshell -p ~/.dotfiles/hypr/scripts/quickshell/AltTab.qml &

    # Update hyprbars colors from pywal palette
    python3 - <<'HYPRBARS_EOF'
import json, subprocess

with open('/home/yousef/.cache/wal/colors.json') as f:
    wal = json.load(f)

c, sp = wal['colors'], wal['special']

def hx(h):
    h = h.lstrip('#')
    return int(h[0:2],16), int(h[2:4],16), int(h[4:6],16)

def lerp(h1, h2, t):
    r1,g1,b1 = hx(h1); r2,g2,b2 = hx(h2)
    return '#{:02x}{:02x}{:02x}'.format(int(r1+(r2-r1)*t),int(g1+(g2-g1)*t),int(b1+(b2-b1)*t))

def rgba(h, a):
    r,g,b = hx(h)
    return 'rgba({:02x}{:02x}{:02x}{:02x})'.format(r,g,b,int(a*255))

bg, fg, mid = sp['background'], sp['foreground'], c['color8']
surface0 = lerp(bg, mid, 0.34)
subtext1 = lerp(mid, fg, 0.90)

kw = lambda k, v: subprocess.run(['hyprctl', 'keyword', k, v], capture_output=True)
kw('plugin:hyprbars:bar_color',           rgba(surface0,     0.15))
kw('plugin:hyprbars:col.text',            rgba(subtext1,     0.30))
kw('plugin:hyprbars:buttons:col.close',   rgba(c['color1'],  0.35))
kw('plugin:hyprbars:buttons:col.minimize',rgba(mid,          0.22))
kw('plugin:hyprbars:buttons:col.maximize',rgba(c['color4'],  0.25))
HYPRBARS_EOF
}

apply() {
    local ws="$1"
    local wallpaper
    wallpaper=$(python3 -c "
import json
with open('$CONFIG') as f:
    cfg = json.load(f)
print(cfg.get('$ws') or cfg.get('default') or '')
" 2>/dev/null)
    [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ] && return

    # Only change wallpaper + re-sync if it actually differs
    [ "$wallpaper" = "$LAST_WALLPAPER" ] && return
    LAST_WALLPAPER="$wallpaper"

    awww img "$wallpaper" \
        --transition-type fade \
        --transition-fps 60 \
        --transition-duration 0.5 \
        &>/dev/null

    if [ "$(cat "$FLAG" 2>/dev/null)" = "wal" ]; then
        wal_sync "$wallpaper" "$ws" &
    fi
}

# Apply for whichever workspace is active right now
apply "$(hyprctl activeworkspace -j 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])" 2>/dev/null)"

# Reconnect loop — socat exits if Hyprland restarts
while true; do
    SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    if [ ! -S "$SOCK" ]; then
        sleep 2
        continue
    fi

    socat -u "UNIX-CONNECT:$SOCK" STDOUT 2>/dev/null | while IFS= read -r line; do
        if [[ "$line" == workspace\>\>* ]]; then
            apply "${line#workspace>>}"
        fi
    done

    sleep 1  # brief pause before reconnect
done
