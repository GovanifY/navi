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
      wofi grim wl-clipboard firefox
      mpv imv slurp 
    ];
  };

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
