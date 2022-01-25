{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.navi.profile.graphical {

    navi.profile.headfull = true;

    # scudo breaks everything on a graphical setup, eg firefox can't even
    # launch, so this is out of the question.
    navi.components.hardening.scudo = false;

    # use networkmanager by default on graphical setups; makes life easier
    networking.networkmanager.enable = true;

    navi.components = {
      bootloader.verbose = false;
      vte.enable = true;
      browser.enable = true;
      # userspace takes ~2s to boot with the standard configuration, enabling a
      # splash with this much time to wait just doesn't make sense, so let's
      # disable it until our boot time stops being so blazingly fast :)
      #splash.enable = true;
      wm.enable = true;
      chat.graphical = true;
    };
  };
}
