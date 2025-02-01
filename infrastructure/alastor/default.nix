{ config, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./hardware.nix
  ];

  config = mkIf (config.navi.device == "alastor") {
    networking.hostName = "alastor";
    users.motd = ''
      [49m               [38;5;232m▄[38;5;52;48;5;232m▄[49m     [38;5;232m▄[38;5;52;48;5;232m▄[49m▄       [0m
      [49m             [38;5;232m▄[38;5;52;48;5;232m▄▄[48;5;52m [49m▄ [49m▄  [48;5;232m [48;5;52m  [49m       [0m
      [49m             [48;5;232m [48;5;52m      [49m [38;5;232m▄[38;5;52;48;5;232m▄[48;5;52m   [49m      [0m
      [49m            [38;5;232m▄[38;5;9;48;5;232m▄[48;5;9m  [48;5;232m▄▄[48;5;52m▄▄[48;5;9m   [48;5;52m▄▄▄[49m      [0m
      [49m           [38;5;9m▀[48;5;9m   [38;5;1m▄[38;5;186;48;5;1m▄▄▄▄▄▄[38;5;52;48;5;9m▄[38;5;1m▄   [49m     [0m
      [49m          [48;5;1m [48;5;9m   [38;5;1m▄[38;5;144;48;5;1m▄[38;5;52;48;5;186m▄[38;5;1;48;5;52m▄▄[38;5;52;48;5;186m▄ [38;5;1;48;5;52m▄[48;5;1m [48;5;186m [48;5;1m [48;5;9m [49m      [0m
      [49m     [38;5;52;48;5;9m▄[38;5;232m▄[38;5;9;49m▄▄  [38;5;1m▀[48;5;9m▄▄[38;5;52;48;5;1m▄[48;5;144m [48;5;186m [48;5;1m  [38;5;9m▄[48;5;186m [48;5;1m [38;5;1;48;5;9m▄[48;5;186m [48;5;52m▄[38;5;52;49m▄      [0m
      [49m      [38;5;52m▀[48;5;232m▄[38;5;232;48;5;9m▄[49m  [49m▀[48;5;52m▄  [38;5;52;48;5;232m▄[38;5;144;48;5;186m▄[38;5;172;48;5;1m▄[38;5;186m▄▄[48;5;186m  [38;5;172m▄ [38;5;232;48;5;1m▄[48;5;52m  [49m     [0m
      [49m         [38;5;1;48;5;232m▄[38;5;232;48;5;9m▄[49m [49m▀[48;5;52m▄  [38;5;52;48;5;232m▄[38;5;144;48;5;186m▄[38;5;186;48;5;172m▄   [48;5;186m [49m [38;5;232m▀[48;5;52m▄[49m      [0m
      [49m           [38;5;232m▀[49m▄ [49m▀[38;5;1;48;5;232m▄[38;5;52;49m▄▄[48;5;52m [38;5;232;48;5;144m▄▄▄[38;5;52;49m▄[38;5;1m▄▄  [38;5;52m▄   [49m▄[0m
      [49m             [38;5;232m▀[49m▄[38;5;52;48;5;1m▄[49m▀▀[38;5;1;48;5;52m▄[38;5;52;48;5;9m▄ [48;5;52m [38;5;1m▄[38;5;52;49m▀▀[48;5;1m▄[38;5;1;49m▄ [38;5;9;48;5;52m▄ [38;5;52;49m▀ [0m
      [49m             [38;5;1m▀[48;5;1m [48;5;232m▄[38;5;232;49m▄ [48;5;1m  [38;5;1;48;5;52m▄[48;5;1m  [49m   [38;5;52m▀[48;5;1m▄[38;5;1;49m▀   [0m
      [49m               [38;5;9m▀[38;5;1m▄[48;5;232m▄[38;5;232;48;5;1m▄[38;5;9m▄▄[38;5;52m▄ [38;5;1;49m▄        [0m
      [49m               [48;5;1m   [48;5;52m [48;5;232m [38;5;232;48;5;9m▄[38;5;9;49m▀[48;5;52m [48;5;1m [38;5;1;49m▄       [0m
      [49m              [48;5;1m   [48;5;52m [49m [48;5;232m  [38;5;232;49m▀[49m▄[38;5;52m▀[38;5;1m▀       [0m
      [49m                  [38;5;232m▄[48;5;1m▄[48;5;9m▄[49m▄ [38;5;9m▀        [0m

                 Welcome to alastor!
          "Smile, my dear! You know, you're 
           never fully dressed without one!"
    '';

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
    services.xserver.displayManager.gdm.autoSuspend = false;

    #modules.tor.transparentProxy = {
    #enable = true; 
    #outputNic = "wlp3s0"; 
    #inputNic = "wlp3s0"; 
    #};
  };

}
