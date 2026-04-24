#!/bin/bash

BATTERY=/sys/class/power_supply/BAT1
CAPACITY=$(cat $BATTERY/capacity)
STATUS=$(cat $BATTERY/status)

if [ "$STATUS" = "Discharging" ]; then
    if [ "$CAPACITY" -le 5 ]; then
        notify-send -u critical "Battery Critical" "${CAPACITY}% — Plug in now!" -i battery-empty
    elif [ "$CAPACITY" -le 15 ]; then
        notify-send -u critical "Battery Low" "${CAPACITY}% remaining" -i battery-low
    elif [ "$CAPACITY" -le 25 ]; then
        notify-send -u normal "Battery Low" "${CAPACITY}% remaining" -i battery-caution
    fi
fi
