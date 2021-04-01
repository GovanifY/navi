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
      startWhenNeeded = true;
      user = config.navi.username;
      group = "users";
      musicDirectory = "/home/${config.navi.username}/Music";
      extraConfig = ''
        auto_update "yes"
      '';
    };
    environment.systemPackages = with pkgs; [
      ncmpcpp
    ];
    nixpkgs.overlays = [
      (self: super: {
        ncmpcpp = super.ncmpcpp.override {
          visualizerSupport = true;
      };
    })];
  };
}
