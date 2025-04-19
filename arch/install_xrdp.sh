#!/bin/sh

homeDir="$HOME"
dotfilesDir="${homeDir}/SysSync"

source "$dotfilesDir/bin/lib"

cprint -p "Installing Remote Desktop XRDP!"

yay -S xrdp xorgxrdp pipewire-module-xrdp

sudo systemctl enable xrdp.service
sudo systemctl start xrdp.service

# sudo echo "allowed_users=anybody\nneeds_root_rights=no" > /etc/X11/wrapper.config

cprint -p "NOTE: You will still need to install a Desktop Environment if you"
cprint    "      have not already done so.."
cprint    ""
cprint -p "Install Complete!"
