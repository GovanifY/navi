#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

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
                echo -n "Please enter the default root password of headfull devices: " 
                read -s pass_root
                printf "\n"
                echo -n "Please enter the default user password of headfull devices: "
                read -s pass_user
                {
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
                    cp -rf $ssh_key ../secrets/headfull/assets/ssh/navi

                    old_gpg_home=$GNUPGHOME
                    export GNUPGHOME="$(mktemp -d)"
                    # import gpg key, get pubring and trustdb
                    gpg --import $gpg_key
                    gpg_admin=$(gpg --show-keys $gpg_key | sed -n 2p | xargs)
                    echo -e "5\ny\n" |  gpg --batch --command-fd 0 --expert --edit-key $gpg_admin trust
                    cp -rf $GNUPGHOME/pubring.kbx ../secrets/common/assets/gpg/updates/pubring.kbx
                    cp -rf $GNUPGHOME/trustdb.gpg ../secrets/common/assets/gpg/updates/trustdb.gpg
                    cp -rf $gpg_key ../secrets/headfull/assets/gpg/key.gpg
                    cp -rf $GNUPGHOME/trust.txt ../secrets/headfull/assets/gpg/gpg-trust.txt
                    # we reimport after as we need the pubring without the common
                    # key, to only allow updates signed with the admin key
                    gpg --import $gpg_c_key
                    gpg_common=$(gpg --show-keys $gpg_c_key | sed -n 2p | xargs)
                    echo -e "5\ny\n" |  gpg --batch --command-fd 0 --expert --edit-key $gpg_common trust

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
                } > /dev/null 2>&1
                printf "\n\nAll done! You can now run again this script to\n"
                printf "proceed with the per device setup :)\n"
                exit;;
            [Nn]* ) printf "\nPlease run git-crypt unlock then!\n"; exit;;
            * ) echo "Please answer yes or no."; exit;;
        esac
    done
fi

printf "\n\nWelcome to navi's device bootstrapper!\n\n"
printf "This script is going to automatically provision\n"
printf "your disks and setup device-specific keys.\n\n"
printf "So, first of all, let's decide which drive we should\n"
printf "target; here's a handy list:\n\n"
lsblk
read -p "Do you want to provision a drive(y) or use an existing partition(n) [y/n]: " yn
case $yn in
    [Yy]* ) provision=true; break;;
    [Nn]* ) provision=false; break;;
    * ) echo "Please answer yes or no."; exit;;
esac
read -p "Enter the drive or partition you want to use: " $device
partition=""
case "$device" in 
  *nvme*)
      partition="p"
    ;;
esac
echo -n "Please enter the encryption password of this device: " 
read -s passphrase
printf "\n"
read -p "Enter the main username of the device: " username
read -p "Is your device a headfull device? [y/n]: " yn
case $yn in
    [Yy]* ) headfull=true; break;;
    [Nn]* ) headfull=false; break;;
    * ) echo "Please answer yes or no."; exit;;
esac
if [ "$headfull" = true ] ; then
    read -p "Please enter the url of your git password repository : " git_url
fi

{

if [ "$provision" = true ] ; then
    parted /dev/$device -- mklabel gpt
    parted /dev/$device -- mkpart ESP fat32 1MiB 2G
    parted /dev/$device -- set 1 boot on
    parted /dev/$device -- mkpart primary 2G 100%
    printf "YES\n$passphrase\n$passphrase\n" | cryptsetup luksFormat /dev/${device}${partition}2
    pvcreate /dev/mapper/matrix
    vgcreate matrix /dev/mapper/matrix
    lvcreate -L 8G -n swap matrix
    lvcreate -l '100%FREE' -n root matrix
    mkfs.btrfs -L root /dev/matrix/root
    mkfs.fat -F 32 -n boot /dev/${device}${partition}1
    mkswap -L swap /dev/matrix/swap
    mount /dev/matrix/root /mnt
    mkdir -p /mnt/boot/efi
    mount /dev/${device}${partition}1 /mnt/boot/efi
    swapon /dev/matrix/swap
fi


if [ "$headfull" = true ] ; then
    old_gpg_home=$GNUPGHOME
    export GNUPGHOME="/mnt/home/$username/.config/gnupg"
    mkdir /mnt/home/$username/.config/gnupg
    chmod 700 /mnt/home/$username/.config/gnupg
    mkdir -p /mnt/home/$username/.local/share/mail/ &> /dev/null
    mkdir -p /mnt/home/$username/.cache/mutt/ &> /dev/null
    mkdir -p /mnt/home/$username/.local/share/wineprefixes/ &> /dev/null
    mkdir -p /mnt/home/$username/.config/gdb &> /dev/null
    mkdir -p /mnt/home/$username/.local/share/wineprefixes/default &> /dev/null 
    mkdir -p /mnt/home/$username/.local/share/mpd &> /dev/null
    mkdir -p /mnt/home/$username/.config/ncmpcpp &> /dev/null
    mkdir -p /mnt/home/$username/.config/notmuch/default/ &> /dev/null
    touch /mnt/home/$username/.config/gdb/init &> /dev/null

    git clone $git_url /mnt/home/$username/.config/pass
    echo "git pull --rebase" > /mnt/home/$username/.config/pass/.git/hooks/post-commit
    echo "git push" >> /mnt/home/$username/.config/pass/.git/hooks/post-commit
    chmod +x /mnt/home/$username/.config/pass/.git/hooks/post-commit
fi

chown $username -R /mnt/home/$username/
export GNUPGHOME=$old_gpg_home

rm -rf /mnt/etc/nixos
# should i make this url configurable?
git clone https://projects.govanify.com/govanify/navi /mnt/etc/nixos
cd /mnt/etc/nixos
git remote set-url origin --push git@projects.govanify.com:govanify/navi.git
nixos-generate-config --root /mnt
rm -rf configuration.nix
cp -rf configuration.sample.nix configuration.nix
} > /dev/null 2>&1

# in lieu of fully automating everything let's, for now, do an echo for when i
# have the time to setup something better
printf "\n\nDone! Make sure to setup nixpkgs and home-manager channels\n"
printf "and then configure your device correctly! Look at infrastructure/\n"
printf "for examples. To help you, a hardware.nix file has been auto-generated\n"
printf "but it will possibly require manual intervention. For example, luks\n"
printf "devices will need the path to their keyfile set\n"
printf "(found in /etc/secrets/initrd)."
