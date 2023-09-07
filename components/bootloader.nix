# for a fully silent boot on coreboot you might want to call curs_set(0); before
# initializing our bootloader!
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.bootloader;
  sources = import ../nix/sources.nix;
  lanzaboote = import sources.lanzaboote;
in
{

  imports = [ lanzaboote.nixosModules.lanzaboote ];

  options.navi.components.bootloader = {
    enable = mkEnableOption "Enable navi's bootloader";
    verbose = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enables verbosity of the boot process of navi.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.bootspec.enable = true;
    environment.systemPackages = [
      # For debugging and troubleshooting Secure Boot.
      pkgs.sbctl
    ];

    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      configurationLimit = 2;
    };

    # TODO: add this back whenever lanzaboote gets those options
    boot.consoleLogLevel = mkIf (!cfg.verbose) 0;
    boot.kernelParams = mkIf (!cfg.verbose) [ "quiet" ];
    boot.plymouth.enable = mkIf (!cfg.verbose) true;
  };
}
