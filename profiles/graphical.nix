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
    programs.firefox.enable = true;
    navi.components = {
      bootloader.verbose = false;
      vte.enable = true;
      # 
      #browser.enable = true;
      # userspace takes ~2s to boot with the standard configuration, enabling a
      # splash with this much time to wait just doesn't make sense, so let's
      # disable it until our boot time stops being so blazingly fast :)
      #splash.enable = true;
      wm.gnome.enable = true;
      chat.graphical = true;
      ime.enable = true;
    };

    programs.dconf.enable = true;
    environment.sessionVariables = {
      NIX_PROFILES = "${pkgs.lib.concatStringsSep " " (pkgs.lib.reverseList config.environment.profiles)}";
      NIXOS_OZONE_WL = "1";
    };

    # allow by default, to be configured by the end user or DE
    services.usbguard = {
      enable = true;
      dbus.enable = true;
      implicitPolicyTarget = "allow";
    };
  };
}
