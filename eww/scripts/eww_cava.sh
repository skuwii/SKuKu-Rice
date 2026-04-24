#!/bin/bash

killall cava 2>/dev/null

config_file="/tmp/eww_cava_config"
cat > "$config_file" << EOF
[general]
framerate = 60
bars = 10
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

cava -p "$config_file" | sed -u 's/;//g;s/0/ /g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g'
