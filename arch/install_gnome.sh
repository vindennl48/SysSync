#!/bin/sh

homeDir="$HOME"
dotfilesDir="${homeDir}/SysSync"

source "$dotfilesDir/bin/lib"

cprint -p "Installing Gnome Desktop!"

sudo pacman -Syu gnome gnome-extra

backup_or_remove ${homeDir}/.xinitrc

echo "export XDG_SESSION_TYPE=x11" > ${homeDir}/.xinitrc
echo "export GDK_BACKEND=x11" >> ${homeDir}/.xinitrc
echo "exec gnome-session" >> ${homeDir}/.xinitrc

cprint -p "Install Complete!"
