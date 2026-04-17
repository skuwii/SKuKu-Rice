#!/bin/bash
read -r _ a1 b1 c1 d1 _ < /proc/stat
sleep 0.5
read -r _ a2 b2 c2 d2 _ < /proc/stat
total1=$((a1+b1+c1+d1))
total2=$((a2+b2+c2+d2))
idle_delta=$((d2-d1))
total_delta=$((total2-total1))
if [ "$total_delta" -eq 0 ]; then
  echo "0"
else
  echo $(( (total_delta - idle_delta) * 100 / total_delta ))
fi
