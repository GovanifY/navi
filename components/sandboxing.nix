{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.sandboxing;
in
{
  options.navi.components.sandboxing = {
    enable = mkEnableOption "Enable navi's sandboxing features";
    programs = mkOption {
      type = types.attrsOf types.path;
      description = ''
        The binary path of programs to sandbox.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.firejail = {
      enable = true;
      wrappedBinaries = cfg.programs;
    };
  };
}
