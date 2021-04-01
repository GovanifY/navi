{ config, lib, ... }: {
  config = mkIf (config.navi.profile.name == "desktop") {
    navi.components.gaming.enable = true;
    navi.profile.graphical = true;
  };
}
