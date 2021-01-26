{ config, lib, pkgs, ... }: {
  services.getty.autologinUser = "govanify";
  services.redshift = {
    enable = true;
    package = pkgs.redshift-wlr;
  };

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock # lockscreen
      swayidle
      # legacy apps
      xwayland xorg.xrdb
      wineWowPackages.full
      kanshi # autorandr
      # misc wayland utils
      wofi grim wl-clipboard slurp brightnessctl
      # multimedia
      mpv imv 
      # reading
      calibre okular kcc
      # web browsers
      # standard firefox is used for basically everything and is "impossible" to
      # fingerprint with my configuration, but i do login on websites sometimes.
      # As such tor is used as a clean cut identity that also make sure I didn't
      # fuck up tracking when need happens.
      firefox
      #tor-browser-bundle-bin
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
      # themes
      breeze-gtk breeze-qt5 breeze-icons
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
  };

  programs.wireshark.enable = true;

  fonts.fonts = with pkgs; [
    hack-font
  ];

  # QT theme engine
  programs.qt5ct.enable = true;

  environment.variables = {
    # fix sway java bug
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # QT theme
    QT_QPA_PLATFORMTHEME="qt5ct";
    # force wayland
    QT_QPA_PLATFORM="wayland-egl";
    GDK_BACKEND="wayland";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_THEME = "Breeze-Dark";
  };


  environment.sessionVariables = {
      XCURSOR_PATH = [
        "${config.system.path}/share/icons"
        "$HOME/.nix-profile/share/icons/"
        "$HOME/.local/share/icons/"
        "${pkgs.breeze-qt5}/share/icons/"
      ];
      GTK_DATA_PREFIX = [
        "${config.system.path}"
      ];
  };


  environment = {
    etc = {
      "gtk-2.0/gtkrc" = { text = ''
        gtk-icon-theme-name=breeze-dark
      ''; mode = "444"; };
      "X11/Xresources" = { text = ''
        Xcursor.size: 12 
      ''; mode = "444"; };
    };
  };

  systemd.user.services.swaywm = {
    description = "Sway - Wayland window manager";
    documentation = [ "man:sway(5)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    # We explicitly unset PATH here, as we want it to be set by
    # systemctl --user import-environment in startsway
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.sway}/bin/sway
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  environment.shellInit = ''
    if [[ -z $DISPLAY ]] && [[ "$(whoami)" == "govanify" ]]; then
      if ! systemctl is-active --quiet swaywm; then
        xrdb -load /etc/X11/Xresources &> /dev/null
        systemctl --user import-environment
        systemctl --user start swaywm
      fi
    fi
  '';

  home-manager.users.govanify = {
   # QT theme
   home.file.".config/qt5ct/qt5ct.conf".source  = ./../assets/graphical/qt5ct/qt5ct.conf;
   home.file.".config/qt5ct/colors/breeze-dark.conf".source  = ./../assets/graphical/qt5ct/breeze-dark.conf;

   # GTK theme
   #home.file.".local/share/icons/default".source = "${pkgs.breeze-qt5}/share/icons/breeze_cursors";
   #gtk-icon-theme-name=breeze-dark
   home.file.".config/gtk-3.0/settings.ini".text  = ''
        [Settings]
        gtk-theme-name=Breeze-Dark
        gtk-application-prefer-dark-theme = true
        gtk-cursor-theme-name=breeze_cursors
      ''; 
  };

  navi.components.headfull.graphical = {
    vte.enable = true;
    browser.enable = true;
    splash.enable = true;
  };
}
