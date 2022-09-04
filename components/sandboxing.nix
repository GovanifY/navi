{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.sandboxing;
in
{
  imports = [
    (mkAliasOptionModule [ "navi" "components" "sandboxing" "programs" ] [
      "programs"
      "firejail"
      "wrappedBinaries"
    ])
  ];
  options.navi.components.sandboxing = {
    enable = mkEnableOption "Enable navi's sandboxing features";
  };
  config = mkIf cfg.enable {
    programs.firejail = {
      enable = true;
    };
  };
}
