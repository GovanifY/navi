{ config, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./hardware.nix
    # include if you add the led matrix
    #./ledmatrix.nix
  ];

  config = mkIf (config.navi.device == "xanadu") {
    networking.hostName = "xanadu"; # Define your hostname.
    time.timeZone = "Europe/Paris";

    #modules.tor.transparentProxy = {
    #  enable = true; 
    #  outputNic = "wlp1s0"; 
    #  inputNic = "wlp1s0"; 
    #  };


    navi.components = {
      bluetooth.enable = true;
      virtualization.enable = true;
      wm.sway = {
        battery = true;
        azerty = true;
      };
      shell.greeting = ./banner;
    };

    navi.wallpaper = ./wallpaper.png;

    home-manager.users.govanify = {
      home.file."Pictures/wallpaper.png".source = ./wallpaper.png;
    };

    navi.profile.name = "laptop";
  };
}
