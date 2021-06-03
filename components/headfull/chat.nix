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
        ];
        scripts = with pkgs.weechatScripts; [ weechat-autosort weechat-matrix ];
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
      # matrix
      element-desktop
      (
        pkgs.writeTextFile {
          name = "element-x11";
          destination = "/bin/element-x11";
          executable = true;
          text = ''
            #! ${pkgs.bash}/bin/bash
            # Electron sucks
            GDK_BACKEND=x11
            # then start the launcher 
            exec element-desktop
          '';
        }
      )
    ];
  };
}
