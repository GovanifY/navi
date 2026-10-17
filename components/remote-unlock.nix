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
    # stage 1 networking is generated from networking.interfaces by
    # systemd-networkd
    boot.initrd.systemd.enable = true;
    boot.initrd.network.enable = true;
    boot.initrd.network.ssh = {
      enable = true;
      port = 222;
      authorizedKeys = [ (builtins.readFile ./../secrets/common/assets/ssh/navi.pub) ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    # prompt for the LUKS passphrases directly upon login
    boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
  };

}
