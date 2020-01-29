{ config, pkgs, lib, ... }: {

  imports = [ ./../pkgs/termite.nix ];
  services.mingetty.autologinUser = "govanify";

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock # lockscreen
      swayidle
      xwayland # for legacy apps
      kanshi # autorandr
      # misc wayland utils
      wofi grim wl-clipboard slurp 
      # multimedia
      mpv imv 
      # web browsers
      firefox-wayland tor-browser-bundle-bin
      # art
      blender krita kdenlive ardour
      # stem
      freecad kicad 
      #ghidra in the future when it is actually updated
      # themes
      breeze-gtk breeze-qt5 breeze-icons
    ];
  };

  # firefox security notes:
  #
  # firefox should sync to your own server whatever you care(it's E2EE,
  # personally i use it to keep a consistant set of tabs between devices)
  # and to make tracking a whole lot harder you should:
  # 1. route all your traffic through tor, hides you from your local ISP/state
  # 2. use those extensions to mitigate website-side tracking as much as
  # possible:
  #
  # * cookie autodelete with autodelete enabled
  # * decentraleyes (not necessary but neat)
  # * NoScript with a whitelist setup of javascript enabled websites
  # * Privacy Badger |
  #                  |--> not necessary with noScript but sane defaults
  # * uBlock origin  | 
  # * user agent switcher with random switch enabled
  #
  # this way the only identifiable information websites should be able to gather
  # is the one you give to them by, ie, logging in, as the only identifiable and
  # non randomized string left is your accept_html, which gives out your
  # language basically, everything else is randomized assuming noScript is
  # enabled and tor runs, so your tracking ID should change.
  #
  # also simple tab groups and stylus are nice cosmetic additions


  fonts.fonts = with pkgs; [
    hack-font
  ];

  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };


  environment = {
    etc = {
      # Put config files in /etc. Note that you also can put these in ~/.config, but then you can't manage them with NixOS anymore!
      "sway/config".source = ./../dotfiles/sway/config;
      "sway/locale.sh".source = ./../dotfiles/sway/locale.sh;
      "sway/status.sh".source = ./../dotfiles/sway/status.sh;
    };
  };
  # soooo we have all of those nice systemd services below but NONE OF THEM
  # ACTUALLY WORKS for a reason that is beyond me. I'm as confused as you are,
  # so let's just keep it this way shall we? worst case scenario i login into
  # another shell

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
      touch ~/.config/gdb/init &> /dev/null
    fi
    if [ ! -d ~/.config/pass ] && [[ $(tty) = /dev/tty1 ]]; then
      # we try to clone user passwords, network might not be started or
      # unreliable yet so we just try to clone until it works
      ~/.cache/clone-pass.sh &
    fi
    if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
      exec sway
    fi
  '';

  home-manager.users.govanify = {
    home.file.".cache/clone-pass.sh".source  = ./../dotfiles/clone-pass.sh;
  };

  environment.extraInit = ''
        # GTK3: add theme to search path for themes
        export XDG_DATA_DIRS="${pkgs.breeze-gtk}/share:$XDG_DATA_DIRS"
        # GTK3: add /etc/xdg/gtk-3.0 to search path for settings.ini
        export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"
        # GTK2 theme + icon theme
        export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="breeze"''}:$GTK2_RC_FILES
        # QT theme
        export QT_STYLE_OVERRIDE=breeze
        '';

  environment.etc."xdg/gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-icon-theme-name=breeze
      gtk-theme-name=Breeze-Dark
      gtk-application-prefer-dark-theme = true
    '';
    mode = "444";
  };

  environment.etc."gtk-2.0/gtkrc" = {
    text = ''
      gtk-icon-theme-name=breezewwweeew
    '';
    mode = "444";
  };
}
