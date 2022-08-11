{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "laptop") {
    programs.fuse.userAllowOther = true;
    fileSystems."/mnt/axolotl" =
      {
        device = "alastor-user:/mnt/axolotl";
        fsType = "fuse.sshfs";
        options = [ "defaults" "x-systemd.automount" "allow_other" "_netdev" ];
      };

    systemd.services.forward = {
      description = "Sixty degrees that come in threes";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.AUTOSSH_PIDFILE = "/run/forward";
      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/forward";
        ExecStart = ''
          ${pkgs.autossh}/bin/autossh -M 20000 -f -N -L 3000:localhost:3000 alastor-user
        '';
        Restart = "on-failure";
      };

    };
  };
}
