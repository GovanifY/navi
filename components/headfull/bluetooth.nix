{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.bluetooth;
in
{
  options.navi.components.bluetooth = {
    enable = mkEnableOption "Enable bluetooth support in navi";
    audio = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable bluetooth features required for wireless headsets.
        This notably pulls in pulseaudio.
      '';
    };
  };
  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluez;
    # TODO: disable only when kde is enabled
    #services.blueman.enable = true;

    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };

    # we don't really need mpris afaict
    #systemd.user.services.mpris-proxy = mkIf cfg.audio {
    #description = "Mpris proxy";
    #after = [ "network.target" "sound.target" ];
    #serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    #wantedBy = [ "graphical-session.target" ];
    #};
  };
}
