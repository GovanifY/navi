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
    interactiveShellInit =  ''
      compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
    '';
  };
}
