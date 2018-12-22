#!/bin/bash

ram=$(free --giga | grep Mem: | awk '{print $2}')

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
NOCOLOR="\033[0m"

function pass() {
  echo -e "\r[${GREEN}PASS${NOCOLOR}] $1"
}

function info() {
  echo -e "\r[${CYAN}INFO${NOCOLOR}] $1"
}

function prompt() {
  echo -en "\r[${YELLOW}PROMPT${NOCOLOR}] $1"
}

function error() {
  echo -e "\r[${RED}ERROR${NOCOLOR}] $1"
}

prompt "Enter name for new user: "
read -r username
prompt "Enter password for \"$username\": "
read -r -s userpw
echo
prompt "Enter password for root: "
read -r -s rootpw
echo
prompt "Enter encryption passphrase: "
read -r -s encpw
echo
info "available disks:"
lsblk -o PATH,TYPE | grep disk | cut -d " " -f 1
prompt "Enter rootdisk: "
read -r rootdisk
prompt "Enter hostname: "
read -r host

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
info "setting up ${ram}G swap"

read -r -p "Continue? (type \"yes\") " response
if [[ "$response" =~ ^([yY][eE][sS])$ ]]; then
  info "starting installation"
else
  error "user cancelled"
  exit 1
fi

################################################################################
# START                                                                        #
################################################################################

### cleanup
umount -R /mnt
swapoff /dev/vg/swap
vgremove -y vg
cryptsetup close cryptlvm

info "setting ntp"
timedatectl set-ntp true

info "partitoning disk"
fdisk --wipe always --wipe-partition always /dev/sda <<EOF
g
n


+550M
t
1
n



w
EOF

### debug
lsblk

maj=$(lsblk -no MAJ:MIN,PATH | grep -w "$rootdisk" | cut -d ":" -f 1)
bootpart=$(lsblk -nI $maj -o PATH,TYPE | grep part | cut -d " " -f 1 | head -n 1)
rootpart=$(lsblk -nI $maj -o PATH,TYPE | grep part | cut -d " " -f 1 | tail -n 1)

info "setting up encryption"
cryptsetup luksFormat --type luks2 $rootpart <<EOF
$encpw
$encpw
EOF
if [ $? -ne 0 ]; then
  error "encryption"
  exit 1
fi

cryptsetup open $rootpart cryptlvm <<EOF
$encpw
EOF
if [ $? -ne 0 ]; then
  error "decryption"
  exit 1
fi

info "creating lvm environment"
pvcreate /dev/mapper/cryptlvm
vgcreate vg /dev/mapper/cryptlvm

lvcreate -L ${ram}G vg -n swap
### change to 40
lvcreate -L 10G vg -n root
lvcreate -l 100%FREE vg -n home

info "formatting partitions"
mkfs.vfat -F 32 $bootpart
mkfs.ext4 /dev/vg/root
mkfs.ext4 /dev/vg/home
mkswap /dev/vg/swap

info "mounting partitions"
mount /dev/vg/root /mnt
mkdir /mnt/boot
mount $bootpart /mnt/boot
mkdir /mnt/home
mount /dev/vg/home /mnt/home
swapon /dev/vg/swap
mkdir /mnt/hostrun
mount --bind /run /mnt/hostrun

info "installing missing dependencies"
pacman -Sy --noconfirm --needed pacman-contrib
info "generating up-to-date mirrorlist"
curl -s "https://www.archlinux.org/mirrorlist/?country=DE&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel

genfstab -U /mnt >> /mnt/etc/fstab
curl -sL "https://raw.githubusercontent.com/JohnnyVim/ArchCustomInstall/master/chroot.sh" -o /mnt/chroot.sh
arch-chroot /mnt bash chroot.sh $rootpart $username $userpw $rootpw $host
umount /mnt/hostrun
rm -rf /mnt/hostrun
rm /mnt/chroot.sh
umount -R /mnt
swapoff /dev/vg/swap
pass "done"
