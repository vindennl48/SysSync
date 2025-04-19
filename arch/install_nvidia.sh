#!/bin/bash

# NVIDIA Driver Install Script for Arch Linux (Supports GRUB and systemd-boot)

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

# Install NVIDIA packages
pacman -Sy --noconfirm linux-headers nvidia nvidia-dkms

# need to do more testing here.. i think we need to do more with the nvidia-dkms setup..

echo ""
echo "Installation complete!"
echo "Please REBOOT your system and verify with:"
echo "1. nvidia-smi (should show GPU info)"
echo "2. glxinfo | grep -i \"opengl renderer\" (should show NVIDIA GPU)"
echo ""
