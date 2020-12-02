{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.component.desktop;
in {
  options.component.desktop = {
    enable = mkEnableOption "Is a desktop";
  };

  config = mkIf cfg.enable {
  
}
