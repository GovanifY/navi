{ config, lib, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "server") {
    boot.initrd.network.enable = true;
    boot.initrd.network.ssh = {
      enable = true;
      authorizedKeys = config.user.users.${config.navi.username}.openssh.authorizedKeys.keys;
    };
  };
}
