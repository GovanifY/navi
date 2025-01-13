{ pkgs, modulesPath, lib, isoImage, ... }: {

  imports = [
    ./default.nix
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  networking.hostName = "iso";
  users.motd = ''
    '';

  time.timeZone = "Europe/Paris";
  navi.profile.name = "iso";
  navi.device = "void";
  isoImage.efiSplashImage = ./infrastructure/assets/navi.png;
  isoImage.splashImage = ./infrastructure/assets/navi.png;
  isoImage.grubTheme = null;
}
