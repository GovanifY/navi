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
      wofi grim wl-clipboard firefox-wayland
      mpv imv slurp 
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
      "sway/status.sh".source = ./../dotfiles/sway/status.sh;
    };
  };
  # soooo we have all of those nice systemd services below but NONE OF THEM
  # ACTUALLY WORKS for a reason that is beyond me. I'm as confused as you are,
  # so let's just keep it this way shall we? worst case scenario i login into
  # another shell
  environment.interactiveShellInit = ''
    if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
      exec sway
    fi
    '';

}
