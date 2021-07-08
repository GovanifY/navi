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

  #TODO: double check postfix config, gitea config, passwords
  config = mkIf cfg.enable {
    services.gitea = {
      enable = true;
      appName = "projects";
      database = {
        type = "postgres";
        password = "TODO";
      };
      domain = "${cfg.domain}";
      rootUrl = "https://${cfg.domain}/";
      httpPort = 3001;
      extraConfig =
        let
          docutils =
            pkgs.python37.withPackages (ps: with ps; [
              docutils
              pygments
            ]);
        in
        ''
          [mailer]
          ENABLED = true
          FROM = "admin@${cfg.domain}"
          [service]
          REGISTER_EMAIL_CONFIRM = true
          [markup.restructuredtext]
          ENABLED = true
          FILE_EXTENSIONS = .rst
          RENDER_COMMAND = ${docutils}/bin/rst2html.py
          IS_INPUT_FILE = false
          [metrics]
          ENABLED=true
        '';
    };

    services.nginx.virtualHosts = {
      virtualHosts."${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://[::1]:3001/";
      };
    };

    services.postgresql = {
      enable = true;
      authentication = ''
        local gitea all ident map=gitea-users
      '';
      identMap = ''
        gitea-users gitea gitea
      '';
    };
  };
}
