#!/bin/bash

echo "checking internect connection.."
if
	ping archlinux.org -c 3
	true
then
	echo ""
	echo "[PASS] internet connection"
else
	echo ""
	echo "Make sure you have a working internet connection and try again!"
	exit
fi

if
	[[ `id -u` -eq 0 ]]
then
	echo "[PASS] root"
else
	echo ""
	echo "Run the script as root or using sudo!"
	exit
fi

if
	find "/sys/firmware/efi/efivars" -mindepth 1 -print -quit | grep -q .
then
	echo "[PASS] UEFI boot"
else
	echo ""
	echo "Reboot using UEFI!"
	exit
fi

timedatectl set-ntp true

lsblk
echo ""
echo "Enter the name of the disk you wish to delete and use for your new Arch Linux installation!"
read disk
if
cat <<EOF | fdisk /dev/$disk
g
n


+550M
n


+32G
n


+4G
n



t
1
1
t
3
19
p
w
EOF
then
	echo ""
else
	echo ""
	echo "Disk doesn't exist."
	exit
fi

partprobe

echo "formatting partitions.."
mkfs.vfat -F 32 /dev/"$disk"p1
mkfs.ext4 /dev/"$disk"p2
mkswap /dev/"$disk"p3
mkfs.ext4 /dev/"$disk"p4
swapon /dev/"$disk"p3

mount /dev/"$disk"p2 /mnt
mkdir /mnt/boot
mount /dev/"$disk"p1 /mnt/boot
mkdir /mnt/home
mount /dev/"$disk"p4 /mnt/home

pacstrap /mnt base base-devel

genfstab -U /mnt >> /mnt/etc/fstab

curl https://github.com/JohnnyPow/ArchCustomInstall/raw/master/chroot.sh > /mnt/chroot.sh
arch-chroot /mnt bash chroot.sh
rm /mnt/chroot.sh

efibootmgr -c -d /dev/"$disk" -l /EFI/BOOT/BOOTX64.EFI -L "Linux Boot Manager"
rm disk

echo "Finished successfully if no other errors have been reported!"
echo "Make the new entry default by using 'efibootmgr -o NUMBER'!"
echo "You can remove unneeded entries by using 'efibootmgr -b NUMBER -B'!"
