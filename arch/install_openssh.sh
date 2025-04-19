#!/bin/sh

homeDir="$HOME"
dotfilesDir="${homeDir}/SysSync"

source "$dotfilesDir/bin/lib"

cprint -p "Installing OpenSSH for Arch!"

sudo pacman -Syu --noconfirm openssh

# comment out KbdInteractiveAuthentication in /etc/ssh/sshd_config
read -p "--> Make sure to comment out KbdInteractiveAuthentication in /etc/ssh/sshd_config" ans
sudo vim /etc/ssh/sshd_config

cprint -p "Enabling and starting SSH service..."
sudo systemctl enable sshd.service && sudo systemctl start sshd.service

cprint -p "Install Complete!"
