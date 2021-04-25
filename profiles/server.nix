{ config, lib, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "server") {
    services.postgresql.enable = true;
    services.nginx.enable = true;
  };
}
