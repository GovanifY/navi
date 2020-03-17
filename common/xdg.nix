# TODO: currently non compliant to XDG in default config are: 
# * nix old folders, yuuuuup, i should make a PR

# TODO: steam: done BUT need to start through startsteam, might want to modify
# that(ie modify desktop file)
# java: need to make a system wrapper like steam up above

# need to verify: dbus, doesn't appear on my system and breaks nixos build
# anyways
# firefox: doesn't seem to work?
{ config, pkgs, ... }: {
  # ssh devs don't want to make ssh XDG compliant? well let's roll our own
  # compliance!
  nixpkgs.config = {
    packageOverrides = super: let self = super.pkgs; in {
      openssh = super.openssh.overrideAttrs (oldAttrs: rec {
        postPatch = oldAttrs.postPatch + ''
          sed -i 's/"\.ssh"/"\.config\/ssh"/' $(grep -Rl '"\.ssh"')
        '';
      });

    # https://github.com/google/mozc/issues/474
    # hopefully temporary
    ibus-engines.mozc = super.ibus-engines.mozc.overrideAttrs (oldAttrs: rec {
      postPatch = ''
          sed -i 's/"\.mozc"/"\.config\/mozc"/' $(grep -Rl '"\.mozc"')
      '';
    });

    ## rarely created on my setup, seems to be x11 related? either way here we go
    # NOT haha, this breaks nixos build at some point, so let's forget this
   # dbus = super.dbus.overrideAttrs (oldAttrs: rec {
      #postPatch = oldAttrs.postPatch + ''
          #sed -i 's/"\.dbus"/"\.config\/dbus"/' $(grep -Rl '"\.dbus"')
      #'';
    #});

    ## eh, it's just a forgotten pulseaudio module everyone forgot about. easier
    ## to patch than to submit a PR.
    pulseaudio = super.pulseaudio.overrideAttrs (oldAttrs: rec {
      postPatch = ''
          sed -i 's/"\.esd_auth"/"\.config\/esd_auth"/' $(grep -Rl '"\.esd_auth"')
      '';
    });

    ## a PR is in development but knowing the entire thing has been in the work
    ## since 15 years ago I'd assume it's going to take a _little_ bit longer
    ## https://phabricator.services.mozilla.com/D6995
    firefox-wayland = super.firefox-wayland.overrideAttrs (oldAttrs: rec {
      postPatch = ''
          sed -i 's/"\.mozilla"/"\.local\/share\/mozilla"/' $(grep -Rl '"\.mozilla"')
      '';
    });

    # would be nice to get this working
    #freecad = super.freecad.overrideAttrs (oldAttrs: rec {
    #  postPatch = ''
    #      sed -i 's/"\.FreeCAD"/"\.config\/FreeCAD"/' $(grep -Rl '"\.FreeCAD"')
    #  '';
    #});

    # this works but this also breaks nixos build
#    w3m = super.w3m.overrideAttrs (oldAttrs: rec {
      #postPatch = ''
          #sed -i 's/"~\/\.w3m"/"~\/\.config\/w3m"/' $(grep -Rl '"~\/\.w3m"')
      #'';
    #});

    # fuck this dev, contains config+cache hence data
    # https://github.com/baldurk/renderdoc/pull/1741
    renderdoc = super.renderdoc.overrideAttrs (oldAttrs: rec {
      postPatch = ''
          sed -i 's/"\.renderdoc"/"\.local\/share\/renderdoc"/' $(grep -Rl '"\.renderdoc"')
      '';
    });

    };
  };

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    LESSKEY = "$XDG_CONFIG_HOME/less/lesskey";
    LESSHISTFILE = "-";
    ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";
    WINEPREFIX = "$HOME/.local/share/wineprefixes/default";
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
    # i'm... not sure myself but this seems to be required for ssh to use the
    # godforsaken correct xdg path
    GIT_SSH = "ssh";
  };

  home-manager.users.govanify = {
    home.file.".config/wgetrc".source  = ./../dotfiles/xdg/wgetrc;
    home.file.".config/python/startup.py".source  = ./../dotfiles/xdg/python/startup.py;
  };
  programs.zsh.shellAliases = {
    gdb = "gdb -nh -x \"$XDG_CONFIG_HOME\"/gdb/init";
    subversion = "svn --config-dir \"$XDG_CONFIG_HOME\"/subversion";
    dosbox = "dosbox -conf \"$XDG_CONFIG_HOME\"/dosbox/dosbox.conf";
  };
}
