{ config, lib, pkgs, ... }:

{

  imports = [ ./hardware.nix
              ../../common/default.nix
              ../../common/desktop.nix
            ];
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
    home.file."Pictures/wallpaper.png".source  = ./wallpaper.png;
  };


  time.timeZone = "Europe/Paris";
  location.latitude = 48.864716;
  location.longitude = 2.349014;

  navi.components = {
    virtualization = {
      enable = true;
      pci_devices = "8086:1912";
      bridge_devices = [ "wlp3s0" ];
    };
    headfull = {
      bluetooth.enable = true;
      graphical.wm = {
        azerty = true;
        extraConf = ''
          output DP-2 scale 2.0
          output DP-2 pos 1920 0 res 3840x2160
          output HDMI-A-2 pos 0 0 res 1920x1080 
          input "5426:515:Razer_Razer_BlackWidow_Chroma" {
              xkb_layout "fr(nodeadkeys)"
          }
        '';
      };
    };
  };


  #modules.tor.transparentProxy = {
    #enable = true; 
    #outputNic = "wlp3s0"; 
    #inputNic = "wlp3s0"; 
    #};

}
