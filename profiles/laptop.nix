{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "laptop") {
    # low power also means low performance
    nix.distributedBuilds = true;
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';

    navi.profile.graphical = true;
    navi.components.gaming.enable = true;

    services.tlp.enable = mkIf config.navi.components.wm.sway.enable true;

    # check weekly for updates on laptop instead of the usual daily, a few hours
    # after other devices updates so that they had the time to build the new
    # updates and our laptop can fetch it from the binary cache. While we're
    # at it use a persistent state so that systemd realize when the system was
    # shut down for quite some time.
    system.autoUpgrade.dates = "Mon *-*-* 20:00:00";
    systemd.timers.nixos-upgrade.timerConfig.Persistent = true;
  };
}
