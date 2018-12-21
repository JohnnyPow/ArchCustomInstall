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
