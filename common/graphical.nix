{ config, lib, pkgs, ... }: {
  services.redshift = {
    enable = true;
    package = pkgs.redshift-wlr;
  };

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  environment.systemPackages = with pkgs; [
    wineWowPackages.full
    # multimedia
    mpv imv 
    # reading
    calibre okular kcc
    # art
    blender krita kdenlive 
    ardour
    # stem
    #freecad 
    kicad wireshark pandoc limesuite
    # sourcetrail
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
    #ghidra in the future when it is actually updated
    # math stuff
    coq lean elan 
    # ELECTRON BELOW
    # you should try to run with GDK_BACKEND=x11
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

  programs.wireshark.enable = true;

  navi.components.hardening.scudo = false;
  navi.components.headfull.graphical = {
    vte.enable = true;
    browser.enable = true;
    splash.enable = true;
    wm.enable = true;
  };
}
