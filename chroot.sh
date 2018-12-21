ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/locale.gen" -o /etc/locale.gen
locale-gen
locale > /etc/locale.conf
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/vconsole.conf" -o /etc/vconsole.conf
echo "enter hostname"
read -r hostname
echo "$hostname" > /etc/hostname
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/mkinitcpio.conf" -o /etc/mkinitcpio.conf
mkinitcpio -p linux
echo "set root password"
passwd
install grub efibootmgr
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/grub" -o /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
