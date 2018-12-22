#!/bin/bash

CYAN="\033[0;36m"
NOCOLOR="\033[0m"
IFS=$'\n'

function info() {
  echo -e "\r[${CYAN}INFO${NOCOLOR}] $1"
}

function infon() {
  echo -en "\r                                                                                \r[${CYAN}INFO${NOCOLOR}] $1"
}

mkdir .build
cd .build

curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/makepkg.conf" -o /etc/makepkg.conf
pacman -Sy --noconfirm --needed git go &>/dev/null

git clone https://aur.archlinux.org/yay.git &>/dev/null
chown -R 1000:users .
cd yay
sudo -u \#1000 makepkg &>/dev/null
pacman -U --noconfirm --needed yay*.pkg.tar.xz &>/dev/null

info "installing official packages"
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/pkgs" | pacman -S --noconfirm --needed - &>out &
while [ $(ps --no-headers -C pacman | wc -l) -gt 0 ]; do
  infon "$(cat out | tail -n 1)"
  sleep 1
done
echo
info "installing AUR packages"
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/aurpkgs" | sudo -u \#1000 yay -S --noconfirm --needed - &>out &
while [ $(ps --no-headers -C yay | wc -l) -gt 0 ]; do
  infon "$(cat out | tail -n 1)"
  sleep 1
done
echo
systemctl enable lightdm &>/dev/null
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/lightdm.conf" -o /etc/lightdm/lightdm.conf
info "installing st"
git clone git://git.suckless.org/st &>/dev/null
cd st
make &>/dev/null && make install &>/dev/null
