#!/bin/bash
# Toggle game mode — kills animations/blur, enables gamemoded CPU+GPU optimisations.
# SUPER+SHIFT+G to trigger. Toggle again to restore.

FLAG="/tmp/qs_gamemode"
current=$(cat "$FLAG" 2>/dev/null || echo "off")

if [ "$current" = "off" ]; then
    # ── Enable game mode ──────────────────────────────────────
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:shadow:enabled false
    systemctl --user start gamemoded
    echo "on" > "$FLAG"
    notify-send -u low "Game Mode" "ON — animations off, gamemoded active" -t 2000
else
    # ── Restore normal mode ───────────────────────────────────
    hyprctl keyword animations:enabled true
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:shadow:enabled true
    systemctl --user stop gamemoded
    echo "off" > "$FLAG"
    notify-send -u low "Game Mode" "OFF — compositor restored" -t 2000
fi
