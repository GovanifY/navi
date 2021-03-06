{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.chat-server;
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
    secret = mkOption {
      type = types.str;
      default = "";
      description = ''
        The registration secret used to register an account on the messaging
        server. Can be created by using the command `pwgen -s 64 1`.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      "${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."= /.well-known/matrix/server".extraConfig =
          let
            # use 443 instead of the default 8448 port to unite
            # the client-server and server-server port for simplicity
            server = { "m.server" = "${cfg.access_domain}:443"; };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://${cfg.access_domain}"; };
            };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON client}';
          '';
      };
      "${cfg.access_domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/".return = "418";

        locations."/_matrix" = {
          proxyPass = "http://[::1]:8008";
        };
      };
    };

    # TODO: look through config and add mx-puppet-discord & telegram
    services.matrix-synapse = {
      enable = true;
      server_name = cfg.domain;
      enable_metrics = config.navi.components.monitor.enable;
      registration_shared_secret = cfg.secret;
      listeners = [
        {
          port = 8008;
          bind_address = "::1";
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ] ++ optionals config.navi.components.monitor.enable [ "client" ];
              compress = false;
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
