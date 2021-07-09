{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.mail-server;
  cert = config.security.acme.certs."${cfg.root_domain}".directory;
in
{
  imports = [
    <nixos-mailserver>
  ];

  options.navi.components.mail-server = {
    enable = mkEnableOption "Enable navi's mail server";
    #inherit (options.mailserver) loginAccounts;
    domains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        The domains this mailserver should serve.
      '';
    };
    root_domain = mkOption {
      type = types.str;
      default = "";
      description = ''
        The root domain this server will identify itself as when
        sending and receiving mails.
      '';
    };
  };

  config = mkIf cfg.enable {
    mailserver = {
      enable = true;
      fqdn = cfg.root_domain;
      domains = cfg.domains;
      certificateScheme = 1;
      certificateFile = "${cert}/fullchain.pem";
      keyFile = "${cert}/key.pem";
      dkimSelector = config.navi.device;
      dkimKeyBits = 2048;
      #loginAccounts = cfg.accounts;
    };
    navi.components.web-server = {
      enable = true;
      # this server is a stub that we still need to setup for acme, so we just
      # make it stay up whenever and return a nice error code :)
      domains."${cfg.root_domain}".return = "418";
    };
  };
}
