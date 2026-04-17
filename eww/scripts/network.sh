#!/bin/bash
MODE="$1"
IFACE=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
[ -z "$IFACE" ] && echo "0 B/s" && exit 0

if [ "$MODE" = "rx" ]; then
  FILE="/sys/class/net/$IFACE/statistics/rx_bytes"
elif [ "$MODE" = "tx" ]; then
  FILE="/sys/class/net/$IFACE/statistics/tx_bytes"
else
  echo "0 B/s" && exit 1
fi

[ ! -f "$FILE" ] && echo "0 B/s" && exit 0

B1=$(cat "$FILE")
sleep 2
B2=$(cat "$FILE")

RATE=$(( (B2 - B1) / 2 ))

if [ "$RATE" -ge 1048576 ]; then
  printf "%.1f MB/s" "$(echo "$RATE" | awk '{printf "%.1f", $1/1048576}')"
elif [ "$RATE" -ge 1024 ]; then
  printf "%.0f KB/s" "$(echo "$RATE" | awk '{printf "%.0f", $1/1024}')"
else
  echo "${RATE} B/s"
fi
