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
    networking.useDHCP = false;
    systemd.network.enable = true;
    systemd.network.networks."30-wan" = {
      matchConfig.Name = "enp0s31f6";
      networkConfig.DHCP = "ipv4";
      address = [
        "2a01:4f9:2b:22c1::1/64"
      ];
      routes = [
        { Gateway = "fe80::1"; }
      ];
    };

    navi.components.shell.greeting = ./banner;
    navi.profile.name = "server";
  };
}
