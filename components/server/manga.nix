{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.manga;
in
{
  options.navi.components.manga = {
    enable = mkEnableOption "Enable navi's manga's server";
    domain = mkOption {
      type = types.str;
      default = "example.com";
      description = ''
        The domain that will be used to connect to the server.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      ${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:7111";
        };
      };
    };

    services.komga = {
      enable = true;
      port = 7111;
      openFirewall = true;
    };
  };
}
