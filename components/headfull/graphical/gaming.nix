{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.gaming;
in
{
  options.navi.components.gaming = {
    enable = mkEnableOption "Enable navi's gaming setup";
    retro = mkOption {
      type = types.bool;
      default = true;
      description = ''
        This adds various emulators to navi's gaming setup
      '';
    };
  };
  config = mkIf cfg.enable {
    # we need to enable x86 if we want to start most games
    navi.components.hardening = {
      legacy = true;
    };
    hardware.opengl.driSupport32Bit = true;
    hardware.pulseaudio.support32Bit = true;

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      (pkgs.steam.override { extraLibraries = pkgs: with pkgs; [ pango harfbuzz libthai ]; })
      lutris
    ] ++ optionals cfg.retro [ retroarch pcsx2 ];
  };
}
