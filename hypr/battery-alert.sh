#!/bin/bash

# Warn at 20%, critically warn at 10%
WARNING_LEVEL=20
CRITICAL_LEVEL=10

while true; do
    # Read battery capacity and status
    BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
    STATUS=$(cat /sys/class/power_supply/BAT0/status)

    if [ "$STATUS" = "Discharging" ]; then
        if [ "$BATTERY_LEVEL" -le "$CRITICAL_LEVEL" ]; then
            notify-send "Battery Critical" "Laptop is at ${BATTERY_LEVEL}%. Plug in immediately!" -u critical
            sleep 300 # Wait 5 minutes before warning again
        elif [ "$BATTERY_LEVEL" -le "$WARNING_LEVEL" ]; then
            notify-send "Low Battery" "Laptop is at ${BATTERY_LEVEL}%. Consider plugging in." -u normal
            sleep 600 # Wait 10 minutes before warning again
        fi
    fi
    sleep 60 # Check every 60 seconds
done
