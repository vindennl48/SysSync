#!/bin/sh

homeDir="$HOME"
dotfilesDir="${homeDir}/SysSync"

source "$dotfilesDir/bin/lib"

cprint -p "Installing YAY for Arch"

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git ${homeDir}/yay-bin
cd ${homeDir}/yay-bin
makepkg -si

cprint -p "All set!"
