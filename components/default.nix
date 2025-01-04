{ config, lib, ... }:
with lib;
{
  imports = [
    <home-manager/nixos>
    ./bootloader.nix
    ./xdg.nix
    ./shell.nix
    ./multiplexer.nix
    ./macspoofer.nix
    ./sandboxing.nix
    ./hardening.nix
    ./torrent.nix
    ./drives-health.nix
    ./remote-unlock.nix
    ./headfull
    ./server
  ];

  options.navi = {
    username = mkOption {
      type = types.str;
      default = "govanify";
      description = ''
        The main username of the infrastructure 
      '';
    };
    branding = mkOption {
      type = types.str;
      default = "navi";
      description = ''
        The name of the infrastructure to use for branding
      '';
    };
    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        The wallpaper used by the computer
      '';
    };
  };
}
