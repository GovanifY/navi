{ config, lib, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "server") {
    navi.components.remote-unlock.enable = true;
  };
}
