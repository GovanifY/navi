{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.navi.profile.graphical {

    navi.profile.headfull = true;

    # needed to export obs as a virtual camera
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    # make obs work with wayland + virtual camera module
    home-manager.users.${config.navi.username} = {
      programs.obs-studio = {
        enable = true;
        plugins = [ pkgs.obs-wlrobs pkgs.obs-v4l2sink ];
      };
    };

    environment.systemPackages = with pkgs; [
      # legacy windows
      wineWowPackages.full

      # multimedia
      mpv
      imv

      # reading
      calibre
      okular
      kcc

      # art
      blender
      krita
      kdenlive
      ardour

      # stem
      kicad
      wireshark
      pandoc
      limesuite
      ghidra-bin
      #freecad sourcetrail

      # recording/streaming
      obs-studio
      obs-wlrobs
      obs-v4l2sink

      jdk
      android-studio
      (
        pkgs.writeTextFile {
          name = "startandroid";
          destination = "/bin/startandroid";
          executable = true;
          text = ''
            #! ${pkgs.bash}/bin/bash
            # Java sucks
            export QT_QPA_PLATFORM=xcb
            export GDK_BACKEND=xcb
            mkdir -p $XDG_DATA_HOME/android-home
            export HOME=$XDG_DATA_HOME/android-home
            # then start the launcher 
            exec android-studio 
          '';
        }
      )

      # math
      coq
      lean
      elan

    ];

    # give you the rights to inspect traffic as this is a single user box/not a
    # server, android funsies and realtime audio access for ardour and jack
    programs.wireshark.enable = true;
    programs.adb.enable = true;
    users.users.${config.navi.username} = {
      extraGroups = [ "wireshark" "adbusers" "audio" ];
    };

    # scudo breaks everything on a graphical setup, eg firefox can't even
    # launch, so this is out of the question.
    navi.components.hardening.scudo = false;

    navi.components = {
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
