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
    runner_secrets = mkOption {
      type = types.str;
      example = "/some/path";
      description = ''
        File path containing the following variables:
        `CI_SERVER_URL`
        `REGISTRATION_TOKEN`
      '';
    };

  };

  config = mkIf cfg.enable {
    boot.kernel.sysctl."net.ipv4.ip_forward" = true;
    virtualisation.docker.enable = true;
    services.gitlab-runner = {
      enable = true;
      services = {
        nix = with lib;{
          registrationConfigFile = cfg.runner_secrets;
          dockerImage = "alpine";
          dockerVolumes = [
            "/nix/store:/nix/store:ro"
            "/nix/var/nix/db:/nix/var/nix/db:ro"
            "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
          ];
          dockerDisableCache = true;
          preBuildScript = pkgs.writeScript "setup-container" ''
            mkdir -p -m 0755 /nix/var/log/nix/drvs
            mkdir -p -m 0755 /nix/var/nix/gcroots
            mkdir -p -m 0755 /nix/var/nix/profiles
            mkdir -p -m 0755 /nix/var/nix/temproots
            mkdir -p -m 0755 /nix/var/nix/userpool
            mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
            mkdir -p -m 1777 /nix/var/nix/profiles/per-user
            mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
            mkdir -p -m 0700 "$HOME/.nix-defexpr"
            . ${pkgs.nix}/etc/profile.d/nix-daemon.sh
            ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-20.09 nixpkgs # 3
            ${pkgs.nix}/bin/nix-channel --update nixpkgs
            ${pkgs.nix}/bin/nix-env -i ${concatStringsSep " " (with pkgs; [ nix cacert git openssh ])}
          '';
          environmentVariables = {
            ENV = "/etc/profile";
            USER = "root";
            NIX_REMOTE = "daemon";
            PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
            NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
          };
          tagList = [ "nix" ];
        };
      };
    };

    services.gitlab = {
      enable = true;
      host = cfg.domain;
      port = 443;
      https = true;
      smtp.enable = true;
    };

    services.nginx = {
      clientMaxBodySize = "5000m";
      virtualHosts = {
        "${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
        };
      };
    };
  };
}
