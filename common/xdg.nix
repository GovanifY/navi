# TODO: currently non compliant to XDG in default config are: 
# * mozilla (in progress upstream hopefully)
# * nix old folders, yuuuuup, i should make a PR

# TODO: dbus esd_auth gets removed each time you start a new shell, should be done
# upon user login along with swaystart
# * steam: done BUT need to start through startsteam, might want to modify
# that(ie modify desktop file)

{ config, pkgs, ... }: {
  # ssh devs don't want to make ssh XDG compliant? well let's roll our own
  # compliance!
  nixpkgs.config.packageOverrides = pkgs: {
    openssh = pkgs.openssh.overrideAttrs (oldAttrs: rec {
      postPatch = oldAttrs.postPatch + ''
          sed -i 's/\.ssh/\.config\/ssh/' $(grep -Rl '"\.ssh"')
      '';
    });

    # https://github.com/google/mozc/issues/474
    # hopefully temporary
    ibus-mozc = pkgs.ibus-mozc.overrideAttrs (oldAttrs: rec {
      postPatch = oldAttrs.postPatch + ''
          sed -i 's/\.mozc/\.config\/mozc/' $(grep -Rl '"\.mozc"')
      '';
    });

    # rarely created on my setup, seems to be x11 related? either way here we go
    dbus = pkgs.dbus.overrideAttrs (oldAttrs: rec {
      postPatch = oldAttrs.postPatch + ''
          sed -i 's/\.dbus/\.config\/dbus/' $(grep -Rl '"\.dbus"')
      '';
    });

    pulseaudio = pkgs.pulseaudio.overrideAttrs (oldAttrs: rec {
      postPatch = oldAttrs.postPatch + ''
          sed -i 's/\.esd_auth/\.config\/esd_auth/' $(grep -Rl '"\.esd_auth"')
      '';
    });

  };

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    LESSKEY = "$XDG_CONFIG_HOME/less/lesskey";
    LESSHISTFILE = "-";
    ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";
    WINEPREFIX = "$XDG_DATA_HOME/wineprefixes/default";
    # does not parse it correctly for some reason
    WEECHAT_HOME = "~/.config/weechat";
    GNUPGHOME = "~/.config/gnupg";
    GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
    GEM_HOME = "$XDG_DATA_HOME/gem";
    GEM_SPEC_CACHE = "$XDG_CACHE_HOME/gem";
    # java still store fonts in .java so i use a per-app wrapper
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java";
    WGETRC = "$HOME/.config/wgetrc";
    PYTHONSTARTUP = "$HOME/.config/python/startup.py";
    PASSWORD_STORE_DIR = "$HOME/.config/pass";
    NOTMUCH_CONFIG = "$HOME/.config/notmuch";
  };

  home-manager.users.govanify = {
    home.file.".config/wgetrc".source  = ./../dotfiles/xdg/wgetrc;
    home.file.".config/python/startup.py".source  = ./../dotfiles/xdg/python/startup.py;
  };
}
