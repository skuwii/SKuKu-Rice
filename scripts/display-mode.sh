#!/bin/bash
# Switch the external display between mirror and extend (SUPER+P cycles).
# Usage: display-mode.sh [mirror|extend]

INTERNAL="eDP-1"
STATE="${XDG_RUNTIME_DIR:-/tmp}/str-display-mode"

external=$(hyprctl monitors all -j | jq -r --arg internal "$INTERNAL" \
    '.[] | select(.name != $internal) | .name' | head -n1)

if [ -z "$external" ]; then
    notify-send "Display" "No external display connected" -t 2500
    exit 1
fi

mode="$1"
if [ -z "$mode" ]; then
    current=$(cat "$STATE" 2>/dev/null || echo "mirror")
    if [ "$current" = "mirror" ]; then mode="extend"; else mode="mirror"; fi
fi

case "$mode" in
    mirror)
        hyprctl eval "hl.monitor({ output = \"$external\", mode = \"preferred\", position = \"auto\", scale = 1, mirror = \"$INTERNAL\" })"
        ;;
    extend)
        hyprctl eval "hl.monitor({ output = \"$external\", mode = \"preferred\", position = \"auto-right\", scale = 1 })"
        ;;
    *)
        echo "usage: $0 [mirror|extend]" >&2
        exit 2
        ;;
esac

echo "$mode" > "$STATE"
notify-send "Display" "$external: $mode" -t 2500
