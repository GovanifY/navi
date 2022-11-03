{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.projects;
in
{
  options.navi.components.projects = {
    enable = mkEnableOption "Enable navi's project management server";
    domain = mkOption {
      type = types.str;
      default = "code.example.com";
      description = ''
        Domain pointing to navi's project management services
      '';
    };
  };

  config = mkIf cfg.enable {
    services.gitlab-runner.enable = true;

    services.gitlab = {
      enable = true;
      host = cfg.domain;
      port = 443;
      https = true;
      smtp.enable = true;
    };

    services.nginx.virtualHosts = {
      "${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
    };
  };
}
