echo "uuid of rootdisk: $1"
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
pacman -Sy --noconfirm --needed grub efibootmgr
ROOT_UUID=$(blkid $1 -s UUID -o value)
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/grub" | sed "s/#CRYPT#/$ROOT_UUID/" > /etc/default/grub
mkdir /run/lvm
mount --bin /hostrun/lvm /run/lvm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
umount /run/lvm
