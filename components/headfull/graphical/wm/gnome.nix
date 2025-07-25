{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.wm.gnome;
in
{
  options.navi.components.wm.gnome = {
    enable = mkEnableOption "Enable navi's window manager (gnome)";
    qt-theme = mkOption {
      type = types.bool;
      default = true;
      description = "Enable gnome's qt theming to adwaita-dark";
    };
    hidpi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hidpi on gdm login screen";
    };
  };
  config = mkIf cfg.enable {
    # modify gdm logo by branding
    nixpkgs.overlays = [
      (
        self: super: {
          gdm = super.gdm.overrideAttrs (
            oldAttrs: {
              preInstall = oldAttrs.preInstall + ''
                sed "s|logo='.*|logo='${../../../../infrastructure/assets/navi.png}'|g" -i "$DESTDIR/$out/share/glib-2.0/schemas/org.gnome.login-screen.gschema.override"
              '';
            }
          );
        }
      )
    ];


    environment.systemPackages = with pkgs; with pkgs.gnomeExtensions; [
      xdg-dbus-proxy
      gnome-browser-connector
      gnome-tweaks
      fractal
      dino
      gnome-themes-extra
      gnome-chess
      gnome-builder
      gnome-boxes
      dconf-editor
      cartridges
      bottles
      impression
      komikku
      d-spy
      stockfish
      sysprof

      # shell extensions
      blur-my-shell
      compiz-windows-effect
      coverflow-alt-tab
      kimpanel
      #user-themes
    ];

    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    programs.dconf.profiles.gdm.databases = mkIf cfg.hidpi [{
      settings = {
        "org/gnome/desktop/interface" = {
          scaling-factor = lib.gvariant.mkUint32 2;
        };
      };
    }];

    qt.style = mkIf cfg.qt-theme "adwaita-dark";

    # as MLS is dead, we default to beacondb for now.
    services.geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    services.geoclue2.enable = true;

    # in order to allow efi installation in gnome boxes
    systemd.tmpfiles.rules =
      let
        firmware =
          pkgs.runCommandLocal "qemu-firmware" { } ''
            mkdir $out
            cp ${pkgs.qemu}/share/qemu/firmware/*.json $out
            substituteInPlace $out/*.json --replace ${pkgs.qemu} /run/current-system/sw
          '';
      in
      [ "L+ /var/lib/qemu/firmware - - - - ${firmware}" ];

    # usbguard and polkit rules so that you cannot plug new usb when on login
    # screen on gnome
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.usbguard.Policy1.listRules" ||
             action.id == "org.usbguard.Policy1.appendRule" ||
             action.id == "org.usbguard.Policy1.removeRule" ||
             action.id == "org.usbguard.Devices1.applyDevicePolicy" ||
             action.id == "org.usbguard.Devices1.listDevices" ||
             action.id == "org.usbguard1.getParameter" ||
             action.id == "org.usbguard1.setParameter") &&
             subject.active == true && subject.local == true &&
             subject.isInGroup("wheel")) { return polkit.Result.YES; }
      });
    '';
    services.desktopManager.gnome.extraGSettingsOverrides = ''
      [org.gnome.desktop.background]
      picture-uri='file://${./../../../../infrastructure/assets/wallpaper.png}'
      picture-uri-dark='file://${./../../../../infrastructure/assets/wallpaper.png}'

      [org.gnome.desktop.screensaver]
      picture-uri='file://${./../../../../infrastructure/assets/wallpaper.png}'
    '';

    services.gnome.tinysparql.enable = true;
    services.gnome.localsearch.enable = true;
    services.gnome.games.enable = true;
  };
}
