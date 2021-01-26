{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.headfull.music;
in
{
  options.navi.components.headfull.music = {
    enable = mkEnableOption "Enable navi's music player";
  };
  config = mkIf cfg.enable {
    services.mpd = {
      enable = true;
      startWhenNeeded = true;
      user = "govanify";
      group = "users";
      musicDirectory = "/home/govanify/Music";
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
