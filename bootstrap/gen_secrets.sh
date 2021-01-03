#!/bin/sh
if [ "$#" -ne 2 ]; then
    echo "usage: ./gen_secrets.sh hostname root"
    echo "example: ./gen_secrets.sh alastor /mnt"
    exit 1
fi

mkdir $2/var/lib/bootloader
if [ ! -d "$2/var/lib/bootloader" ]; then
    echo "could not create secret path! do you have sufficient rights?"
    exit 1
fi

old_gpg_home=$GNUPGHOME
export GNUPGHOME="$(mktemp -d)"
script_key="$(mktemp)"

cat >$script_key <<EOF
%no-protection
Key-Type: default
Subkey-Type: default
Name-Real: navi bootloader device key
Name-Email: $1@navi
Passphrase: '' 
Expire-Date: 0
EOF
gpg --batch --generate-key $script_key
gpg --output $2/var/lib/bootloader/pub.gpg --export $1@navi 
gpg --output $2/var/lib/bootloader/priv.gpg --export-secret-key $1@navi 
rm -rf $script_key
rm -rf $GNUPGHOME
export GNUPGHOME=$old_gpg_home

tmp_password=$(mktemp)
echo "Please set the password of your bootloader" 
grub-mkpasswd-pbkdf2 | tee $tmp_password
grep "grub." $tmp_password | sed -r 's/.*grub\./grub\./' > $2/var/lib/bootloader/pass_hash
rm -rf $tmp_password
