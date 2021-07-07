#!/bin/sh
# THIS IS A HEADFULL ONLY BOOTSTRAPPER! I NEED TO MAKE ONE FOR OTHER DEVICES TOO
# AAAAAAA

echo "Welcome to navi's bootstrapper!"
cat icon.motd

echo "4d16330208714286d397e2cf7d8a977ac2771ac9fa0311226afc0df06e00b4d6 ../secrets/common/assets/canary" \
    | sha256sum --check --status &> /dev/null

if [ "$?" -ne 0 ]; then
    while true; do
        read -p "Failed to verify secrets! Do you want to start the first time setup? [y/n]: " yn
        case $yn in
            [Yy]* ) 
                printf "\n\nWelcome to navi's first time setup!\n\n"
                printf "This script is going to generate the secrets needed for\n"
                printf "common and headfull devices to work. You can then add\n"
                printf "more on top of this baseline to fit your needs.\n\n\n"
                printf "navi's security model relies _heavily_ on gpg and\n"
                printf "ssh keys:\n* gpg keys are used to verify updates,\n"
                printf "store passwords, secrets in this repository,\n"
                printf "encrypted emails, etc.\n"
                printf "* ssh keys are used for remote building, caching, login, etc.\n\n"
                printf "As such, we will need you to specify an admin\n"
                printf "ssh key, a gpg one and a common gpg one. You will _need_ to sign\n"
                printf "all of your commits to your navi's repository with\n"
                printf "the admin gpg key, at the very least, for auto updates to\n"
                printf "work. The common gpg key will be shared across all\n"
                printf "devices to be able to decrypt shared secrets.\n\n"
                read -p "Once you read this warning, please press enter to continue"
                read -p "Please enter the path of your gpg admin private key: " gpg_key
                read -p "Please enter the path of your ssh private key: " ssh_key
                read -p "Please enter the path of your gpg common private key: " gpg_c_key
                read -p "Please enter the default root password of headfull devices: " pass_root
                read -p "Please enter the default user password of headfull devices: " pass_user
                rm -rf ../.git-crypt
                rm -rf ../secrets/*/
                mkdir -p ../secrets/common/assets/gpg/updates
                mkdir -p ../secrets/common/assets/ssh
                cp -rf $ssh_key.pub ../secrets/common/assets/ssh/navi.pub
                cp -rf canary ../secrets/common/assets/canary
                cp -rf common_default.nix ../secrets/common/default.nix

                mkdir -p ../secrets/headfull/assets/gpg
                mkdir -p ../secrets/headfull/assets/shadow
                mkdir -p ../secrets/headfull/assets/ssh
                cp -rf headfull_canary ../secrets/headfull/assets/canary
                cp -rf common_default.nix ../secrets/headfull/default.nix
                cp -rf $sshkey ../secrets/headfull/assets/ssh/navi

                old_gpg_home=$GNUPGHOME
                export GNUPGHOME="$(mktemp -d)"
                # import gpg key, get pubring and trustdb
                gpg --import $gpg_key
                for fpr in $(gpg --list-keys --with-colons  | awk -F: '/fpr:/ {print $10}' | sort -u); do  echo -e "5\ny\n" |  gpg --command-fd 0 --expert --edit-key $fpr trust; done
                cp -rf $GNUPGHOME/pubring.kbx ../secrets/common/assets/gpg/updates/pubring.kbx
                cp -rf $GNUPGHOME/trustdb.gpg ../secrets/common/assets/gpg/updates/trustdb.gpg
                cp -rf $GNUPGHOME/key.gpg ../secrets/headfull/assets/gpg/key.gpg
                cp -rf $GNUPGHOME/gpg-trust.txt ../secrets/headfull/assets/gpg/gpg-trust.txt
                gpg_common=$(gpg --show-keys $gpg_c_key | sed -n 2p | xargs)
                gpg_admin=$(gpg --show-keys $gpg_key | sed -n 2p | xargs)
                git-crypt init
                git-crypt add-gpg-user $gpg_admin
                git-crypt init -k common
                git-crypt add-gpg-user -k common $gpg_admin
                git-crypt add-gpg-user -k common $gpg_common
                rm -rf $GNUPGHOME
                export GNUPGHOME=$old_gpg_home
                ssh-keygen -t ed25519 -C "distbuild@navi" -N "" -f ../secrets/headfull/assets/ssh/distbuild
                echo "$pass_root" | mkpasswd --method=SHA-512 --stdin > ../secrets/headfull/assets/shadow/root
                echo "$pass_user" | mkpasswd --method=SHA-512 --stdin > ../secrets/headfull/assets/shadow/main
                printf "\n\nAll done! You can now run again this script to\n"
                printf "proceed with the per device setup :)\n"
                exit;;
            [Nn]* ) printf "\nPlease run git-crypt unlock then!\n"; exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
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
gpg --import ../secrets/headfull/assets/gpg/key.gpg 
gpg --import-ownertrust ../secrets/headfull/assets/gpg/gpg-trust.txt 
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

# in lieu of fully automating everything let's, for now, do an echo for when i
# have the time to setup something better
echo "Done! Make sure to setup nixpkgs and home-manager channels!"
