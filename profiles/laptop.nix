{ config, lib, ... }:
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
  };
}
