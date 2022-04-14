{ config, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./hardware.nix
  ];

  config = mkIf (config.navi.device == "star") {
    networking.hostName = "star"; # Define your hostname.
    users.motd = ''
      TODO
    '';


    time.timeZone = "Europe/Paris";

    #modules.tor.transparentProxy = {
    #  enable = true; 
    #  outputNic = "wlp1s0"; 
    #  inputNic = "wlp1s0"; 
    #  };


    navi.components = {
      bluetooth.enable = true;
      virtualization.enable = true;
      wm = {
        battery = true;
        extraConf = ''
          input "2:10:TPPS/2_IBM_TrackPoint" {
            pointer_accel 0.7
          }
          input "1739:0:Synaptics_TM3276-022" {
            tap enabled
          }
        '';
      };
    };

    home-manager.users.govanify = {
      home.file."Pictures/wallpaper.png".source = ./wallpaper.png;
    };

    navi.profile.name = "laptop";
  };
}
