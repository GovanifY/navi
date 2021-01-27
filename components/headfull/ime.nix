{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.headfull.ime;
in
{
  options.navi.components.headfull.ime = {
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
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc ];
    };

    environment.variables = {
      GTK_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      QT_IM_MODULE = "ibus";
    };
  };
}
