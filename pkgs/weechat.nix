{ pkgs, config, ... }:
let 
weechat = pkgs.weechat.override {
  configure = {availablePlugins, ...}: 
  {
    scripts = with pkgs.weechatScripts; [ weechat-autosort weechat-matrix ];
  };
};
in
{
  environment.systemPackages = with pkgs; [
    weechat
  ];
}
