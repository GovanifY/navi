{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.chat-server;
  clientConfig = {
    "m.homeserver".base_url = "https://${cfg.access_domain}";
    "org.matrix.msc3575.proxy".url = "https://sliding.${cfg.access_domain}";
    "m.identity_server" = { };
  };
  serverConfig."m.server" = "${cfg.access_domain}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  options.navi.components.chat-server = {
    enable = mkEnableOption "Enable navi's messaging server";
    domain = mkOption {
      type = types.str;
      default = "example.com";
      description = ''
        The domain that will be shown as a part of your username.
      '';
    };
    access_domain = mkOption {
      type = types.str;
      default = "matrix.example.com";
      description = ''
        The domain that will be used to connect to the server.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      "${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
        locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
      };
      "${cfg.access_domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = '' 
          return 404;
        '';
        locations."/_matrix".proxyPass = "http://[::1]:8008";
        locations."/_synapse/client".proxyPass = "http://[::1]:8008";
      };
    };

    # TODO: look through config and add mx-puppet-discord & telegram
    services.matrix-synapse = {
      enable = true;
      settings.enable_metrics = config.navi.components.monitor.enable;
      settings.server_name = cfg.domain;
      settings.listeners = [
        {
          port = 8008;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = true;
            }
          ];
        }

      ];
    };

    # default postgresql password set by the service
    services.postgresql = {
      enable = true;
      initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };
  };
}
