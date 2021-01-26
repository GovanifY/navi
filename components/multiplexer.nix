{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.multiplexer;
in
{
  options.navi.components.multiplexer = {
    enable = mkEnableOption "Use navi's multiplexer";
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "tmux-256color";
      extraConfig = '' 
        set -ga terminal-overrides ",*256col*:Tc"
        set-window-option -g automatic-rename off
        set -sg escape-time 10
      '' + optionalString config.navi.components.shell.enable ''
        set -g default-shell "${pkgs.fish}/bin/fish"
      '';

    };
    environment.systemPackages = with pkgs; [
      tmuxPlugins.pain-control
    ];
  };
}
