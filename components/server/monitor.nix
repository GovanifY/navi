{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.monitor;
in
{
  options.navi.components.monitor = {
    enable = mkEnableOption "Enable navi's default monitoring capabilities";
    domain = mkOption {
      type = types.str;
      default = "monitor.example.com";
      description = ''
        Domain pointing to navi's monitoring interface 
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

    # TODO: maybe configure to add the default dashboard & set base user?
    # also add some basic blind testing scenario eg for patchouli alerting that
    # emet-selch is down
    services.grafana = {
      enable = true;
      domain = cfg.domain;
      port = 2342;
      addr = "127.0.0.1";
    };

    services.prometheus = {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
        nginx = mkIf navi.components.web-server.enable {
          enable = true;
          port = 9113;
        };
        tor = mkIf services.tor.enable {
          enable = true;
          port = 9130;
        };
        postgres = mkIf services.postgresql.enable {
          enable = true;
          port = 9187;
        };
        postfix = mkIf navi.components.mail-server.enable {
          enable = true;
          port = 9154;
        };
        dovecot = mkIf navi.components.mail-server.enable {
          enable = true;
          port = 9166;
        };
      };
      scrapeConfigs = [{
        job_name = "system";
        static_configs = [{
          targets = [ "127.0.0.1:9002" ];
        }];
      }] ++ optionals navi.components.chat-server.enable [{
        job_name = "synapse";
        metrics_path = "/_synapse/metrics";
        scrape_interval = "15s";
        static_configs = [{
          targets = [ "127.0.0.1:8008" ];
        }];
      }] ++ optionals navi.components.web-server.enable [{
        job_name = "nginx";
        static_configs = [{
          targets = [ "127.0.0.1:9112" ];
        }];
      }] ++ optionals services.tor.enable [{
        job_name = "tor";
        static_configs = [{
          targets = [ "127.0.0.1:9130" ];
        }];
      }] ++ optionals services.postgresql.enable [{
        job_name = "postgres";
        static_configs = [{
          targets = [ "127.0.0.1:9187" ];
        }];
      }] ++ optionals navi.components.projects.enable [{
        job_name = "gitea";
        static_configs = [{
          targets = [ "127.0.0.1:3001" ];
        }];
      }] ++ optionals navi.components.mail-server.enable [{
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
    };
  };
}
