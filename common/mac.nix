{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.services.macspoofer;
in {
  options.services.macspoofer = {
    enable = mkEnableOption "Mac Spoofer service";
    interface = mkOption {
      type = types.str;
      default = "";
    };
  };

  # we do not spoof the OUI part of the MAC address in this case. The reason is
  # twofold: since all connection is wired through tor, hopefully, your traffic
  # could be automatically identified and your MAC address assumed to be
  # spoofed, since Tails does spoof it. With that said, Tails do not spoof the
  # OUI part of the MAC address and as such breaking the OUI stamdard would make
  # you stand out compared to Tails user, which makes you somewhat stand out as
  # using a different technology.
  # Morale of the day: use common network cards or add to macchanger an OUI list
  # support. Also you might still be able to be tracked down against a truly
  # global adversary: 1. list people using tor in their network 2. list people
  # using your OUI (a small subset I'd assume) OR list people breaking the OUI
  # standard (basically only you by this point).
  # The more people use tor, the better our security will be.
  config = lib.mkIf cfg.enable {

  environment.systemPackages = with pkgs; [ macchanger ];
    systemd.services.macspoofer = {
      wantedBy = [ "multi-user.target" ];
      description = "Mac Spoofer service";
      wants = [ "network-pre.target" ];
      before = [ "network-pre.target" ];
      bindsTo = [ "sys-subsystem-net-devices-${cfg.interface}.device" ];
      after = [ "sys-subsystem-net-devices-${cfg.interface}.device" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.macchanger}/bin/macchanger -e ${cfg.interface}
        '';
      };
    };
  };
}
