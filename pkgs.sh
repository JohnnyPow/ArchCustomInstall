#!/bin/bash

mkdir .build
cd .build

function pacins() {
  pacman -S --noconfirm --needed $@
}

function yayins() {
  yay -S --noconfirm --needed $@
}

curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/makepkg.conf" -o /etc/makepkg.conf
pacins git go

git clone https://aur.archlinux.org/yay.git
chown -R 1000:users .
cd yay
sudo -u \#1000 makepkg
pacman -U yay*.pkg.tar.xz

