{ pkgs, config, ... }:
let 
weechat = pkgs.weechat.override {
  configure = {availablePlugins, ...}: 
  {
    plugins = with availablePlugins; [
         (python.withPackages (_: [ pkgs.weechatScripts.weechat-matrix ]))
        ];
    scripts = with pkgs.weechatScripts; [ weechat-autosort weechat-matrix ];
  };
};
in
{
  environment.systemPackages = with pkgs; [
    weechat
  ];
}
