#!/bin/bash
# Perform a volume/brightness action and write state to /tmp/qs_osd for the OSD overlay.
# Usage: osd-trigger.sh <type> <action>
#   type:   volume | brightness
#   action: up | down | mute

TYPE=$1
ACTION=$2

case $TYPE in
    volume)
        case $ACTION in
            up)   wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
            down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
            mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        esac
        RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
        VOL=$(echo "$RAW" | awk '{printf "%.0f", $2*100}')
        MUTED=$(echo "$RAW" | grep -c "MUTED" || true)
        [ "$ACTION" = "mute" ] && [ "$MUTED" -eq 0 ] && MUTED=1 || true
        echo "volume:${VOL:-0}:${MUTED:-0}" > /tmp/qs_osd
        ;;
    brightness)
        case $ACTION in
            up)   brightnessctl set 5%+ -q ;;
            down) brightnessctl set 5%- -q ;;
        esac
        VAL=$(brightnessctl get 2>/dev/null)
        MAX=$(brightnessctl max 2>/dev/null)
        PCT=$(( MAX > 0 ? VAL * 100 / MAX : 0 ))
        echo "brightness:${PCT}:0" > /tmp/qs_osd
        ;;
esac
