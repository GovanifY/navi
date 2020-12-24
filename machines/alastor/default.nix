{ config, lib, pkgs, ... }:

{

  imports = [ ./hardware.nix
              ../../common/default.nix
              ../../component/tor.nix
              ../../common/desktop.nix
              ../../common/bluetooth.nix
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
    #services.macspoofer = {
    #  enable = true; 
    #  interface = "wlp1s0"; 
    #  };
  networking.bridges.br0.interfaces = [ "wlp3s0" ];
  networking.dhcpcd.denyInterfaces = [ "virbr0" ];

  home-manager.users.govanify = {
    home.file."Pictures/wallpaper.png".source  = ./wallpaper.png;
  };

}
