#!/bin/bash
# Snapshots lock and compositor state after resume, to a log that survives a
# forced power-off (Hyprland's own log is on tmpfs). Run by hypridle's
# after_sleep_cmd. Records process and output state only, never keystrokes.

dir="$HOME/.local/state/resume-probe"
mkdir -p "$dir"
chmod 700 "$dir"
log="$dir/$(date +%F_%H%M%S).log"

sample() {
    echo "===== $(date +%T.%3N)"
    local pid
    for pid in $(pidof hyprlock Hyprland); do
        echo "$(cat "/proc/$pid/comm") pid=$pid wchan=$(cat "/proc/$pid/wchan" 2>/dev/null)" \
            "$(grep -E '^(State|Threads)' "/proc/$pid/status" | tr -s '\t\n' ' ')"
    done
    pidof hyprlock >/dev/null || echo "hyprlock: NOT RUNNING"

    # A timeout here means the compositor's event loop is stuck
    timeout 3 hyprctl monitors -j | jq -c '.[] | {name, dpmsStatus, disabled}'
    echo "hyprctl rc=${PIPESTATUS[0]}"
    timeout 3 hyprctl layers -j | jq -c '[.. | .namespace? // empty]'
    timeout 3 hyprctl devices -j | jq -c '{keyboards: [.keyboards[].name], mice: [.mice[].name]}'
    # Drop input-level lines so nothing typed at the lock can end up on disk
    timeout 3 hyprctl rollinglog | grep -viE 'libinput|key|input|text' | tail -25
}

elapsed=0
for at in 1 4 10 20 40; do
    sleep $((at - elapsed))
    elapsed=$at
    sample >>"$log" 2>&1
done

ls -1t "$dir"/*_*.log | tail -n +21 | xargs -r rm --
