{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "laptop") {
    systemd.user.services.mountpoint = {
      description = "Sixty degrees that come in threes";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.sshfs}/bin/sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 alastor:/mnt/axolotl /mnt/axolotl/
        '';
        Restart = "on-failure";
      };
    };
  };
}
