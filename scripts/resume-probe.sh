#!/bin/bash
# Snapshots lock and compositor state after resume, to a log that survives a
# forced power-off (Hyprland's own log is on tmpfs). Run by hypridle's
# after_sleep_cmd. Records process and output state only, never keystrokes.
#
# It also works around the freeze itself: on a bad resume Hyprland logs
# "Restoring after VT switch" but never re-modesets eDP-1, so the screen keeps
# showing the old frame while hyprlock runs (and takes input) underneath.

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

# Succeeds unless the latest resume restore was never followed by a modeset.
# Unknown states count as restored, so a good resume is never disturbed.
display_restored() {
    local hl_log="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log"
    [ -r "$hl_log" ] || return 0
    local last
    last=$(tac "$hl_log" | grep -m1 -oE 'Modesetting eDP-1|Restoring after VT switch')
    [ "$last" != "Restoring after VT switch" ]
}

unstick_display() {
    display_restored && return
    echo "##### $(date +%T.%3N) display not restored: cycling DPMS"
    hyprctl dispatch 'hl.dsp.dpms({action="off"})'
    sleep 1
    hyprctl dispatch 'hl.dsp.dpms({action="on"})'
    sleep 3
    display_restored && { echo "##### DPMS cycle restored the display"; return; }
    echo "##### still not restored: reloading the renderer"
    hyprctl dispatch 'hl.dsp.force_renderer_reload()'
}

elapsed=0
for at in 1 4 10 20 40; do
    sleep $((at - elapsed))
    elapsed=$at
    sample >>"$log" 2>&1
    # Good resumes modeset within about a second, so by 4s it is stuck
    [ "$at" -eq 4 ] && unstick_display >>"$log" 2>&1
done

ls -1t "$dir"/*_*.log | tail -n +21 | xargs -r rm --
