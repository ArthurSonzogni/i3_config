#!/bin/bash

# Terminate other instances of this script, excluding the current process ID
for pid in $(pgrep -f "monitor_daemon.sh"); do
    if [ "$pid" != "$$" ]; then
        kill "$pid" 2>/dev/null
    fi
done

# Start a continuous listener for monitor/output events from i3
stdbuf -oL i3-msg -t subscribe -m '["output"]' | while read -r event; do
    # When a monitor arrangement changes, give Xorg a tiny bit of time to settle
    sleep 0.5
    # Then re-assign the top-left workspaces
    ~/.config/i3/scripts/assign_workspaces.sh
done
