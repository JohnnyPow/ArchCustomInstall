#!/bin/bash

username=$1
rootdisk=$2

if [[ $(id -u) -eq 0 ]]; then
  echo root
else
  echo 'this script has to be run as root'
  exit 1
fi

if find "/sys/firmware/efi/efivars" -mindepth 1 -print -quit | grep -q .; then
  echo 'UEFI boot'
else
  echo 'not booted in uefi mode'
  exit 1
fi

echo -n '[TEST] internet connection'
if
  ping archlinux.org -c 3 &>/dev/null
  true
then
  echo 'internet connection'
else
  echo 'no working internet connection'
  exit 1
fi

echo formatting disk $rootdisk
echo setting up use $username
