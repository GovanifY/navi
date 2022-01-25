{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.music;
in
{
  options.navi.components.music = {
    enable = mkEnableOption "Enable navi's music player";
  };
  config = mkIf cfg.enable {
    services.mpd = {
      enable = true;
      user = config.navi.username;
      group = "users";
      dataDir = "/home/${config.navi.username}/${config.navi.components.xdg.data}/mpd";
      musicDirectory = "/home/${config.navi.username}/Music";
      extraConfig = ''
        auto_update "yes"
        audio_output {  
            type  "pulse"  
            name  "Pulseaudio"
            server "127.0.0.1"
        }  
      '';
    };


    hardware.pulseaudio.extraConfig = ''
      load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
    '';

    environment.systemPackages = with pkgs; [
      ncmpcpp
      mpc_cli
    ];

    nixpkgs.overlays = [
      (
        self: super: {
          ncmpcpp = super.ncmpcpp.override {
            visualizerSupport = true;
          };
        }
      )
    ];
  };
}
