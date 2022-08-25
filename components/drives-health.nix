{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.drives-health;
  # we filter through the accounts attrSet, only retrieve the primary account
  # and convert it to a string
  email-as-user = pkgs.writeShellScript "email-as-user" (''
    ${pkgs.sudo}/bin/sudo ${pkgs.shadow.su}/bin/su ${config.navi.username} -c "msmtp -a'' +
  (concatStringsSep "" (mapAttrsToList
    (name: account:
      optionalString (account.primary) " ${name} ")
    config.navi.components.mail.accounts)) + "$*\"");
in
{
  options.navi.components.drives-health = {
    enable = mkEnableOption "Enable navi's drives monitoring";
    email = mkOption {
      type = types.str;
      default = false;
      description = ''
        The notification email address to send out warnings to.
      '';
    };
    user = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to use navi's builtin user email client.
      '';
    };
    btrfs = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable regular btrfs scrubs.
      '';
    };
  };

  config = mkIf cfg.enable {
    services = {
      smartd = {
        notifications.mail = {
          enable = true;
          mailer = mkIf cfg.user email-as-user;
          recipient = cfg.email;
          sender = cfg.email;
        };
        enable = true;
      };
      # this doesn't notify you but repairs small errors. It is assumed SMART
      # will log an error during the scrub if something goes wrong. If it
      # doesn't, well, I can't recommend you enough to get a reliable drive.
      btrfs.autoScrub.enable = mkIf cfg.btrfs true;
    };
  };
}
