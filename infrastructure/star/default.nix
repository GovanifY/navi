{ config, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./hardware.nix
    <apple-silicon-support/apple-silicon-support>
  ];

  config = mkIf (config.navi.device == "star") {
    networking.hostName = "star"; # Define your hostname.
    time.timeZone = "Europe/Paris";


    navi.components = {
      bluetooth.enable = true;
      shell.greeting = ./banner;
      wm.sway = {
        battery = true;
      };
    };

    navi.wallpaper = ./wallpaper.png;

    home-manager.users.govanify = {
      home.file."Pictures/wallpaper.png".source = ./wallpaper.png;
    };

    navi.profile.name = "laptop";
  };
}
