{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.chat;

  # add matrix plugin to weechat
  weechat = pkgs.weechat.override {
    configure = { availablePlugins, ... }:
      {
        plugins = with availablePlugins; [
          (python.withPackages (_: [ pkgs.weechatScripts.weechat-matrix ]))
          perl
        ];
        scripts = with pkgs.weechatScripts; [
          weechat-autosort
          weechat-matrix
          weechat-go
          highmon
          buffer_autoset
          colorize_nicks
        ];
      };
  };
in
{
  options.navi.components.chat = {
    enable = mkEnableOption "Enable navi's messaging softwares";
    graphical = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable messaging softwares that require a window manager
      '';
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      weechat
    ] ++ optionals cfg.graphical [
      element-desktop-wayland
    ];
    services.weechat.binary = "${weechat}/bin/weechat";
  };
}
