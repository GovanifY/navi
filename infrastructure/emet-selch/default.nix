{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "emet-selch") {
    networking = {
      hostName = "emet-selch";
      domain = "govanify.com";
    };

    # TODO: find emet-selch pixel art :)
    users.motd = ''
      '';

    time.timeZone = "Europe/Paris";

    navi.profile.name = "server";
  };
}
