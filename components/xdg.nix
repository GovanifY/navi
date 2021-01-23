# TODO: currently non compliant to XDG in default config are: 
# * nix old folders, yuuuuup, i should make a PR

# TODO: steam: done BUT need to start through startsteam, might want to modify
# that(ie modify desktop file)
# java: need to make a system wrapper like steam up above

# need to verify: dbus, doesn't appear on my system and breaks nixos build
# anyways
# firefox: wait for PR
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.xdg;
in
{
  options.navi.components.xdg = {
    enable = mkEnableOption "Force programs to adhere to the XDG base specification";
    config = mkOption {
      type = types.str;
      default = ".config";
      description = ''
        Value assigned to XDG_CONFIG_HOME minus the HOME
      '';
    };
    data = mkOption {
      type = types.str;
      default = ".local/share";
      description = ''
        Value assigned to XDG_CONFIG_HOME minus the HOME
      '';
    };
    cache = mkOption {
      type = types.str;
      default = ".cache";
      description = ''
        Value assigned to XDG_CACHE_HOME minus the HOME
      '';
    };
  };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (self: super: {
        # ssh devs don't want to make ssh XDG compliant? well let's roll our own
        # compliance!
        openssh = super.openssh.overrideAttrs (oldAttrs: rec {
            postPatch = oldAttrs.postPatch + ''
              sed -i 's/"\.ssh"/"${escape ["/" "."] cfg.config}\/ssh"/' $(grep -Rl '"\.ssh"')
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
              sed -i 's/"\.esd_auth"/"${escape ["/" "."] cfg.config}\/esd_auth"/' $(grep -Rl '"\.esd_auth"')
          '';
        });

        # would be nice to get this working
        #freecad = super.freecad.overrideAttrs (oldAttrs: rec {
        #  postPatch = ''
        #      sed -i 's/"\.FreeCAD"/"\.config\/FreeCAD"/' $(grep -Rl '"\.FreeCAD"')
        #  '';
        #});

        # fuck this dev, contains config+cache hence data
        # https://github.com/baldurk/renderdoc/pull/1741
        renderdoc = super.renderdoc.overrideAttrs (oldAttrs: rec {
          postPatch = ''
              sed -i 's/"\.renderdoc"/"${escape ["/" "."] cfg.data}\/renderdoc"/' $(grep -Rl '"\.renderdoc"')
          '';
        });
    })];

    environment.variables = {
      XDG_CONFIG_HOME = "$HOME/${cfg.config}";
      XDG_CACHE_HOME = "$HOME/${cfg.cache}";
      XDG_DATA_HOME = "$HOME/${cfg.data}";
      LESSKEY = "$XDG_CONFIG_HOME/less/lesskey";
      LESSHISTFILE = "-";
      HISTFILE = "$HOME/${cfg.data}/bash_history";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
      CARGO_HOME = "$HOME/${cfg.data}/cargo";
      WINEPREFIX = "$HOME/${cfg.data}/wineprefixes/default";
      # does not parse it correctly for some reason
      WEECHAT_HOME = "$HOME/${cfg.config}/weechat";
      GNUPGHOME = "$HOME/${cfg.config}/gnupg";
      GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
      GEM_HOME = "$XDG_DATA_HOME/gem";
      GEM_SPEC_CACHE = "$XDG_CACHE_HOME/gem";
      # TODO: merge https://github.com/openjdk/jdk/pull/1494
      #_JAVA_OPTIONS = "-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java";
      WGETRC = "$HOME/${cfg.config}/wgetrc";
      PYTHONSTARTUP = "$HOME/${cfg.config}/python/startup.py";
      PASSWORD_STORE_DIR = "$HOME/${cfg.config}/pass";
      NOTMUCH_CONFIG = "$HOME/${cfg.config}/notmuch";
      # i'm... not sure myself but this seems to be required for ssh to use the
      # godforsaken correct xdg path
      GIT_SSH = "ssh";
      ANDROID_SDK_HOME = "$XDG_CONFIG_HOME/android";
      ADB_VENDOR_KEY = "$XDG_CONFIG_HOME/android";
      CCACHE_CONFIGPATH = "$XDG_CONFIG_HOME/ccache.config";
      CCACHE_DIR = "$XDG_CACHE_HOME/ccache";
      NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
      GDBHISTFILE = "$HOME/${cfg.data}/gdb_history";
      NUGET_PACKAGES = "$XDG_CACHE_HOME/NuGetPackages";
    };

    home-manager.users.govanify = {
      home.file.".config/wgetrc".text  = "hsts-file = \"$XDG_CACHE_HOME\"/wget-hsts";
      home.file.".config/python/startup.py".text  = ''
        import sys
        def register_readline_completion():
          # rlcompleter must be loaded for Python-specific completion
          try: 
            import readline, rlcompleter
          except ImportError: 
            return
          # Enable tab-completion
          readline_doc = getattr(readline, '__doc__', ''')
          if readline_doc is not None and 'libedit' in readline_doc:
            readline.parse_and_bind('bind ^I rl_complete')
          else:
            readline.parse_and_bind('tab: complete')
        sys.__interactivehook__ = register_readline_completion
      '';
      home.file.".config/npm/npmrc".text  = ''
        prefix=$XDG_DATA_HOME/npm
        cache=$XDG_CACHE_HOME/npm
        tmp=$XDG_RUNTIME_DIR/npm
        init-module=$XDG_CONFIG_HOME/npm/config/npm-init.js
      '';
    };
    programs.fish.shellAliases = {
      gdb = "gdb -nh -x \"$XDG_CONFIG_HOME\"/gdb/init";
      subversion = "svn --config-dir \"$XDG_CONFIG_HOME\"/subversion";
      dosbox = "dosbox -conf \"$XDG_CONFIG_HOME\"/dosbox/dosbox.conf";
    };
  };
}
