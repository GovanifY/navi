{ config, pkgs, lib, ... }: {
  users.defaultUserShell = pkgs.zsh; 
  programs.zsh = {
    enable = true;
    ohMyZsh = { 
      enable = true;
      plugins = [ "git" "common-aliases" "dirhistory" "pip" "python" "sudo" ];
      theme = "robbyrussell";
    };
    histFile = "$XDG_DATA_HOME/zsh/history";
    # we unloaded the pulseaudio module already so this file shouldn't be used
    # after startup. VERY hacky but oh well
    interactiveShellInit =  ''
      compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
      rm $HOME/.esd_auth &> /dev/null
      mkdir -p /home/govanify/.local/share/zsh &> /dev/null
    '';
  };
}
