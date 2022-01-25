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
            name  "pulse audio"
            device "pulse" 
            mixer_type "hardware" 
        }  
      '';
    };
    environment.systemPackages = with pkgs; [
      ncmpcpp
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
