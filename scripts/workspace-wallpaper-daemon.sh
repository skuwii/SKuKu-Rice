#!/bin/bash
# Per-workspace wallpaper daemon — listens to Hyprland workspace events.
# Config: ~/.config/hypr/workspace-wallpapers.json
# Format: { "1": "/path/wallpaper.jpg", "default": "/path/fallback.jpg" }

CONFIG="$HOME/.config/hypr/workspace-wallpapers.json"

[ ! -f "$CONFIG" ] && echo '{}' > "$CONFIG"

apply() {
    local ws="$1"
    local wallpaper
    wallpaper=$(python3 -c "
import json
with open('$CONFIG') as f:
    cfg = json.load(f)
print(cfg.get('$ws') or cfg.get('default') or '')
" 2>/dev/null)
    [ -n "$wallpaper" ] && [ -f "$wallpaper" ] && \
        awww img "$wallpaper" \
            --transition-type fade \
            --transition-fps 60 \
            --transition-duration 0.5 \
            &>/dev/null &
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
