{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.remote-unlock;
in
{
  options.navi.components.remote-unlock = {
    enable = mkEnableOption "Enable navi's networked remote unlock";
  };

  config = mkIf cfg.enable {
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
