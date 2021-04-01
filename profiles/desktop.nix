{ config, lib, ... }: {
  config = mkIf (config.navi.profile.name == "desktop") {
    navi.components.headfull = {
      graphical.enable = true;
      graphical.gaming.enable = true;
    };
  };
}
