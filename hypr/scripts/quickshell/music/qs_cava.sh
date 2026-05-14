#!/bin/bash
# Quickshell cava bridge — writes block-char bars to /tmp/qs_cava_bars.txt
# Launch once via hyprland exec-once; LeftPanel.qml polls the file at 150ms

config_file="/tmp/qs_cava_config"
cat > "$config_file" << EOF
[general]
framerate = 30
bars = 10
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

cava -p "$config_file" | while IFS= read -r line; do
    printf '%s\n' "$line" \
        | sed 's/;//g;s/0/ /g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g' \
        > /tmp/qs_cava_bars.txt
done
