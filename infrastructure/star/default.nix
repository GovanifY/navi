{ config, lib, pkgs, ... }:
with lib;
{

  imports = [
    ./hardware.nix
    <apple-silicon-support/apple-silicon-support>
  ];

  config = mkIf (config.navi.device == "star") {
    networking.hostName = "star"; # Define your hostname.
    users.motd = ''
      [49m         [38;5;0m▄▄[38;5;167;48;5;0m▄[38;5;0;49m▄▄▄▄▄▄▄▄▄▄ [49m▄[38;5;167;48;5;0m▄[38;5;0;49m▄     [0m
           [38;5;0m▄▄[38;5;222;48;5;0m▄▄[48;5;222m [48;5;0m [38;5;0;48;5;239m▄[48;5;167m [38;5;167;48;5;0m▄[38;5;0;48;5;179m▄▄[48;5;222m▄▄▄▄▄[48;5;179m▄[38;5;167;48;5;0m▄[48;5;167m [38;5;0;48;5;239m▄[48;5;0m [49m     [0m
         [38;5;0m▄[38;5;222;48;5;0m▄[48;5;222m    [38;5;0m▄[38;5;239;48;5;0m▄[38;5;167;48;5;239m▄[38;5;0;48;5;167m▄▄▄▄▄▄▄▄▄▄▄▄ [38;5;167;48;5;0m▄[38;5;0;49m▄    [0m
        [38;5;0m▄[38;5;222;48;5;0m▄[48;5;222m   [38;5;0m▄[38;5;239;48;5;0m▄[38;5;0;48;5;239m▄[38;5;179;48;5;0m▄▄[38;5;222;48;5;179m▄▄[48;5;222m          [38;5;179;48;5;0m▄[38;5;0;48;5;239m▄ [48;5;0m [49m   [0m
        [48;5;0m [48;5;222m   [38;5;0m▄[38;5;239;48;5;0m▄[38;5;0;48;5;239m▄[48;5;0m [38;5;222;48;5;179m▄[38;5;0;48;5;222m▄[38;5;222;48;5;0m▄[38;5;0;48;5;222m▄▄▄[38;5;222;48;5;0m▄[48;5;222m    [38;5;179m▄ [38;5;222;48;5;179m▄▄[38;5;0m▄[48;5;0m [48;5;239m [48;5;0m [49m  [0m
        [48;5;0m [48;5;222m   [48;5;0m [48;5;239m [48;5;0m [48;5;222m [38;5;222;48;5;0m▄▄[48;5;222m   [38;5;179m▄▄▄[48;5;179m [38;5;0;48;5;222m▄[48;5;179m▄[38;5;173;48;5;0m▄[38;5;0;48;5;179m▄[48;5;222m▄[48;5;179m [38;5;179;48;5;222m▄ [38;5;222;48;5;0m▄[38;5;179;48;5;222m▄[48;5;0m [49m [0m
        [48;5;0m [48;5;222m   [38;5;0;48;5;179m▄[38;5;216;48;5;0m▄▄▄[38;5;0;48;5;222m▄[48;5;179m▄▄▄▄[38;5;15;48;5;0m▄   [38;5;173;48;5;95m▄[38;5;223;48;5;173m▄▄[48;5;0m [48;5;15m [48;5;0m  [38;5;0;48;5;179m▄▄[38;5;0;48;5;0m▄[49m  [0m
        [38;5;0;48;5;0m▄[38;5;0;48;5;222m▄  [48;5;0m [48;5;216m [38;5;216;48;5;0m▄[38;5;0;48;5;234m▄[48;5;216m [48;5;223m [48;5;0m [48;5;15m   [48;5;0m   [48;5;223m   [48;5;0m [48;5;15m [48;5;0m  [48;5;222m [48;5;0m [49m   [0m
         [48;5;0m [48;5;222m  [38;5;179;48;5;0m▄[38;5;0;48;5;216m▄[48;5;223m [38;5;223;48;5;0m▄[48;5;223m [38;5;173m▄ [38;5;223;48;5;0m▄[38;5;0;48;5;15m▄▄▄[48;5;0m [38;5;223m▄[48;5;223m  [38;5;95m▄[38;5;173;48;5;0m▄[38;5;0;48;5;15m▄▄[48;5;0m [48;5;179m [48;5;0m [49m   [0m
         [48;5;0m [48;5;222m  [48;5;179m  [38;5;179;48;5;0m▄▄▄[38;5;0;48;5;173m▄[38;5;173;48;5;223m▄[48;5;218m [38;5;218;48;5;223m▄[48;5;218m [48;5;223m [38;5;0m▄      [48;5;218m [48;5;0m [48;5;179m [48;5;0m [49m   [0m
         [38;5;0;48;5;0m▄[38;5;0;48;5;222m▄  [48;5;179m     [38;5;179;48;5;0m▄[38;5;0;48;5;173m▄[38;5;173;48;5;218m▄[48;5;223m▄  [38;5;223;48;5;0m▄▄▄[48;5;223m  [38;5;0m▄[38;5;179;48;5;0m▄[48;5;179m  [48;5;0m [49m   [0m
          [48;5;0m [48;5;222m  [48;5;179m       [38;5;179;48;5;0m▄▄ [38;5;173m▄▄▄   [48;5;179m    [48;5;0m [49m   [0m
          [48;5;0m [48;5;222m  [48;5;179m     [38;5;0m▄[38;5;66;48;5;0m▄[38;5;115m▄▄▄▄▄[38;5;0;48;5;223m▄▄[48;5;173m▄[48;5;0m  [48;5;179m▄  [48;5;0m [49m   [0m
          [48;5;0m [48;5;222m  [48;5;179m    [48;5;0m [38;5;15;48;5;115m▄▄[38;5;115;48;5;66m▄[38;5;66;48;5;115m▄▄      [48;5;0m [38;5;222m▄[38;5;0;48;5;179m▄ [48;5;0m [49m   [0m
         [38;5;0m▄[38;5;222;48;5;0m▄[48;5;222m  [48;5;179m   [38;5;0m▄[38;5;173;48;5;0m▄[38;5;223m▄[38;5;173m▄[38;5;0;48;5;15m▄[48;5;0m [48;5;66m  [48;5;115m  [38;5;168m▄[48;5;168m [48;5;0m [48;5;222m [48;5;0m  [48;5;179m  [48;5;0m [49m  [0m
         [48;5;0m [48;5;222m  [38;5;179m▄[48;5;179m   [48;5;0m [48;5;223m   [48;5;173m [48;5;0m  [38;5;0;48;5;66m▄ [48;5;115m [48;5;168m▄[38;5;179;48;5;0m▄[38;5;0;48;5;222m▄[48;5;0m [38;5;66m▄ [48;5;179m  [48;5;0m [49m  [0m
        [38;5;0m▄[38;5;222;48;5;0m▄[48;5;222m  [48;5;179m   [48;5;0m [48;5;223m   [38;5;173m▄[38;5;0;48;5;173m▄[38;5;179;48;5;0m▄[48;5;179m [48;5;0m [38;5;0;48;5;66m▄[38;5;179;48;5;0m▄[38;5;0;48;5;179m▄[38;5;66;48;5;0m▄[48;5;66m [38;5;115m▄▄[48;5;0m [48;5;179m  [48;5;0m [49m  [0m
        [48;5;0m [48;5;222m   [48;5;179m  [48;5;0m [48;5;223m   [38;5;173m▄[38;5;0;48;5;173m▄[38;5;179;48;5;0m▄[48;5;179m [48;5;0m [48;5;0m▄[38;5;0;48;5;179m▄[38;5;66;48;5;0m▄[48;5;66m [48;5;115m    [48;5;0m [38;5;223m▄[38;5;0;48;5;179m▄ [48;5;0m [49m [0m
       [48;5;0m [48;5;222m    [38;5;0;48;5;179m▄[38;5;173;48;5;0m▄[38;5;223;48;5;173m▄▄[48;5;223m [38;5;173m▄[48;5;173m [48;5;0m [38;5;222m▄ [38;5;0;48;5;179m▄[38;5;66;48;5;0m▄[48;5;66m  [48;5;115m     [38;5;115;48;5;0m▄[38;5;0;48;5;173m▄[38;5;173;48;5;223m▄[38;5;223;48;5;0m▄ [49m [0m
      [38;5;0m▄[38;5;222;48;5;0m▄[48;5;222m  [38;5;0m▄[38;5;223;48;5;0m▄[48;5;223m  [38;5;0m▄▄ [48;5;173m [48;5;0m [48;5;222m  [38;5;179m▄[38;5;0;48;5;179m▄[38;5;115;48;5;0m▄[48;5;115m        [48;5;0m▄[38;5;0;48;5;173m▄[48;5;223m▄▄[48;5;0m [0m
      [48;5;0m [48;5;222m [48;5;0m [48;5;222m [38;5;222;48;5;0m▄▄▄[38;5;179m▄[48;5;179m [48;5;0m [38;5;0;48;5;223m▄[38;5;179;48;5;0m▄▄[38;5;0;48;5;179m▄[38;5;145;48;5;0m▄[38;5;0;48;5;179m▄[38;5;145;48;5;0m▄[48;5;115m         [38;5;15m▄[48;5;0m▄[38;5;0;48;5;179m▄[48;5;0m [49m [0m
       [48;5;0m [48;5;222m      [48;5;179m     [48;5;0m [38;5;131m▄[38;5;239m▄[38;5;0;48;5;145m▄[48;5;15m▄▄[48;5;145m▄[48;5;15m▄▄[48;5;145m▄[48;5;15m▄▄[48;5;145m▄[48;5;15m▄[38;5;179;48;5;0m▄[48;5;179m [48;5;0m [49m [0m
        [48;5;0m [48;5;222m      [38;5;222;48;5;179m▄  [38;5;0m▄[38;5;239;48;5;0m▄[38;5;168;48;5;131m▄[48;5;210m▄[38;5;210;48;5;131m▄[48;5;239m▄▄[48;5;0m [38;5;131;48;5;239m▄[38;5;168m▄[48;5;131m▄[48;5;210m▄▄[48;5;0m [48;5;179m [38;5;222m▄[48;5;0m [49m  [0m
         [38;5;0;48;5;0m▄[38;5;0;48;5;222m▄▄  [38;5;222;48;5;0m▄[38;5;0;48;5;222m▄ [48;5;222m▄[38;5;239;48;5;0m▄[38;5;168;48;5;131m▄[48;5;210m [38;5;210;48;5;168m▄▄▄[38;5;0m▄[38;5;239;48;5;0m▄[48;5;131m▄[48;5;210m▄[38;5;168m▄▄[48;5;0m [48;5;222m [38;5;0m▄[38;5;0;48;5;0m▄[49m   [0m
            [38;5;0;48;5;0m▄▄▄[49m [48;5;0m▄ [38;5;238m▄[38;5;0;48;5;168m▄▄▄▄▄[48;5;0m [38;5;238m▄▄▄[38;5;239m▄▄ [38;5;0m▄[49m     [0m
                [48;5;0m [48;5;238m  [38;5;239m▄[48;5;239m    [48;5;0m [48;5;238m  [48;5;239m   [48;5;0m [49m      [0m
                [48;5;0m [48;5;238m [38;5;239m▄[48;5;239m     [48;5;0m [48;5;238m [48;5;238m▄[48;5;239m   [48;5;0m [49m      [0m
               [48;5;0m [48;5;238m  [48;5;239m     [48;5;238m [48;5;0m [38;5;238;48;5;145m▄[38;5;145;48;5;239m▄[38;5;238m▄▄[38;5;0m▄[38;5;15;48;5;0m▄[38;5;0;49m▄     [0m
               [48;5;0m [48;5;238m [38;5;238;48;5;15m▄[38;5;15;48;5;239m▄[38;5;238m▄▄[38;5;0m▄[38;5;15;48;5;0m▄[38;5;0;48;5;238m▄[48;5;0m [38;5;145;48;5;238m▄▄[38;5;15m▄[48;5;239m▄▄▄[48;5;0m [49m     [0m
               [48;5;0m [38;5;0;48;5;145m▄[38;5;145;48;5;238m▄▄[38;5;15;48;5;239m▄▄▄▄▄[48;5;0m [38;5;0m▄▄▄▄▄▄▄[49m     [0m
                 [38;5;0;48;5;0m▄▄▄▄▄▄▄▄[49m            [0m
           
                Welcome to star!
             Sometimes, all you need
             is a good old magic wand
    '';



    time.timeZone = "Europe/Paris";


    navi.components = {
      bluetooth.enable = true;
      wm = {
        battery = true;
      };
    };

    home-manager.users.govanify = {
      home.file."Pictures/wallpaper.png".source = ./wallpaper.png;
    };

    navi.profile.name = "laptop";
  };
}
