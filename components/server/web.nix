{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.web-server;
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
      type = types.attrsOf (types.submodule ({ url, ... }: {
        options = {
          url = mkOption {
            type = types.str;
            example = "example.com";
            description = "The url of the domain.";
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
          git = mkOption
            {
              default = { };
              description = ''
                Whether to use a git based versionning system for static websites.
                If you toggle this option, you will be able to update your prod
                website by pushing to the following git path:
                user@example.com:~/domain.git
              '';
              user = mkOption {
                type = types.nullOr types.str;
                example = "govanify";
                description = "The username to use to manage the git website.";
              };
              keys = mkOption {
                type = types.nullOr (types.listOf types.path);
                description = "The ssh public key allowed to manage remotely the website.";
              };
              );
              };
              config.url = mkDefault url;
            }));
        };

        config = mkIf cfg.enable {
          networking.firewall.allowedTCPPorts = [ 80 443 ];
          security.acme.acceptTerms = true;
          security.acme.email = cfg.email;
          services.nginx = {
            enable = true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            recommendedProxySettings = true;
            recommendedTlsSettings = true;
          };

          services.nginx.virtualHosts = mapAttrs'
            (domain: attr:
              {
                "${domain}" = {
                  forceSSL = attr.tls;
                  enableACME = attr.tls;
                  root = mkIf (attr.static) "/var/www/${domain}";
                  return = mkIf (attr.return != null) attr.return;
                };
              })
            cfg.domains;


          users.users = mapAttrs'
            (_: attr:
              {
                "${attr.git.user}" = mkIf (attr.git.user != null) {
                  isNormalUser = true;
                  openssh.authorizedKeys.keyFiles = attr.git.keys;
                };
              };
            }) cfg.domains;

          systemd.services.make-git-paths = {
            script = ''
              if [[ ! -d "/home/<user>/<domain.git>/" ]]
              then
                  ${pkgs.git}/bin/git init /home/<user>/<domain.git>/
                  ${pkgs.git}/bin/git clone -l /home/<user>/<domain.git>/ /var/www/<domain>
                  cat <<'EOF' >> /home/<user>/<domain>.git/hooks/post-receive
                  #!/bin/sh
                  GIT_WORK_TREE=/home/<user>/<domain.git>/ ${pkgs.git}/bin/git checkout -f
                  EOF
                  chmod +x /home/<user>/<domain>.git/hooks/post-receive
                  chown <user>:users -R /home/<user>/<domain>.git
                  chown <user>:users -R /home/<user>/<domain>.git /var/www/<domain>
                  chmod a+r /home/<user>/<domain>.git /var/www/<domain>
              fi
            '';
            wantedBy = [ "multi-user.target" ];
          };

        };
      }
