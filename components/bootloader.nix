# for a fully silent boot on coreboot you might want to call curs_set(0); before
# initializing our bootloader!
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.bootloader;
in
{
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

    # TODO: whenever we work on adding SB to upstream switch to it and add an
    # unified bzImage signed with our keys. With a well provisioned TPM this
    # should essentially solve the entire boot tampering issue.
    boot.loader = {
      timeout = mkIf (config.navi.profile.name != "server") 0;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
    };


    boot.initrd.systemd.enable = mkIf (config.navi.profile.name != "server") true;
    boot.consoleLogLevel = mkIf (!cfg.verbose) 0;
    boot.kernelParams = mkIf (!cfg.verbose) [ "quiet" ];
    boot.plymouth.enable = mkIf (!cfg.verbose) true;
  };
}
