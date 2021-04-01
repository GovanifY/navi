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
      steam
      (
        pkgs.writeTextFile {
          name = "startsteam";
          destination = "/bin/startsteam";
          executable = true;
          text = ''
            #!${pkgs.bash}/bin/bash

            # XDG compliance
            mkdir -p $XDG_DATA_HOME/steam-home
            HOME=$XDG_DATA_HOME/steam-home
            # then start the launcher
            exec steam
          '';
        }
      )
    ] ++ optionals cfg.retro [ retroarch pcsx2 ];
  };
}
