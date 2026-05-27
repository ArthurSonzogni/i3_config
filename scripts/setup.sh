#!/bin/bash

# Exit on error
set -e

echo "Updating package lists..."
sudo apt-get update

echo "Installing i3 and core dependencies..."
sudo apt-get install -y \
    i3 \
    i3status \
    feh \
    picom \
    jq \
    rofi \
    dex \
    network-manager-gnome \
    xfce4-power-manager \
    redshift \
    diodon \
    curl \
    pango1.0-tools \
    fonts-ubuntu

echo "Creating wallpaper directory..."
mkdir -p "$HOME/.config/i3/wallpapers"

# Check if the abstract wallpaper exists, if not download it
WALLPAPER="$HOME/.config/i3/wallpapers/abstract_dark.jpg"
if [ ! -f "$WALLPAPER" ]; then
    echo "Downloading default wallpaper..."
    curl -L -o "$WALLPAPER" "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=3840&auto=format&fit=crop"
fi

echo "Setting permissions for scripts..."
chmod +x "$HOME/.config/i3/scripts/"*.sh

echo "---------------------------------------------------"
echo "Setup complete!"
echo "You can now reload i3 (Mod+Shift+r) or log in again."
echo "---------------------------------------------------"
