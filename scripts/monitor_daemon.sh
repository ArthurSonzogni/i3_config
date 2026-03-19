#!/bin/bash

# Terminate any previously running instances of the subscriber loop
pkill -f "i3-msg -t subscribe -m \\[\"output\"\\]"

# Start a continuous listener for monitor/output events from i3
stdbuf -oL i3-msg -t subscribe -m '["output"]' | while read -r event; do
    # When a monitor arrangement changes, give Xorg a tiny bit of time to settle
    sleep 0.5
    # Then re-assign the top-left workspaces
    ~/.config/i3/scripts/assign_workspaces_topleft.sh
done
