{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.wm.kde;
in
{
  options.navi.components.wm.kde = {
    enable = mkEnableOption "Enable navi's window manager (kde)";
    sddm = mkOption {
      type = types.bool;
      default = true;
      description = "Enable KDE's login manager (sddm)";
    };
  };
  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      # /!\ actively breaks several packages like kdenlive and kaidan /!\
      #kdePackages.full

      kdePackages.discover
      labplot
      kdePackages.kate
      kdePackages.kdeconnect-kde
      kdePackages.filelight
      kdePackages.kiten
      kdePackages.akregator
      kdePackages.kcalc
      kdePackages.isoimagewriter
      kdePackages.kdevelop
      kdePackages.krdc
      #kdePackages.k3b
      kdePackages.skanlite
      kdePackages.skanpage
      kdePackages.marble
      kdePackages.dragon
      kdePackages.kompare
      kdePackages.kgpg
      kdePackages.kleopatra
      kdePackages.kdebugsettings
      kdePackages.ksystemlog
      kdePackages.konversation
      kaidan
      kdePackages.kontact
      kdePackages.cantor
      kdePackages.kruler
      digikam
      kdePackages.kmail
      kdePackages.kmail-account-wizard
      kdePackages.neochat
      amarok
      kdePackages.knights
      stockfish
      kdePackages.kolourpaint
      kdePackages.kwave
      kdePackages.ktorrent
      kdePackages.kcachegrind
      kdePackages.ffmpegthumbs
      okteta

      # add default login wallpaper
      (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background=${config.navi.wallpaper}
      '')
    ];

    programs.kdeconnect.enable = true;
    programs.partition-manager.enable = true;

    services = {
      desktopManager.plasma6.enable = true;
      displayManager = mkIf cfg.sddm {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
      };
    };
  };
}
