{ config, lib, ... }:
with lib;
let
  cfg = config.navi.components.sandboxing;
in
{
  options.navi.components.sandboxing = {
    enable = mkEnableOption "Enable navi's sandboxing features";
  };
  config = mkIf cfg.enable {
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        mpv = "${lib.getBin pkgs.mpv}/bin/mpv";
      };
    };
  };
}

