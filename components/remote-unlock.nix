{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.remote-unlock;
  # reads a passphrase on stdin and answers every pending systemd password
  # query with it, eg: pass navi/host | ssh root@host -p 222 navi-unlock
  unlock = pkgs.writeScript "navi-unlock" ''
    #!/bin/sh
    IFS= read -r pass
    answered=0
    for ask in /run/systemd/ask-password/ask.*; do
      # queries vanish once systemd reuses the first passphrase for the others
      [ -e "$ask" ] || continue
      while IFS='=' read -r key value; do
        if [ "$key" = "Socket" ] && [ -S "$value" ] && \
          printf '%s' "$pass" | systemd-reply-password 1 "$value" 2>/dev/null; then
          answered=$((answered + 1))
        fi
      done < "$ask" 2>/dev/null
    done
    if [ "$answered" = 0 ]; then
      echo "no pending passphrase query" >&2
      exit 1
    fi
  '';
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
    boot.initrd.systemd.extraBin = {
      navi-unlock = unlock;
      systemd-reply-password = "${config.boot.initrd.systemd.package}/lib/systemd/systemd-reply-password";
    };
  };

}
