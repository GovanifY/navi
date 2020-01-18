# TODO: currently non compliant to XDG in default config are: 
# * mozilla (in progress upstream hopefully)
# * nix old folders, yuuuuup, i should make a PR
# * steam: games are dumb so we need to setup $HOME anyways
# * dbus: games are dumb so we need to setup $HOME anyways

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
    WEECHAT_HOME = "$XDG_CONFIG_HOME/weechat";
    GNUPGHOME = "$XDG_DATA_HOME/gnupg";
    GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
    GEM_HOME = "$XDG_DATA_HOME/gem";
    GEM_SPEC_CACHE = "$XDG_CACHE_HOME/gem";
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
  # export HOME=/tmp or equivalent before running it but this wouldn't work
  # either as we would expand the global ssh config first...
}
