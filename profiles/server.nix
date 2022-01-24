{ config, lib, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "server") {
    # stub
  };
}
