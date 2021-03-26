{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.headfull.bluetooth;
in
{
  options.navi.components.headfull.bluetooth = {
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
    hardware.bluetooth.package = pkgs.bluezFull;
    services.blueman.enable = true;

    hardware.pulseaudio = mkIf cfg.audio {
      enable = true;
      package = pkgs.pulseaudioFull;
    };

    hardware.bluetooth.settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };

    systemd.user.services.mpris-proxy = mkIf cfg.audio {
      description = "Mpris proxy";
      after = [ "network.target" "sound.target" ];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      wantedBy = [ "graphical-session.target" ];
    };
  };
}
