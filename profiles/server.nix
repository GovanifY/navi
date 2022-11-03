{ config, lib, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "server") {
    boot.initrd.network.enable = true;
    boot.initrd.network.ssh = {
      enable = true;
      port = 222;
      authorizedKeys = [ (builtins.readFile ./../secrets/common/assets/ssh/navi.pub) ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    boot.initrd.systemd.enable = mkForce false;
  };
}
