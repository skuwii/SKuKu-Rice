#!/bin/bash
# Per-workspace wallpaper daemon — listens to Hyprland workspace events.
# Config: ~/.config/hypr/workspace-wallpapers.json
# Format: { "1": "/path/to/wallpaper.jpg", "default": "/path/to/fallback.jpg" }
# Set a wallpaper for the current workspace: workspace-wallpaper-set.sh

CONFIG="$HOME/.config/hypr/workspace-wallpapers.json"
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

[ ! -f "$CONFIG" ] && echo '{}' > "$CONFIG"

apply() {
    local ws="$1"
    local wallpaper
    wallpaper=$(python3 -c "
import json, sys
with open('$CONFIG') as f:
    cfg = json.load(f)
w = cfg.get('$ws') or cfg.get('default') or ''
print(w)
" 2>/dev/null)
    [ -n "$wallpaper" ] && [ -f "$wallpaper" ] && \
        awww img "$wallpaper" \
            --transition-type fade \
            --transition-fps 60 \
            --transition-duration 0.5 \
            &>/dev/null &
}

# Apply wallpaper for the initial workspace on startup
apply "$(hyprctl activeworkspace -j 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])" 2>/dev/null)"

socat - "UNIX-CONNECT:$SOCK" 2>/dev/null | while IFS= read -r line; do
    if [[ "$line" == workspace\>\>* ]]; then
        apply "${line#workspace>>}"
    fi
done
