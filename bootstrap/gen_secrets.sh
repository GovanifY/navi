#!/bin/sh
if [ "$#" -ne 1 ]; then
    echo "usage: ./gen_secrets.sh hostname"
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
mkdir ../secrets/bootloader/$1
gpg --output ../secrets/bootloader/$1/pub.gpg --export $1@navi 
gpg --output ../secrets/bootloader/$1/priv.gpg --export-secret-key $1@navi 
rm -rf $script_key
rm -rf $GNUPGHOME
export GNUPGHOME=$old_gpg_home
