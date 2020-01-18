{ config, lib, pkgs, ... }:

{

  imports = [ ./hardware.nix
              ../../common/default.nix
              ../../common/laptop.nix
              ../../common/gaming.nix
            ];
  networking.hostName = "xanadu"; # Define your hostname.
}
