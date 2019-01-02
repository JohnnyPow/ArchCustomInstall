#!/bin/bash

CYAN="\033[0;36m"
NOCOLOR="\033[0m"

function info() {
  echo -e "\r[${CYAN}INFO${NOCOLOR}] $1"
}

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/locale.gen" -o /etc/locale.gen
info "generating locales"
locale-gen &>/dev/null
locale > /etc/locale.conf
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/vconsole.conf" -o /etc/vconsole.conf
echo "$5" > /etc/hostname
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/mkinitcpio.conf" -o /etc/mkinitcpio.conf
info "building initramfs"
mkinitcpio -p linux &>/dev/null
info "installing packages"
pacman -Sy --noconfirm --needed grub efibootmgr intel-ucode zsh dialog networkmanager &>/dev/null
ROOT_UUID=$(blkid $1 -s UUID -o value)
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/grub" | sed "s/#CRYPT#/$ROOT_UUID/" > /etc/default/grub
mkdir /run/lvm
mount --bin /hostrun/lvm /run/lvm
info "installing bootloader"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB &>/dev/null
grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
umount /run/lvm
useradd -m -g users -G wheel -s /bin/zsh -c "$9" $2
echo "$2:$3" | chpasswd
echo "root:$4" | chpasswd
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/sudoers.temp" -o /etc/sudoers
systemctl enable NetworkManager &>/dev/null

cd /tmp
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/pkgs.sh" | bash
info "cloning rice"
curl -sLO "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/rice.sh"
sudo -u $2 bash rice.sh $2
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/sudoers" -o /etc/sudoers
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/hidpi" -o /etc/profile.d/hidpi.sh
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/slick-greeter" -o /etc/lightdm/slick-greeter.conf

mkdir -p /etc/samba/credentials
chown root:root /etc/samba/credentials
chmod 700 /etc/samba/credentials
echo "username=$7" > /etc/samba/credentials/$6
echo "password=$8" >> /etc/samba/credentials/$6
chmod 600 /etc/samba/credentials/$6
mkdir /mnt/{home,web,shared,media,MyStuff}
echo "//$6/home /mnt/home cifs credentials=/etc/samba/credentials/$6,uid=1000,x-systemd.automount,noauto,_netdev 0 0" >> /etc/fstab
echo "//$6/web /mnt/web cifs credentials=/etc/samba/credentials/$6,uid=1000,x-systemd.automount,noauto,_netdev 0 0" >> /etc/fstab
echo "//$6/shared /mnt/shared cifs credentials=/etc/samba/credentials/$6,uid=1000,x-systemd.automount,noauto,_netdev 0 0" >> /etc/fstab
echo "//$6/media /mnt/media cifs credentials=/etc/samba/credentials/$6,uid=1000,x-systemd.automount,noauto,_netdev 0 0" >> /etc/fstab
echo "//$6/MyStuff /mnt/MyStuff cifs credentials=/etc/samba/credentials/$6,uid=1000,x-systemd.automount,noauto,_netdev 0 0" >> /etc/fstab
ssh-keygen &>/dev/null <<EOF

EOF
mount /mnt/home
sudo -u $2 git clone /mnt/home/sync /home/$2/.sync
sudo -u $2 bash /home/$2/.sync/deploy.sh
