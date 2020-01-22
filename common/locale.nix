{ config, pkgs, ... }:
{
    # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  
  # Enable fonts to use on your system.  You should make sure to add at least
  # one English font (like dejavu_fonts), as well as Japanese fonts like
  # "ipafont" and "kochi-substitute".
  fonts.fonts = with pkgs; [
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
  ];

  # These settings enable default fonts for your system.  This setting is very
  # important.  It lets fontconfig know that you want to fall back to a Japanese
  # font (for example "IPAGothic") if an application tries to show fonts with
  # Japanese.  For instance, this is important if you are using a terminal
  # emulator and you `cat` some Japanese text to the screen. If you don't have
  # "defaultFonts" configured, fontconfig will pick a random Japanese font to
  # use.  If you have this "defaultFonts" setting configured, fontconfig will
  # pick the font you have selected.  This makes sure Japanese fonts look nice.
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
}

