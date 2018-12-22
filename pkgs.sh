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
pacins git

sudo -u \#1000 git clone https://aur.archlinux.org/yay.git
cd yay
sudo -u \#1000 makepkg -si

