{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.wm.gnome;
in
{
  options.navi.components.wm.gnome = {
    enable = mkEnableOption "Enable navi's window manager (gnome)";
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

      # shell extensions
      blur-my-shell
      compiz-windows-effect
      coverflow-alt-tab
      kimpanel
    ];
    environment.gnome.excludePackages = with pkgs; [
      # https://github.com/NixOS/nixpkgs/issues/372459
      # use the flatpak for now
      geary
    ];

    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

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
  };
}
