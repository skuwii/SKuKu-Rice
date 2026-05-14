#!/bin/bash
# Quickshell cava bridge — writes raw semicolon-separated values to /tmp/qs_cava_bars.txt
# QML parses these and draws real Rectangle bars with animated height

config_file="/tmp/qs_cava_config"
cat > "$config_file" << EOF
[general]
framerate = 60
bars = 16
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

cava -p "$config_file" | while IFS= read -r line; do
    # Strip trailing semicolon, write raw numbers e.g. "3;5;7;2;1;4;6;3;0;5"
    printf '%s\n' "${line%;}" > /tmp/qs_cava_bars.txt
done
