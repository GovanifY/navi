{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.navi.profile.graphical {

    navi.profile.headfull = true;

    # use networkmanager by default on graphical setups; makes life easier
    networking.networkmanager.enable = true;

    # let's disable navi stuff on firefox until i have the time to mess around
    # with it
    environment.variables.BROWSER = "firefox";
    environment.systemPackages = [ pkgs.firefox ];
    navi.components = {
      bootloader.verbose = false;
      vte.enable = true;
      # 
      #browser.enable = true;
      # userspace takes ~2s to boot with the standard configuration, enabling a
      # splash with this much time to wait just doesn't make sense, so let's
      # disable it until our boot time stops being so blazingly fast :)
      #splash.enable = true;
      # experimenting with alternate wm
      #wm.enable = true;
      wm.enable = false;
      chat.graphical = true;
      ime.enable = true;
    };

    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        autoLogin = {
          enable = true;
          user = "${config.navi.username}";
        };
      };
    };
    programs.dconf.enable = true;
    environment.sessionVariables = {
      NIX_PROFILES = "${pkgs.lib.concatStringsSep " " (pkgs.lib.reverseList config.environment.profiles)}";
    };
    programs.kdeconnect.enable = true;
    programs.partition-manager.enable = true;

  };
}
