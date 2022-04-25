{ config, lib, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "server") {
    services.rtorrent.enable = true;
  };
}
