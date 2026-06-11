#!/bin/bash

# Path to the i3 config directory
CONF_DIR="$HOME/.config/i3/conf"

# Extract all bindsym lines, clean them up, and format for Rofi
# We look for lines starting with bindsym, remove the 'bindsym' keyword, 
# and try to keep it readable.
shortcuts=$(grep -rh "^bindsym" "$CONF_DIR" | \
    sed 's/^bindsym \+//' | \
    sed 's/ \+/ /g' | \
    sort)

# Show in Rofi
echo -e "$shortcuts" | rofi -dmenu -i -p "Shortcuts" \
    -theme ~/.config/i3/rofi/config.rasi \
    -theme-str 'window {width: 40%;} listview {lines: 15;}'
