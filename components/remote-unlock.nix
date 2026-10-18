{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.remote-unlock;
  unlock = pkgs.writeScript "navi-unlock" ''
    #!/bin/sh
    IFS= read -r secret
    mode=passphrase seen=" "
    until timeout 5 systemctl -q is-active cryptsetup.target; do
      for ask in /run/systemd/ask-password/ask.*; do
        socket=''' pid=''' msg='''
        { while IFS='=' read -r key value; do
            case $key in Socket) socket=$value ;; PID) pid=$value ;; Message) msg=$value ;; esac
          done < "$ask"; } 2>/dev/null
        [ -S "$socket" ] || continue
        case $seen in *" $socket "*) continue ;; esac
        seen="$seen$socket "
        case $msg in *PIN*) kind=pin ;; *) kind=passphrase ;; esac
        if [ $kind = pin ] && [ $mode = passphrase ]; then
          systemd-reply-password 0 "$socket" </dev/null
          continue
        fi
        case "$seen" in *" $kind:$pid "*) asked_again=1 ;; *) asked_again=''' ;; esac
        if [ $mode = pin ] && { [ $kind = passphrase ] || [ -n "$asked_again" ]; }; then
          echo "navi-unlock: rejected as passphrase and as TPM PIN: $msg" >&2
          exit 1
        fi
        if [ -n "$asked_again" ]; then
          echo "navi-unlock: not the passphrase, trying it as the TPM PIN"
          mode=pin
          timeout 5 systemctl list-units --plain --no-legend --state=activating 'systemd-cryptsetup@*' |
            while read -r unit _; do systemctl restart --no-block "$unit"; done
          break
        fi
        seen="$seen$kind:$pid "
        echo "navi-unlock: $msg"
        printf '%s' "$secret" | systemd-reply-password 1 "$socket"
      done
      sleep 1
    done
    echo "navi-unlock: all volumes unlocked"
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
    # if we allow remote unlock, disable timer otherwise we may only have 90s to
    # mount root
    fileSystems."/".options = [ "x-systemd.device-timeout=0" ];
  };

}
