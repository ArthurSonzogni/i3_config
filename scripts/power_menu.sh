#!/bin/bash

# Define options
LOCK="🔒 Lock"
LOGOUT="🚪 Logout"
SUSPEND="😴 Suspend"
REBOOT="🔄 Reboot"
SHUTDOWN="🔌 Shutdown"

options="$LOCK\n$LOGOUT\n$SUSPEND\n$REBOOT\n$SHUTDOWN"

# Show rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/i3/rofi/theme.rasi -theme-str 'window {width: 15%;} listview {lines: 5;}')

case "$chosen" in
    "$LOCK")
        if command -v i3lock-fancy >/dev/null 2>&1; then
            i3lock-fancy
        else
            i3lock -c 1d1f21
        fi
        ;;
    "$LOGOUT")
        i3-msg exit
        ;;
    "$SUSPEND")
        systemctl suspend
        ;;
    "$REBOOT")
        systemctl reboot
        ;;
    "$SHUTDOWN")
        systemctl poweroff
        ;;
esac
