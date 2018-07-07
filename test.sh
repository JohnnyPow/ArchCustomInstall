#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

function pass {
	echo -e "\r[${GREEN}PASS${NOCOLOR}] $1"
}

function error {
	echo -e "\r[${RED}ERROR${NOCOLOR}] $1"
	exit
}

if [[ `id -u` -eq 0 ]]; then
  pass 'root'
else
  error 'this script has to be run as root'
fi

if find "/sys/firmware/efi/efivars" -mindepth 1 -print -quit | grep -q .; then
  pass 'UEFI boot'
else
  error 'not booted in uefi mode'
fi

#echo -n '[TEST] internet connection'
#if ping archlinux.org -c 3 &> /dev/null; true; then
#  pass 'internet connection'
#else
#  error 'no working internet connection'
#fi

#username=`dialog --nocancel --inputbox 'enter username' 8 50 3>&1 1>&2 2>&3 3>&1`
#echo $username
disks=(`lsblk | tail -n +2 | cut -d ' ' -f 1`)
options=
for ((i = 0; i < ${#disks[@]}; i++)); do
	options="$options $i ${disks[i]} off "
done
menoptions=(${options})
tess=(dialog --separate-output --nocancel --checklist 'testtt' 40 150 20)
te=$("${tess[@]}" "${menoptions[@]}" 2>&1 >/dev/tty)
for d in $te; do
	echo $d
done
