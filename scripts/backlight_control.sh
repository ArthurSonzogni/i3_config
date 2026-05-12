#!/bin/bash

# Auto-detect brightness control tool and execute command
# Usage: backlight_control.sh [up|down] [step]

ACTION=$1
STEP=${2:-5}

send_notification() {
    if command -v notify-send >/dev/null 2>&1; then
        # Get current brightness based on available tool
        local val=""
        if command -v xbacklight >/dev/null 2>&1; then
            val=$(xbacklight -get | cut -d. -f1)
        elif command -v brightnessctl >/dev/null 2>&1; then
            val=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        elif command -v light >/dev/null 2>&1; then
            val=$(light -G | cut -d. -f1)
        fi
        
        [ -n "$val" ] && notify-send -h string:x-canonical-private-synchronous:brightness -t 1000 "Brightness" "${val}%"
    fi
}

# 1. Try xbacklight (User confirmed working)
if command -v xbacklight >/dev/null 2>&1; then
    case $ACTION in
        up)   xbacklight -inc "$STEP" ;;
        down) xbacklight -dec "$STEP" ;;
    esac
    send_notification
    exit 0
fi

# 2. Try brightnessctl
if command -v brightnessctl >/dev/null 2>&1; then
    case $ACTION in
        up)   brightnessctl set "${STEP}%+" ;;
        down) brightnessctl set "${STEP}%-" ;;
    esac
    send_notification
    exit 0
fi

# 3. Try light
if command -v light >/dev/null 2>&1; then
    case $ACTION in
        up)   light -A "$STEP" ;;
        down) light -U "$STEP" ;;
    esac
    # Only notify if light actually worked (it might fail due to permissions)
    [ $? -eq 0 ] && send_notification
    exit 0
fi

echo "No brightness control tool found (xbacklight, brightnessctl, light)" >&2
exit 1
