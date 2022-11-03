{ config, lib, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "server") {
    boot.initrd.network.enable = true;
    boot.initrd.network.ssh = {
      enable = true;
      authorizedKeys = [ (builtins.readFile ./../secrets/common/assets/ssh/navi.pub) ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
  };
}
