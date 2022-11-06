{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.monitor;
in
{
  # TODO: currently navi's monitor module is pretty bad for very scalable
  # alerting servers, as it relies on an "all or nothing" scenario, to not be
  # dependant on any alerting server, since I am running this on a fairly
  # contrived setup. Obviously, this doesn't make sense on a 5+ server network,
  # where you'd want to be able to have a main alerting server and a backup one
  # doing a blackbox exporter on the main one, with only exporters running on
  # all other servers. So the answer, in this case, is to deal with NixOS
  # configuration options directly for now. I'll look into making this less of a
  # pain in the future.
  options.navi.components.monitor = {
    enable = mkEnableOption "Enable navi's default monitoring capabilities";
    domain = mkOption {
      type = types.str;
      default = "monitor.example.com";
      description = ''
        Domain pointing to navi's monitoring interface 
      '';
    };
    username = mkOption {
      type = types.str;
      default = "";
      description = ''
        Username to connect to the monitoring interface
      '';
    };
    password_file = mkOption {
      type = types.str;
      default = "";
      description = ''
        File containing the password  to connect to the monitoring interface
      '';
    };
    email = mkOption {
      type = types.str;
      default = "someone@example.com";
      description = ''
        email to which send alerts to 
      '';
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      ${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2342";
          proxyWebsockets = true;
        };
      };
    };

    services.grafana = {
      enable = true;
      settings = {
        server.domain = cfg.domain;
        server.http_port = 2342;
        server.http_addr = "127.0.0.1";

        database.type = "postgres";
        database.host = "/run/postgresql";
        database.user = "grafana";

        users.allowSignUp = false;
        users.allowOrgCreate = false;
        "auth.anonymous".enabled = false;
        analytics.reporting_enable = false;
        security.admin_user = cfg.username;
        security.admin_password = "$__file{${cfg.password_file}}";
      };
    };

    systemd.services.grafana.after = [ "postgresql.service" ];
    services.postgresql = {
      enable = true;
      ensureDatabases = [ config.services.grafana.settings.database.name ];
      ensureUsers = [
        {
          name = config.services.grafana.settings.database.user;
          ensurePermissions = { "DATABASE ${config.services.grafana.settings.database.name}" = "ALL PRIVILEGES"; };
        }
      ];
    };

    # For alerting we might want to setup twilio with priority alerts
    # also add some basic blind testing scenario eg for patchouli alerting that
    # emet-selch is down
    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = "15s";
      alertmanagers = [
        {
          scheme = "http";
          path_prefix = "/";
          static_configs = [{ targets = [ "localhost:${toString config.services.prometheus.alertmanager.port}" ]; }];
        }
      ];
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
        nginx = mkIf config.navi.components.web-server.enable {
          enable = true;
          port = 9113;
        };
        tor = mkIf config.services.tor.enable {
          enable = true;
          port = 9130;
        };
        postgres = mkIf config.services.postgresql.enable {
          enable = true;
          port = 9187;
        };
        postfix = mkIf config.navi.components.mail-server.enable {
          enable = true;
          port = 9154;
        };
        dovecot = mkIf config.navi.components.mail-server.enable {
          enable = true;
          port = 9166;
        };
      };
      scrapeConfigs = [{
        job_name = "node";
        static_configs = [{
          targets = [ "127.0.0.1:9002" ];
        }];
      }] ++ optionals
        config.navi.components.chat-server.enable
        [{
          job_name = "synapse";
          metrics_path = "/_synapse/metrics";
          static_configs = [{
            targets = [ "127.0.0.1:8448" ];
          }];
        }] ++ optionals
        config.navi.components.web-server.enable
        [{
          job_name = "nginx";
          static_configs = [{
            targets = [ "127.0.0.1:9112" ];
          }];
        }] ++ optionals
        config.services.tor.enable
        [{
          job_name = "tor";
          static_configs = [{
            targets = [ "127.0.0.1:9130" ];
          }];
        }] ++ optionals
        config.services.postgresql.enable
        [{
          job_name = "postgres";
          static_configs = [{
            targets = [ "127.0.0.1:9187" ];
          }];
        }] ++ optionals
        config.navi.components.projects.enable
        [{
          job_name = "gitea";
          static_configs = [{
            targets = [ "127.0.0.1:3001" ];
          }];
        }] ++ optionals
        config.navi.components.mail-server.enable
        [{
          job_name = "postfix";
          static_configs = [{
            targets = [ "127.0.0.1:9154" ];
          }];
        }
          {
            job_name = "dovecot";
            static_configs = [{
              targets = [ "127.0.0.1:9166" ];
            }];
          }];
      alertmanager = {
        enable = true;
        listenAddress = "localhost";
        configuration = {
          global = {
            smtp_smarthost = "localhost:25";
            smtp_from = "alertmanager@${cfg.domain}";
          };
          route = {
            receiver = "email";
            routes = [{
              # in the future, when nixpkgs gets more up to date, we should use
              # matchers. currently amtool throws its hand in the air.
              match = { severity = "critical"; };
              receiver = "pager";
            }];
          };
          receivers = [
            {
              name = "email";
              email_configs = [
                { to = cfg.email; }
              ];
            }
            # this should eventually be handled by sachet whenever nixpkgs has
            # it upstream
            {
              name = "pager";
              email_configs = [
                { to = cfg.email; }
              ];
            }

          ];
        };
      };
    };
  };
}
