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
    fonts.fonts = with pkgs; [
      carlito
      dejavu_fonts
      ipafont
      kochi-substitute
      source-code-pro
      ttf_bitstream_vera
    ];

    fonts.fontconfig.defaultFonts = {
      monospace = [
        "DejaVu Sans Mono"
        "IPAGothic"
      ];
      sansSerif = [
        "DejaVu Sans"
        "IPAPGothic"
      ];
      serif = [
        "DejaVu Serif"
        "IPAPMincho"
      ];
    };

    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
      ];
    };
  };
}
