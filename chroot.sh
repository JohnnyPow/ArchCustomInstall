ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

curl https://github.com/JohnnyPow/ArchCustomInstall/raw/master/etc/locale.gen > /etc/locale.gen
locale-gen

curl https://github.com/JohnnyPow/ArchCustomInstall/raw/master/etc/locale.conf > /etc/locale.conf
curl https://github.com/JohnnyPow/ArchCustomInstall/raw/master/etc/vconsole.conf > /etc/vconsole.conf

echo "Enter a name for this computer:"
read comp
cat comp > /mnt/etc/hostname
rm comp

pacman --noconfirm --needed -Sy networkmanager
systemctl enable NetworkManager
systemctl start NetworkManager

mkinitcpio -p linux

echo "Set a password for the root account:"
passwd

pacman --noconfirm --needed -S efibootmgr intel-ucode

mkdir -p /boot/loader/entries
mkdir -p /boot/efi/EFI/BOOT
curl https://github.com/JohnnyPow/ArchCustomInstall/raw/master/boot/efi/EFI/BOOT/BOOTX64.EFI > /boot/efi/EFI/BOOT/BOOTX64.EFI
curl https://github.com/JohnnyPow/ArchCustomInstall/raw/master/boot/loader/loader.conf > /boot/loader/loader.conf
curl https://github.com/JohnnyPow/ArchCustomInstall/raw/master/boot/loader/entries/arch.conf > /boot/loader/entries/arch.conf
echo "check /boot/loader/entries/arch.conf and change according to your system"
