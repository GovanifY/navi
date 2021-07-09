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
    username = mkOption {
      type = types.str;
      default = "";
      description = ''
        Username to connect to the monitoring interface
      '';
    };
    password = mkOption {
      type = types.str;
      default = "";
      description = ''
        Password to connect to the monitoring interface
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
      domain = cfg.domain;
      port = 2342;
      addr = "127.0.0.1";

      database.type = "postgres";
      database.host = "/run/postgresql";
      database.user = "grafana";

      smtp.enable = false;
      users.allowSignUp = false;
      users.allowOrgCreate = false;
      auth.anonymous.enable = false;
      analytics.reporting.enable = false;
      security.adminUser = cfg.username;
      security.adminPassword = cfg.password;

      provision = {
        enable = true;
        dashboards = [
          ({
            name = "General";
            type = "file";
            disableDeletion = true;
            options.path = ./../../assets/dashboards;
          })
        ];
        datasources = [
          {
            access = "proxy";
            name = "prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
          }
        ];
      };
    };

    systemd.services.grafana.after = [ "postgresql.service" ];
    services.postgresql = {
      enable = true;
      ensureDatabases = [ config.services.grafana.database.name ];
      ensureUsers = [
        {
          name = config.services.grafana.database.user;
          ensurePermissions = { "DATABASE ${config.services.grafana.database.name}" = "ALL PRIVILEGES"; };
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
            targets = [ "127.0.0.1:8008" ];
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
      rules = [
        (
          builtins.toJSON {
            groups = [
              {
                name = "rules";
                rules = [
                  {
                    alert = "InstanceLowDiskAbs";
                    expr = ''node_filesystem_avail_bytes{fstype!~"(tmpfs|ramfs)",mountpoint!~"^/boot.?/?.*"} / 1024 / 1024 < 1024'';
                    for = "1m";
                    labels = {
                      severity = "page";
                    };
                    annotations = {
                      description = "Less than 1GB of free disk space left on the root filesystem";
                      summary = "Instance {{ $labels.instance }}: {{ $value }}MB free disk space on {{$labels.device }} @ {{$labels.mountpoint}}";
                      value = "{{ $value }}";
                    };
                  }
                  (
                    let
                      low_megabyte = 70;
                    in
                    {
                      alert = "InstanceLowBootDiskAbs";
                      expr = ''node_filesystem_avail_bytes{mountpoint=~"^/boot.?/?.*"} / 1024 / 1024 < ${toString low_megabyte}''; # a single kernel roughly consumes about ~40ish MB.
                      for = "1m";
                      labels = {
                        severity = "page";
                      };
                      annotations = {
                        description = "Less than ${toString low_megabyte}MB of free disk space left on one of the boot filesystem";
                        summary = "Instance {{ $labels.instance }}: {{ $value }}MB free disk space on {{$labels.device }} @ {{$labels.mountpoint}}";
                        value = "{{ $value }}";
                      };
                    }
                  )
                  {
                    alert = "InstanceLowDiskPerc";
                    expr = "100 * (node_filesystem_free_bytes / node_filesystem_size_bytes) < 10";
                    for = "1m";
                    labels = {
                      severity = "page";
                    };
                    annotations = {
                      description = "Less than 10% of free disk space left on a device";
                      summary = "Instance {{ $labels.instance }}: {{ $value }}% free disk space on {{ $labels.device}}";
                      value = "{{ $value }}";
                    };
                  }
                  {
                    alert = "InstanceLowDiskPrediction12Hours";
                    expr = ''predict_linear(node_filesystem_free_bytes{fstype!~"(tmpfs|ramfs)"}[3h],12 * 3600) < 0'';
                    for = "2h";
                    labels.severity = "page";
                    annotations = {
                      description = ''Disk {{ $labels.mountpoint }} ({{ $labels.device }}) will be full in less than 12 hours'';
                      summary = ''Instance {{ $labels.instance }}: Disk {{ $labels.mountpoint }} ({{ $labels.device}}) will be full in less than 12 hours'';
                    };
                  }

                  {
                    alert = "InstanceLowMem";
                    expr = "node_memory_MemAvailable_bytes / 1024 / 1024 < node_memory_MemTotal_bytes / 1024 / 1024 / 10";
                    for = "3m";
                    labels.severity = "page";
                    annotations = {
                      description = "Less than 10% of free memory";
                      summary = "Instance {{ $labels.instance }}: {{ $value }}MB of free memory";
                      value = "{{ $value }}";
                    };
                  }

                  {
                    alert = "ServiceFailed";
                    expr = ''node_systemd_unit_state{state="failed"} > 0'';
                    for = "2m";
                    labels.severity = "page";
                    annotations = {
                      description = "A systemd unit went into failed state";
                      summary = "Instance {{ $labels.instance }}: Service {{ $labels.name }} failed";
                      value = "{{ $labels.name }}";
                    };
                  }
                  {
                    alert = "ServiceFlapping";
                    expr = ''changes(node_systemd_unit_state{state="failed"}[5m])
                > 5 or (changes(node_systemd_unit_state{state="failed"}[1h]) > 15
                unless changes(node_systemd_unit_state{state="failed"}[30m]) < 7)
              '';
                    labels.severity = "page";
                    annotations = {
                      description = "A systemd service changed its state more than 5x/5min or 15x/1h";
                      summary = "Instance {{ $labels.instance }}: Service {{ $labels.name }} is flapping";
                      value = "{{ $labels.name }}";
                    };
                  }
                ];
              }
            ];
          }
        )
      ];
      alertmanager = {
        enable = true;
        listenAddress = "localhost";
        configuration = {
          route.receiver = "email";
          global = {
            smtp_smarthost = "localhost:25";
            smtp_from = "alertmanager@${cfg.domain}";
          };
          receivers = [
            {
              name = "email";
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
