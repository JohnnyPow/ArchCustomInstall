#!/bin/bash

mkdir $HOME/.build
cd $HOME/.build

function pacins() {
  pacman -S --noconfirm --needed $@
}

function yayins() {
  yay -S --noconfirm --needed $@
}

curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/makepkg.conf" -o /etc/makepkg.conf
pacins git

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si


