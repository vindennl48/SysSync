#!/bin/sh

homeDir="$HOME"
dotfilesDir="${homeDir}/SysSync"

source "$dotfilesDir/bin/lib"

cprint -p "Installing Plasma Desktop!"

sudo pacman -Syu plasma-meta kde-applications-meta

backup_or_remove ${homeDir}/.xinitrc

echo "export XDG_SESSION_TYPE=x11" > ${homeDir}/.xinitrc
echo "export GDK_BACKEND=x11" >> ${homeDir}/.xinitrc
echo "export DESKTOP_SESSION=plasma" >> ${homeDir}/.xinitrc
echo "exec startplasma-x11" >> ${homeDir}/.xinitrc

cprint -p "Install Complete!"
