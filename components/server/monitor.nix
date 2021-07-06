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
      domain = "monitor.govanify.com";
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
      };
      scrapeConfigs = [
        {
          job_name = "system";
          static_configs = [{
            targets = [ "127.0.0.1:9002" ];
          }];
        }
      ];
    };
  };
}
