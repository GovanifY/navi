# TODO: currently non compliant to XDG in default config are: 
# * mozilla (in progress upstream hopefully)
# * nix old folders, yuuuuup, i should make a PR
# * dbus: ~/.dbus in root
# https://github.com/google/mozc/issues/474
# ^ mozc wise


# TODO: dbus esd_auth gets removed each time you start a new shell, should be done
# upon user login along with swaystart
# * steam: done BUT need to start through startsteam, might want to modify
# that(ie modify desktop file)

{ config, pkgs, ... }: {

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


  # ssh devs don't want to make ssh XDG compliant? well let's roll our own
  # compliance!
  # a thing to note: XDG are not parsed yet so we have to make it like this
  programs.ssh.extraConfig = ''
    IdentityFile ~/.config/ssh/id_dsa
    IdentityFile ~/.config/ssh/id_ecdsa
    IdentityFile ~/.config/ssh/id_ed25519
    IdentityFile ~/.config/ssh/id_rsa
    UserKnownHostsFile ~/.config/ssh/known_hosts
  '';

  # TODO: after all that ssh STILL tries to create the ~/.ssh folder. We need to
  # execute the following command in override postpatch of ssh
  # sed -i 's/\.ssh/\.config\/ssh/' *pathnames.h

}
