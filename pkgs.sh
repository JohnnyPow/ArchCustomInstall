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
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/aurpkgs" | sudo -u \#1000 yay -S --noconfirm --needed -
systemctl enable lightdm
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/lightdm.conf" -o /etc/lightdm/lightdm.conf
git clone git://git.suckless.org/st
cd st
make && make install
