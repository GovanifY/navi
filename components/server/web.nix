{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.web-server;
in
{
  options.navi.components.web-server = {
    enable = mkEnableOption "Enable navi's web server";
    email = mkOption {
      type = types.str;
      default = "admin@example.com";
      description = ''
        Default contact email that the web server will use.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    security.acme.acceptTerms = true;
    security.acme.email = cfg.email;
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
  };
}
