{ config, lib, pkgs, ... }: {
  config = mkIf (config.navi.profile.graphical) {

    # don't want to become blind
    services.redshift = {
      enable = true;
      package = pkgs.redshift-wlr;
    };

    # needed to export obs as a virtual camera
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    # make obs work with wayland + virtual camera module
    home-manager.users.${navi.username} = {
       programs.obs-studio = {
         enable = true;
         plugins = [ pkgs.obs-wlrobs pkgs.obs-v4l2sink ];
       };
    };

    environment.systemPackages = with pkgs; [
      # legacy windows
      wineWowPackages.full

      # multimedia
      mpv imv 

      # reading
      calibre okular kcc

      # art
      blender krita kdenlive ardour

      # stem
      kicad wireshark pandoc limesuite ghidra
      #freecad sourcetrail

      # recording/streaming
      obs-studio obs-wlrobs obs-v4l2sink

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
      coq lean elan 

      # matrix
      element-desktop
      (
      pkgs.writeTextFile {
        name = "element-x11";
        destination = "/bin/element-x11";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash
          # Electron sucks
          GDK_BACKEND=x11
          # then start the launcher 
          exec element-desktop
        '';
      }
      )
    ];

    # give you the rights to inspect traffic as this is a single user box/not a
    # server, android funsies and realtime audio access for ardour and jack
    programs.wireshark.enable = true;
    users.users.${navi.username} = {
      extraGroups = [ "wireshark" "adbusers" "audio" ]; 
    };

    # scudo breaks everything on a graphical setup, eg firefox can't even
    # launch, so this is out of the question.
    navi.components.hardening.scudo = false;

    navi.components.headfull.graphical = {
      vte.enable = true;
      browser.enable = true;
      splash.enable = true;
      wm.enable = true;
    };
  };
}
