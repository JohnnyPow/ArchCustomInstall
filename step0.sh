#!/bin/bash

timedatectl set-ntp true

fdisk --wipe always --wipe-partition always /dev/sda <<EOF
g
n


+550M
t
1
n



w
EOF

maj=$(lsblk -no MAJ:MIN,PATH | grep -w "$1" | cut -d ":" -f 1)
rootpart=$(lsblk -nI $maj -o PATH,TYPE | grep part | cut -d " " -f 1 | tail -n 1)

cryptsetup luksFormat --type luks2 $rootpart
