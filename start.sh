#!/bin/bash

username=$1
rootdisk=$2

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NOCOLOR="\033[0m"

function pass() {
  echo -e "\r[${GREEN}PASS${NOCOLOR}] $1"
}

function info() {
  echo -e "\r[${BLUE}INFO${NOCOLOR}] $1"
}

function error() {
  echo -e "\r[${RED}ERROR${NOCOLOR}] $1"
}

if [ ! $rootdisk ]; then
  error "argument missing"
  info "usage: ./start.sh USERNAME DISK"
  exit 1
fi

if [[ $username =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  pass "valid username"
else
  error "$username is not a valid username"
  exit 1
fi

if lsblk -no PATH,TYPE | grep disk | grep -w $rootdisk >/dev/null; then
  pass "valid rootdisk"
else
  error "$rootdisk is not a valid disk"
  info "available disks:"
  lsblk -no PATH,TYPE | grep disk | cut -d " " -f 1
  exit 1
fi

if [[ $(id -u) -eq 0 ]]; then
  pass "root"
else
  error "this script has to be run as root"
  exit 1
fi

if find "/sys/firmware/efi/efivars" -mindepth 1 -print -quit | grep -q .; then
  pass "UEFI boot"
else
  error "not booted in uefi mode"
  exit 1
fi

echo -n "[TEST] internet connection"
if ping archlinux.org -c 2 >/dev/null; then
  pass "internet connection"
else
  error "no working internet connection"
  exit 1
fi

info "creating user \"$username\""
info "disk $rootdisk will be formatted"

read -r -p "Continue? (type \"yes\") " response
if [[ "$response" =~ ^([yY][eE][sS])$ ]]; then
  curl -sLO https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/step0.sh
  step0.sh
else
  error "user cancelled"
  exit 1
fi
