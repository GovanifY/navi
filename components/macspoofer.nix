{ config, lib, ... }:
with lib;
let
  cfg = config.navi.components.macspoofer;
in
{
  options.navi.components.macspoofer = {
    enable = mkEnableOption "Enables navi's MAC address spoofer";
    full_random = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Assign a new MAC address at each reconnection to the AP instead of
        keeping a random stable one per AP
      '';
    };
  };
  config = mkIf cfg.enable {
    # use a different mac address for each connection, but keep it per connection.
    # the mac is derived from a system private key, this allows to avoid a network
    # from identifying you are mac address spoofing while still preventing global
    # tracking through MAC address maps.
    networking.networkmanager.wifi.macAddress = 
      (if cfg.full_random then "random" else "stable");
    networking.networkmanager.ethernet.macAddress = 
      (if cfg.full_random then "random" else "stable");
  };
}
