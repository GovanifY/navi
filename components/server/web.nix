{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.web-server;

  gitUsers = optionals (cfg.domains != null) (unique (filter (u: u != null)
    (mapAttrsToList (name: attr: attr.git.user) cfg.domains)));
  gitDomains = optionals (cfg.domains != null)
    (filter (attr: attr.git.user != null) (attrValues cfg.domains));

  webRoot = name: attr: if attr.root == null then "/var/www/${name}" else attr.root;

  # deploy only: every key is forced into a write-only rsync of its web root
  deployKeys = name: attr: map
    (key: ''restrict,command="${pkgs.rrsync}/bin/rrsync -wo ${webRoot name attr}" ${key}'')
    (concatMap (f: filter (l: l != "" && !hasPrefix "#" l) (splitString "\n" (readFile f)))
      attr.git.keys);

  git_paths_bringup = mkIf (cfg.domains != null) (concatStrings (
    mapAttrsToList
      (name: attr: optionalString (attr.git.user != null) ''
        if [[ ! -d "${webRoot name attr}" ]]
        then
            mkdir -p ${webRoot name attr}
            chown ${attr.git.user}:users ${webRoot name attr}
            chmod 755 ${webRoot name attr}
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
            webRoot name attr else null;
        locations =
          (if (attr.return != null) then {
            "/".return =
              attr.return;
            "/.git/".return = "404";
          } else { "/.git/".return = "404"; }) //
          (if (attr.php) then {
            "~ \.php$".extraConfig = ''
              fastcgi_pass  unix:${config.services.phpfpm.pools.mypool.socket};
              fastcgi_index index.php;
            '';
            "/".index = "index.php";
          } else { });
        default = attr.default;
      }))
    cfg.domains);

  git_users = mkIf (cfg.domains != null) (mapAttrs'
    (name: attr: (if (attr.git.user != null) then
      (lib.nameValuePair
        "${attr.git.user}"
        {
          isNormalUser = true;
          # sshd runs even forced commands through the login shell, so it has
          # to be a real one; the keys below are what restrict the user
          shell = pkgs.bashInteractive;
          openssh.authorizedKeys.keys = deployKeys name attr;
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
    php = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable the php services.
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
          php = mkOption {
            type = types.bool;
            default = false;
            description = "Whether or not to enable PHP for this website.";
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
                The username to use to deploy the website.
                Setting this creates a deploy-only user for this domain: its
                keys can only rsync into the web root, which is the target's
                root directory, e.g.
                rsync -a --delete public/ user@example.com:
              '';
            };
            keys = mkOption {
              type = types.nullOr (types.listOf types.path);
              default = null;
              description = "The ssh public keys allowed to deploy the website.";
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
    # its own user, not nobody which other services may share
    users.groups.php-web = mkIf cfg.php { };
    # the master is root to start the workers as php-web
    navi.components.sandboxing.units.phpfpm-mypool = mkIf cfg.php {
      CapabilityBoundingSet = [ "CAP_SETUID" "CAP_SETGID" "CAP_CHOWN" "CAP_KILL" ];
    };
    services.phpfpm.pools.mypool = mkIf cfg.php {
      user = "php-web";
      group = "php-web";
      settings = {
        "pm" = "dynamic";
        "listen.owner" = config.services.nginx.user;
        "pm.max_children" = 100;
        "pm.start_servers" = 15;
        "pm.min_spare_servers" = 10;
        "pm.max_spare_servers" = 30;
        "pm.max_requests" = 500;
      };
    };
    services.nginx.virtualHosts = virtualhosts;
    users.users = mkMerge [
      git_users
      (mkIf cfg.php { php-web = { isSystemUser = true; group = "php-web"; }; })
    ];
    # one forced command per user, so a deploy user cannot span two web roots
    assertions = [{
      assertion = length gitUsers == length gitDomains;
      message = "navi.components.web-server: each git.user must deploy a single domain";
    }];
    # no forwarding to localhost services, no ~/.ssh/rc (run by /bin/sh
    # whatever the login shell) and no keys added in the home directory
    services.openssh.extraConfig = mkIf (gitUsers != [ ]) (mkAfter ''
      Match User ${concatStringsSep "," gitUsers}
        AllowTcpForwarding no
        AllowStreamLocalForwarding no
        AllowAgentForwarding no
        X11Forwarding no
        PermitTunnel no
        PermitTTY no
        PermitUserRC no
        AuthorizedKeysFile /etc/ssh/authorized_keys.d/%u
      Match all
    '');
    # creates the web roots owned by their deploy user. Ready to rsync!
    systemd.services.make-git-paths = {
      script = git_paths_bringup;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
