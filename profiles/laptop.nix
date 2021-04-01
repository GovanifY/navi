{ config, lib, ... }: {
  config = mkIf (config.navi.profile.name == "laptop") {
    hardware.enableAllFirmware = true;
    services.upower.enable = true;

    # low power also means low performance
    nix.distributedBuilds = true;
    nix.extraOptions = ''
        builders-use-substitutes = true
    '';

    # most laptops have some sort of bluetooth support nowadays
    navi.components = {
      graphical.enable = true;
      bluetooth.enable = true;
    };
  };
}
