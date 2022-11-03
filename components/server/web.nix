{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.web-server;

  git_paths_bringup = mkIf (cfg.domains != null) (concatStrings (
    mapAttrsToList
      (name: attr: optionalString (attr.git.user != null) ''
        if [[ ! -d "/home/${attr.git.user}/${name}.git/" ]]
        then
            ${pkgs.git}/bin/git init --bare /home/${attr.git.user}/${name}.git/
            ${pkgs.git}/bin/git clone -l /home/${attr.git.user}/${name}.git/ /var/www/${name}
            cat > /home/${attr.git.user}/${name}.git/hooks/post-receive <<EOF
        #!/bin/sh
        GIT_WORK_TREE=/var/www/${name} ${pkgs.git}/bin/git checkout -f
        EOF
            chmod +x /home/${attr.git.user}/${name}.git/hooks/post-receive
            chown ${attr.git.user}:users -R /home/${attr.git.user}/${name}.git/
            chown ${attr.git.user}:users -R /var/www/${name}
            chmod a+r /var/www/${name}
        fi
      '')
      cfg.domains));

  virtualhosts = mkIf (cfg.domains != null) (mapAttrs'
    (name: attr: (lib.nameValuePair
      "${name}"
      {
        forceSSL = attr.tls;
        enableACME = attr.tls;
        root =
          if (attr.static || (attr.git.user != null)) then
            (if attr.root == null then
              "/var/www/${name}" else attr.root) else null;
        locations =
          if (attr.return != null) then {
            "/".return =
              attr.return;
            "/.git/".return = "404";
          } else { "/.git/".return = "404"; };
        default = attr.default;
      }))
    cfg.domains);

  git_users = mkIf (cfg.domains != null) (mapAttrs'
    (name: attr: (if (attr.git.user != null) then
      (lib.nameValuePair
        "${attr.git.user}"
        {
          isNormalUser = true;
          openssh.authorizedKeys.keyFiles = attr.git.keys;
          # we already have set the main username's data, as such nix won't fail
          # in a weird fashion trying to create a blank user! Probably a better
          # way to do this but nix syntax is _so_ obtuse sometimes
        }) else lib.nameValuePair "${config.navi.username}" { }))
    cfg.domains);

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
    domains = mkOption {
      type = types.nullOr (types.attrsOf (types.submodule ({ url, ... }: {
        options = {
          url = mkOption {
            type = types.str;
            example = "example.com";
            description = "The url of the domain.";
          };
          root = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "/var/www/example.com";
            description = "The root folder of the domain, if static.";
          };
          static = mkOption {
            type = types.bool;
            default = false;
            description = "Whether or not to build a static website.";
          };
          tls = mkOption {
            type = types.bool;
            default = true;
            description = "Whether or not tls should be forced for this domain.";
          };
          return = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Return code that this domain should return. Useful for maintenance.";
          };
          default = mkOption {
            type = types.bool;
            default = false;
            description = "Sets the default domain to show when no correct domain name is given.";
          };
          git = {
            user = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "govanify";
              description = ''
                The username to use to manage the git website.
                Setting this will toggle a git based versionning system for static websites.
                If you toggle this option, you will be able to update your prod
                website by pushing to the following git path:
                user@example.com:~/domain.git
              '';
            };
            keys = mkOption {
              type = types.nullOr (types.listOf types.path);
              default = null;
              description = "The ssh public key allowed to manage remotely the website.";
            };
          };
        };
      })));
      default = null;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    security.acme.acceptTerms = true;
    security.acme.defaults.email = cfg.email;
    services.nginx = {
      enable = true;
      statusPage = config.navi.components.monitor.enable;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    services.nginx.virtualHosts = virtualhosts;
    users.users = git_users;
    # automatically setups the git repositories and /var/www perms, with
    # an automatic git fetch hook. Ready to push!
    systemd.services.make-git-paths = {
      script = git_paths_bringup;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
