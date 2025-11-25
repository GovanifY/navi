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

    networking = {
      useDHCP = false;
      useNetworkd = true;
    };
    navi.components = {
      shell.greeting = ./banner;
      hardening.enable = lib.mkForce true;
    };

    navi.profile.name = "server";
  };
}
