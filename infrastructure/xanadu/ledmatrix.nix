{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "xanadu") {

    systemd.timers."navi-ledmatrix" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "0s";
        OnUnitActiveSec = "30s";
        Unit = "navi-ledmatrix.service";
      };
    };

    systemd.services."navi-ledmatrix" = {
      script = ''
        set -eu
        ${pkgs.inputmodule-control}/bin/inputmodule-control --serial-dev /dev/ttyACM0 led-matrix --image-bw ${./navi-right.gif} --brightness 3
        ${pkgs.inputmodule-control}/bin/inputmodule-control --serial-dev /dev/ttyACM1 led-matrix --image-bw ${./navi-left.gif} --brightness 3
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
