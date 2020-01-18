{ config, pkgs, lib, ... }: {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "tmux-256color";
      extraTmuxConf = '' 
        set -ga terminal-overrides ",*256col*:Tc"
        set-window-option -g automatic-rename off
        set -g @resurrect-processes ':all:'
        set -g @continuum-restore 'on'
        set -g @continuum-boot 'on'
      '';

    };
  environment.systemPackages = with pkgs; [
    tmuxPlugins.pain-control
    tmuxPlugins.resurrect tmuxPlugins.continuum 
  ];

}
