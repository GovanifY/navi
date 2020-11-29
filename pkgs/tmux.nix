{ config, pkgs, lib, ... }: {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "tmux-256color";
      extraConfig = '' 
        set -ga terminal-overrides ",*256col*:Tc"
        set-window-option -g automatic-rename off
        set -g @resurrect-processes ':all:'
        set -g @continuum-restore 'on'
        set -g @continuum-boot 'on'
        set -sg escape-time 10
        set -g default-shell "${pkgs.fish}/bin/fish"
        set -g default-command "${pkgs.fish}/bin/fish"
      '';

    };
  environment.systemPackages = with pkgs; [
    tmuxPlugins.pain-control
    tmuxPlugins.resurrect tmuxPlugins.continuum 
  ];

}
