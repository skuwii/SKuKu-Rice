#!/bin/bash
# Presentation mode (SUPER+SHIFT+P): stops hypridle so the screen never dims,
# locks or suspends mid-talk. Run again to restore normal idle behaviour.

if pidof hypridle >/dev/null; then
    pkill hypridle
    notify-send "Presentation mode on" "No dimming, lock or sleep until you toggle it off" -t 4000
else
    hypridle >/dev/null 2>&1 &
    disown
    notify-send "Presentation mode off" "Idle dim, lock and sleep restored" -t 3000
fi
