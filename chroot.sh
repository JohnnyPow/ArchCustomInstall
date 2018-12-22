#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/locale.gen" -o /etc/locale.gen
locale-gen &>/dev/null
locale > /etc/locale.conf
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/vconsole.conf" -o /etc/vconsole.conf
echo "$5" > /etc/hostname
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/mkinitcpio.conf" -o /etc/mkinitcpio.conf
mkinitcpio -p linux &>/dev/null
pacman -Sy --noconfirm --needed grub efibootmgr intel-ucode zsh dialog networkmanager &>/dev/null
ROOT_UUID=$(blkid $1 -s UUID -o value)
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/grub" | sed "s/#CRYPT#/$ROOT_UUID/" > /etc/default/grub
mkdir /run/lvm
mount --bin /hostrun/lvm /run/lvm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB &>/dev/null
grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
umount /run/lvm
useradd -m -g users -G wheel -s /bin/zsh $2
echo "$2:$3" | chpasswd
echo "root:$4" | chpasswd
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/sudoers.temp" -o /etc/sudoers
systemctl enable NetworkManager &>/dev/null

cd /tmp
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/pkgs.sh" | bash
curl -sLO "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/rice.sh"
bash rice.sh $2
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/sudoers" -o /etc/sudoers
