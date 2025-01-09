{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.ime;
in
{
  options.navi.components.ime = {
    enable = mkEnableOption "Enable IME support in navi";
  };
  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        corefonts
        b612
        dejavu_fonts
        noto-fonts
        noto-fonts-cjk-sans
        cantarell-fonts
        noto-fonts-emoji
        source-code-pro
        source-sans-pro
        source-serif-pro
        ttf_bitstream_vera
      ];
      fontconfig.useEmbeddedBitmaps = true;
    };

    # ibus sortaaaaaa works? but never as well as fcitx, which is more themeable
    # by default and doesn't have the weird input jump glitches it has on
    # wayland currently.
    i18n.inputMethod = {
      enable = true;
      #type = if config.navi.components.wm.gnome.enable then "ibus" else "fcitx5";
      #ibus.engines = with pkgs.ibus-engines; [ mozc ];
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };

    #environment.variables.GTK_IM_MODULE = lib.mkForce "wayland";
  };
}
