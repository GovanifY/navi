{ config, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./hardware.nix
  ];

  config = mkIf (config.navi.device == "alastor") {
    networking.hostName = "alastor";
    home-manager.users.govanify = {
      home.file."Pictures/wallpaper.png".source = ./wallpaper.png;
    };

    time.timeZone = "Europe/Paris";

    navi.components = {
      remote-unlock.enable = true;
      virtualization = {
        enable = true;
        gvt = true;
      };
      bluetooth.enable = true;
      # trusted server on static ranges
      macspoofer.enable = mkForce false;
      torrent = {
        enable = true;
      };
      shell.greeting = ./banner;
      wm.sway = {
        azerty = true;
        extraConf = ''
          output DP-6 scale 2.0
          output DP-6 pos 1920 0 res 3840x2160
          output HDMI-A-4 pos 0 0 res 1920x1080
          input "5426:515:Razer_Razer_BlackWidow_Chroma" {
              xkb_layout "fr"
          }
          input "6127:24801:TrackPoint_Keyboard_II_Keyboard" {
              xkb_layout "fr"
          }
          workspace 1 output DP-6
          workspace 2 output HDMI-A-4
          workspace 3 output DP-6
        '';
      };
    };

    navi.wallpaper = ./wallpaper.png;

    navi.profile.name = "desktop";

    # alastor is also a server !
    services.displayManager.gdm.autoSuspend = false;

    #modules.tor.transparentProxy = {
    #enable = true; 
    #outputNic = "wlp3s0"; 
    #inputNic = "wlp3s0"; 
    #};
  };

}
