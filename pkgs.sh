#!/bin/bash

mkdir .build
cd .build

curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/makepkg.conf" -o /etc/makepkg.conf
pacman -Sy --noconfirm --needed git go

git clone https://aur.archlinux.org/yay.git
chown -R 1000:users .
cd yay
sudo -u \#1000 makepkg
pacman -U --noconfirm --needed yay*.pkg.tar.xz

curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/pkgs" | pacman -S --noconfirm --needed -
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/aurpkgs" | yay -S --noconfirm --needed -
