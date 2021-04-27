{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.splash;
  breeze-navi = pkgs.breeze-plymouth.override {
    logoFile = config.boot.plymouth.logo;
    logoName = config.navi.branding;
    osName = "";
    osVersion = "";
  };
in
{
  options.navi.components.splash = {
    enable = mkEnableOption "Enable navi's boot splash";
  };
  config = mkIf cfg.enable {
    boot.plymouth.enable = true;
    boot.plymouth.logo =
      pkgs.fetchurl {
        url = "https://govanify.com/img/star.png";
        sha256 = "19ij7sn6xax9i7df97i3jmv0nrsl9cvr9p6j9vnq4r4n5n81zq8i";
      };
    boot.plymouth.themePackages = [ breeze-navi ];
    security.wrappers = {
      plymouth-quit.source =
        (
          pkgs.writeScriptBin "plymouth-quit" ''
            #!${pkgs.bash}/bin/bash -p
            ${pkgs.systemd}/bin/systemctl start plymouth-quit.service
          ''
        ).outPath + "/bin/plymouth-quit";
    };
    systemd.services.systemd-ask-password-plymouth.enable = lib.mkForce false;
    systemd.paths.systemd-ask-password-plymouth.enable = lib.mkForce false;
    # XXX: for some reason shellInit isn't called by plymouth which never starts
    # the user target, hmmm -- govanify
    #systemd.services.plymouth-quit-wait.enable = lib.mkForce false;
    #systemd.services.plymouth-quit.wantedBy = lib.mkForce [  ];
  };
}
