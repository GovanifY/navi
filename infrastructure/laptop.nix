{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "laptop") {
    fileSystems."/mnt/axolotl" =
      {
        device = "alastor-user:/mnt/axolotl";
        fsType = "fuse.sshfs";
        options = [ "defaults" "allow_other" "_netdev" ];
      };

    systemd.services.forward = {
      description = "Sixty degrees that come in threes";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.autossh}/bin/autossh -M 20000 -L 3000:localhost:3000 alastor-user
        '';
        Restart = "on-failure";
      };
    };
  };
}
