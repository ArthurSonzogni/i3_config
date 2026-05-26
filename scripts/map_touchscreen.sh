#!/bin/bash

# Give xrandr/i3 a moment if running on startup
sleep 1.5

# Find primary active output name via i3-msg (closest to x=0, y=0)
ACTIVE_OUTPUT=$(i3-msg -t get_outputs | jq -r '[.[] | select(.active == true)] | sort_by(.rect.x + .rect.y) | .[0].name')

if [ -z "$ACTIVE_OUTPUT" ] || [ "$ACTIVE_OUTPUT" = "null" ]; then
    echo "No active output found" >&2
    exit 1
fi

# Find any absolute pointer devices (touchscreen, stylus, tablet)
# Matches "touch", "pen", "tablet", "wacom", "stylus", but excludes touchpads and test pointers
xinput list --name-only | grep -E -i "touch|pen|tablet|wacom|stylus" | grep -v -E -i "pad|pointer|xtest" | while read -r device; do
    echo "Mapping '$device' to output '$ACTIVE_OUTPUT'..."
    xinput --map-to-output "$device" "$ACTIVE_OUTPUT" || true
done
