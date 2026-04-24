#!/bin/bash

options="󰐥 Shutdown\n󰜉 Reboot\n󰒲 Suspend\n󰌾 Lock\n󰗼 Logout"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme-str '
window { width: 200px; }
listview { lines: 5; }
')

case "$chosen" in
    *Shutdown) systemctl poweroff ;;
    *Reboot)   systemctl reboot ;;
    *Suspend)  systemctl suspend ;;
    *Lock)     hyprlock ;;
    *Logout)   hyprctl dispatch exit ;;
esac
