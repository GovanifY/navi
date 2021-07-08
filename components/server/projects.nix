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
    disableRegistration = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to disable or not registration. The first user
        to register will be set to admin.
      '';
    };
    disableHooks = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to disable or not git hooks.
        /!\ USERS WHO HAVE ACCESS TO GIT HOOKS EFFECTIVELY
        HAVE ACE ON THE USER RUNNING BEHIND THIS APP, DO 
        _NOT_ GIVE THE PERM TO ANYONE ELSE BUT THE SERVER
        ADMIN.'';
    };
  };

  config = mkIf cfg.enable {
    users.users.git = {
      useDefaultShell = true;
      home = "/var/lib/gitea";
      group = "gitea";
    };
    users.extraGroups = [ "gitea" ];

    services.gitea = {
      enable = true;
      appName = "projects";
      user = "git";
      database = {
        type = "postgres";
        user = "git";
      };
      cookieSecure = true;
      domain = "${cfg.domain}";
      rootUrl = "https://${cfg.domain}/";
      httpPort = 3001;
      disableRegistration = cfg.registration;
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
          [ui]
          DEFAULT_THEME = arc-green
          [repository.upload]
          ALLOWED_TYPES = */*
          [attachment]
          ALLOWED_TYPES = */*
          [picture]
          DISABLE_GRAVATAR        = true
          ENABLE_FEDERATED_AVATAR = false
          [openid]
          ENABLE_OPENID_SIGNIN = false 
          ENABLE_OPENID_SIGNUP = false
          [security]
          DISABLE_GIT_HOOKS = ${cfg.disableHooks}
        '';
    };

    services.nginx.virtualHosts = {
      virtualHosts."${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://[::1]:3001/";
      };
    };
  };
}
