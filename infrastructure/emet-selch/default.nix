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
    networking.interfaces."enp0s31f6".useDHCP = false;
    networking.enableIPv6 = true;
    networking.interfaces."enp0s31f6".ipv6.addresses = [
      {
        address = "2a01:4f9:2b:22c1::1";
        prefixLength = 64;
      }
    ];
    networking.defaultGateway6 = { address = "fe80::1"; interface = "enp0s31f6"; };
    navi.components.shell.greeting = ./banner;
    navi.profile.name = "server";
  };
}
