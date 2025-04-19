#!/bin/sh

homeDir="$HOME"
dotfilesDir="${homeDir}/SysSync"

source "$dotfilesDir/bin/lib"

cprint -p "Installing NVIDIA drivers for Arch!"

# Install NVIDIA packages
sudo pacman -Syu --noconfirm linux-headers nvidia nvidia-dkms

# need to do more testing here.. i think we need to do more with the nvidia-dkms setup..

cprint ""
cprint -p "Installation complete!"
cprint "Please REBOOT your system and verify with:"
cprint "1. nvidia-smi (should show GPU info)"
cprint "2. glxinfo | grep -i \"opengl renderer\" (should show NVIDIA GPU)"
cprint ""
