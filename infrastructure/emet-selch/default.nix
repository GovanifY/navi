{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./hardware.nix
  ];

  config = mkIf (config.navi.device == "emet-selch") {
    networking = {
      hostName = "emet-selch";
      domain = "govanify.com";
    };

    time.timeZone = "Europe/Paris";

    users.users.${config.navi.username}.initialHashedPassword = fileContents ./../../secrets/emet-selch/assets/shadow/main;

    # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
    systemd.network = {
      enable = true;
      networks."enp0s31f6".extraConfig = ''
        [Match]
        Name = enp0s31f6
        [Network]
        Address = 2a01:4f9:2b:22c1::1/64
        Gateway = fe80::1
      '';
    };

    navi.components.shell.greeting = ./banner;
    navi.profile.name = "server";
  };
}
