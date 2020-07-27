{ config, lib, pkgs, ... }: {
  imports = [ ./../pkgs/termite.nix ];
  services.mingetty.autologinUser = "govanify";

  # firefox no segfaulty
  xdg.portal.enable = false;


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
      wofi grim wl-clipboard slurp 
      # multimedia
      mpv imv 
      # reading
      #calibre 
      okular kcc
      # web browsers
      # standard firefox is used for basically everything and is "impossible" to
      # fingerprint with my configuration, but i do login on websites sometimes.
      # As such tor is used as a clean cut identity that also make sure I didn't
      # fuck up tracking when need happens.
      firefox-wayland 
      #tor-browser-bundle-bin
      #firefox-bin
      # art
      blender krita kdenlive ardour
      # stem
      freecad kicad wireshark sourcetrail
      # recording/streaming
      obs-studio obs-wlrobs

      jdk11 
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
      # ELECTRON BELOW
      # you should try to run with GDK_BACKEND=x11
      # this is good for lean
      vscodium lean elan
      (
      pkgs.writeTextFile {
        name = "vscodium-x11";
        destination = "/bin/vscodium-x11";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash
          # Electron sucks
          GDK_BACKEND=x11
          # then start the launcher 
          exec codium
        '';
      }
      )
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

  # firefox security notes:
  #
  # firefox should sync to your own server whatever you care(it's E2EE,
  # personally i use it to keep a consistant set of tabs between devices)
  # and to make tracking a whole lot harder you should:
  # 1. route all your traffic through tor, hides you from your local ISP/state
  # 2. use those extensions to mitigate website-side tracking as much as
  # possible:
  #
  # * Forget Me Not with autodelete enabled
  # * decentraleyes (not necessary but neat)
  # * NoScript with a whitelist setup of javascript enabled websites
  # * Privacy Badger |
  #                  |--> not necessary with noScript but sane defaults
  # * uBlock origin  | 
  # * HTTPS Everywhere, just in case
  # 3. Make sure to use those settings in about:config:
  # * privacy.resistFingerprinting = true
  # * privacy.firstparty.isolate = true
  # * app.normandy.enabled = false 
  # -------------------------------------------
  #            ONION DNS RELATED
  # -------------------------------------------
  # * dom.securecontext.whitelist_onions = true
  # * network.dns.blockDotOnion = false
  # * network.http.referer.hideOnionSource = true
  #
  # this way the only identifiable information websites should be able to gather
  # is the one you give to them by, ie, logging in, as everything else  
  # is non unique assuming noScript is
  # enabled and tor runs, so your tracking ID should change.
  #
  # also simple tab groups and stylus are nice cosmetic additions
  #
  # this way when disabling javascript, done by default, you have as much
  # privacy as Tor Browser while still keeping some possibly wanted features(ie
  # WebGL) when enabling it, along with Firefox fingerprint blockers by default, 
  # allowing for a good compromise. 
  # Definitely not as secure as the Tor Browser for very specific cases(ie
  # custom made fingerprint engine that works around firefox blocker and
  # javascript enabled) but good enough for 99% of standard usage, just take
  # care about javascript usage!
  #
  # Another thing to note but TBB is still able to be somewhat fingerprinted by
  # checking for things such as the screen size, to a lesser degree than this
  # though. For this specific example they round the screen size to the nearest
  # 200x100, a feature called letterboxing, but this is definitely an unwanted
  # feature for a day-to-day browser. The entire JavaScript engine leaks too
  # much data and has never been thought out with security in mind and it shows.


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
  };

  environment.sessionVariables = {
      XCURSOR_PATH = [
        "${config.system.path}/share/icons"
        "$HOME/.icons"
        "$HOME/.nix-profile/share/icons/"
      ];
      GTK_DATA_PREFIX = [
        "${config.system.path}"
      ];
  };


  environment = {
    etc = {
      # GTK theme
      "xdg/gtk-3.0/settings.ini" = { text = ''
        [Settings]
        gtk-icon-theme-name=breeze-dark
        gtk-theme-name=Breeze-Dark
        gtk-application-prefer-dark-theme = true
        gtk-cursor-theme-name=breeze_cursors
      ''; mode = "444"; };
      
      "gtk-2.0/gtkrc" = { text = ''
        gtk-icon-theme-name=breeze-dark
      ''; mode = "444"; };
      "X11/Xresources" = { text = ''
        Xcursor.size: 12 
      ''; mode = "444"; };

    };
  };

  # the gpg thing should be done in headfull but we need to do that before it
  # execs sway because sway obviously never returns
  environment.interactiveShellInit = ''
    if [ ! -f ~/.config/gnupg/trustdb.gpg ] && [[ $(tty) = /dev/tty1 ]]; then
      # let's just put the entire first time setup here
      find ~/.config/gnupg -type f -exec chmod 600 {} \;
      find ~/.config/gnupg -type d -exec chmod 700 {} \;
      gpg --import ~/.config/gnupg/key.gpg                                       
      gpg --import-ownertrust ~/.config/gnupg/trust.txt 
      mkdir -p ~/.local/share/mail/ &> /dev/null
      mkdir -p ~/.cache/mutt/ &> /dev/null
      mkdir -p ~/.local/share/wineprefixes/ &> /dev/null
      mkdir -p ~/.config/gdb &> /dev/null
      mkdir -p ~/.local/share/wineprefixes/default &> /dev/null 
      touch ~/.config/gdb/init &> /dev/null
    fi
    if [ ! -d ~/.config/pass ] && [[ $(tty) = /dev/tty1 ]]; then
      # we try to clone user passwords, network might not be started or
      # unreliable yet so we just try to clone until it works
      ~/.cache/clone-pass.sh &
    fi
    if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]] && [[ $EUID -ne 0 ]]; then
      xrdb -load /etc/X11/Xresources &> /dev/null
      exec sway
    fi
  '';

  home-manager.users.govanify = {
    # initial pass setup
    # should i make this global?
    home.file.".cache/hello.sh".source  = ./../dotfiles/clone-pass.sh;

   # QT theme
   home.file.".config/qt5ct/qt5ct.conf".source  = ./../dotfiles/graphical/qt5ct/qt5ct.conf;
   home.file.".config/qt5ct/colors/breeze-dark.conf".source  = ./../dotfiles/graphical/qt5ct/breeze-dark.conf;

   home.file.".config/sway/config".source = ./../dotfiles/graphical/sway/config;
   home.file.".config/sway/locale.sh".source = ./../dotfiles/graphical/sway/locale.sh;
   home.file.".config/sway/status.sh".source = ./../dotfiles/graphical/sway/status.sh;


  };
}
