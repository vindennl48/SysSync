#!/bin/bash

# SSH Install Script for Arch Linux

echo "Installing SSH..."
sudo pacman -Sy openssh

# comment out KbdInteractiveAuthentication in /etc/ssh/sshd_config
read -p "--> Make sure to comment out KbdInteractiveAuthentication in /etc/ssh/sshd_config" ans
sudo vim /etc/ssh/sshd_config

echo "Enabling and starting SSH service..."
sudo systemctl enable sshd.service && sudo systemctl start sshd.service
