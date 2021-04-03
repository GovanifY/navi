#!/bin/sh
echo "Welcome to navi's bootstrapper!"
cat icon.motd

echo "4d16330208714286d397e2cf7d8a977ac2771ac9fa0311226afc0df06e00b4d6 ../secrets/assets/canary" \
    | sha256sum --check --status &> /dev/null

if [ "$?" -ne 0 ]; then
    echo "failed to verify canary"
fi

if [ "$#" -ne 2 ]; then
    echo "usage: ./bootstrap.sh hostname username root"
    echo "example: ./bootstrap.sh alastor govanify /mnt"
    exit 1
fi

mkdir $3/var/lib/bootloader
if [ ! -d "$3/var/lib/bootloader" ]; then
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
gpg --output $3/var/lib/bootloader/pub.gpg --export $1@navi 
gpg --output $3/var/lib/bootloader/priv.gpg --export-secret-key $1@navi 
rm -rf $script_key
rm -rf $GNUPGHOME
export GNUPGHOME=$old_gpg_home

tmp_password=$(mktemp)
echo "Please set the password of your bootloader" 
grub-mkpasswd-pbkdf2 | tee $tmp_password
grep "grub." $tmp_password | sed -r 's/.*grub\./grub\./' > $3/var/lib/bootloader/pass_hash
rm -rf $tmp_password


old_gpg_home=$GNUPGHOME
export GNUPGHOME="$3/home/$2/.config/gnupg"
find $3/home/$2/.config/gnupg -type f -exec chmod 600 {} \;
find $3/home/$2/.config/gnupg -type d -exec chmod 700 {} \;
gpg --import ../secrets/assets/gpg/key.gpg 
gpg --import-ownertrust ../secrets/assets/gpg/gpg-trust.txt 
mkdir -p $3/home/$2/.local/share/mail/ &> /dev/null
mkdir -p $3/home/$2/.cache/mutt/ &> /dev/null
mkdir -p $3/home/$2/.local/share/wineprefixes/ &> /dev/null
mkdir -p $3/home/$2/.config/gdb &> /dev/null
mkdir -p $3/home/$2/.local/share/wineprefixes/default &> /dev/null 
touch $3/home/$2/.config/gdb/init &> /dev/null

git clone git@code.govanify.com:govanify/passwords.git $3/home/$2/.config/pass
echo "git pull --rebase" > $3/home/$2/.config/pass/.git/hooks/post-commit
echo "git push" >> $3/home/$2/.config/pass/.git/hooks/post-commit
chmod +x $3/home/$2/.config/pass/.git/hooks/post-commit                                                                                                                                                                                                               

chown $2 -R $3/home/$2/
export GNUPGHOME=$old_gpg_home
